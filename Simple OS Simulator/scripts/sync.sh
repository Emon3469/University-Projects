#!/usr/bin/env bash

lockdir="/tmp/os_sim_lockdir"
counterfile="/tmp/os_sim_counter"

echo 0 > "$counterfile"

semaphore_wait() {
    while ! mkdir "$lockdir" 2>/dev/null; do
        sleep 0.01
    done
}

semaphore_signal() {
    rmdir "$lockdir" 2>/dev/null || true
}

worker() {
    id=$1

    for i in 1 2 3 4 5; do
        semaphore_wait
        val=$(cat "$counterfile")
        val=$((val + 1))
        echo $val > "$counterfile"
        echo "worker $id incremented to $val"
        semaphore_signal
        sleep 0.1
    done
}

worker 1 &
worker 2 &

wait

echo "final:" $(cat "$counterfile")
