# Papa KOReader Simple UI

This branch integrates the upstream Simple UI plugin as a pinned Git submodule,
rather than maintaining a reduced imitation of its feature set.

## Base

- Papa base branch: `work/epub-compat-altbar-sarabun-ui`
- Papa base commit: `0ae1148af71c70dbeabc50a961803f3eaa02d3b4`
- Branch: `papa-koreader-simple-ui`
- Upstream plugin: https://github.com/doctorhetfield-cmd/simpleui.koplugin
- Pinned upstream commit: `402686fec8ad7d190c1156d45ffce7e68b38da5c`

## Integration

The full upstream plugin is mounted at `plugins/simpleui.koplugin`.
The Android APK workflow initializes this submodule before building and checks
that the plugin entry point is present in the resulting APK.

This replaces the earlier lightweight proof-of-concept dashboard plugin.
The complete Simple UI feature set remains upstream-maintained and pinned to
the tested revision, avoiding a partial or stale local copy.

## Papa compatibility requirements

- Preserve Papa's Sarabun UI font integration. Simple UI's bundled Inter and
  Geist Pixel font options must not become the app-wide default.
- Preserve EPUB typography and book CSS exactly; UI font choices must not
  rewrite reading-content styles.
- Preserve Papa's reader changes, Alt Bar, top/footer progress, G7S physical
  input handling, and Android-specific fixes.
- Keep Simple UI's upstream compatibility checks visible and review any
  plugin-disable decisions before changing Papa's plugin set.
- Do not change book files, scan/copy EPUBs, or alter user reading data.

## Validation

The user has already confirmed that the upstream Simple UI plugin works when
installed manually on Papa APK 26. This branch packages that plugin into the
APK so a separate manual installation is no longer needed.

The next validation is an Android ARM64 build from this branch, followed by
installation and regression testing on Meebook G7S and OPPO Reno 8. A
successful build is not considered device validation.
