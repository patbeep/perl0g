# Perlog

Perlog is a native iPhone personal log: one chronological place for thoughts, moods, photos, places, meals, shopping, music, measurements, sleep, steps, tasks, dividers, tags, and memories.

## Build the IPA

The included GitHub Actions workflow builds an unsigned physical-iPhone `.app`, verifies it, creates a standard `Payload/Perlog.app` IPA, verifies the archive, and uploads the actual `.ipa` as the `Perlog-Sideloadly-IPA` artifact.

### Sideloadly

1. Push the repository to GitHub.
2. Run **Actions → Build Perlog IPA for Sideloadly**.
3. Open the completed run and download **Perlog-Sideloadly-IPA**.
4. Extract `Perlog-Sideloadly.ipa`.
5. Put that IPA into Sideloadly and let Sideloadly sign/install it.

The build targets **iPhone only**, iOS 17+, and a generic physical iOS device. It does not attempt App Store distribution signing.
