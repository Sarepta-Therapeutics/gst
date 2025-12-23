# Contributing to gst

Thank you for your interest in contributing to **gst**! We welcome bug
reports, feature requests, and code contributions. This guide will help
you get started.

------------------------------------------------------------------------

## 📦 Table of Contents

- Reporting Bugs
- Requesting Features
- Contributing Code
- Code Style
- Pull Request Process
- Community and Conduct

------------------------------------------------------------------------

## 🐛 Reporting Bugs

If you find a bug, please help us by reporting it:

1.  **Search existing issues** to avoid duplicates.
2.  Open a new issue with the following information:
    - A clear and descriptive title.
    - Steps to reproduce the issue.
    - Expected vs. actual behavior.
    - R version and operating system.
    - Any relevant logs or screenshots.

👉 [Submit a bug
report](https://github.com/Sarepta-Therapeutics/gst/issues/new)

------------------------------------------------------------------------

## 💡 Requesting Features

We love hearing your ideas! To request a new feature:

1.  Check if the feature has already been suggested.
2.  Open a new issue labeled `enhancement` with:
    - A clear description of the feature.
    - Why it would be useful.
    - Any relevant examples or use cases.

👉 [Request a
feature](https://github.com/Sarepta-Therapeutics/gst/issues/new)

------------------------------------------------------------------------

## 🧑‍💻 Contributing Code

We welcome contributions of all kinds — bug fixes, new functions,
documentation improvements, and more.

### Getting Started

1.  **Fork** the repository.

2.  **Clone** your fork locally:

    ``` bash
    git clone https://github.com/yourusername/yourpackagename.git
    ```

3.  Create a new branch:

    ``` bash
    git checkout -b feature/your-feature-name
    ```

4.  Make your changes and commit:

    ``` bash
    git commit -m "Add feature: your-feature-name"
    ```

5.  Push to your fork:

    ``` bash
    git push origin feature/your-feature-name
    ```

6.  Open a **Pull Request** on the main repository.

------------------------------------------------------------------------

## 🎨 Code Style

Please follow these conventions:

- Use **tidyverse** style where applicable.
- Document all exported functions using **roxygen2**.
- Include unit tests using **testthat**.
- Avoid long lines (\>80 characters).
- Use meaningful commit messages.

------------------------------------------------------------------------

## ✅ Pull Request Process

When submitting a PR:

- Ensure all tests pass
  ([`devtools::test()`](https://devtools.r-lib.org/reference/test.html)).
- Run
  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
  and fix any warnings or errors.
- Link the PR to any related issues.
- Add a short description of your changes.

------------------------------------------------------------------------

## 🤝 Community and Conduct

We follow the Contributor Covenant Code of Conduct. Be respectful,
inclusive, and constructive in all interactions.

------------------------------------------------------------------------

## 🙌 Thank You!

Your contributions make this project better. We appreciate your time and
effort!
