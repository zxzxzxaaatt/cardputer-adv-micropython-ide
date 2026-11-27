# adv_store.py —— SD 卡上的 IDE 状态 / 日志 / 输入法词频
#
# 目录名带设备指纹后缀，避免和别的固件（LX Shell 等）的日志目录撞名：
#     /sd/M5ADV_IDE_9F3C7A2B/            状态 + 词频
#     /sd/M5ADV_IDE_9F3C7A2B/logs/       每次运行的日志

import os

BASE = "/sd/M5ADV_IDE_9F3C7A2B"
LOGD = BASE + "/logs"
STATE = BASE + "/state.txt"
FREQ = BASE + "/imefreq.txt"


def sd_ok():
    try:
        return os.stat("/sd")[0] & 0x4000
    except OSError:
        return False
    except Exception:
        return False


def _mkdir(p):
    try:
        os.mkdir(p)
    except OSError:
        pass
    except Exception:
        pass


def ensure():
    if not sd_ok():
        return False
    _mkdir(BASE)
    _mkdir(LOGD)
    return True


def _now():
    try:
        import time
        t = time.localtime()
        if t[0] >= 2020:
            return "%04d-%02d-%02d %02d:%02d:%02d" % (t[0], t[1], t[2], t[3], t[4], t[5])
    except Exception:
        pass
    try:
        import time
        return "tick %d" % time.ticks_ms()
    except Exception:
        return "tick ?"


def _today():
    try:
        import time
        t = time.localtime()
        if t[0] >= 2020:
            return "%04d%02d%02d" % (t[0], t[1], t[2])
    except Exception:
        pass
    return "session"


def log(tag, text=""):
    if not ensure():
        return
    name = "%s/ide_%s.log" % (LOGD, _today())
    try:
        with open(name, "a") as f:
            f.write("%s %s %s\n" % (_now(), tag, text))
    except Exception:
        pass


# ---------------- 状态 ----------------
def load_state():
    d = {}
    try:
        with open(STATE, "r") as f:
            for line in f:
                line = line.strip()
                if not line or "=" not in line:
                    continue
                k, v = line.split("=", 1)
                d[k] = v
    except Exception:
        pass
    return d


def save_state(d):
    if not ensure():
        return
    try:
        with open(STATE, "w") as f:
            for k in d:
                f.write("%s=%s\n" % (k, d[k]))
    except Exception:
        pass


def set_state(k, v):
    d = load_state()
    d[k] = str(v)
    save_state(d)


# ---------------- 输入法词频 -------------
def load_freq():
    d = {}
    try:
        with open(FREQ, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = line.split()
                if len(parts) != 2:
                    continue
                d[int(parts[0])] = int(parts[1])
    except Exception:
        pass
    return d


def save_freq(d):
    if not ensure():
        return
    try:
        with open(FREQ, "w") as f:
            for cp in d:
                if d[cp] > 0:
                    f.write("%d %d\n" % (cp, d[cp]))
    except Exception:
        pass
