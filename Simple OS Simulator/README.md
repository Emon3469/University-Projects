# Simple OS Simulator in Bash

A comprehensive Bash-based Operating System simulator demonstrating core OS concepts including CPU scheduling, memory management, page replacement algorithms, process synchronization, and deadlock detection.

## Features

### 1. CPU Scheduling Algorithms
- **FCFS** (First Come First Serve)
- **SJF** (Shortest Job First - Non-preemptive)
- **Round Robin** with configurable quantum
- **Priority Scheduling** (Non-preemptive)
- **Preemptive Priority Scheduling** (Advanced)

### 2. Memory Management
- **First Fit** allocation
- **Best Fit** allocation
- **Worst Fit** allocation
- **Fragmentation Analysis** (External fragmentation reporting)

### 3. Page Replacement Algorithms
- **FIFO** (First In First Out)
- **LRU** (Least Recently Used)
- **LFU** (Least Frequently Used)
- **Thrashing Detection** (Automatic warning for high page fault rates)

### 4. Synchronization
- **Semaphore-based synchronization** with worker threads
- **Deadlock Detection Demo** (Circular wait demonstration)

## Requirements

- Bash 4.0 or higher
- `bc` calculator (for floating-point arithmetic)
- Unix-like environment (Linux, macOS, WSL, or Git Bash on Windows)

## Project Structure

```
Simple OS Simulator/
├── run.sh                          # Main menu interface
├── scripts/
│   ├── scheduler.sh                # CPU scheduling algorithms
│   ├── memory.sh                   # Memory allocation algorithms
│   ├── paging.sh                   # Page replacement algorithms
│   ├── sync.sh                     # Synchronization demo
│   └── sync_deadlock.sh           # Deadlock detection demo
├── data/
│   ├── processes.csv               # Process data for scheduling
│   ├── process_sizes.txt          # Process sizes for memory allocation
│   ├── reference.txt              # Page reference string
│   └── thrashing.txt              # Large working set for thrashing demo
├── check-env.ps1                  # PowerShell environment checker
└── README.md                       # This file
```

## Installation & Usage

### On Linux/macOS:
```bash
cd "Simple OS Simulator"
chmod +x run.sh scripts/*.sh
./run.sh
```

### On Windows (Git Bash):
```bash
cd "Simple OS Simulator"
bash run.sh
```

### On Windows (WSL):
```bash
cd "/mnt/c/Users/User/Desktop/Simple OS Simulator"
chmod +x run.sh scripts/*.sh
./run.sh
```

## Test Cases with Expected Outputs

### Test 1: CPU Scheduling - FCFS

**Input:**
- Select option: `1` (CPU Scheduling)
- Select algorithm: `1` (FCFS)
- Uses data from `data/processes.csv`:
```
P1,0,5,2
P2,1,3,1
P3,2,8,4
P4,3,6,3
```

**Expected Output:**
```
FCFS Scheduling
PID,Arrival,Completion,TAT,Waiting
P1,0,5,5,0
P2,1,8,7,4
P3,2,16,14,6
P4,3,22,19,13
Avg Turnaround=11.25 Avg Waiting=5.75
```

---

### Test 2: CPU Scheduling - SJF

**Input:**
- Select option: `1` (CPU Scheduling)
- Select algorithm: `2` (SJF)
- Uses same `data/processes.csv`

**Expected Output:**
```
SJF Scheduling
PID,Arrival,Completion,TAT,Waiting
P1,0,5,5,0
P2,1,8,7,4
P4,3,14,11,5
P3,2,22,20,12
Avg Turnaround=10.75 Avg Waiting=5.25
```

---

### Test 3: CPU Scheduling - Round Robin

**Input:**
- Select option: `1` (CPU Scheduling)
- Select algorithm: `3` (Round Robin)
- Enter quantum: `2`
- Uses same `data/processes.csv`

**Expected Output:**
```
Round Robin (quantum=2)
P1 completed at 13
P2 completed at 8
P3 completed at 22
P4 completed at 18
```

---

### Test 4: CPU Scheduling - Priority (Non-preemptive)

**Input:**
- Select option: `1` (CPU Scheduling)
- Select algorithm: `4` (Priority)
- Uses same `data/processes.csv` (lower number = higher priority)

