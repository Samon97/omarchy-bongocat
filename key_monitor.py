#!/usr/bin/env python3
import glob
import os
import select
import struct
import sys

EVENT_FORMAT = "llHHI"
EVENT_SIZE = struct.calcsize(EVENT_FORMAT)
EV_KEY = 1

devices = []
for pattern in ("/dev/input/event*", "/dev/input/by-path/*-kbd"):
    for path in glob.glob(pattern):
        real = os.path.realpath(path)
        if real not in devices:
            devices.append(real)

streams = []
for path in devices:
    try:
        streams.append(open(path, "rb", buffering=0))
    except (OSError, IOError):
        pass

if not streams:
    sys.exit(0)

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
            sys.stdout.write("\n")
            sys.stdout.flush()
