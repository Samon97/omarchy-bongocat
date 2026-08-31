# Changelog

Alle nennenswerten Änderungen an diesem Plugin werden in dieser Datei
dokumentiert. Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/),
Versionierung nach [Semantic Versioning](https://semver.org/lang/de/).

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
