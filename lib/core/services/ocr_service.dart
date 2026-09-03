import 'dart:ui';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptScanResult {
  final String? merchantName;
  final double? amount;
  final DateTime? date;
  final String rawText;

  const ReceiptScanResult({
    this.merchantName,
    this.amount,
    this.date,
    required this.rawText,
  });

  bool get isEmpty => merchantName == null && amount == null && date == null;
}

class _AmountCandidate {
  final double value;
  final bool hasDecimal;
  final Rect box;
  _AmountCandidate(this.value, this.hasDecimal, this.box);
}

class OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<ReceiptScanResult> scanReceipt(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _recognizer.processImage(inputImage);

    final lines = <String>[];
    final amountCandidates = <_AmountCandidate>[];
    final totalLabelBoxes = <Rect>[];
    double? inlineTotalAmount;

    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.isEmpty) continue;
        lines.add(text);

        final isTotalLine =
            _totalKeywords.hasMatch(text) &&
            !_nonTotalContextKeywords.hasMatch(text);
        final isQuantityLine = _quantityLinePattern.hasMatch(text);
        final isExcludedContext = _nonTotalContextKeywords.hasMatch(text);

        if (isTotalLine) {
          totalLabelBoxes.add(line.boundingBox);
        }

        if (!isQuantityLine) {
          for (final match in _amountPattern.allMatches(text)) {
            final raw = match.group(1);
            final value = _parseAmount(raw);
            if (value == null || value <= 0) continue;
            final hasDecimal = RegExp(r'[.,]\d{1,2}$').hasMatch(raw!.trim());

            if (isTotalLine) {
              if (inlineTotalAmount == null || value > inlineTotalAmount!) {
                inlineTotalAmount = value;
              }
            }
            if (!isExcludedContext) {
              amountCandidates.add(
                _AmountCandidate(value, hasDecimal, line.boundingBox),
              );
            }
          }
        }
      }
    }

    final amount = _resolveAmount(
      inlineTotalAmount,
      totalLabelBoxes,
      amountCandidates,
    );
    final date = _extractDate(lines);
    final merchant = _extractMerchantName(lines);

    // TEMP DIAGNOSTIC LOGGING — safe to remove once confirmed reliable
    // across more receipts.
    print('===OCR_LINES_START===');
    for (final l in lines) {
      print('LINE: $l');
    }
    print('===OCR_LINES_END===');
    print('EXTRACTED_AMOUNT: $amount');
    print('EXTRACTED_DATE: $date');
    print('EXTRACTED_MERCHANT: $merchant');

    return ReceiptScanResult(
      merchantName: merchant,
      amount: amount,
      date: date,
      rawText: recognized.text,
    );
  }

  // ── Amount resolution ──
  //
  // Priority order:
  //  1. A number physically on the same line as a "total"-type
  //     keyword (highest confidence — e.g. "Total: $19.96").
  //  2. A number whose on-screen position is roughly the same row as
  //     a "total" label, even if it's a separate text block — this
  //     handles layouts like invoices where the label and value sit
  //     in different columns (e.g. "Receipt Total" ... "$154.06").
  //     ML Kit's line order is NOT guaranteed to match visual reading
  //     order for multi-column layouts, so we use actual bounding-box
  //     geometry here rather than "the next line in the list".
  //  3. Fallback: the largest DECIMAL-bearing amount found anywhere
  //     on the receipt (excluding quantity/tax/cash/subtotal lines).
  //     Preferring decimal-bearing numbers over bare integers matters
  //     because OCR sometimes drops a decimal point entirely (e.g.
  //     misreading "9.06" as "906"), which would otherwise look like
  //     the largest — and therefore most likely to be picked as the
  //     total — number on the page.
  double? _resolveAmount(
    double? inlineTotalAmount,
    List<Rect> totalLabelBoxes,
    List<_AmountCandidate> amountCandidates,
  ) {
    if (inlineTotalAmount != null) return inlineTotalAmount;

    if (totalLabelBoxes.isNotEmpty && amountCandidates.isNotEmpty) {
      _AmountCandidate? best;
      double? bestDistance;
      for (final label in totalLabelBoxes) {
        final labelCenterY = label.top + label.height / 2;
        for (final cand in amountCandidates) {
          final candCenterY = cand.box.top + cand.box.height / 2;
          final verticalDistance = (candCenterY - labelCenterY).abs();
          // Only consider candidates on roughly the same row as the
          // label — within 1.5x the label's own line height.
          if (verticalDistance > label.height * 1.5) continue;
          if (bestDistance == null || verticalDistance < bestDistance) {
            bestDistance = verticalDistance;
            best = cand;
          }
        }
      }
      if (best != null) return best.value;
    }

    return _pickFallbackAmount(amountCandidates);
  }

  double? _pickFallbackAmount(List<_AmountCandidate> candidates) {
    if (candidates.isEmpty) return null;
    final withDecimal = candidates.where((c) => c.hasDecimal).toList();
    final pool = withDecimal.isNotEmpty ? withDecimal : candidates;
    pool.sort((a, b) => b.value.compareTo(a.value));
    return pool.first.value;
  }

  static final _totalKeywords = RegExp(
    r'\b(grand\s*total|amount\s*due|balance\s*due|net\s*amount|total)\b',
    caseSensitive: false,
  );

  static final _nonTotalContextKeywords = RegExp(
    r'\b(sub\s*total|tax|vat|gst|cash|change|tender|paid|balance\s*forward|'
    r'previous\s*balance|qty|quantity)\b',
    caseSensitive: false,
  );

  static final _quantityLinePattern = RegExp(
    r'\d+([.,]\d+)?\s*(kg|g|lb|ml|l)?\s*[x×]\s*\d+([.,]\d+)?',
    caseSensitive: false,
  );

  static final _amountPattern = RegExp(
    r'(?:₹|rs\.?|inr|\$|eur|€|£|gbp)?\s*'
    r'([0-9]{1,3}(?:[,.\s][0-9]{3})*(?:[,.][0-9]{1,2})?)',
    caseSensitive: false,
  );

  double? _parseAmount(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();

    final decimalMatch = RegExp(r'[.,](\d{1,2})$').firstMatch(trimmed);

    String integerPart;
    String? decimalPart;
    if (decimalMatch != null) {
      decimalPart = decimalMatch.group(1);
      integerPart = trimmed.substring(0, decimalMatch.start);
    } else {
      integerPart = trimmed;
    }

    integerPart = integerPart.replaceAll(RegExp(r'[.,\s]'), '');
    final combined = decimalPart != null
        ? '$integerPart.$decimalPart'
        : integerPart;
    return double.tryParse(combined);
  }

  // ── Date extraction ──
  static final _numericDatePattern = RegExp(
    r'\b([0-3]?\d)[/\-.]([01]?\d)[/\-.](\d{2,4})\b',
  );
  static final _textDatePattern = RegExp(
    r'\b([0-3]?\d)\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\s+(\d{2,4})\b',
    caseSensitive: false,
  );

  static const _months = {
    'jan': 1,
    'feb': 2,
    'mar': 3,
    'apr': 4,
    'may': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'oct': 10,
    'nov': 11,
    'dec': 12,
  };

  DateTime? _extractDate(List<String> lines) {
    final fullText = lines.join(' ');

    final numericMatch = _numericDatePattern.firstMatch(fullText);
    if (numericMatch != null) {
      final day = int.tryParse(numericMatch.group(1) ?? '');
      final month = int.tryParse(numericMatch.group(2) ?? '');
      var year = int.tryParse(numericMatch.group(3) ?? '');
      if (day != null &&
          month != null &&
          year != null &&
          day >= 1 &&
          day <= 31 &&
          month >= 1 &&
          month <= 12) {
        if (year < 100) year += 2000;
        try {
          final candidate = DateTime(year, month, day);
          if (_isPlausibleReceiptDate(candidate)) return candidate;
        } catch (_) {}
      }
    }

    final textMatch = _textDatePattern.firstMatch(fullText.toLowerCase());
    if (textMatch != null) {
      final day = int.tryParse(textMatch.group(1) ?? '');
      final monthAbbr = textMatch.group(2);
      var year = int.tryParse(textMatch.group(3) ?? '');
      final month = _months[monthAbbr];
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        try {
          final candidate = DateTime(year, month, day);
          if (_isPlausibleReceiptDate(candidate)) return candidate;
        } catch (_) {}
      }
    }

    return null;
  }

  bool _isPlausibleReceiptDate(DateTime date) {
    final now = DateTime.now();
    return date.isBefore(now.add(const Duration(days: 1))) &&
        date.isAfter(now.subtract(const Duration(days: 365 * 5)));
  }

  // ── Merchant name extraction ──
  //
  // Skips lines that look like browser chrome / URLs / search UI —
  // relevant when the test photo captures a whole browser window
  // rather than a cropped receipt (as in the "East Repair Inc." test
  // photo, where the first recognized lines were "YouTube" and a
  // Google search URL fragment, not the actual receipt content).
  static final _phonePattern = RegExp(r'[\d\-\+\(\)\s]{7,}');
  static final _addressHints = RegExp(
    r'\b(road|street|st\.|ave|avenue|floor|block|sector|near|opp\.?)\b',
    caseSensitive: false,
  );
  static final _nonReceiptNoisePattern = RegExp(
    r'(https?:|www\.|\.com\b|google|youtube|whatsapp|\bsearch\b)',
    caseSensitive: false,
  );

  String? _extractMerchantName(List<String> lines) {
    for (final line in lines.take(10)) {
      if (line.length < 2) continue;
      if (_totalKeywords.hasMatch(line)) continue;
      if (_numericDatePattern.hasMatch(line)) continue;
      if (_addressHints.hasMatch(line)) continue;
      if (_nonReceiptNoisePattern.hasMatch(line)) continue;
      if (line.contains('&') || line.contains('=')) continue; // URL-ish
      final digitRatio =
          line.replaceAll(RegExp(r'[^0-9]'), '').length / line.length;
      if (digitRatio > 0.5) continue;
      if (_phonePattern.hasMatch(line) && digitRatio > 0.3) continue;

      return line;
    }
    return null;
  }

  void dispose() {
    _recognizer.close();
  }
}
