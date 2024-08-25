module.exports = {
  /**
   * .commitlintrc.js
   *
   * This configuration file enforces conventional commit message formats
   * for this project. It ensures that commit messages follow a consistent
   * structure, making it easier to generate changelogs, automate versioning,
   * and understand the history of changes.
   *
   * Best Practices:
   * - Use the `type(scope): subject` format for commit messages.
   * - Use lowercase letters for the type and subject.
   * - Keep the subject line concise (50 characters or less).
   * - Use imperative mood in the subject line (e.g., "fix bug" instead of "fixed bug").
   * - Include a detailed description after the subject line, separated by a blank line.
   * - Reference issues and pull requests in the footer using `#issue-number`.
   */

  rules: {
    "type-enum": [2, "always", [
      "feat",     // A new feature
      "fix",      // A bug fix
      "docs",     // Documentation only changes
      "style",    // Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
      "refactor", // A code change that neither fixes a bug nor adds a feature
      "perf",     // A code change that improves performance
      "test",     // Adding missing tests or correcting existing tests
      "build",    // Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)
      "ci",       // Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)
      "chore",    // Other changes that don't modify src or test files
      "revert"    // Reverts a previous commit
    ]],
    "subject-case": [2, "always", "sentence-case"],
    "subject-empty": [2, "never"],
    "subject-max-length": [2, "always", 50],
    "body-max-line-length": [2, "always", 72],
    "footer-max-line-length": [2, "always", 72],
    "scope-case": [2, "always", "lower-case"],
    "type-case": [2, "always", "lower-case"],
    "type-empty": [2, "never"],
    "scope-empty": [0, "never"]
  },

  types: {
    feat: {
      description: "A new feature",
      title: "Features"
    },
    fix: {
      description: "A bug fix",
      title: "Bug Fixes"
    },
    docs: {
      description: "Documentation only changes",
      title: "Documentation"
    },
    style: {
      description: "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)",
      title: "Styles"
    },
    refactor: {
      description: "A code change that neither fixes a bug nor adds a feature",
      title: "Code Refactoring"
    },
    perf: {
      description: "A code change that improves performance",
      title: "Performance Improvements"
    },
    test: {
      description: "Adding missing tests or correcting existing tests",
      title: "Tests"
    },
    build: {
      description: "Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)",
      title: "Builds"
    },
    ci: {
      description: "Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)",
      title: "Continuous Integration"
    },
    chore: {
      description: "Other changes that don't modify src or test files",
      title: "Chores"
    },
    revert: {
      description: "Reverts a previous commit",
      title: "Reverts"
    }
  }
};
