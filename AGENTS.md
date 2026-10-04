# Project guidance

Timcker is a single-screen Flutter app for Web, iOS, and Android. It displays
local time as `HH:mm:ss.SSS` and an integer counter incremented by tapping its
number. Keep the screen minimal: no title bar, section headings, date,
24-hour format label, increment button, or static instruction text. The
counter resets using the reset button or a face-down then face-up gesture on
native iOS and Android. Web always uses Material 3; native iOS uses Cupertino.

## Development

- Prefer Language Server Protocol (LSP) tools for code operations when available.
  Otherwise use Dart tooling and focused file edits.
- Keep the app small and on one screen. Use Flutter's native Material and
  Cupertino widgets, with responsive layout and system light/dark appearance.
- Keep code, code comments, and documentation in English. Localize user-facing
  copy and accessibility labels in Traditional Chinese, Simplified Chinese,
  English, and Japanese; English is the fallback. Detect the device language
  automatically, using `navigator.language` on Web. Do not add a language picker.
- Keep motion detection separate from presentation and test the complete
  gesture, accidental movement, manual reset, and app lifecycle behavior.
- Stop sensor subscriptions and clock frame updates when the app is inactive;
  dispose them when their widgets are removed. Do not request motion data on Web.
- Run `dart format lib test`, `flutter analyze`, and `flutter test` after changes.
  Validate `flutter build web` and native builds when the toolchains are available.
  Distinguish simulated sensor tests from physical-device verification.

## Collaboration and Git

- Use [Conventional Comments](https://conventionalcomments.org/) for review
  feedback: `<label> [decorations]: <subject>`, followed by supporting discussion
  when needed. For example: `suggestion (non-blocking): Simplify this condition.`
- Use [Conventional Branch](https://conventionalbranch.org/) names such as
  `feat/clock-counter`, `fix/flip-reset`, or `chore/update-dependencies`. Use
  lowercase, hyphen-separated descriptions. No AI agent prefix is required;
  do not add `codex/`, `ai/`, or another agent prefix.
- Use Conventional Commits: `<type>(<optional scope>): <description>`.
- Every AI-authored commit must include the footer
  `Committed by: {model name}`. The name must identify the actual model **and
  variant**, for example `Committed by: GPT-6.0 Sol`. Do not copy the example
  unless it is the actual model; do not guess an unavailable model variant.
- AI agents may create branches and commits autonomously when appropriate.
- The merge policy is **squash merge**. Keep work scoped for review and preserve
  the required `Committed by:` attribution footer in the resulting squash commit.
- Prefer the Codex GitHub App over `gh` for GitHub operations.
