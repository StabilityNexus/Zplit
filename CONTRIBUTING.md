# Contributing to Zplit

⭐ First off, thank you for considering contributing to Zplit! ⭐

Zplit is an open-source, decentralized expense-splitting app. We welcome contributions of all kinds — bug reports, feature suggestions, documentation, and code — from everyone.

By participating in this project, you agree to be respectful and collaborative in all interactions.

## 💬 Community & Communication

All project communication happens on **[Discord](https://discord.gg/hjUhu33uAn)**. Please join the server and post your issue/PR updates in the relevant channel — GitHub notifications are easy to miss, and PRs without a Discord update may take longer to review.

- **Discord:** <https://discord.gg/hjUhu33uAn>
- **Website:** <https://stability.nexus>

## 📋 Table of Contents

- [How Can I Contribute?](#-how-can-i-contribute)
- [Coding with AI](#-coding-with-ai)
- [Getting Started](#-getting-started)
- [Development Workflow](#-development-workflow)
- [Pull Request Guidelines](#-pull-request-guidelines)

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates. When opening a bug report, include:

- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior vs. actual behavior
- Screenshots or screen recordings, if applicable
- Environment details (OS, device, Flutter version)

### Suggesting Features

Feature suggestions are welcome! Please check whether the feature has already been requested, then open an issue describing the feature, why it would be useful, and how it might work.

### Contributing Code

1. **Find or open an issue** describing the change you want to make.
2. **Get the issue assigned** (preferable) before starting work — issues are often first-come, first-served.
3. **Submit a pull request** that addresses the issue.

Pull requests unrelated to an issue may be closed or take longer to review.

## 🤖 Coding with AI

AI-assisted contributions are welcome. If you use an AI tool, please disclose it in your pull request description and specify which parts of the contribution were AI-assisted. Make sure you understand and have reviewed any AI-generated content before submitting.

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) with the Dart SDK `^3.9.2` (use the latest stable channel)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for the platform you are targeting
- Git

Verify your setup:

```bash
flutter doctor
```

### Installation

1. **Fork the repository** (click the *Fork* button on GitHub).

2. **Clone your fork:**

```bash
git clone https://github.com/<your-username>/zplit.git
cd zplit
```

3. **Add the upstream remote:**

```bash
git remote add upstream https://github.com/StabilityNexus/Zplit.git
```

4. **Install dependencies:**

```bash
flutter pub get
```

### Running Locally

List the available devices and start the app:

```bash
flutter devices
flutter run
```

To target a specific device, pass its id: `flutter run -d <device-id>`.

## 🔄 Development Workflow

### 1. Create a feature branch

Always work on a new branch, never directly on `main`:

```bash
git checkout -b feature/your-feature-name
```

### 2. Make your changes

Write clean, readable code and follow the existing style.

### 3. Test and analyze

```bash
flutter test
flutter analyze
```

### 4. Commit your changes

Use clear, [Conventional Commit](https://www.conventionalcommits.org/) messages, for example:

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve navigation bug"
```

Common prefixes: `feat:`, `fix:`, `docs:`, `style:`, `refactor:`, `test:`, `chore:`.

### 5. Keep your branch up to date

```bash
git fetch upstream
git rebase upstream/main
```

### 6. Push your changes

```bash
git push origin feature/your-feature-name
```

## 📤 Pull Request Guidelines

Before submitting, please make sure:

- [ ] Your changes are scoped to the related issue
- [ ] `flutter test` and `flutter analyze` pass
- [ ] You have updated documentation where relevant
- [ ] Your commits are clean and follow the commit convention
- [ ] You have rebased on the latest `upstream/main`

When opening the pull request, include a clear description, link the related issue (e.g. `Closes #<issue-number>`), and add screenshots or a short clip for UI changes. After submitting, share your PR in the Discord server and respond to review comments promptly.

---

Thanks again for contributing to Zplit! 💚
