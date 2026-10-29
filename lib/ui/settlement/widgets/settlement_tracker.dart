import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:zplit/core/services/settlement_config.dart';
import 'package:zplit/core/services/settlement_service.dart';

enum PendingSettlementStatus {
  /// Hash saved, waiting for the network to confirm it.
  checking,

  /// Confirmed on-chain. The settlement record has not been sent to the
  /// friend yet.
  confirmed,

  /// The transaction reverted, didn't match, or was never found.
  failed,
}

/// One submitted USDC payment that Zplit is tracking by its transaction hash.
class PendingSettlement {
  final String id;
  final String friendPublicKey;
  final String friendName;
  final String friendWalletAddress;

  /// INR in paise (integer — no floating point on money).
  final int amountPaise;

  /// Minimum raw USDC units the transfer must contain, as a decimal string.
  /// Stored at creation time so a later FX-rate change can't alter what
  /// counts as "paid in full".
  final String minRawAmount;

  final String txHash;
  final int createdAtMs;
  final PendingSettlementStatus status;
  final String? notice;

  const PendingSettlement({
    required this.id,
    required this.friendPublicKey,
    required this.friendName,
    required this.friendWalletAddress,
    required this.amountPaise,
    required this.minRawAmount,
    required this.txHash,
    required this.createdAtMs,
    this.status = PendingSettlementStatus.checking,
    this.notice,
  });

  PendingSettlement copyWith({
    PendingSettlementStatus? status,
    String? notice,
  }) {
    return PendingSettlement(
      id: id,
      friendPublicKey: friendPublicKey,
      friendName: friendName,
      friendWalletAddress: friendWalletAddress,
      amountPaise: amountPaise,
      minRawAmount: minRawAmount,
      txHash: txHash,
      createdAtMs: createdAtMs,
      status: status ?? this.status,
      notice: notice ?? this.notice,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'friendPublicKey': friendPublicKey,
    'friendName': friendName,
    'friendWalletAddress': friendWalletAddress,
    'amountPaise': amountPaise,
    'minRawAmount': minRawAmount,
    'txHash': txHash,
    'createdAtMs': createdAtMs,
    'status': status.name,
    'notice': notice,
  };

  factory PendingSettlement.fromJson(Map<String, dynamic> j) {
    return PendingSettlement(
      id: j['id'] as String,
      friendPublicKey: j['friendPublicKey'] as String,
      friendName: j['friendName'] as String,
      friendWalletAddress: j['friendWalletAddress'] as String,
      amountPaise: j['amountPaise'] as int,
      minRawAmount: j['minRawAmount'] as String,
      txHash: j['txHash'] as String,
      createdAtMs: j['createdAtMs'] as int,
      status: PendingSettlementStatus.values.firstWhere(
        (s) => s.name == j['status'],
        orElse: () => PendingSettlementStatus.checking,
      ),
      notice: j['notice'] as String?,
    );
  }
}

/// A settlement that was started (wallet opened) but not finished. Saved to
/// storage so it survives Android killing Zplit while the wallet app is open.
class SettlementSession {
  final String friendPublicKey;
  final String friendName;
  final String friendAddress;

  /// INR in paise (integer — no floating point on money).
  final int amountPaise;

  /// Minimum raw USDC units the payment must contain, as a decimal string.
  final String minRawAmount;

  /// Optional. When non-empty, only payments FROM this address count.
  final String payerAddress;

  /// Block number when the user tapped Settle. Only payments after this
  /// count.
  final int startBlock;

  /// Network the session was started on. A session from another network is
  /// never checked against this one.
  final int chainId;

  final int createdAtMs;

  const SettlementSession({
    required this.friendPublicKey,
    required this.friendName,
    required this.friendAddress,
    required this.amountPaise,
    required this.minRawAmount,
    required this.payerAddress,
    required this.startBlock,
    required this.chainId,
    required this.createdAtMs,
  });

  Map<String, dynamic> toJson() => {
    'friendPublicKey': friendPublicKey,
    'friendName': friendName,
    'friendAddress': friendAddress,
    'amountPaise': amountPaise,
    'minRawAmount': minRawAmount,
    'payerAddress': payerAddress,
    'startBlock': startBlock,
    'chainId': chainId,
    'createdAtMs': createdAtMs,
  };

