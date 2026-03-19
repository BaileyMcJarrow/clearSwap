# clearSwap 🛡️

clearSwap is a lightweight Linux daemon designed to mitigate disk thrashing on machines with limited RAM. 

When an older machine runs out of RAM, it relies heavily on Swap space. However, heavy Swap usage can lead to disk thrashing, severely degrading system responsiveness. clearSwap monitors memory pressure and intelligently cycles the swap space (moving active pages back into RAM) *only* when it is mathematically safe to do so.

## Features
* **Automated Monitoring:** Runs continuously as a lightweight `systemd` service.
* **OOM-Safe:** Will not attempt to clear swap if the data exceeds currently available RAM.
* **Configurable Thresholds:** Easily tune the sensitivity via `/etc/clearSwap.conf`.

## Installation
### Where to move files
* **clearSwap.conf:** /etc - `sudo mv clearSwap.conf /etc`
* **clearSwap.sh:** /usr/local/bin - `sudo mv clearSwap.sh /usr/local/bin`
* **clearSwap.service:** /etc/systemd/system - `sudo mv clearSwap.service /etc/systemd/system`

### How to initialise system
* Make clearSwap.sh executable: `sudo chmod +x /usr/local/bin/clearSwap.sh`
* Reload systemd to see the new file: `sudo systemctl daemon-reload`
* Enable it to start on boot: `sudo systemctl enable clearSwap`
* Start it right now: `sudo systemctl start clearSwap`
* Check its logs: `sudo journalctl -u clearSwap -f`

### Editing of files
* To edit the .conf file use `sudo nano /etc/clearSwap.conf` to open up nano.
* After making your edits run `ctrl+o`, `Enter`, `ctrl+x` to save and exit.
* Then restart the daemon with ``sudo systemctl restart clearSwap``

## How it Works
The daemon utilizes `free -m` and `awk` to poll system memory states. If Swap usage exceeds the configured threshold (default 60%), it calculates the `MemAvailable`. If `MemAvailable > SwapUsed + Buffer`, it executes a safe `swapoff -a && swapon -a` to pull pages back into physical memory, restoring system responsiveness.