[Superapp](https://www.superappp.com/lovable-uploads/bc4914af-9cbc-4b4c-a764-13dde52ee116.webp)**Superapp**

svg

**Task completed**

3 files

See details

Plan

### Build Perlog’s customizable local-first lifelog core

superseded

Perlog — a free, unlimited, personal lifelog Outcome: Perlog will feel like a highly customizable, timeline-first journal: quick to record, satisfying to revisit, private by default, and styled with a native liquid-glass visual language. The first build will make the journal loop and all five themes genuinely usable; the rest of the current Kiroku App Store feature set will follow in dependency order. Confirmed product decisions The product name is Perlog, with an original identity rather than Kiroku branding or copied assets. It is a personal lifelog and lightweight journal built around a chronological, endlessly scrollable timeline. Every capability is free to use, with no subscriptions, purchase gates, history limits, summary limits, entry limits, or app-imposed photo-count limits. The five themes are Grey, White, Black, Iridescent, and Custom. Iridescent includes a persistent hue control. Custom combines easy accent/surface controls with a fuller palette editor for background, glass tint, primary and secondary text, and accent colors. The visual direction is native, spacious, layered liquid glass—not a web-style dashboard. Records are local-first. The roadmap includes complete import/export, readable PDF/CSV exports, and optional iCloud synchronization. “Everything contextual” means the full reference-app record set plus device integrations: journal notes, moods, photos, meals, shopping, places, music, weight, steps, sleep, tasks, dividers, tags, links, camera/photo library, location, and Apple Health where relevant. Assumptions No ads or tracking are included; “fully free” is treated as an entirely ungated product. The first build uses one timeline-focused flow with a floating quick-add action and a theme control in the top bar. Exact control placement may be adjusted for iPhone ergonomics. Perlog keeps the starter’s iOS 17 minimum and recreates the requested visual language with public SwiftUI APIs, conditionally adopting newer official glass APIs when the installed SDK supports them. “Unlimited” means no Perlog-imposed cap; the user’s available device or iCloud storage remains the practical limit. Now Core loop to ship in the first build Open directly into a polished Perlog Timeline, grouped by day and ordered by occurrence time. Add a quick journal record with text, an optional mood, tags, and an editable date/time. Tap an existing record to edit it; delete with confirmation and an undo opportunity. Persist all records locally so additions, edits, deletions, and ordering survive relaunches. Seed a few clearly marked sample records on first launch so the experience is immediately understandable; samples use the real data model and can be edited or removed. Open Theme Studio from the timeline and switch among Grey, White, Black, Iridescent, and Custom with an immediate live preview. Persist the selected theme and all hue/palette values across launches. Apply the selected palette to the entire flow: background, navigation, timeline cards, editor sheet, buttons, fields, menus, and system chrome. Visual and interaction treatment Use edge-to-edge atmospheric color, translucent material layers, soft specular borders, restrained depth, floating glass controls, and native spring transitions. Keep White bright and frosted, Black deep and high-contrast, Grey neutral, and Iridescent softly multi-hued rather than rainbow-heavy. Give Iridescent a 0–360° base-hue slider with a reset action and subtle motion that stops when Reduce Motion is enabled. Give Custom both quick swatches and advanced color controls for accent, background, glass tint, primary text, and secondary text, with live contrast guidance and a restore-defaults action. Honor Dynamic Type, VoiceOver labels, Reduce Motion, Reduce Transparency, Increase Contrast, safe areas, keyboard avoidance, and comfortable minimum tap targets. Implementation steps Establish the Perlog target and app entry point. Update project.yml, the XcodeGen source of truth, so the target, scheme, product name, and bundle naming use Perlog; keep iPhone-only support and do not hand-edit the generated .xcodeproj. Move the starter resources into a concise Perlog/ source folder and add PerlogApp.swift because the starter currently has no Swift source. Create a forward-compatible local model. Add Models/PerlogEntry.swift with stable UUIDs, created/updated/occurred timestamps, a forward-compatible kind identifier, body text, optional mood, and tags. Use a versioned SwiftData container for persistence. Keep storage swappable. Define an EntryRepository contract and a local SwiftDataEntryRepository so timeline/editor views do not depend directly on one persistence backend; later import, export, and optional iCloud support can adopt the same stable IDs without rewriting the UI. Build first-launch sample handling. Add Data/SeedEntries.swift with a one-time seed marker and editable sample entries; never recreate samples after the user removes them. Build the timeline feature. Add Features/Timeline/TimelineView\.swift, TimelineDaySection.swift, and EntryCard.swift for day grouping, empty state, seeded state, scrolling, edit selection, delete confirmation, and undo. Build the quick editor. Add Features/Editor/EntryEditorView\.swift with add/edit modes, text editing, mood selection, tag chips, date/time editing, validation, save/cancel behavior, and keyboard-safe presentation. Build the theme system. Add DesignSystem/PerlogTheme.swift, ThemeStore.swift, and reusable glass components. Store a Codable ThemeConfiguration locally, inject resolved colors through the SwiftUI environment, and centralize material, border, shadow, and animation behavior. Build Theme Studio. Add Features/Themes/ThemeStudioView\.swift with five preview cards, the Iridescent hue control, Custom quick controls, the advanced palette editor, contrast feedback, resets, and immediate app-wide application. Add graceful availability and accessibility fallbacks. Use only public SDK APIs, conditionally enhance glass styling on newer systems, and provide opaque/high-contrast alternatives when transparency is reduced. Regenerate and verify the Xcode project. Generate from project.yml, then build and run the Perlog scheme on the selected iPhone simulator target. Verification Confirm a clean install creates the editable sample timeline once, and clearing it produces a useful empty state without reseeding. Add, backdate, edit, tag, mood-mark, and delete records; relaunch after each path and confirm the persisted result and ordering. Exercise all five themes and confirm every visible surface updates immediately and restores after relaunch. Verify Iridescent hue changes are visibly distinct and saved; verify all Custom palette fields, reset behavior, and contrast guidance. Check long journal text, many tags, large Dynamic Type, VoiceOver labels, keyboard presentation, landscape, Reduce Motion, Reduce Transparency, and Increase Contrast. Build through the XcodeGen-generated Perlog scheme for an iPhone simulator with no warnings caused by the new source. Confirm the first build contains no account, network dependency, paywall, purchase prompt, analytics, or app-level usage cap. Automated tests are explicitly outside this MVP; verification is direct build-and-run acceptance testing. Material risks and mitigations “iOS 27 Liquid Glass” API availability: the starter currently targets iOS 17, and the available SDK may use different public API names. Implement the requested appearance with public materials and availability checks instead of private or guessed APIs. Theme readability: arbitrary custom text/surface combinations can become unreadable. Show contrast status, supply an automatic readable-text option, and preserve accessibility overrides without removing user control. Reference-app parity: Kiroku can continue changing. This roadmap uses the publicly listed feature set through App Store version 2.11.1 as the parity snapshot. Product identity: match functional outcomes and interaction principles, but use Perlog’s own copy, styling details, data structures, and assets. Next Enable Cloud (iCloud foundation) — add the private cloud database/file capability needed for opt-in Apple-device synchronization while preserving a fully functional local-only mode. Complete record-type composer — let users choose and create journal, mood, photo, meal, shopping, place, music, weight, steps, sleep, to-do, and divider records from one fast add flow. Device context integrations — let users attach camera/photo-library media and places, and—with explicit permission—read relevant weight, steps, and sleep data from Apple Health. Rich media and links — support unlimited photo attachments subject only to available storage, multiple photo layouts, optional camera saves to Photos, long mood notes, URL previews, and music metadata. Timeline discovery — provide performant long-history loading, record-type filters, full-text and tag search, a jump-to-date calendar, and consistent editing for every record type. Past Memories — resurface meaningful entries from previous dates inside the timeline with controls to hide or tune memory suggestions. Monthly Summary — show unlimited-history summaries for moods, photos, visited places, weight, steps, and sleep, with clear trends and drill-down to source records. Tasks and reminders — allow timeline to-dos to be checked off and let users configure multiple local journaling reminders. Data portability — export and restore a complete versioned archive including photos and theme settings, plus generate readable PDF and analysis-friendly CSV exports. Optional iCloud sync — add an off-by-default sync setting for entries, attachments, and preferences, including conflict handling, progress, retry, and a safe return to local-only storage. Settings and privacy center — give users one place to manage themes, permissions, reminders, storage, imports/exports, sync, and clear explanations of where data lives. Reference-language coverage — localize finalized user-facing copy for English, French, German, Japanese, and Korean. Later Subscriptions, in-app purchases, paid themes, advertising, sponsored content, and artificial feature limits. Public profiles, social feeds, shared journals, collaboration, or any default sharing of private records. A pixel-for-pixel Kiroku clone, Kiroku name/icon use, or reuse of another developer’s screenshots, copy, or assets. Automatic weather/calendar harvesting, AI writing or summaries, and other context sources beyond the confirmed reference scope. iPad-specific layouts, Mac, Apple Watch, Android, or web clients; the selected target is iPhone. Audio/video journaling and voice transcription unless requested as a later expansion. A full automated test suite during the MVP phase.

here is the full outline for the original kiroku app, but remember all i have specified i wanted prior to this point: here is the full desctiption for the original kiroku app:

# Kiroku — complete app breakdown

Kiroku: Lifelog & Photo Diary is an iPhone life-logging/journal application designed around a single idea: **instead of keeping separate diaries, mood trackers, photo journals, health logs, travel logs, etc., you continuously add different kinds of records to one chronological timeline.**

The current App Store listing describes it as a place to record “thoughts, moods, steps, and more” and build a personal story one entry at a time. ([App Store][1])

[Image](https://images.openai.com/static-rsc-4/79HhjhEu9Ue2xRPMf--9R7H16DHPzwzM-Bz8EpmAtRT93PYT5qVpSDnPX2dYVN4Oi21e9aogf7_qJKGHxTneiRrzOZ3S7vfVPz0KgMzzy5KyCSKu5AtGVvP76Irx72V-YMtDNFvebWahM-LYpmFp-rY4i5ZpWa2-C9FLGldmYz5IJ4INXGd9HfPIiYUDZzdR?purpose=fullsize)

svg

[Image](https://images.openai.com/static-rsc-4/o0vlcfZUkymlgc0f0fggRXDzfsP-RjIMMTX0LXYR7cLkOHIr4vtw0tlQp7PyWMUf1SvD1bCMhRQMH1bZv-gPpdZDyxxNXu5uY1vo9iNwt7D7i9HN9_dNZuBwjKJHeLPe37BtI1ZPPJfA1xIIWB12Jly7P0OfDNpUQ0PilWJwELXsLLc5NGcEQv2h0yMqxKcx?purpose=fullsize)

svg

[Image](https://images.openai.com/static-rsc-4/3swo5ZFJEqw_NHXpAN14yC017mkwqbg1hfLs5EXKVOricmMLH4oNF9ZLMRJtyZUoln3L9j3WB-opGfM9OdkIkO92QI7vajVu5hXcMWtkwzgVWdnQ_kMobF8Qd7d42rygIeTkd9xgyvyUWiecuwuDrIH4JhCgYa-_U3bGv97dfyXQW3JpBJhCOC8Ib3OwdICg?purpose=fullsize)

svg

## 1. The fundamental concept

Kiroku is **not primarily a traditional diary**.

The fundamental object is a **Kiroku record**.

A record can represent practically anything about your day:

- 📝 Diary/thought
- 😊 Mood
- 📷 Photo
- 🚶 Steps
- 😴 Sleep
- ⚖️ Weight
- 🍽️ Meal
- 🛍️ Shopping
- 📍 Place visited
- 🎵 Music
- ✅ To-do
- and other record types as the developer adds them

The App Store explicitly describes the philosophy as **“Log Anything.”** The developer has repeatedly expanded the available record types since launch. ([App Store][1])

This means a day could theoretically look something like:

> *8:00 AM — Sleep 8:30 AM — Mood: Happy 9:00 AM — Diary: “Had a really good morning.” 12:15 PM — Meal: Lunch 1:00 PM — Place: Coffee shop 3:30 PM — Photo 6:00 PM — Steps 9:00 PM — Music 10:30 PM — Diary*

Rather than these going into different sections, **they become one chronological history of your life.**

---

# 2. The infinite timeline

This is the central interface.

Every record is placed into an **infinite, vertically scrollable timeline**, described by the developer as working somewhat like a social-media feed. ([App Store][1])

The important distinction is that it is a **private personal feed**, rather than a social feed.

You scroll:

**today → yesterday → last week → last month → last year → years ago**

and encounter everything you recorded.

This gives Kiroku its strongest characteristic:

### Your life becomes one continuous chronological document.

A mood doesn't live in a mood-tracking graph.

A photo doesn't live exclusively in your Photos library.

A meal doesn't disappear into a food tracker.

A trip doesn't live separately from your diary.

They all become **events in the same timeline**.

---

# 3. Diary / text entries

You can create normal written journal entries.

Kiroku originally imposed a character limit on diary entries, but version 1.1.0 removed that limitation, allowing long-form entries. ([App Store][2])

The system is therefore capable of serving both:

### Micro-journaling

> *“Great coffee today.”*

and:

### Traditional journaling

> *A substantially longer reflection about what happened during the day.*

The app is intentionally positioned as something **lighter than a conventional diary**, according to its App Store description. ([App Store][1])

---

# 4. Mood tracking

Mood is another record type.

You can create a mood entry and attach text to it.

The app originally had several mood choices and subsequently added:

- **Excited**
- **Annoyed**

The developer also made mood records capable of having their own specific time, rather than simply being associated with the day. ([App Store][1])

So you can effectively document:

> *9:00 — Happy 2:30 — Annoyed 7:00 — Excited*

rather than merely saying:

> *“My mood today was happy.”*

That makes mood part of the chronological life record.

---

# 5. Photos

Photos are first-class timeline records.

You can add photos to Kiroku records, and the app can also use the iPhone camera directly when creating records. ([App Store][3])

The photo system has evolved substantially:

- Photos can be attached to Kiroku records.
- Dedicated Photo records exist.
- Photos can have their own time.
- Camera photos can be saved to the device's Photos library.
- Photo presentation has been redesigned toward a **Polaroid/Vlog-like appearance**.
- Premium increases the number of photos that can be attached.

The latest App Store history says the Vlog-style photo layout was adjusted so the time is less visually dominant. ([App Store][1])

---

# 6. Meals

Kiroku can record meals.

A meal record can include:

- The meal itself
- Associated information
- Photos

The developer subsequently added the ability to take photos directly from the Meal recording interface. ([App Store][2])

An important detail is that the meal isn't isolated in a nutrition database. It becomes another event in your timeline.

---

# 7. Shopping

Shopping is another record category.

You can record purchases/shopping experiences and optionally associate images with them.

One particularly useful change was that **shopping records no longer require an image**. ([App Store][1])

So it can be used simply as:

> *🛍️ Bought new headphones*

or as a more visual memory:

> *🛍️ Bought something 📷 Photo attached*

---

# 8. Places you've visited

Kiroku can record places you've been.

The developer specifically describes examples such as:

- Shops
- Parks
- Travel destinations

These become historical memories in the timeline. ([App Store][2])

So your timeline can effectively contain:

> *📍 Tokyo 📍 Coffee shop 📍 Park 📍 Restaurant*

alongside your written entries and photos.

---

# 9. Steps

Steps are treated as another type of life record.

The app can record your step count and lets you specify the time associated with the steps record. ([App Store][2])

More recently, steps were also incorporated into the **Summary** system. ([App Store][1])

---

# 10. Sleep

Sleep is another supported life metric.

Kiroku can record sleep and account for sleep periods crossing midnight correctly. ([App Store][2])

Sleep is also now included in the Summary view. ([App Store][1])

This makes the app considerably more than a journal: it can combine **subjective experiences** with **objective life data**.

---

# 11. Weight

Weight was added as a dedicated Kiroku item in version 2.8.0.

The subsequent Summary update added weight alongside steps and sleep, and weight can be synchronized from Apple's Health app. ([App Store][1])

So the timeline can contain something like:

> *⚖️ 165 lb*

while the Summary can aggregate the information over time.

---

# 12. Music

Music was added as another record type in version 2.2.0. ([App Store][1])

The conceptual purpose is interesting: instead of music merely being something you listened to, it can become part of your **memory record**.

For example:

> *🎵 Song/artist 📍 Where you were 😊 How you felt 📝 What you were doing*

The result is a timeline of experiences rather than merely a collection of statistics.

---

# 13. To-do lists

The newest version history adds a **To-Do List** item.

The current App Store listing says you can create to-do items and set **multiple reminders**. ([App Store][4])

This means Kiroku is moving beyond retrospective logging and beginning to incorporate forward-looking information as well.

A to-do can therefore coexist with ordinary life records.

---

# 14. Tags

Kiroku added tagging in July 2026.

The developer specifically gives examples such as:

> *`#fandom`*

Tags let you categorize records according to a particular activity, interest, or lifestyle scene. ([App Store][1])

This is important because the timeline is inherently chronological, while tags introduce a **second organizational dimension**.

For example:

**Chronological view**

> *June 12 June 15 June 21 July 3*

**Tag view**

> *#fandom #travel #pets #work etc.*

The App Store specifically describes tagging as a way to categorize records by lifestyle scenes/activities. ([App Store][1])

---

# 15. Search

Kiroku has a search function.

This is important once the timeline becomes very large.

Instead of manually scrolling through months or years, you can search your historical records. Search was introduced in version 2.3.0. ([App Store][1])

---

# 16. Jump to Date

There is also a **Jump to Date** feature.

Rather than scrolling through an enormous timeline, you can specify a particular date and go directly there. ([App Store][1])

This makes the infinite timeline practical once you have accumulated a substantial history.

---

# 17. Timeline filtering

Kiroku can filter the timeline by **record type**.

For example, instead of looking at everything, you can narrow it to a particular category.

This was introduced in version 1.4.0. ([App Store][1])

Conceptually:

**Everything**

> *Diary Photo Mood Meal Steps Sleep Place etc.*

versus:

**Photos only**

> *📷 📷 📷 📷*

This is another way the app balances the simplicity of the unified timeline with the increasing amount of data stored in it.

---

# 18. Past Memories

Kiroku has a feature specifically called **Past Memories**.

Older posts can resurface in your timeline so that you encounter previous memories again rather than having to deliberately search for them. ([App Store][1])

This changes the timeline from simply:

> ***archive → search***

into:

> ***archive → rediscovery***

The idea is similar to unexpectedly encountering an old photograph or journal entry.

---

# 19. Dividers

One of the newest additions is **Dividers**.

These allow you to mark major periods or milestones in your life with:

- A label
- Stickers

The developer gives examples including:

- Trips
- Moving

([App Store][1])

So instead of having an uninterrupted chronological stream, you can visually establish chapters:

> *───────── ****TRIP TO JAPAN**** ✈️ ─────────*

then all the relevant records appear beneath that period.

This effectively introduces the concept of **chapters of your life**.

---

# 20. Link previews

Kiroku also recognizes URLs placed in Kiroku entries and can display **link previews**. ([App Store][1])

So a written record containing a URL isn't necessarily just plain text.

---

# 21. Summary

The app has a separate **Summary** experience.

It automatically aggregates your recorded life data into periodic summaries.

The original Summary feature included:

- Moods
- Photos
- Places visited

Later versions added:

- Weight
- Steps
- Sleep

The Summary was substantially redesigned in version 2.9.0. ([App Store][1])

The important conceptual distinction is:

### Timeline

**What happened, and when?**

### Summary

**What was my life like over this period?**

So Kiroku operates simultaneously as a chronological journal and a lightweight personal analytics system.

---

# 22. Health integration

Weight can be synchronized with Apple's **Health** system.

The App Store privacy information also indicates that Health data can be handled for app functionality. ([App Store][1])

This is what allows Kiroku to combine manually entered memories with automatically available health information.

---

# 23. Reminders

Kiroku can remind you to make records.

The developer added reminders early in the application's life, and the newest versions expanded this so users can configure **multiple reminders**. ([App Store][1])

This is important because the app is intended to become a habitual life log rather than something you only open occasionally.

---

# 24. Export

Kiroku supports exporting record data.

This was added in version 1.5.0. ([App Store][1])

So the information isn't intended to exist solely inside the application's UI.

---

# 25. Themes and appearance

The app supports **Dark Mode**.

The newest release also added a theme whose background changes according to the **time of day**, with additional themes planned. ([App Store][1])

The App Store also lists:

- Larger Text accessibility
- Dark Interface accessibility

([App Store][1])

---

# 26. Privacy model

Privacy is one of Kiroku's explicit selling points.

The App Store says that user data is stored securely on Apple's servers through **iCloud** and is not shared with anyone, including the developer. ([App Store][1])

Apple's App Store privacy disclosure currently says the developer reports certain data that may be collected **not linked to the user's identity**, including:

### Analytics

- User ID
- Device ID
- Product interaction
- Other usage data
- Diagnostics

### App functionality

- Health data
- Photos/videos
- User ID
- Usage data
- Crash/performance diagnostics

Apple notes that these privacy declarations are supplied by the developer and are **not verified by Apple**. ([App Store][1])

---

# 27. Premium

Kiroku is free to download with in-app purchases.

The current US App Store listing shows:

- **Premium Monthly:** $3.99
- **Premium Annual:** $29.99
- **Premium Lifetime:** $89.99

([App Store][4])

Premium historically expanded:

### Photos

Free:

- Kiroku items: 1–3 photos
- Photo items: 3–9 photos

### Summaries

The original Premium system limited Summary history to three months, while Premium provided unlimited Summary access. ([App Store][1])

The exact current entitlement set can evolve with updates, so the App Store purchase screen is the authoritative source.

---

# 28. Who Kiroku is designed for

The App Store specifically identifies several use cases.

### Quick thoughts

Someone who wants something **lighter than a traditional diary**.

### Pet logging

Someone wanting a continuous record of life with a pet.

### Fandom

Someone wanting to record and celebrate fandom-related experiences.

([App Store][1])

But the underlying architecture is much broader than those examples.

---

# 29. The most important design idea

The interesting part of Kiroku isn't any individual feature.

It's the **combination**.

Most apps divide your life into separate databases:

svg

svg

svg

| **AppData**  |                    |
| ------------ | ------------------ |
| Journal      | Thoughts           |
| Mood tracker | Feelings           |
| Photos       | Images             |
| Health       | Steps/sleep/weight |
| Maps         | Places             |
| Music        | Listening          |
| To-do        | Tasks              |
| Travel app   | Trips              |

Kiroku instead tries to make all of these:

### events in one personal timeline.

That is essentially its entire product philosophy.

---

# 30. How the app has evolved

The App Store version history gives a surprisingly clear picture of the product's evolution:

**April 2026**

- Diary
- Photos
- Camera capture
- Mood
- Meals
- Sleep
- Steps

**May**

- Places
- Shopping improvements
- Reminders
- Export
- Timeline filtering
- Date handling

**June**

- Jump to Date
- Summary
- Premium
- Music
- Additional moods
- Search

**July**

- Dark Mode
- Past Memories
- Tags
- Weight
- Health synchronization
- Expanded Summary
- Steps/Sleep/Weight statistics

**August**

- Dividers
- Labels/stickers
- Link previews
- To-do lists
- Multiple reminders
- Vlog/Polaroid-style photo presentation
- Time-of-day themes
- German/French/Korean localization
- Lifetime Premium

([App Store][1])

So it has gone from essentially a **simple diary/timeline** into a much broader **personal life database** in only a few months.

---

# 31. The complete mental model

If you reduce the entire app to its underlying structure, it looks roughly like this:

text

svgsvg

```
                    YOUR LIFE                       │                       ▼              ┌─────────────────┐              │     KIROKU      │              └─────────────────┘                       │          ┌────────────┼────────────┐          ▼            ▼            ▼       RECORDS      TIMELINE     SUMMARY          │            │            │    ┌─────┼─────┐      │      ┌────┼────┐    │     │     │      │      │    │    │  Diary Mood Photo    │    Mood Photos Health  Meal  Place Music   │    Places Steps Sleep  Sleep Steps Weight  │         Weight  Shopping To-do      │                      │                      ▼              INFINITE HISTORY                      │          ┌───────────┼───────────┐          ▼           ▼           ▼        Search      Tags       Jump Date          │          ▼     Past Memories          │          ▼      Dividers   labels + stickers
```

The core loop is therefore:

**Capture → timestamp → place on timeline → continue living → revisit → search/filter → summarize → rediscover.**

That is what makes Kiroku different from a conventional journal: **the journal isn't the product's center; the timeline is.** The journal, mood, photo, health, location, food, music, task, and milestone records are all different ways of populating the same chronological representation of your life. ([App Store][1])

**Current App Store listing:** **Kiroku: Lifelog & Photo Diary on the App Store**