**Expected Output:**
```
Priority Scheduling (non-preemptive)
PID,Arrival,Completion,TAT,Waiting
P1,0,5,5,0
P2,1,8,7,4
P4,3,14,11,5
P3,2,22,20,12
Avg Turnaround=10.75 Avg Waiting=5.25
```

---

### Test 5: CPU Scheduling - Preemptive Priority (Advanced)

**Input:**
- Select option: `1` (CPU Scheduling)
- Select algorithm: `5` (Preemptive Priority)
- Uses same `data/processes.csv`

**Expected Output:**
```
Preemptive Priority Scheduling (lower number = higher priority)
P2 completed at 4
P1 completed at 10
P4 completed at 16
P3 completed at 24
PID,Arrival,Completion,TAT,Waiting
P1,0,10,10,5
P2,1,4,3,0
P3,2,24,22,14
P4,3,16,13,7
Avg Turnaround=12.00 Avg Waiting=6.50
```

---

### Test 6: Memory Management - First Fit

**Input:**
- Select option: `2` (Memory Allocation)
- Select algorithm: `1` (First Fit)
- Uses data from `data/process_sizes.txt`:
```
P1 10
P2 20
P3 5
P4 30
P5 15
```

**Expected Output:**
```
First-fit allocations:
P1 -> 0:10
P2 -> 10:20
P3 -> 30:5
P4 -> 35:30
P5 -> 65:15
External Fragmentation: 20 units
```

---

### Test 7: Memory Management - Best Fit

**Input:**
- Select option: `2` (Memory Allocation)
- Select algorithm: `2` (Best Fit)
- Uses same `data/process_sizes.txt`

**Expected Output:**
```
Best-fit allocations:
P1 -> 0:10
P2 -> 10:20
P3 -> 30:5
P4 -> 35:30
P5 -> 65:15
External Fragmentation: 20 units
```

---

### Test 8: Memory Management - Worst Fit

**Input:**
- Select option: `2` (Memory Allocation)
- Select algorithm: `3` (Worst Fit)
- Uses same `data/process_sizes.txt`

**Expected Output:**
```
Worst-fit allocations:
P1 -> 0:10
P2 -> 10:20
P3 -> 30:5
P4 -> 35:30
P5 -> 65:15
External Fragmentation: 20 units
```

---

### Test 9: Page Replacement - FIFO

**Input:**
- Select option: `3` (Page Replacement)
- Select algorithm: `1` (FIFO)
- Enter frames: `3`
- Uses data from `data/reference.txt`:
```
7 0 1 2 0 3 0 4 2 3 0 3 2
```

**Expected Output:**
```
FIFO misses=9 hits=4 hit_rate=30.77%
WARNING: Thrashing detected! Page fault rate is 9/13 (>70%)
```

---

### Test 10: Page Replacement - LRU

**Input:**
- Select option: `3` (Page Replacement)
- Select algorithm: `2` (LRU)
- Enter frames: `3`
- Uses same `data/reference.txt`

**Expected Output:**
```
LRU misses=9 hits=4 hit_rate=30.77%
WARNING: Thrashing detected! Page fault rate is 9/13 (>70%)
```

---

### Test 11: Page Replacement - LFU

**Input:**
- Select option: `3` (Page Replacement)
- Select algorithm: `3` (LFU)
- Enter frames: `3`
- Uses same `data/reference.txt`

**Expected Output:**
```
LFU misses=9 hits=4 hit_rate=30.77%
WARNING: Thrashing detected! Page fault rate is 9/13 (>70%)
```

---

### Test 12: Page Replacement - FIFO with More Frames (No Thrashing)

**Input:**
- Select option: `3` (Page Replacement)
- Select algorithm: `1` (FIFO)
- Enter frames: `7`
- Uses same `data/reference.txt`

**Expected Output:**
```
FIFO misses=7 hits=6 hit_rate=46.15%
```
(No thrashing warning as page fault rate is <70%)

---

### Test 13: Synchronization Demo

**Input:**
- Select option: `4` (Synchronization / Thread Demo)

