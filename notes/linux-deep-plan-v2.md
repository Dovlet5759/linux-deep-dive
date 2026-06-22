# Deep Linux for DevOps, Cloud & Platform Engineering — v2
### A 10-week mental-model-driven plan (WSL-based, 2-4 hrs/day)
### Revised after Days 1-2 actual execution — see changelog at bottom

---

## How this plan is different from a tutorial list

Every week teaches **one mental model** of how Linux actually behaves, not a bucket of commands. Commands appear as the natural output of understanding the model. Each day ends with a DevOps/Cloud/Platform task that *forces* you to use the model, because a model you can recite but not use isn't learned yet.

Three rules to follow all 10 weeks (third one is new in v2):
1. **Never copy-paste a command without predicting what it will do first.** Guess, run it, compare.
2. **Break something every single day.** Delete a config, kill the wrong process, fill the disk. Then fix it.
3. **NEW — On every review/synthesis day, answer one cold-recall question from 3+ weeks ago, unprompted, before doing that week's own review.** Callbacks between weeks aren't enough on their own for real retention — deliberate, spaced retrieval is what actually prevents Week 1 content from quietly evaporating by Week 6. This adds 5 minutes to each review day, no more.

## Realistic pacing — read this before continuing

Days 1-2 of actually executing this plan took real time well beyond "two days of content," because environment setup and debugging friction (aliases, GitHub auth, etc.) ate real hours that the original schedule didn't account for. **This is normal and expected, not falling behind.** Going forward: if a day's *content* is genuinely understood and demoed correctly, the day is done, regardless of how many real calendar days it took to get there. Do not compress explanations or rush a shaky checkpoint to protect the 10-week number — the 10 weeks was always a target, not a deadline. A more honest estimate for a true beginner, given what we've seen so far, is **10-14 weeks** of real time at this depth. That's not a downgrade of the plan, it's an honest correction to the original estimate.

## WSL vs. real Linux — read this once, refer back when flagged

WSL2 is real Linux, real kernel — but it is **not identical** to a bare-metal machine or a cloud VM in a few specific ways that matter for this plan. Flagged explicitly below wherever a day hits one of these differences:
- **Boot process**: WSL has its own lightweight init, not a full BIOS→bootloader→kernel sequence (Week 2, Day 8).
- **Networking**: WSL2 uses NAT through a virtual network adapter, different from a cloud VM with a real or virtual NIC directly on a cloud network (Week 5, several days).
- **Disk/storage virtualization**: WSL's filesystem sits on a virtual disk (a `.vhdx` file on the Windows side); block-device/partition exercises will show a simplified picture compared to a real cloud disk (Week 4).
- **systemd support**: Modern WSL *does* support systemd (must be enabled in `/etc/wsl.conf`), but historically didn't — worth confirming it's actually on before Week 2.

None of this invalidates the plan — the underlying concepts are identical, Linux is Linux. It just means: where flagged, expect the *output* to look slightly different than a tutorial written for a cloud VM, and that's expected, not a sign something's broken.

---

## Week 1 — Linux Is Just Files (the filesystem mental model)

**The model:** Unix's defining idea is "everything is a file." Once this clicks, `/proc`, `/dev`, `/sys` stop being mysterious.

**Status: Days 1-2 complete** (filesystem hierarchy + reasoning; absolute/relative paths; inodes, hard links, symlinks — all demonstrated hands-on with real WSL output, not just read about).

