# Changelog

Alle nennenswerten Änderungen an diesem Plugin werden in dieser Datei
dokumentiert. Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/),
Versionierung nach [Semantic Versioning](https://semver.org/lang/de/).

## [Unreleased]

### Behoben
- `key_monitor.py`: externe Tastaturen wurden nicht erkannt, sobald sie neben
  Tastencodes noch einzelne Achsen melden. Logitech-Unifying-Empfänger geben am
  Tastatur-Knoten z. B. `REL_HWHEEL` und `ABS_VOLUME` für ihre Medientasten an;
  die Capability-Prüfung verwarf bisher jedes Gerät mit *irgendeiner* Achse und
  ließ damit nur die interne Tastatur übrig. Erkannt wird jetzt über die
  Tipp-Tasten (`KEY_A`, `KEY_Z`, `KEY_SPACE`); ausgeschlossen werden nur echte
  Zeigegeräte mit vollem Achsenpaar (`REL_X`+`REL_Y` bzw. `ABS_X`+`ABS_Y`).

## [1.0.1] - 2026-09-01

### Geändert
- `key_monitor.py`: liest nur noch Tastatur-Geräte (`by-path/*-kbd`,
  `by-id/*-kbd`), zusätzlich gefiltert über Geräte-Capabilities (EVIOCGBIT) —
  Mäuse, Touchpads usw. werden nicht mehr geöffnet. Eingaben werden auf eine
  begrenzte Rate gebündelt (max. 1 Ereignis / 20 ms).
- `BarWidget.qml`: stdout wird per `SplitParser` verarbeitet (pro `\n` ein
  `onRead`, sofort verworfen) statt per `StdioCollector` — der Shell-seitige
  Puffer bleibt dadurch begrenzt.

### Dokumentiert
- README: Berechtigungs-/Scope-Hinweis (input-Gruppe, nur Tastaturen).

## [1.0.0] - 2026-08-29

### Hinzugefügt
- Erstveröffentlichung als Omarchy-Bar-Widget.
- `BarWidget.qml`: rendert die Bongo-Cat-Iconfont auf einem Canvas und trommelt
  bei jedem Tastendruck mit alternierenden Pfoten.
- `key_monitor.py`: liest Tastatureingaben direkt von `/dev/input` und meldet
  jeden Tastendruck an das Widget.
- Idle-Zurücksetzen nach ~1 s ohne Tippen (beide Pfoten oben).
- Eingebettete `bongocat.ttf` (aus dem Bongo-Cat-Iconfont von pixl-garden
  konvertiert) mit fixiertem Duplikat-Contour, das eine ausgehöhlte Munddarstellung
  verursachte.
