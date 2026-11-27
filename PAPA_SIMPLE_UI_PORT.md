# Papa KOReader Simple UI

This branch is a selective, native KOReader integration inspired by
[Simple UI](https://github.com/doctorhetfield-cmd/simpleui.koplugin).
It is not a vendored copy of that plugin.

## Base

- Base branch: `work/epub-compat-altbar-sarabun-ui`
- Base commit at branch creation: `0ae1148af71c70dbeabc50a961803f3eaa02d3b4`
- New branch: `papa-koreader-simple-ui`

## Compatibility rules

- Keep the Papa UI font (Sarabun) supplied by the existing app-wide UI font
  integration. Do not introduce Simple UI's bundled Inter or Geist Pixel fonts.
- Do not alter EPUB content CSS, font selection, rendering, or reading layout.
- Keep the existing KOReader file browser, CoverBrowser, History, collections,
  and statistics implementations as the underlying data/actions.
- Keep the G7S input/rotation changes and the existing Alt Bar/progress work.
- Use KOReader's existing UI widgets and plugin lifecycle; avoid Simple UI's
  broad runtime monkey-patches to FileChooser, FileManager, ReaderUI, and
  window/layout classes.
- No automatic disabling of other plugins, no automatic changes to user
  settings, and no destructive file operations.

## Port status

### Included in the first slice

- A lightweight Papa Simple UI dashboard entry in the main menu.
- A Continue Reading / Recent Books list sourced from KOReader's own
  `readhistory` data and opened through KOReader's normal file-opening path.
- Native KOReader widgets, so existing Sarabun UI styling and e-ink behavior
  remain in control.

### Candidate follow-up slices (after the first APK is tested)

1. Quick Actions launcher for existing destinations (Library, History,
   Collections, Reading Statistics, Settings).
2. A Currently Reading summary and compact recent-cover strip using
   CoverBrowser's existing cache, without replacing its file-browser patches.
3. A simple Home Screen layout with optional modules and persisted ordering.
4. Library enhancements only where KOReader/CoverBrowser already exposes a
   stable API; no duplicate filesystem scanner or second metadata database.

### Explicitly not porting at this stage

- Simple UI's global top/bottom navigation bars and ReaderUI window hooks.
- Its FileChooser/FileManager monkey-patches, virtual-path scanner, and
  replacement library tabs.
- Its automatic conflict detector/auto-disable behavior.
- Its external cover-search integrations and bundled fonts.
- Reading goals/heatmap/streak storage until data ownership and compatibility
  with KOReader Statistics are verified.

## Validation

- Lua syntax and plugin-load checks.
- Verify dashboard opens from the main menu in both File Manager and Reader.
- Verify selecting a recent book uses the normal KOReader open path.
- Verify no changes to EPUB rendering, Alt Bar, top/footer progress, G7S
  physical buttons, History, or CoverBrowser.
- Build Android ARM64 APK and test on Meebook G7S and OPPO Reno 8 before
  considering further library or navigation changes.
