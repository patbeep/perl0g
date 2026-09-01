# Perlog — Your life, logged.

A native SwiftUI + SwiftData personal-log app: one continuous timeline for
thoughts, photos, moods, places, people, meals, music, activities, tasks,
and milestones. Fully local, no account, no subscription.

This repo is set up to build an **unsigned .ipa** automatically via GitHub
Actions, ready for **Sideloadly**. You never need Xcode or a Mac.

---

## 1. Create the GitHub repo

1. Go to https://github.com/new
2. Name it anything (e.g. `perlog-ios`), keep it **Private** if you want, click **Create repository**.
3. On the new repo's page, click **Add file → Upload files**.
4. Drag in **every file and folder from this project** (keep the folder
   structure exactly as given — `Perlog/`, `.github/`, `project.yml`, etc.)
   into the upload area, then commit.

   > GitHub's web uploader flattens empty folders and sometimes struggles
   > with deeply nested drag-and-drop. If anything looks off after
   > uploading, the safest method is installing [GitHub Desktop](https://desktop.github.com/),
   > cloning your new empty repo, copying these files into the cloned
   > folder on disk, and committing + pushing from there. Either method
   > works — just make sure the final repo layout matches section 3 below.

## 2. Let GitHub Actions build it

As soon as you push to `main`, the workflow in `.github/workflows/build.yml`
runs automatically:

1. Go to your repo's **Actions** tab. You should see "Build Perlog
   (unsigned IPA for Sideloadly)" running (takes ~3-5 minutes).
2. If it's not running, click it, then **Run workflow** to trigger it manually.
3. When it finishes with a green check, click into the run, scroll to
   **Artifacts**, and download **Perlog-unsigned-ipa**. That's a zip
   containing `Perlog-unsigned.ipa`.

## 3. Expected file layout

```
your-repo/
├── project.yml
├── README.md
├── .github/
│   └── workflows/
│       └── build.yml
└── Perlog/
    ├── Assets.xcassets/
    │   ├── AppIcon.appiconset/
    │   ├── AccentColor.colorset/
    │   └── Contents.json
    └── Sources/
        ├── App/PerlogApp.swift
        ├── Models/  (LogEntry, Tag, Person, ThemeStore)
        ├── Support/ (Extensions, ExportManager, ShareSheet, LocationProvider)
        └── Views/   (Timeline, Editor, Memories, Stats, Settings, Components)
```

There is **no `.xcodeproj` in this repo on purpose** — the workflow
generates one fresh on every run using [XcodeGen](https://github.com/yonaskolb/XcodeGen)
reading `project.yml`. A hand-maintained `.xcodeproj` is the single
biggest source of "worked yesterday, broken today" build errors with
this kind of pipeline, so this setup avoids it entirely.

## 4. Sideloadly

1. Install [Sideloadly](https://sideloadly.io/) on your Windows PC and
   plug in your iPhone.
2. Unzip `Perlog-unsigned-ipa.zip` from the GitHub artifact — you'll get
   `Perlog-unsigned.ipa`.
3. Open Sideloadly, drag `Perlog-unsigned.ipa` into it, sign in with your
   Apple ID (a free Apple ID works fine), and click **Start**.
4. On your iPhone: **Settings → General → VPN & Device Management** →
   trust your developer profile the first time you install anything this way.
5. Perlog will appear on your home screen.

> Free Apple IDs can only sideload up to 3 apps at a time and the app
> re-signs itself every 7 days (you'll just re-run Sideloadly against the
> same .ipa — no need to rebuild). This is an Apple limitation, not
> something this project can change.

## What's implemented

- **Timeline** — every record type, grouped by day, with a day summary
  line (mood, steps, photo count), search, and a type filter.
- **Add/Edit Record** — horizontal type picker (thought, photo, mood,
  place, person, meal, music, activity, task, milestone), photos via
  `PhotosPicker`, tags, people, optional GPS via CoreLocation, and
  type-specific fields (mood picker, due dates, measurements, etc).
- **Memories** — "On this day" (same month/day in past years),
  milestones, and a rediscovery shelf of older entries.
- **Stats** — streak, total records, photos, tags, people, a bar chart
  of records by type (Swift Charts), and task completion counts.
- **Theme Studio** — Black / Grey / White / Iridescent / Custom presets
  with a live base-hue slider, matching the reference design.
- **Settings** — manage people and tags, export your entire log as one
  JSON file (share sheet → Files/AirDrop/Mail), and a plain-language
  privacy note.
- **Local-first** — everything is stored on-device with SwiftData.
  Nothing is uploaded anywhere. No account, no subscription, no feature
  gating.

## Editing the app yourself later

Every screen is a small, separate Swift file under `Perlog/Sources/`.
If you want to change colors, copy, or add a new record type, the
places to look are:

- `Models/LogEntry.swift` — the `EntryType` enum (add a case here for a
  new record type; the timeline, editor, and stats screens all key off
  `EntryType.allCases` automatically).
- `Models/ThemeStore.swift` — the five theme presets and their colors.
- `Views/Timeline/`, `Views/Editor/`, `Views/Memories/`,
  `Views/Stats/`, `Views/Settings/` — one folder per tab.

After any change, just commit and push — Actions rebuilds the IPA
automatically.

## Changing the bundle identifier

The default bundle ID is `com.perlogapp.perlog`, set in `project.yml`
under `PRODUCT_BUNDLE_IDENTIFIER`. If Sideloadly ever complains about a
bundle ID collision with another app on your device, either change that
line to something else (e.g. `com.yourname.perlog`) and push again, or
use Sideloadly's own "Bundle ID" override field at install time — both
work.