| Day | Focus | Hands-on DevOps task |
|---|---|---|
| 1 ✅ | FHS: why `/etc`, `/var`, `/usr`, `/opt` exist. | Explain why Docker's data lives under `/var/lib/docker`. |
| 2 ✅ | Absolute vs relative paths, `.`/`..`, symlinks vs hard links, inodes. | Symlink scenario — `current` pointing at a "version," switch it (mirrors `nvm`/`pyenv` and blue-green binary swaps). |
| 3 | File types beyond regular files: directories, device files, sockets, pipes. `file` and `stat` commands in depth (not just `ls -i`). | Use `stat` to compare full metadata of a hardlinked file vs its "original" — link count, timestamps, everything `ls -i` doesn't show. |
| 4 | `/proc` and `/sys` as "the kernel exposed as files," in real depth this time — `/proc/cpuinfo`, `/proc/meminfo`, `/proc/<pid>/status`. | Find a running process's open file descriptors via `/proc/<pid>/fd` — this is exactly what you're debugging when a container "won't release a file handle." |
| 5 | Permissions properly: user/group/other, the octal system (derive it, don't memorize), `chmod`/`chown`/`chgrp`, setuid/setgid/sticky bit (full treatment now, building on the `/tmp` sticky-bit preview from Day 1). | Reproduce a real bug: a file only root can write, a non-root process tries to write to it, fix via correct ownership — explain *why* `chmod 777` is the wrong instinct, not just that it is. |
| 6 | Hard vs soft links to mounted filesystems, `du`/`df`, mount points conceptually (foreshadowing Docker volumes, Week 4, Week 9). | Fill disk space deliberately, observe `df` change, diagnose with `du -sh */ \| sort -h`. |
| 7 | **Review + synthesis.** Re-derive the FHS from memory. **Cold-recall check: explain the difference between a hard link and symlink, from memory, no notes — this is the Day 2 concept, test it stays solid a week later.** | Write a one-page personal cheat-sheet in your own words. |

**Week 1 checkpoint:** Explain why Dockerfile `COPY` and `VOLUME` interact with the filesystem the way they do, using inode/mount concepts.

---

## Week 2 — Linux Boots and Organizes Itself (init, systemd, the kernel's job)

**The model:** A running Linux machine is a kernel managing hardware + a tree of processes started by `systemd` (PID 1).

**⚠️ WSL note for this entire week:** Confirm systemd is actually active first — run `ps -p 1 -o comm=` and check it says `systemd`, not `init`. If not, enable it via `/etc/wsl.conf` (`[boot]` section, `systemd=true`) and restart WSL (`wsl --shutdown` from PowerShell, then reopen). Day 8 specifically will look different from a real machine's boot — treat it as theory to *recognize* later, not to fully reproduce here.

| Day | Focus | Hands-on task |
|---|---|---|
| 8 | The boot sequence conceptually (BIOS/UEFI → bootloader → kernel → initramfs → systemd). **WSL-flagged: this sequence is mostly skipped/different in WSL** — focus on understanding it for real VMs/cloud instances. | Compare `ps -ef \| head` in WSL vs reading about a real VM boot — note PID 1's role either way. |
| 9 | systemd units: services, targets, timers. `systemctl status/start/stop/enable/disable`. Why `enabled` ≠ `running`. | Write your own systemd service file that runs a script on a timer. |
| 10 | Logs: `journalctl` deeply — filtering by unit/time/priority, following live (`-f`). | Intentionally break your custom service (bad path, missing permission), diagnose purely from `journalctl -u yourservice -xe`. |
| 11 | Dependency ordering between units (`Wants=`, `Requires=`, `After=`). | Second service that must start *after* Day 9's and depends on it — observe what happens when you stop the dependency. |
| 12 | Package management: `apt`, `dpkg`, what a `.deb` contains. | Install a package, inspect its placed files with `dpkg -L <package>` — connect back to Week 1's FHS. |
| 13 | Cron vs systemd timers. | Build the same scheduled task two ways, compare debugging experience. |
| 14 | **Review + synthesis.** Re-derive boot → systemd → service lifecycle out loud, no notes. **Cold-recall check: explain the sticky bit on `/tmp` again, unprompted — Week 1, Day 1/6 content.** | Diagram the full lifecycle of deploying a background worker on a cloud VM. |

**Week 2 checkpoint:** Diagnose a broken/unknown systemd service within minutes using `systemctl` + `journalctl` alone.

---

## Week 3 — Processes Are the Living System (process & resource model)

**The model:** Every running thing is a process with a PID, parent, owner, signals, resource usage. Containers and pods are just processes with extra isolation.

| Day | Focus | Hands-on task |
|---|---|---|
| 15 | Process tree: `ps`, `pstree`, parent/child, orphans/zombies. | Spawn a background process, kill its parent, observe orphaning with `pstree`. |
| 16 | Signals: SIGTERM vs SIGKILL vs SIGHUP vs SIGINT — why graceful shutdown matters (directly explains k8s grace periods, Docker stop timeouts). | Script that traps SIGTERM and cleans up; kill with SIGTERM vs SIGKILL, compare. |
| 17 | Foreground/background jobs, `&`, `nohup`, `disown`, `jobs`, `fg`/`bg`. | Background a task, disown it, close terminal, reconnect, confirm survival — then redo "properly" with systemd, compare reliability. |
| 18 | Resource monitoring: `top`/`htop`, load average math, memory (used vs cached vs available). | Generate CPU load deliberately, watch load average climb and settle. |
| 19 | cgroups and namespaces conceptually (full depth in Week 9). | Look at `/sys/fs/cgroup`, find a process's cgroup, connect to Docker memory limits mentally. |
| 20 | `nice`/`renice`, `ulimit`, resource limits — "noisy neighbor" problem on shared infra. | Set a `ulimit` for max open files, hit it deliberately, observe the failure. |
| 21 | **Review + synthesis.** **Cold-recall check: explain `/etc` vs `/var`'s separation reasoning again, unprompted — Week 1 content, three weeks old now.** | Explain, no notes, what happens (in process terms) when you run `docker stop`. |

**Week 3 checkpoint:** Explain Kubernetes graceful pod termination and Docker's container lifecycle purely in signals/process-tree terms.

---

## Week 4 — Storage and Devices

**⚠️ WSL note:** Your filesystem sits on a virtualized disk (a `.vhdx` file, Windows-side). `lsblk` and partition exercises will show a simplified picture vs. a real cloud VM with real/virtual block storage. The *concepts* (block devices, mounting, filesystems) are identical — just don't expect to see multiple real partitions the way you would on bare metal.

| Day | Focus | Hands-on task |
|---|---|---|
| 22 | Block vs character devices, `/dev` tour, partitions conceptually, `lsblk`/`blkid`. | Inspect WSL's virtual disk structure, connect to cloud EBS/managed disks being "just block devices attached to a VM." |
| 23 | Filesystems (ext4 conceptually), `mount`/`umount`, `/etc/fstab`. | Create a loopback file, format as ext4, mount, write, unmount — mirrors a Docker volume or cloud persistent disk. |
| 24 | Disk usage forensics: `du`, `df`, inode exhaustion ("no space left" despite free space). | Deliberately exhaust inodes, diagnose "out of space" vs "out of inodes." |
| 25 | Swap conceptually, OOM killer behavior. | Read WSL's swap config, explain when OOM activates and why it matters for sizing k8s pod memory limits. |
| 26 | Archiving/compression: `tar`, `gzip`, why `.tar.gz` is two steps. | Package a directory the "DevOps way," unpack, verify integrity. |
| 27 | **Review + synthesis.** **Cold-recall check: explain a process's signal-handling for graceful shutdown again, unprompted — Week 3 content.** | Explain a Kubernetes PersistentVolumeClaim binding, tying back to mount/block device knowledge. |
| 28 | **Buffer/catch-up day** — explicitly protected, do not skip even if "on schedule." Revisit anything shaky from Weeks 1-4. | Re-do whichever hands-on task felt weakest. |

---

## Week 5 — Linux Talks to the Network

**⚠️ WSL note for this entire week:** WSL2 networking goes through NAT via a virtual adapter — meaningfully different from a cloud VM sitting directly on a VPC/virtual network. Expect `ip a`/`ip route` output to look different from any cloud-focused tutorial. The concepts (interfaces, routing, DNS, ports, firewalls) transfer directly; the specific numbers/interface names will not.

| Day | Focus | Hands-on task |
|---|---|---|
| 29 | Network interfaces, IP basics, `ip a`, `ip route`. | Map WSL's interface and default route, explain WSL2's NAT networking in your own words. |
| 30 | DNS: `/etc/resolv.conf`, `/etc/hosts`, `dig`/`nslookup`. | Fake entry in `/etc/hosts`, curl it — mirrors how local dev fakes production domains. |
| 31 | TCP/UDP ports and sockets, `ss -tulpn`. | Start a simple HTTP server, confirm with `ss`, kill it, confirm port frees — debug "port already in use." |
| 32 | `curl`/`wget` deeply — headers, status codes, redirects. | Hit a real public API, inspect headers, handle non-200, pipe JSON into `jq` (preview). |
| 33 | Firewalls: `iptables`/`ufw`, mapped to cloud security groups/NSGs. | Block a port locally, confirm with `curl`/`ss`, unblock — narrate the cloud-ticket parallel out loud. |
| 34 | SSH properly: key-based auth mechanics, `~/.ssh/config`. | Generate a keypair, configure `~/.ssh/config` alias, SSH into WSL via localhost. |
| 35 | **Review + synthesis.** **Cold-recall check: explain hard link vs symlink AND the FHS reasoning, both unprompted — oldest material, 5 weeks old, the real test of whether it stuck.** | Explain, end to end, what happens at the OS level during a load-balancer health check. |

**Week 5 checkpoint:** Cloud networking diagrams (VPC/subnet/security group/load balancer) should look like named, managed versions of things you already understand at the Linux level.

---

## Week 6 — Users, Identity, and Security

**⚠️ DECISION POINT BEFORE DAY 36 — do not skip this:** Day 36 asks you to hand-edit `/etc/passwd`, `/etc/group`, and potentially `/etc/shadow` directly. **This carries real risk of locking yourself out of your own WSL user account or breaking sudo if done incorrectly.** Before that day, explicitly decide and confirm one of:
- **(a)** Export/back up your WSL distro first (`wsl --export Ubuntu ubuntu-backup.tar` from PowerShell) so you have a restore point, or
- **(b)** Do the hand-editing exercise in a throwaway WSL distro instead of your main one (`wsl --install -d Ubuntu` a second instance, or use a Docker container as an even more disposable sandbox for just this one exercise).

Do not proceed into Day 36 without picking one. This is the single highest-risk hands-on task in the entire 10-week plan, and the original plan only mentioned this in a parenthetical — it deserves a real decision, not an afterthought.

| Day | Focus | Hands-on task |
|---|---|---|
| 36 | Users/groups deeply: `/etc/passwd`, `/etc/group`, `/etc/shadow` structure, UID/GID, why root is UID 0. **(See decision point above before starting.)** | Create a user/group by hand-editing the files directly (in your backed-up or disposable environment) to see exactly what `useradd` automates. |
| 37 | `sudo` properly: `/etc/sudoers`, least privilege, why "just sudo everything" is a real production risk (connects to cloud IAM). | Configure a limited sudo rule (restart one specific service only) — mirrors cloud IAM policy thinking. |
| 38 | SSH key management at scale: `authorized_keys`, why this doesn't scale past a handful of servers. | Add a second key, test login with both, remove one, confirm revocation. |
| 39 | Permission edge cases with a security lens: world-writable directories, full sticky-bit treatment now that processes/users are understood together. | `find / -perm -002 -type f 2>/dev/null`, explain which results matter and why. |
| 40 | Secrets handling: why plaintext secrets in files/env vars are risky, `/proc/<pid>/environ` exposure. | Export a fake secret as an env var, read it back via `/proc/<pid>/environ` — genuinely eye-opening. **(Use only a fake/dummy secret — never a real one, for obvious reasons given recent experience.)** |
| 41 | Auditing basics: `last`, `who`, `w`, auth logs. | Review your own WSL login history. |
| 42 | **Review + synthesis.** **Cold-recall check: explain systemd's enabled-vs-running distinction again, unprompted — Week 2 content.** | Write a short "security model" paragraph connecting users/permissions/sudo/SSH — genuinely interview-relevant. |

---

## Week 7 — Commanding Linux: The Shell as a Real Tool

**The model:** The shell is a programming environment, not a command list.

| Day | Focus | Hands-on task |
|---|---|---|
| 43 | Shell fundamentals: variables, quoting (`"$var"` vs `$var`), command substitution, exit codes `$?`. | 10-line script checking a service's status by exit code. |
| 44 | Pipes/redirection as composition — stdin/stdout/stderr as file descriptors 0/1/2 (ties to Week 1's "everything is a file"). | Pipeline of 4+ commands solving a real problem; verify each stage independently first. |
| 45 | `grep`, `sed`, `awk` — regex basics, in-place editing, field processing. | Parse a real/sample log file: extract 5xx errors, count by IP, sort by frequency. |
| 46 | Loops/conditionals, functions, argument parsing (`$1`, `$@`, `getopts`). | Reusable script with flags (`--source`/`--dest` style). |
| 47 | `jq` for JSON, combined with `curl` from Week 5. | Pull a real API response, extract nested fields, reformat into a table. |
| 48 | Idempotency/safety: `set -euo pipefail`, trapping errors. | Harden Day 46's script — safe to re-run without side effects. |
| 49 | **Review + synthesis.** **Cold-recall check: explain the inode-survives-deletion behavior again, unprompted — Week 1, Day 2 content, now 7 weeks old.** | Capstone script: monitor a log, extract errors, summarize, alert. |

**Week 7 checkpoint:** Default to composing shell tools rather than searching "how to do X in bash."

---

## Week 8 — Configuration, Automation, "Infrastructure-as-Text"

| Day | Focus | Hands-on task |
|---|---|---|
| 50 | Env variable/config precedence (system vs user vs session vs process). | Demonstrate the full precedence chain, prove which level wins. |
| 51 | Config file formats (YAML/INI/conf-style); read a real nginx.conf or unit file structurally. | Minimal nginx config proxying to Day 31's test server. |
| 52 | Version control hygiene for infra-as-text: `.gitignore` and secrets (directly informed by your own recent GitHub token episode). | Structure your Week 7 scripts as a small repo with a proper README. |
| 53 | Dependency-pinning mental model; why "works on my machine" happens. | Reproduce a "works on my machine" failure deliberately, fix via explicit dependency versions. |
| 54 | Cross-distro awareness: `apk` vs `apt` vs `yum/dnf`, musl vs glibc briefly — critical since Docker base images vary. | Pull an Alpine container, notice missing tools vs Ubuntu, install what's needed. |
| 55 | Logging conventions, `logrotate` — directly building on the real rotation evidence you already saw in `/var/log` on Day 1. | Configure a logrotate rule, force rotation, confirm. |
| 56 | **Review + synthesis.** **Cold-recall check: explain the WSL-vs-real-Linux networking difference again, unprompted — Week 5 content.** | "How I'd configure a fresh Linux server for a small app" — Weeks 1-8 knowledge only. |

---

## Week 9 — Containers Are Just Linux Wearing a Costume

**The model:** Docker is namespaces + cgroups + a union filesystem — all concepts from Weeks 1, 3, 4.

| Day | Focus | Hands-on task |
|---|---|---|
| 57 | Namespaces/cgroups at full depth (Week 3, Day 19 callback), mapped explicitly to `docker run`. | Run a container, inspect its process from the host (`ps aux`) — find host PID vs in-container PID 1, proving namespaces are "just a view." |
| 58 | Docker images as layered filesystems — direct Week 1 inode/filesystem callback. | Build two Dockerfiles (good vs bad layer ordering), compare build cache and image sizes. |
| 59 | Dockerfile as structured shell script (`RUN`=shell, `COPY`=filesystem, `USER`=Week 6 identity, `EXPOSE`=Week 5 ports). | Write a Dockerfile from scratch for a Week 7 script, non-root `USER` applied deliberately. |
| 60 | Container networking: bridge networks as namespaces + virtual interfaces + NAT (Week 5 callback). | Two containers on a custom network, talking via name resolution — explain Docker's embedded DNS. |
| 61 | Volumes/bind mounts — direct Week 4 mount callback. | Demonstrate data loss without a volume vs persistence with one. |
| 62 | Resource limits (`--memory`, `--cpus`) — direct Week 3 cgroups callback. | Memory limit below what a process needs, watch OOM killer terminate it, read the exit code. |
| 63 | **Review + synthesis.** **Cold-recall check: explain the engine/config/state model (your own nginx breakdown from Day 1) again, unprompted.** | Explain `docker run`'s full lifecycle purely in namespaces/cgroups/layers terms — no Docker jargon allowed. |

**Week 9 checkpoint:** Containers should feel like "Linux process isolation with good tooling," not a separate technology.

---

## Week 10 — Orchestration & Cloud Are Linux at Scale

**The model:** Kubernetes nodes are Linux machines running container runtimes; cloud VMs are Linux with managed networking/storage layered on.

| Day | Focus | Hands-on task |
|---|---|---|
| 64 | Local Kubernetes (k3s/minikube/kind — lightest for WSL) as "many Week 9 containers, coordinated." | Single-node cluster, `kubectl exec` into a pod, run Week 1-3 diagnostic commands inside it — proving it's just Linux. |
| 65 | Pod lifecycle mapped to Week 3 signals — `terminationGracePeriodSeconds` is literally SIGTERM-to-SIGKILL timing. | Custom grace period, force delete, watch signal timing vs your Week 3, Day 16 experiment. |
| 66 | Pod networking/Services mapped to Week 5 — load-balanced DNS + iptables/IPVS under the hood. | Inspect iptables/ipvsadm rules a Service generates. |
| 67 | ConfigMaps/Secrets mapped to Week 8's precedence knowledge. | Mount a ConfigMap as both env var and file, connect to Day 50. |
| 68 | Resource requests/limits mapped to Week 9's cgroups exercise. | Pod memory limit too low, OOMKilled, cross-reference Week 9, Day 62 — same failure, two abstraction layers. |
| 69 | Cloud VM tie-in: security groups=Week 5 firewalls, IAM roles=Week 6 sudo/permissions thinking, EBS/managed disks=Week 4 block devices. | One cloud provider's free-tier docs, translate each major concept into the Linux term you already know. |
| 70 | **Final synthesis.** No new material. **Full cold-recall sweep: pick three random days from across all 10 weeks, explain each unprompted before doing the main task.** | Full narrative: "I deploy a containerized app from my laptop to a Kubernetes cluster running on cloud VMs," using only this plan's vocabulary, start to finish, no hand-waving. |

---

## How to know you've actually reached "comfortable intermediate"

On any unfamiliar Linux box, without panic: orient yourself in the filesystem, check what's running and why something stopped, read logs to find root cause, check network/port issues, write a short script to automate the fix — explaining *why*, not just *what*.

---

## Changelog — what changed from v1 and why

Based on Days 1-2 actually being executed, not just planned:
1. **Realistic pacing section added** — original plan didn't account for environment-setup/debugging friction eating real hours; 10-14 weeks is the honest range for a true beginner, not a hard 10.
2. **WSL-vs-real-Linux caveats added explicitly** at Weeks 2, 4, and 5 — these were silently assumed away in v1 and would have caused confusion when WSL's output didn't match a cloud-VM-focused explanation.
3. **Day 36 risk made an explicit decision point** instead of a buried parenthetical — hand-editing `/etc/passwd` carries real lockout risk and deserved a forced choice (backup vs disposable environment), not a suggestion easy to skip past.
4. **Spaced cold-recall checks added to every review day** — callbacks between weeks (e.g., Week 9 referencing Week 1) are necessary but not sufficient for retention; each review day now also tests something from 3+ weeks back, unprompted, before that week's own review content.
5. **Day 40's secrets exercise now explicitly says "use only a fake secret"** — added directly in response to the real near-miss with a live GitHub token during setup; the lesson is the same, the risk doesn't need to be real.
6. **Day 52 (git/infra-as-text hygiene) now explicitly references your own GitHub token episode** rather than a generic example — using your own real experience as the worked example, since it already happened and was instructive.