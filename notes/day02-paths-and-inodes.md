# Day 2 — Paths, and What a File's "Identity" Actually Is

## Part 1: Absolute vs Relative Paths

### The core idea
Absolute path = "starting from the building's front entrance" — always begins
with `/`, always means the same thing no matter where you currently are.
Relative path = "from where you're standing right now" — interpreted against
your CURRENT WORKING DIRECTORY (whatever `pwd` shows at that moment). Same
relative path typed from two different locations can resolve to two
completely different places.

`~` is a shortcut that EXPANDS to your home directory's absolute path the
instant you type it (`~/Desktop` → `/home/dovlet/Desktop`).
`.` = current directory. `..` = parent directory (one level up).

### Real proof from this session
`ls notes/` failed while sitting inside `exercises/` — relative path looked
for `notes` INSIDE `exercises`, but they're siblings under `linux-deep-dive`,
not parent/child. Fixed two ways:
- `ls ../notes` (relative — go up one level first, correct from where I was)
- `ls ~/Desktop/linux-deep-dive/notes` (absolute — works from anywhere)
This is the exact same root cause as the very first `cd /Desktop/...` failure
on Day 1 — wrong assumption about what a path is relative to.

### Root has no parent — proven three times
```
cd /../../../../../../../..
pwd
→ /
```
No matter how many `..` you chain from `/`, you stay at `/`. Root is defined
as its own parent specifically so "go up too far" never errors — it just
harmlessly stops climbing. Confirmed with single `..`, double, and finally
eight chained in a row — all landed at `/`.

### Word-splitting strikes again (the opposite mistake from Day 1)
```
cd ../ ..
→ cd: too many arguments
```
Day 1 had a MISSING space causing one word to merge into one bad command.
This time an EXTRA space split one path into two separate arguments — `cd`
only accepts one destination. Same underlying rule both times: the shell
splits strictly on spaces, no exceptions, no guessing intent.

### Why this actually matters (not just "easy mechanics")
Every script, CI/CD pipeline, and Dockerfile assumes things about WHERE it's
currently running from and references other files relative to that location.
Weak intuition here = scripts that work from one folder and silently break
from another — one of the most common real automation bugs ("works on my
machine, fails in CI" is very often exactly this).

---

## Part 2: Inodes — What a File Actually Is

### The core idea
A file's NAME is not part of the file. The name is just a label kept in a
directory's lookup table, pointing at the file's real identity: its INODE
NUMBER. The inode is where the actual metadata lives (size, permissions,
owner, location of the real data on disk). A directory is basically a table
mapping names → inode numbers, nothing more.

### Hard link vs symlink — the real distinction
**Hard link** = a second name pointing at the EXACT SAME inode. No original,
no copy — genuinely one file, two labels. Edit through either name, both show
the change instantly, because there's only ever been one file.

**Symlink** = its own SEPARATE file, with its OWN inode, whose entire content
is just a stored path string ("go look over there instead"). Never touches
the original file's data directly — it's a reference to a NAME, not a
connection to the actual content.

### Proven directly, with real inode numbers
```bash
echo "original content" > original.txt
ls -i original.txt          → 10400 original.txt

ln original.txt hardlink.txt
ls -i original.txt hardlink.txt   → 10400 hardlink.txt  10400 original.txt
(SAME inode — confirmed: not a copy, one real file, two names)

ln -s original.txt symlink.txt
ls -i original.txt symlink.txt    → 10400 original.txt  46058 symlink.txt
(DIFFERENT inode — confirmed: symlink is its own distinct file)
```

### The edit test
```bash
echo "edited through hardlink" >> hardlink.txt
cat original.txt   → shows the edit
cat hardlink.txt    → shows the edit
cat symlink.txt    → shows the edit (just follows its stored path)
```
At this stage hard link and symlink LOOK behaviorally identical — both reveal
the edit. The real difference only shows up once the original is removed.

### The delete test — the genuinely important one
```bash
rm original.txt
cat hardlink.txt    → STILL WORKS, shows both lines
cat symlink.txt    → "No such file or directory" — BROKEN
```
**Why:** `rm original.txt` only removed ONE NAME pointing at inode 10400.
The inode itself only disappears once the count of names pointing at it
drops to zero — `hardlink.txt` was still pointing at it, so the real data
never went away. The symlink broke instantly because it was never connected
to the data at all — only to the now-nonexistent name "original.txt".

### Why this matters in real DevOps work
This exact mechanism (data isn't freed until the LAST reference disappears)
is why deleting a log file a running process still has open doesn't
immediately free disk space — an open file handle inside that process acts
like one more "name" holding the inode alive, even though no directory
listing shows it anymore. This becomes a real "disk full but I can't find
what's eating it" mystery one day — and now the cause is already understood,
just with a different mechanism (open handle) holding the inode alive
instead of a second filename.

This also directly previews Week 9 (Docker layered filesystems) and Week 4
(mount points) — both rely on this same "name vs real identity" separation.

## Self-check passed this session
Explained back cleanly, unprompted, with correct ordering on the second
attempt: "a hard link is a second name for the exact same file... symlink is
a separate file that stores a path and reference to a name." First attempt
had the inode/content relationship backwards (said hard link was "about
inode" and symlink "about content" — actually the reverse: hard link IS the
content via shared inode, symlink is detached, pointing at a name only).
Correcting and re-deriving cleanly without being walked through it again is
real evidence this is solid, not just demoed correctly.