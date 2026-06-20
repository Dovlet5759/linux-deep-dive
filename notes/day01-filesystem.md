# Day 1 — The Linux Filesystem: One Tree, Organized by Purpose

## The big idea before anything else

An operating system's job is to sit between hardware and programs, and arbitrate
access to it safely and consistently. Linux (the kernel) does this job; what we
call "Linux" day to day (Ubuntu etc.) is the kernel plus a huge stack of tools
built on top of it (GNU project and others).

## "Everything is a file" — why this isn't just a slogan

Unix's core design bet: instead of inventing different rules for disks,
keyboards, network connections, printers — make almost everything behave like
a file (open, read, write, close), using the SAME small set of operations
regardless of what's actually on the other end. This is why `/proc` and `/sys`
can expose live, constantly-changing kernel data AS FILES later this week —
it's not a trick, it's Linux being consistent with its own philosophy.

## One tree, not drive letters

Windows: new disk = new letter (C:, D:...), separate parallel namespace.
Linux: ONE tree starting at `/` (root). Other disks get MOUNTED into that one
tree at some folder — they don't get their own namespace.
Real proof from my own WSL: `/mnt/c` is literally my Windows C: drive, grafted
into the Linux tree at that folder. Full mounting mechanics: Week 4.

## Why each top-level folder exists — the REASONING, not just the list

**`/usr/bin`, `/usr/sbin`** — "What can run?" The engine/toolshed. Historically
`/bin` was kept separate for tools needed even before the main disk was fully
trusted/mounted at boot. Modern Ubuntu merged this ("usr-merge") since the
original reason mostly stopped applying — `/bin` is now just a symlink to
`/usr/bin`, kept only for backward compatibility with old scripts/muscle memory.

**`/etc`** — "How should it behave?" Configuration, deliberately kept separate
from program code, because config changes constantly and is machine-specific,
while code shouldn't change once installed. This separation is WHY
"check `/etc` first" becomes instinct for troubleshooting.

**`/var`** — "What's happening while it runs?" Logs, caches, databases —
constantly changing runtime data, deliberately separated from static program
files so that runaway log growth can't threaten the rest of the system.
Real evidence I saw myself: `/var/log` showing automatic log rotation in
action (`alternatives.log`, `.log.1`, `.log.2.gz` etc) — a live system policy
clearing the "warehouse floor" before it overflows. (Full logrotate
mechanics: Week 8.)

**`/opt`** — self-contained third-party software that doesn't fit the normal
spread-across-the-system pattern.

**`/home`** — private, per-user space. **`/root`** — NOT the same as `/` —
it's specifically the root user's own home folder, just one small branch of
the tree, easy to confuse with `/` by name alone.

**`/tmp`** — shared scratch space, anyone can write here, but the STICKY BIT
(seen as the `t` in `drwxrwxrwt`) means you can only delete/rename YOUR OWN
files here, even though the directory looks fully open. Proved this myself:
created `/tmp/myfile_test.txt`, confirmed ownership (`dovlet dovlet`), deleted
it cleanly — full loop, no permission issues, because it was mine.

**`/dev`** — hardware represented as files (the "utility panel" — switches,
sensors, exposed using the same file operations as everything else).

**`/proc`** — NOT real files on disk. The kernel's live, generating-on-demand
view of system state. Proved this with `/proc/uptime`.

## Real commands run today, and what they actually showed

```bash
ls /usr/bin | wc -l
```
→ 886 tools on my system. Lesson: never need to memorize all of these — build
a smaller core set deeply, learn to discover the rest (`man`, `--help`) when needed.

```bash
cat /etc/hostname
```
→ `DESKTOP-IVIHOE7` (WSL inheriting the Windows machine name — WSL quirk, noted, moved on).

```bash
ls -la /var/log | head -10
```
→ Real log rotation evidence (see above). Also noticed `syslog` as a GROUP
owner, not a person — a system group that exists specifically so logging
processes can write without needing full root access. (Full users/groups
depth: Week 6.)

```bash
cat /proc/uptime
```
→ `7700.23 25589.54`
First number = seconds since boot (~2.14 hours).
Second number = cumulative IDLE time summed ACROSS ALL CPU CORES — which is
why it can be larger than actual uptime. Good early lesson for later reading
multi-core cloud VM CPU stats correctly.

```bash
touch /tmp/myfile_test.txt
ls -la /tmp/myfile_test.txt
rm /tmp/myfile_test.txt
```
→ Full create/confirm/delete loop in `/tmp`, proving the sticky-bit model
with my own hands, not just reading about it.

## The accidental lesson — shell word-splitting

Typed `cat/tmp/remote-wsl-loc.txt` (missing the space after `cat`).
Result: `zsh: no such file or directory: cat/tmp/remote-wsl-loc.txt`

**Why:** the shell splits whatever you type into words based on spaces. The
FIRST word is always taken as the command, everything after as arguments.
Missing a space doesn't make the shell "guess intent" — it takes you
completely literally, and tried to run a program literally named
`cat/tmp/remote-wsl-loc.txt`, which obviously doesn't exist.

Fixed by adding the space: `cat /tmp/remote-wsl-loc.txt` worked correctly,
revealing a VS Code WSL-Remote extension breadcrumb file containing a literal
Windows path — a real, live example of `/tmp` being used exactly as designed:
short-lived, cross-process coordination data.

Also hit `cat /tmp/snap-private-tmp` → **Permission denied**. Correctly did
NOT treat this as something broken — it's Linux correctly protecting a file
that isn't mine to read (Snap's private sandbox folder). Permission denied
is usually the system working correctly, not failing.

## Real-world engine/config/state model (refined from my own reasoning)

```
Executable (/usr/bin, /usr/sbin)   → the engine, but useless alone
Configuration (/etc)               → gives the engine its behavior
Runtime state/logs (/var)          → what happens while it runs
```

Real example I worked through: nginx.
```
/usr/sbin/nginx       executable — useless without...
/etc/nginx/           config — tells it what port, what site, where files are
/var/log/nginx/       logs — what actually happened while it ran
```

Important refinement: this model fits CONTINUOUSLY RUNNING SERVICES well.
Simple one-shot command-line tools (`ls`, `grep`) often have NO `/etc` config
and NO `/var` runtime state at all — they just run and exit. Some tools do
support personal config in the home folder (different category from
system-wide `/etc` config) — covered properly when we reach `~/.bashrc`-style
files.

This maps almost directly onto real troubleshooting triage:
**Is it the executable? Is it the config? Is it the runtime state/logs?**
→ which is just `/usr/bin` vs `/etc` vs `/var`, the categories made conscious.

## Open items / honest self-assessment for today

- This was the conceptually easiest day in the whole 10-week plan — geography,
  not mechanics. Don't over-extrapolate "Linux feels easy" from Day 1 alone;
  the real test comes with processes/signals (Week 3) and live debugging
  under pressure (Week 2, Week 5).
- Real strength shown today: building a model, then testing it against a
  real example (nginx) unprompted, and self-correcting from an actual error
  (`cat/tmp` typo) instead of just re-running blindly.
- Real weakness flagged (from the GitHub auth detour, not Linux content
  itself): under frustration, instinct leaned toward "just give me the
  copy-paste" rather than slowing down — and a live token nearly got posted
  twice. Worth deliberately watching for this pattern going forward, since
  it's a real, common cause of credential leaks in actual DevOps work.