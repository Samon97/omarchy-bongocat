import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "Samon97.bongocat"

  readonly property string home: Quickshell.env("HOME")
  readonly property string monitorScript: home + "/.config/omarchy/plugins/Samon97.bongocat/key_monitor.py"

  // The BongoCat icon font (extracted from the VS Code extension
  // pixl-garden.BongoCat). Two glyphs are drawn side by side (left half + right
  // half) to build the cat. b=left-up, d=left-down, c=right-up, a=right-down.
  readonly property string fIdle:      "\u0062\u0063" // both paws up
  readonly property string fLeftDown:  "\u0064\u0063" // left down, right up
  readonly property string fRightDown: "\u0062\u0061" // left up, right down

  // The cat frame currently shown.
  readonly property string frameIdle: "idle"
  property string frame: frameIdle

  readonly property color fg: bar ? bar.barForeground : Color.foreground

  // Font size so the cat sits compactly inside the bar, like the other icons.
  readonly property int iconSize: Math.round(Math.min(barSize, 26) * 0.6)

  // Fixed slot, large enough for any frame, centred in the bar. A fixed size
  // keeps the cat from shifting side to side while it drums.
  readonly property int slotH: Math.min(barSize, Math.round(iconSize * 1.25))
  readonly property int slotW: Math.round(slotH * 2.4)

  implicitWidth: slotW
  implicitHeight: slotH

  FontLoader {
    id: bongoFont
    source: Qt.resolvedUrl("bongocat.ttf")
    onStatusChanged: if (bongoFont.status === FontLoader.Ready) canvas.requestPaint()
  }

  Canvas {
    id: canvas
    anchors.fill: parent

    property string curText: root.frame === frameIdle ? root.fIdle
                            : (root.frame === "leftdown" ? root.fLeftDown : root.fRightDown)
    onCurTextChanged: requestPaint()

    onPaint: {
      var ctx = getContext("2d")
      if (typeof ctx.reset === "function") ctx.reset()
      ctx.clearRect(0, 0, width, height)

      var fam = bongoFont.name
      ctx.font = root.iconSize + "px \"" + fam + "\""
      ctx.fillStyle = root.fg
      ctx.textAlign = "left"
      ctx.textBaseline = "alphabetic"

      // Measure the painted extents so the visible cat — not its invisible
      // side/baseline bearings — is what gets centred.
      var m = ctx.measureText(root.frame === frameIdle ? root.fIdle
              : (root.frame === "leftdown" ? root.fLeftDown : root.fRightDown))
      var bx = (m && typeof m.actualBoundingBoxLeft === "number") ? m.actualBoundingBoxLeft : 0
      var bw = (m && typeof m.actualBoundingBoxRight === "number") ? bx + m.actualBoundingBoxRight : m.width
      var top = (m && typeof m.actualBoundingBoxAscent === "number") ? m.actualBoundingBoxAscent : root.iconSize
      var bot = (m && typeof m.actualBoundingBoxDescent === "number") ? m.actualBoundingBoxDescent : 0
      var bh = top + bot

      // Centre the painted art inside the fixed slot. Baseline sits below the
      // ascent, so placing it `top` below the vertical centre lowers the glyph
      // body into view instead of pushing it above the slot.
      var x = (width - bw) / 2

      // Anchor the cat's bottom line to the same line as the clock's text
      // bottom: the clock label is vertically centred in barSize, so its bottom
      // sits half a line-height below the bar's vertical centre. Pinning the
      // painted bottom (`penY + bot`) there keeps the cat's base fixed across
      // poses, so only the raised paw moves — and the default pose's bottom
      // lines up with the time label.
      var lineRef = (typeof Style !== "undefined" && Style.font && Style.font.body)
        ? Style.font.body : root.iconSize
      var penY = root.barSize / 2 + lineRef * 0.6 - bot
      ctx.fillText(root.frame === frameIdle ? root.fIdle
                  : (root.frame === "leftdown" ? root.fLeftDown : root.fRightDown),
                   x - bx, penY)
    }
  }

  // Each keypress toggles which paw is down; a 1 s idle timer returns the cat
  // to both-paws-up when typing stops. Exactly like the VS Code extension.
  property string lastPaw: "left"
  function drum() {
    if (root.lastPaw === "left") {
      root.frame = "leftdown"
      root.lastPaw = "right"
    } else {
      root.frame = "rightdown"
      root.lastPaw = "left"
    }
    idleReset.restart()
  }
  function idle() {
    root.frame = frameIdle
  }

  Timer {
    id: idleReset
    interval: 1000
    repeat: false
    onTriggered: root.idle()
  }

  property int watcherRestarts: 0
  Process {
    id: keyWatcher
    command: [root.monitorScript]
    stdout: StdioCollector {
      waitForEnd: false
      onDataChanged: {
        if (String(text || "").length > 0) {
          root.drum()
        }
      }
    }
    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (String(text || "").trim() !== "") console.warn("bongocat", String(text).trim())
    }
    running: true
    onExited: {
      if (exitCode !== 0 && root.watcherRestarts < 3) {
        root.watcherRestarts += 1
        restartWatcher.start()
      }
    }
  }

  Timer {
    id: restartWatcher
    interval: 1200
    repeat: false
    onTriggered: keyWatcher.running = true
  }

  // The cat only drums on keyboard input, not on click.
  Component.onCompleted: root.idle()
}
