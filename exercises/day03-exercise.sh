#!/bin/bash
# Day 3 Exercises — File Types and stat
# Predict before running. Type each line yourself rather than running this
# whole file at once.

# ── Part 1: Identify file types in /dev ─────────────────────────────────────
ls -la /dev | head -20
# Find one character device, one block device, one symlink, and one
# directory in the output above. Write the line and the type letter for each:
# Character device: ____________
# Block device: ____________
# Symlink: ____________
# Directory: ____________

# Task: use `file` to confirm two of these without reading the ls output
file /dev/null
file /dev/sda 2>&1
# What do the numbers in parentheses represent? ____________


# ── Part 2: stat in depth ───────────────────────────────────────────────────

# Task: full stat on a file you already know
stat /etc/hostname
# Links count: ____________  (what does this number directly prove,
# tying back to Day 2?) ____________

# Task: prove Modify vs Change are genuinely different things
# Predict BEFORE running: will Modify change? Will Change change?
# Modify prediction: ____________   Change prediction: ____________
stat /etc/hostname
sudo chmod 644 /etc/hostname
stat /etc/hostname
# Actual result — did Modify change? ____________  Did Change change? ____________
# Why does this happen? (one sentence, your own words)
# ____________


# ── Part 3: build and use a named pipe ──────────────────────────────────────

mkfifo /tmp/mypipe_exercise
ls -la /tmp/mypipe_exercise
# What type letter shows up first? ____________
# What is the file's SIZE, and why is that the case? ____________

# Open a SECOND terminal tab and run this there:
#   cat /tmp/mypipe_exercise
# It will appear to wait. That's expected — it's listening, not frozen.
# Back in THIS terminal, run:
echo "hello through the pipe" > /tmp/mypipe_exercise
# Switch to the second terminal — what happened there? ____________

# Cleanup
rm /tmp/mypipe_exercise


# ── Self-check before Day 4 ─────────────────────────────────────────────────
# Without looking back at notes, answer cold:
# 1. Why do character devices, block devices, regular files, directories,
#    pipes, sockets, and symlinks all get treated through the same basic
#    open/read/write/close operations?
# 2. What's the practical difference between Modify and Change timestamps —
#    give a real scenario where the distinction would actually matter.
# 3. What happens, mechanically, when one process writes to a named pipe
#    while another is reading from it? Where is the data actually stored
#    while this is happening?