  factory SettlementSession.fromJson(Map<String, dynamic> j) {
    return SettlementSession(
      friendPublicKey: j['friendPublicKey'] as String,
      friendName: j['friendName'] as String,
      friendAddress: j['friendAddress'] as String,
      amountPaise: j['amountPaise'] as int,
      minRawAmount: j['minRawAmount'] as String,
      payerAddress: (j['payerAddress'] as String?) ?? '',
      startBlock: j['startBlock'] as int,
      chainId: j['chainId'] as int,
      createdAtMs: j['createdAtMs'] as int,
    );
  }
}

/// Keeps submitted settlement payments and checks each ONE specific tx hash
/// when the app opens. No polling and no scanning of the chain for pending
/// hashes: one RPC call per pending hash, only when [checkAll] is called.
///
/// It also keeps unfinished settlement SESSIONS (see [SettlementSession]) so
/// a payment made while Android killed Zplit can still be found afterwards.
class SettlementTracker {
  SettlementTracker._();

  static const _storage = FlutterSecureStorage();
  static const _pendingKey = 'pending_settlements';
  static const _usedKey = 'used_settlement_tx_hashes';
  static const _sessionsKey = 'settlement_sessions';

  /// A hash the node has never seen after this long is treated as failed
  /// (wrong network, typo'd hash, dropped transaction).
  static const Duration notFoundTimeout = Duration(hours: 24);

  /// A session older than this is dropped.
  static const Duration sessionTimeout = Duration(hours: 2);

  // ── Pending list ──────────────────────────────────────────────────────