**Expected Output:**
```
Semaphore Demo with Workers
[Worker1] inc counter 0 -> 1
[Worker2] inc counter 1 -> 2
[Worker1] inc counter 2 -> 3
[Worker2] inc counter 3 -> 4
[Worker1] inc counter 4 -> 5
[Worker2] inc counter 5 -> 6
[Worker1] inc counter 6 -> 7
[Worker2] inc counter 7 -> 8
[Worker1] inc counter 8 -> 9
[Worker2] inc counter 9 -> 10
Final counter=10
```

---

### Test 14: Deadlock Detection Demo

**Input:**
- Select option: `5` (Deadlock Detection Demo)

**Expected Output:**
```
=== Deadlock Detection Demo ===
Worker1 locks A then B
Worker2 locks B then A
This creates circular wait condition

[Worker1] Acquiring lockA...
[Worker2] Acquiring lockB...
[Worker1] Acquired lockA
[Worker2] Acquired lockB
[Worker1] Waiting for lockB...
[Worker2] Waiting for lockA...
[Worker1] DEADLOCK DETECTED! Cannot acquire lockB (held by Worker2)
[Worker2] DEADLOCK DETECTED! Cannot acquire lockA (held by Worker1)

=== Deadlock Demo Complete ===
```

---

### Test 15: Thrashing Demonstration with Large Working Set

**Input:**
1. Manually test with `data/thrashing.txt`:
```bash
bash scripts/paging.sh data/thrashing.txt
```
2. Select algorithm: `1` (FIFO)
3. Enter frames: `3`

The file `data/thrashing.txt` contains:
```
1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 1 2 3 4 5 6 7 8 9 10
```

**Expected Output:**
```
FIFO misses=23 hits=2 hit_rate=8.00%
WARNING: Thrashing detected! Page fault rate is 23/25 (>92%)
```

---

## Understanding the Outputs

### CPU Scheduling Metrics:
- **TAT (Turnaround Time)** = Completion Time - Arrival Time
- **Waiting Time** = Turnaround Time - Burst Time
- **Average Turnaround Time** = Sum of all TAT / Number of processes
- **Average Waiting Time** = Sum of all Waiting Times / Number of processes

### Memory Management:
- **Allocation format**: `ProcessID -> offset:length`
- **External Fragmentation**: Total unused memory in holes (cannot be allocated due to fragmentation)

### Page Replacement:
- **Misses**: Number of page faults (page not in frame)
- **Hits**: Number of times page was found in frame
- **Hit Rate**: (Hits / Total References) × 100
- **Thrashing Warning**: Triggered when miss rate > 70%

### Synchronization:
- Demonstrates mutual exclusion using semaphores
- Shows atomic increment operations with critical sections

### Deadlock Detection:
- Demonstrates circular wait condition
- Shows timeout-based deadlock detection mechanism

## Advanced Features

### 1. Preemptive Priority Scheduling
Unlike the basic priority algorithm, this version interrupts a running process when a higher-priority process arrives, providing more realistic scheduling behavior.

### 2. Fragmentation Analysis
After each memory allocation run, the simulator calculates and displays external fragmentation, helping understand memory waste.

### 3. Thrashing Detection
The system automatically detects when page fault rates exceed 70%, indicating insufficient physical memory for the working set.

### 4. Deadlock Detection
Demonstrates the classic dining philosophers-style circular wait problem with automatic timeout-based detection.

## Troubleshooting

### "command not found: bc"
Install bc calculator:
- Ubuntu/Debian: `sudo apt-get install bc`
- macOS: `brew install bc`
- Fedora: `sudo dnf install bc`

### Permission Denied
Make scripts executable:
```bash
chmod +x run.sh scripts/*.sh
```

### "Bad substitution" or syntax errors
Ensure you're using Bash 4.0+:
```bash
bash --version
```

### Windows Users
- Use Git Bash or WSL (Windows Subsystem for Linux)
- PowerShell/CMD cannot run Bash scripts directly
- Run `check-env.ps1` to verify your environment

## Educational Value

This simulator is designed for:
- Operating Systems course lab assignments
- Understanding CPU scheduling trade-offs
- Learning memory management techniques
- Studying page replacement algorithms
- Demonstrating synchronization primitives
- Analyzing deadlock scenarios

## License

Educational use only.

## Author

Created as an educational tool for understanding operating system concepts through hands-on simulation.
