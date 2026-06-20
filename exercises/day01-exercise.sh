#!/bin/bash
# Day 1 Exercises — The Linux Filesystem
# Run these ONE AT A TIME. Predict the result BEFORE running each one.
# This file is a reference/checklist, not meant to be run all at once with ./day01-exercise.sh
# (though it would technically work — better to type each command yourself in the terminal).

# ── Task 1: How many tools live in the toolshed? ──────────────────────────
# PREDICT FIRST: how many programs do you think /usr/bin contains?
# My prediction: ____________
# Actual result:
ls /usr/bin | wc -l
# My result: ____________
# Lesson: don't aim to memorize all of these. Build a core set deeply,
# learn to discover the rest with `man` and `--help`.


# ── Task 2: Read a real policy binder ──────────────────────────────────────
# PREDICT FIRST: what do you think this file contains, based on the name alone?
cat /etc/hostname
# Result noted: ____________


# ── Task 3: Visit the warehouse floor ──────────────────────────────────────
# Look closely for evidence of log rotation (files ending in .1, .2.gz etc)
ls -la /var/log | head -10
# What did you notice about file naming patterns? ____________
# What's the GROUP owner on most of these files, and what do you think it's for?
# ____________


# ── Task 4: Peek at the live dashboard ──────────────────────────────────────
# PREDICT FIRST: this file is named "uptime" — what do you think the two
# numbers represent?
cat /proc/uptime
# First number = ____________
# Second number = ____________
# Why might the second number be LARGER than the first? (hint: cores)
# ____________


# ── Task 5: Create, confirm, destroy — prove the sticky bit model ─────────
touch /tmp/myfile_test.txt
ls -la /tmp/myfile_test.txt
# Who owns this file? ____________
rm /tmp/myfile_test.txt
ls /tmp/myfile_test.txt 2>&1
# Confirm: file is gone, no permission issues, because it was MINE.


# ── Bonus Task 6 (optional): deliberately break the space rule ─────────────
# Try running a command WITHOUT a space between the command and its argument
# e.g.: cat/etc/hostname   (no space after cat)
# Predict what error you'll get, then run it for real:
cat/etc/hostname 2>&1
# Why did this fail exactly the way it did? ____________
# Now run it correctly:
cat /etc/hostname


# ── Self-check before moving to Day 2 ───────────────────────────────────────
# Can you explain, in your own words, with no notes:
# 1. Why /bin showed up as a symlink to /usr/bin on this system?
# 2. What problem the sticky bit on /tmp actually solves?
# 3. Why /etc and /var are kept separate from the executable itself?
# If any of these feel shaky, go back to notes/day01-filesystem.md before
# starting Day 2.