  static Future<List<PendingSettlement>> loadAll() async {
    try {
      final raw = await _storage.read(key: _pendingKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List;
      return list
          .map(
            (e) =>
                PendingSettlement.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('SettlementTracker.loadAll failed: $e');
      return [];
    }
  }

  static Future<void> _saveAll(List<PendingSettlement> list) {
    return _storage.write(
      key: _pendingKey,
      value: jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  static Future<List<PendingSettlement>> forFriend(
    String friendPublicKey,
  ) async {
    final all = await loadAll();
    return all.where((p) => p.friendPublicKey == friendPublicKey).toList();
  }

  static Future<void> add(PendingSettlement s) async {
    final all = await loadAll();
    all.add(s);
    await _saveAll(all);
    await markHashUsed(s.txHash);
  }

  static Future<void> remove(String id) async {
    final all = await loadAll();
    all.removeWhere((p) => p.id == id);
    await _saveAll(all);
  }

  // ── Used hashes (a payment can settle only one balance) ───────────────

  static String _norm(String h) => h.trim().toLowerCase();

  static Future<Set<String>> _loadUsed() async {
    try {
      final raw = await _storage.read(key: _usedKey);
      if (raw == null || raw.isEmpty) return <String>{};
      return (jsonDecode(raw) as List).map((e) => e as String).toSet();
    } catch (e) {
      debugPrint('SettlementTracker._loadUsed failed: $e');
      return <String>{};
    }
  }

  static Future<bool> isHashUsed(String hash) async {
    return (await _loadUsed()).contains(_norm(hash));
  }

  static Future<void> markHashUsed(String hash) async {
    final used = await _loadUsed();
    used.add(_norm(hash));
    await _storage.write(key: _usedKey, value: jsonEncode(used.toList()));
  }

  // ── Sessions (survive Android killing the app while the wallet is open) ─

  static Future<List<SettlementSession>> _loadSessions() async {
    try {
      final raw = await _storage.read(key: _sessionsKey);
      if (raw == null || raw.isEmpty) return [];
      return (jsonDecode(raw) as List)
          .map(
            (e) =>
                SettlementSession.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      debugPrint('SettlementTracker._loadSessions failed: $e');
      return [];
    }
  }

  static Future<void> _saveSessions(List<SettlementSession> list) {
    return _storage.write(
      key: _sessionsKey,
      value: jsonEncode(list.map((e) => e.toJson()).toList()),
    );
  }

  /// One session per friend: starting a new settlement replaces the old one.
  /// Call this BEFORE opening the wallet.
  static Future<void> saveSession(SettlementSession s) async {
    final all = await _loadSessions();
    all.removeWhere((x) => x.friendPublicKey == s.friendPublicKey);
    all.add(s);
    await _saveSessions(all);
  }

  static Future<void> clearSession(String friendPublicKey) async {
    final all = await _loadSessions();
    all.removeWhere((x) => x.friendPublicKey == friendPublicKey);
    await _saveSessions(all);
  }

  static Future<void>? _resuming;

  /// Looks for payments from settlements that were started but never
  /// finished (for example because Android killed the app while the wallet
  /// was open). A payment that is found becomes a "confirmed" pending
  /// settlement, so the friend screen's existing banner takes over.
  ///
  /// Call this when the app starts and when the friend screen opens. Do NOT
  /// call it while the settlement screen is open: it could find the payment
  /// first and mark its hash as used. Concurrent calls share one run.
  static Future<void> resumeSessions() {
    return _resuming ??= _resumeSessions().whenComplete(() => _resuming = null);
  }

  static Future<void> _resumeSessions() async {
    final sessions = await _loadSessions();
    if (sessions.isEmpty) return;

    final net = SettlementConfig.active;
    final now = DateTime.now().millisecondsSinceEpoch;
    final keep = <SettlementSession>[];

    for (final s in sessions) {
      // A session from another network can't be checked here: leave it.
      if (s.chainId != net.chainId) {
        keep.add(s);
        continue;
      }
      // Too old: drop it.
      if (now - s.createdAtMs > sessionTimeout.inMilliseconds) continue;

      final look = await SettlementService.findPayment(
        recipientAddress: s.friendAddress,
        minRawAmount: BigInt.parse(s.minRawAmount),
        fromBlock: s.startBlock,
        payerAddress: s.payerAddress,
      );

      if (look.status == TransferCheckStatus.verified) {
        FoundTransfer? pick;
        for (final m in look.matches) {
          if (!await isHashUsed(m.txHash)) {
            pick = m;
            break;
          }
        }
        if (pick != null) {
          await add(
            PendingSettlement(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              friendPublicKey: s.friendPublicKey,
              friendName: s.friendName,
              friendWalletAddress: s.friendAddress,
              amountPaise: s.amountPaise,
              minRawAmount: s.minRawAmount,
              txHash: pick.txHash,
              createdAtMs: now,
              status: PendingSettlementStatus.confirmed,
              notice: look.message,
            ),
          );
          continue; // consumed: don't keep this session
        }
      }

      // Not found yet (maybe still being mined, or no network): try again
      // next time, until the session times out.
      keep.add(s);
    }

    // Re-load before saving so a session saved while the lookups above were
    // in flight is not overwritten.
    final fresh = await _loadSessions();
    final keptKeys = keep.map((k) => k.friendPublicKey).toSet();
    final checkedKeys = sessions.map((k) => k.friendPublicKey).toSet();
    final merged = <SettlementSession>[
      ...keep,
      ...fresh.where(
        (f) =>
            !checkedKeys.contains(f.friendPublicKey) &&
            !keptKeys.contains(f.friendPublicKey),
      ),
    ];
    await _saveSessions(merged);
  }

  // ── Re-checking pending payments ──────────────────────────────────────

  static Future<void>? _running;

  /// Re-checks every pending payment once. Safe to call from several places
  /// (app start, screen open, app resume): concurrent calls share one run.
  static Future<void> checkAll() {
    return _running ??= _checkAll().whenComplete(() => _running = null);
  }

  static Future<void> _checkAll() async {
    final snapshot = await loadAll();
    final updates = <String, PendingSettlement>{};

    for (final p in snapshot) {
      if (p.status != PendingSettlementStatus.checking) continue;

      final check = await SettlementService.verifyTransfer(
        txHash: p.txHash,
        recipientAddress: p.friendWalletAddress,
        minRawAmount: BigInt.parse(p.minRawAmount),
      );

      switch (check.status) {
        case TransferCheckStatus.verified:
          updates[p.id] = p.copyWith(
            status: PendingSettlementStatus.confirmed,
            notice: check.message,
          );
        case TransferCheckStatus.mismatch:
        case TransferCheckStatus.failed:
          updates[p.id] = p.copyWith(
            status: PendingSettlementStatus.failed,
            notice: check.message,
          );
        case TransferCheckStatus.notFound:
          final age = DateTime.now().millisecondsSinceEpoch - p.createdAtMs;
          if (age > notFoundTimeout.inMilliseconds) {
            updates[p.id] = p.copyWith(
              status: PendingSettlementStatus.failed,
              notice:
                  'This transaction was not found on the network after 24 '
                  'hours. Check the hash and the network, then try again.',
            );
          }
        case TransferCheckStatus.networkError:
          break; // try again next time
      }
    }

    if (updates.isEmpty) return;

    // Re-load before saving so we don't overwrite entries added or removed
    // while the network calls above were in flight.
    final fresh = await loadAll();
    final merged = fresh.map((p) => updates[p.id] ?? p).toList();
    await _saveAll(merged);
  }
}
