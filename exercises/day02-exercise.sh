#!/bin/bash
# Day 2 Exercises — Paths and Inodes
# Predict before running. Type each line yourself rather than running this
# whole file at once.

# ── Part 1: Paths ───────────────────────────────────────────────────────────

# Task 1: confirm your anchor point
pwd

# Task 2: relative vs absolute, predict before each
cd ..
pwd
# Predicted: ____________   Actual: ____________

cd ..
pwd
# Predicted: ____________   Actual: ____________

# Task 3: prove root has no parent
cd /
pwd
cd ../../../../../../../..
pwd
# Predicted: ____________   Actual: ____________
# Why does this happen, in your own words? ____________

# Task 4: relative path from the WRONG starting point (deliberate mistake)
# Try this from inside exercises/ — predict the error before running:
cd ~/Desktop/linux-deep-dive/exercises
ls notes/ 2>&1
# Why did this fail? ____________
# Now fix it two ways:
ls ../notes
ls ~/Desktop/linux-deep-dive/notes


# ── Part 2: Inodes, hard links, symlinks ────────────────────────────────────

# Task 5: create a file and check its inode
echo "original content" > test_original.txt
ls -i test_original.txt
# Inode number noted: ____________

# Task 6: hard link — predict same or different inode before running
ln test_original.txt test_hardlink.txt
ls -i test_original.txt test_hardlink.txt
# Same inode? ____________

# Task 7: symlink — predict same or different inode before running
ln -s test_original.txt test_symlink.txt
ls -i test_original.txt test_symlink.txt
# Same inode? ____________

# Task 8: edit through the hard link, check both
echo "edited via hardlink" >> test_hardlink.txt
cat test_original.txt
cat test_hardlink.txt
cat test_symlink.txt
# Did all three show the edit? ____________

# Task 9: THE important one — delete the original, predict BOTH outcomes
# before running:
# Hard link prediction: ____________
# Symlink prediction: ____________
rm test_original.txt
cat test_hardlink.txt 2>&1
cat test_symlink.txt 2>&1
# What actually happened to each? ____________
# Why does the hard link survive but the symlink break? (one sentence,
# anchored to the word "inode")
# ____________

# Cleanup (these were throwaway test files)
rm -f test_hardlink.txt test_symlink.txt


# ── Self-check before Day 3 ─────────────────────────────────────────────────
# Without looking back at notes, answer cold:
# 1. What's the actual difference between an absolute and relative path?
# 2. Why does going "up" from / always just stay at /?
# 3. In one sentence each: what IS a hard link, what IS a symlink?
# 4. If you delete a file that has 3 hard links pointing at it, how many
#    deletions does it take before the actual data is gone?