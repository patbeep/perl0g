# Perlog iOS

Perlog is a free, local-first personal log for iPhone. It is built as a native SwiftUI/SwiftData iOS app and produces an unsigned IPA intended for Sideloadly.

## Build
GitHub Actions uses macOS 15 + Xcode 16.4, generates the project with XcodeGen, builds a generic iOS device target, and packages `Perlog-unsigned.ipa`.

## Device support
iPhone only, iOS 17+. The layout uses adaptive SwiftUI sizing and safe areas rather than fixed screenshot dimensions.
