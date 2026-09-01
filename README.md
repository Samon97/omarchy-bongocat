# 🐱 Bongo Cat for Omarchy

A small bongo cat that sits in your Omarchy bar and drums on the table with its
paws whenever you type. Stop typing for a second and it goes back to its
default pose (both paws up).

![Bongo cat drumming in the bar](https://github.com/Samon97/omarchy-bongocat/raw/main/assets/bongocat.gif)

> **Heads up:** this is an adaptation of the
> [Bongo Cat](https://github.com/kitgore/BongoCat) VS Code extension by
> **pixl-garden**. I rebuilt it as an Omarchy bar widget and borrowed its icon
> font (more on that [below](#credits)).

## What it does

- Drums on every keypress, alternating paws (left down / right down).
- Goes back to its idle pose after ~1 second without typing.
- Fits compactly in the bar — the cat's bottom line lines up with the clock's
  text.
- Reads locally from `/dev/input` — no cloud, no editor dependency.

## Install

Install it as an Omarchy plugin straight from GitHub:

```bash
omarchy plugin add https://github.com/Samon97/omarchy-bongocat.git --enable
```

Then enable / move it in the bar with:

```bash
omarchy plugin enable samon97.bongocat
```

### Requirements

- **Omarchy** (and its Quickshell-based shell)
- Read access to `/dev/input/event*`. The keyboard usually already belongs to
  the `input` group, so most of the time it just works. If nothing happens,
  check that your user is in that group.
- An **external asset**: the bundled `bongocat.ttf` icon font is a modified
  conversion of the font from the MIT-licensed
  [Bongo Cat](https://github.com/kitgore/BongoCat) VS Code extension by
  pixl-garden (Copyright © 2023 ben). See [Credits](#credits) and
  [`LICENSE`](LICENSE).

## Uninstall

Remove the plugin again with:

```bash
# Disable it in the bar, then remove the plugin folder
omarchy plugin disable samon97.bongocat
rm -rf ~/.config/omarchy/plugins/samon97.bongocat
```

That's it — the plugin doesn't write any config or state outside its own
folder.

## Repo layout

```
samon97.bongocat/
├── manifest.json       # Omarchy manifest (must live in the repo root)
├── BarWidget.qml       # Widget entry point (canvas rendering + logic)
├── key_monitor.py      # Reads keypresses from /dev/input
├── bongocat.ttf        # Bundled icon font (converted from pixl-garden)
├── assets/bongocat.gif # Demo GIF for this README
├── LICENSE             # MIT (with a note about the original font)
├── CHANGELOG.md
└── README.md
```

**Note for the repo:** `omarchy plugin add` clones your repo and validates it
directly, so `manifest.json` and the entry point `BarWidget.qml` have to sit in
the **repo root**. Entry points are relative paths, and symlinks aren't
allowed. This flat layout follows the convention of the built-in bar widgets.

## How it works

1. `key_monitor.py` opens all `/dev/input` devices and prints a line to stdout
   for every pressed key (`EV_KEY` event with value 1).
2. `BarWidget.qml` runs that script as a `Process`. Each incoming line calls
   `drum()`, which switches between "left paw down" and "right paw down".
3. A `Timer` resets it to the idle pose after ~1 second.
4. The icon glyphs are drawn on a `Canvas`. Instead of the invisible bounding
   box, the *visible* painted outline is centered, and the cat's bottom edge is
   anchored to the bottom of the clock's text line.

## Credits

This is an **adaptation**, not a from-scratch idea. It's based on the
**[Bongo Cat](https://github.com/kitgore/BongoCat)** VS Code extension by
**pixl-garden** (MIT, Copyright © 2023 ben).

What I took from pixl-garden:
- The **cat artwork**, as an icon font. The `bongocat.ttf` here is a
  conversion of the font pixl-garden published (`bongocat.woff`).
- The **behavior**: drum on input with alternating paws, then settle back after
  a pause. That logic comes from their `src/extension.ts` and was reworked for
  Omarchy.

What's new here (my own work):
- The whole Omarchy / Quickshell plugin: `BarWidget.qml` is fresh QML code
  (canvas rendering, process handling, the alignment stuff) written from
  scratch, not copied.
- `key_monitor.py`: a new Linux input reader for `/dev/input`. The original
  extension was pure VS Code status-bar logic and couldn't be reused.
- A small **font fix**: removed a duplicate overlapping outline in the
  "left paw up" glyph that made the mouth look hollow.

So the cat isn't "cloned" — I took pixl-garden's freely MIT-licensed icon font
and built a brand new Omarchy widget around it.

## How AI was involved

This project was made together with an **AI coding assistant**
([opencode](https://opencode.ai)), in an iterative back-and-forth:

- The **AI** designed and wrote most of the QML / Python, ran
  `omarchy plugin validate`, and reloaded the shell as we went.
- The **AI** debugged things like the hollow mouth (traced to the duplicate
  font outline) and fixed the vertical alignment to the clock.
- The **human** (me) judged what it looked like — e.g. deciding the cat should
  line up with the bottom of the clock — and steered the design.

So the behavior, look, and feel were decided together; the coding was mostly
done by the AI, then reviewed and approved by me. See `CHANGELOG.md` and
`LICENSE` for source and licensing details.

## License

MIT — see [`LICENSE`](LICENSE). The bundled icon font comes from the Bongo Cat
extension by pixl-garden (MIT, Copyright © 2023 ben); their license and
copyright are noted in `LICENSE`.
