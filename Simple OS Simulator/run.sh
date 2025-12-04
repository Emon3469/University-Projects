#!/usr/bin/env bash

DIR=$(dirname "$0")

PSV="$DIR/data/processes.csv"
MSZ="$DIR/data/process_sizes.txt"
REF="$DIR/data/reference.txt"

while true; do
  echo "Simple OS Simulator"
  echo "1) CPU Scheduling"
  echo "2) Memory Allocation"
  echo "3) Page Replacement"
  echo "4) Synchronization / Thread Demo"
  echo "5) Deadlock Detection Demo"
  echo "6) Exit"

  read -p "Choice: " c

  case "$c" in
    1)
      bash "$DIR/scripts/scheduler.sh" "$PSV"
      ;;
    2)
      bash "$DIR/scripts/memory.sh" "$MSZ"
      ;;
    3)
      bash "$DIR/scripts/paging.sh" "$REF"
      ;;
    4)
      bash "$DIR/scripts/sync.sh"
      ;;
    5)
      bash "$DIR/scripts/sync_deadlock.sh"
      ;;
    6)
      exit 0
      ;;
    *)
      echo "invalid"
      ;;
  esac

  echo
done
