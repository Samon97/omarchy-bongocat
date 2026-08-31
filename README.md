# 🐱 Bongo Cat for Omarchy

Eine kleine Bongo Cat, die in deiner Omarchy-Leiste sitzt und bei jedem
Tastendruck mit den Pfoten auf die „Trommel" schlägt. Sobald du kurz aufhörst
zu tippen, setzt sie sich zurück in ihre Ruhepose (beide Pfoten oben).

![Demo](https://github.com/kitgore/BongoCat/assets/87792049/cd430b3e-968b-4e87-9c11-2aa2765d99de)

> Screenshot/GIF hier platzieren.

## Features

- Trommeln bei jedem Tastendruck, mit wechselnden Pfoten (links runter / rechts runter).
- Zurück zur Ruhepose nach ~1 Sekunde ohne Tippen.
- Kompakt in die Leiste integriert; die unterste Linie der Katze ist auf die
  unterste Linie der Uhrzeit ausgerichtet.
- Liest komplett lokal von `/dev/input` — keine Cloud, keine Abhängigkeit von
  einem Editor.

## Installation

Das Plugin wird als Omarchy-Plugin über GitHub installiert:

```bash
omarchy plugin add https://<deine-repo-url>.git --enable
```

Danach erscheint die Widget-Kategorie **Fun → BongoCat** und kann über
`omarchy plugin enable samuel.bongocat` aktiv bzw. in einer Bar-Sektion platziert
werden.

### Abhängigkeiten

- **Omarchy** (mit unserem Quickshell-Shell-Unterbau)
- Berechtigung, `/dev/input/event*` zu lesen (normalerweise gehört die
  Tastatur zur `input`-Gruppe des Benutzers; falls nichts passiert, prüfe die
  Gruppenmitgliedschaft).

## Aufbau

```
samuel.bongocat/
├── manifest.json       # Omarchy-Manifest (Pflichtdatei im Repo-Root)
├── BarWidget.qml       # Widget-Einstiegspunkt (Canvas-Rendering + Logik)
├── key_monitor.py      # Liest Tastendrücke von /dev/input
├── bongocat.ttf        # Eingebettete Iconfont (aus pixl-garden konvertiert)
├── LICENSE             # MIT (mit Hinweis auf den Ursprung der Iconfont)
├── CHANGELOG.md
└── README.md
```

**Wichtig fürs Repo:** `omarchy plugin add` klont das Repo und validiert es
direkt. Daher müssen `manifest.json` und der Einstiegspunkt `BarWidget.qml` im
Repo-**Root** liegen; Dateien aus `entryPoints` sind relative Pfade und es
dürfen keine Symlinks verwendet werden. Der flache Aufbau entspricht der
Konvention der mitgelieferten Bar-Widgets.

## Wie das funktioniert

1. `key_monitor.py` öffnet alle `/dev/input`-Geräte und gibt bei jedem
   `EV_KEY`-Event (Wert 1 = gedrückt) eine neue Zeile auf stdout aus.
2. `BarWidget.qml` startet das Skript als `Process` und ruft bei jedem
   eingehenden Zeichen `drum()` auf, das zwischen „linke Pfote runter" und
   „rechte Pfote runter" hin- und herschaltet.
3. Ein `Timer` setzt nach ~1 s auf die Ruhepose zurück.
4. Die Iconfont-Glyphen werden auf einem `Canvas` gezeichnet. Dabei wird nicht
   die unsichtbare Bounding-Box, sondern der **sichtbare** gemalte Umfang
   zentriert, und die Unterkante der Katze wird an der Unterkante der
   Uhrzeichentextzeile verankert.

## Umfang der Bongo-Cat-Extension von pixl-garden

Dieses Plugin basiert auf der Idee und dem **Iconfont** der VS-Code-Extension
**[Bongo Cat](https://github.com/kitgore/BongoCat)** von *pixl-garden*
(MIT, Copyright © 2023 ben).

**Übernommen/umgesetzt aus pixl-garden:**
- Die **Bongo-Cat-Grafik** in Form der Iconfont-Glyphen (`b`/`c`/`d`/`a` =
  linke/rechte Pfote, oben/unten). Die `bongocat.ttf` hier ist eine Konvertierung
  der von pixl-garden veröffentlichten Font (`bongocat.woff`).
- Das **Verhalten**: bei Tasteneingabe mit alternierenden Pfoten schlagen, nach
  kurzer Pause zurück in die Ruheposition. Diese Logik stammt aus
  `src/extension.ts` der Extension und wurde für Omarchy neu umgesetzt.

**Eigenleistung / neue Entwicklung (nicht von pixl-garden):**
- Das komplette Omarchy-/Quickshell-Plugin: `BarWidget.qml` (QML-Code, Canvas-
  Rendering, Prozess-Anbindung, Ausrichtung) — Code ist von Grund auf neu,
  nicht übernommen.
- `key_monitor.py`: ein neuer Linux-Eingabe-Reader für `/dev/input` (die
  Extension selbst war reine VS-Code-/Statusleisten-Logik und konnte nicht
  wiederverwendet werden).
- **Bugfix** an der Font: ein doppelt überlappender Contour in der Glyphe für
  die „linke Pfote oben" wurde entfernt, dadurch ist der Mund jetzt korrekt
  gefüllt statt ausgehöhlt dargestellt.

> Die Katze ist damit nicht von pixl-garden „kopiert", sondern deren freie
> Iconfont wurde — lizenziertes MIT — in einen neuen, eigenständigen
> Omarchy-Widget-Stack integriert.

## Rolle der KI

Dieses Projekt wurde in einer **gemeinsamen Entwicklungssitzung mit einem
KI-Coding-Assistenten** ([opencode](https://opencode.ai)) erstellt. Der Ablauf
war iterativ und mit menschlicher Rückmeldung:

- Der **Assistent** hat den QML-/Python-Code entworfen und geschrieben, den
  Plugin-Aufbau per `omarchy plugin validate` geprüft und wiederholt
  Shell/Bar neu geladen.
- Der **Assistent** hat Bugdiagnosen durchgeführt — u. a. die ausgehöhlte
  Munddarstellung auf ein doppelt überlappendes Font-Contour zurückgeführt und
  behoben, sowie die vertikale Ausrichtung an der Uhrzeitzeile korrigiert.
- Die **menschliche Person** hat die visuelle Ausrichtung bewertet (z. B. die
  Entscheidung, die Katze an der Unterkante der Uhrzeit auszurichten) und die
  Designrichtungen vorgegeben.

Der Funktionsumfang, das Verhalten und die Bildgestaltung wurden Mensch-und-KI
gemeinsam festgelegt; die Code-Eigenleistung stammt überwiegend von der KI,
geprüft und freigegeben vom Menschen. Siehe auch `CHANGELOG.md` und
`LICENSE` für Details zu Herkunft und Lizenz.

## Lizenz

MIT — siehe [`LICENSE`](LICENSE). Die eingebettete Iconfont stammt aus der
Bongo-Cat-Extension von pixl-garden (MIT, Copyright © 2023 ben); die dortigen
Lizenz- und Copyright-Hinweise sind in `LICENSE` dokumentiert.
