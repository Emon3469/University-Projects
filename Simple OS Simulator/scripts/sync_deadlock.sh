#!/usr/bin/env bash

lockA="/tmp/os_sim_lockA"
lockB="/tmp/os_sim_lockB"
rm -rf "$lockA" "$lockB"

worker1() {
    echo "[Worker1] Acquiring lockA..."
    while ! mkdir "$lockA" 2>/dev/null; do
        sleep 0.1
    done
    echo "[Worker1] Acquired lockA"
    
    sleep 1
    
    echo "[Worker1] Waiting for lockB..."
    timeout=0
    while ! mkdir "$lockB" 2>/dev/null; do
        sleep 0.1
        timeout=$((timeout + 1))
        if [ $timeout -gt 20 ]; then
            echo "[Worker1] DEADLOCK DETECTED! Cannot acquire lockB (held by Worker2)"
            rmdir "$lockA" 2>/dev/null
            exit 1
        fi
    done
    echo "[Worker1] Acquired lockB"
    
    echo "[Worker1] Processing..."
    sleep 1
    
    rmdir "$lockB" 2>/dev/null
    rmdir "$lockA" 2>/dev/null
    echo "[Worker1] Released both locks"
}

worker2() {
    echo "[Worker2] Acquiring lockB..."
    while ! mkdir "$lockB" 2>/dev/null; do
        sleep 0.1
    done
    echo "[Worker2] Acquired lockB"
    
    sleep 1
    
    echo "[Worker2] Waiting for lockA..."
    timeout=0
    while ! mkdir "$lockA" 2>/dev/null; do
        sleep 0.1
        timeout=$((timeout + 1))
        if [ $timeout -gt 20 ]; then
            echo "[Worker2] DEADLOCK DETECTED! Cannot acquire lockA (held by Worker1)"
            rmdir "$lockB" 2>/dev/null
            exit 1
        fi
    done
    echo "[Worker2] Acquired lockA"
    
    echo "[Worker2] Processing..."
    sleep 1
    
    rmdir "$lockA" 2>/dev/null
    rmdir "$lockB" 2>/dev/null
    echo "[Worker2] Released both locks"
}

echo "=== Deadlock Detection Demo ==="
echo "Worker1 locks A then B"
echo "Worker2 locks B then A"
echo "This creates circular wait condition"
echo

worker1 &
w1=$!
worker2 &
w2=$!

wait $w1
wait $w2

echo
echo "=== Deadlock Demo Complete ==="
rm -rf "$lockA" "$lockB"
