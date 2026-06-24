# Day 3 — File Types Beyond "Just a File," and `stat`'s Full Story

## The real-world problem this solves (start here if anything feels abstract)

A program needs to read a keyboard. Another needs to read a disk. Another
needs to talk to another running program. Another needs the network. Without
a unifying idea, every tool would need separate logic for each. Unix's
answer: make all of these "open, read, write, close" — same basic interface —
but record on each file what KIND of thing is actually on the other end, so
the kernel routes the read/write correctly while the program itself doesn't
need to care.

This matters for real DevOps/cloud/platform work because: when something
breaks (a container won't start, a service can't reach a database), the
evidence is very often exactly a file listing with types and permissions in
it. Recognizing "that's a socket, two processes are supposed to talk through
it, and something's wrong with it" on sight is the difference between
panicking and diagnosing.

## The seven file types (first character of `ls -la` permission string)

- `-` Regular file — plain bytes (text, scripts, binaries, photos)
- `d` Directory — a lookup table mapping names → inode numbers (Day 2 callback)
- `l` Symlink — content is just a path string (Day 2, fully proven already)
- `c` Character device — streams data one byte at a time, no "position"
  concept. Examples seen in own `/dev`: `console`, `full`, `fuse`, `null`.
- `b` Block device — read/write in fixed chunks, can seek/jump around.
  Example seen: `/dev/sda`.
- `p` Named pipe / FIFO — exists purely to pass data between two processes,
  first-in-first-out. BUILT AND USED ONE MYSELF this session.
- `s` Socket — like a pipe, but for network-style inter-process communication.

## Real `/dev` evidence from my own system

```
crw-r--r--  ...  autofs        (character device)
crw-------  ...  console       (character device, root-only — sensitive)
crw-rw-rw-  ...  full, fuse    (character device, world read/write — harmless to expose)
drwxr-xr-x  ...  block, disk   (directories grouping device files, not devices themselves)
lrwxrwxrwx  ...  core -> /proc/kcore       (symlink, even inside /dev)
lrwxrwxrwx  ...  fd -> /proc/self/fd       (symlink, even inside /dev)
```
Permission looseness/strictness on devices isn't random — it reflects how
dangerous the device is. `/dev/full` (always reports "disk full," used for
testing error handling) is harmless to let anyone write to. `/dev/console`
controls the actual system console — letting anyone write there is dangerous,
hence root-only.

`file /dev/null` → "character special (1/3)"
`file /dev/sda` → "block special (8/0)"
Numbers in parentheses = major/minor device numbers — the kernel's internal
addressing for which driver this device file actually talks to. Not
something to memorize, just recognize the format.

## `stat` — the full story `ls -i` and `ls -la` only show pieces of

```
stat /etc/hostname
  Size: 7    Blocks: 8    IO Block: 4096   regular file
  Inode: 662    Links: 1
  Access: ...
  Modify: ...
  Change: ...
  Birth:  ...
```

**Links: 1** — directly confirms Day 2's hard link lesson with a single
number, no need to manually compare inode numbers between files anymore.
1 = no other names point at this inode yet.

### The four timestamps — the genuinely tricky part

- **Access** — last time CONTENT was read. Often not perfectly reliable on
  modern systems (relaxed tracking, `relatime`) for performance reasons.
- **Modify** — last time CONTENT actually changed. The one people usually
  mean by "last modified."
- **Change** — last time METADATA changed (permissions, ownership, link
  count) — even if content never changed at all. The confusing one, because
  it sounds like a synonym for Modify, but answers a different question.
- **Birth** — when the inode was first created.

### Proven directly, with real before/after timestamps
```
Before chmod:
  Modify: 2026-06-24 12:33:22.584...
  Change: 2026-06-24 12:33:22.584...   (identical — nothing touched recently)

sudo chmod 644 /etc/hostname   (same permission value as before — no real change)

After chmod:
  Modify: 2026-06-24 12:33:22.584...   ← UNCHANGED — content never touched
  Change: 2026-06-24 14:42:05.582...   ← UPDATED — chmod always touches metadata,
                                          even when the resulting value is identical
                                          to what it already was
```
This is real, checkable evidence — not trivia. This is exactly how you'd
investigate "did someone quietly change this file's permissions without
touching its content" — Modify would show nothing, Change would show the
exact moment it happened.

## Named pipe — built and used live, not just read about

```bash
mkfifo /tmp/mypipe
ls -la /tmp/mypipe   → prw-r--r-- ... 0 ... /tmp/mypipe
```
Confirmed: `p` type, as predicted from "FIFO = First In First Out."
**Size: 0** — a pipe has no real storage on disk, ever, regardless of how
much data flows through it. It's a kernel-managed relay point that only
exists while processes are actively using it — not "stored data" in any
real sense.

Two-terminal test: `cat /tmp/mypipe` waits (doesn't hang/freeze — it's
genuinely waiting for input). `echo "hello through the pipe" > /tmp/mypipe`
from elsewhere delivers the message instantly, `cat` prints it and returns
to a normal prompt. Two separate processes handed data through a "file"
with zero disk storage behind it.

## Honest note on today's pacing

This day needed a real stop-and-rebuild partway through — the command-level
material was running ahead of the "why does this exist" reasoning, and that
gap was flagged honestly rather than pushed through. Re-explaining the real-
world problem first (why file types exist at all, why timestamps matter for
real investigation scenarios) before returning to commands fixed it. Worth
remembering as a pattern: if a demo ever feels like "I don't know why I'm
running this," that's the signal to stop and rebuild the reasoning, not to
push forward with more commands.