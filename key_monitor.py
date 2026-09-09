#!/usr/bin/env python3
import glob
import fcntl
import os
import select
import struct
import sys
import time

EVENT_FORMAT = "llHHI"
EVENT_SIZE = struct.calcsize(EVENT_FORMAT)
EV_KEY = 1
EV_REL = 2
EV_ABS = 3

_IOC_NRBITS = 8
_IOC_TYPEBITS = 8
_IOC_SIZEBITS = 14
_IOC_DIRBITS = 2
_IOC_NRSHIFT = 0
_IOC_TYPESHIFT = 8
_IOC_SIZESHIFT = 16
_IOC_DIRSHIFT = 30
_IOC_READ = 2


def _ioc(direction, type_, nr, size):
    return (
        (direction << _IOC_DIRSHIFT)
        | (type_ << _IOC_TYPESHIFT)
        | (nr << _IOC_NRSHIFT)
        | (size << _IOC_SIZESHIFT)
    )


# EVIOCGBIT(ev, len): fetch the capability bitmask for an event type `ev`.
def _eviocgbit(ev, size):
    return _ioc(_IOC_READ, ord("E"), 0x20 + ev, size)


long_size = struct.calcsize("L")
KEY_CAP = _eviocgbit(EV_KEY, long_size)
REL_CAP = _eviocgbit(EV_REL, long_size)
ABS_CAP = _eviocgbit(EV_ABS, long_size)


def _capability_bits(fd, request):
    mask = fcntl.ioctl(fd, request, b"\0" * long_size)
    return struct.unpack("=Q", mask.ljust(8, b"\0"))[0]


# Keys that only a device you can actually type on reports. Mice and media
# blocks carry a scattering of KEY_* codes (BTN_LEFT, volume, play/pause), but
# never the typing keys.
TYPING_KEYS = (30, 44, 57)  # KEY_A, KEY_Z, KEY_SPACE
TYPING_MASK = sum(1 << bit for bit in TYPING_KEYS)

# A pointer is a device carrying both axes of a cursor: REL_X/REL_Y for mice,
# ABS_X/ABS_Y for touchpads, touchscreens, and tablets.
XY_MASK = 0b11


def is_keyboard(fd):
    # Match on what the device can type, not on whether it has any axis at all.
    # Wireless keyboards routinely advertise a stray axis alongside their media
    # keys -- Logitech unifying receivers report REL_HWHEEL and ABS_VOLUME on
    # the keyboard node -- so a lone axis must not disqualify a device. Only a
    # real pointer's X/Y pair does.
    try:
        if _capability_bits(fd, KEY_CAP) & TYPING_MASK != TYPING_MASK:
            return False
        if _capability_bits(fd, REL_CAP) & XY_MASK == XY_MASK:
            return False
        if _capability_bits(fd, ABS_CAP) & XY_MASK == XY_MASK:
            return False
    except OSError:
        return False
    return True


# Keyboard-only candidates: udev maintains these symlinks, so we never open
# mice, touchpads, or other input devices.
devices = []
for pattern in ("/dev/input/by-path/*-kbd", "/dev/input/by-id/*-kbd"):
    for path in glob.glob(pattern):
        real = os.path.realpath(path)
        if real not in devices:
            devices.append(real)

streams = []
for path in devices:
    try:
        fd = open(path, "rb", buffering=0)
    except OSError:
        continue
    if is_keyboard(fd):
        streams.append(fd)
    else:
        fd.close()

if not streams:
    sys.exit(0)

# Coalesce bursts: at most one event per MIN_INTERVAL seconds bounds the
# stdout byte rate even under fast typists, key auto-repeat, or pasted text.
MIN_INTERVAL = 0.02
last_emit = 0.0

while True:
    try:
        readable, _, _ = select.select(streams, [], [], 0.1)
    except (OSError, ValueError):
        sys.exit(0)
    for fd in readable:
        try:
            data = fd.read(EVENT_SIZE)
        except (OSError, ValueError):
            streams.remove(fd)
            if not streams:
                sys.exit(0)
            continue
        if not data or len(data) < EVENT_SIZE:
            continue
        _, _, etype, code, value = struct.unpack(EVENT_FORMAT, data[:EVENT_SIZE])
        if etype == EV_KEY and value == 1:
            now = time.monotonic()
            if now - last_emit >= MIN_INTERVAL:
                last_emit = now
                sys.stdout.write("\n")
                sys.stdout.flush()
