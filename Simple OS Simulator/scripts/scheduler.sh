#!/usr/bin/env bash

# input CSV file with lines: pid,arrival,burst,priority
file=${1:-"$(dirname "$0")/../data/processes.csv"}

IFS=$'\n'
mapfile -t LINES < <(tail -n +1 "$file" | sed '/^$/d')

fcfs() {
  mapfile -t S < <(printf "%s\n" "${LINES[@]}" | sort -t, -k2n)

  t=0
  sumw=0
  sumt=0

  printf "PID,A,B,C,TAT,W\n"

  for ln in "${S[@]}"; do
    pid=$(echo "$ln" | cut -d',' -f1)
    a=$(echo "$ln" | cut -d',' -f2)
    b=$(echo "$ln" | cut -d',' -f3)

    if [ "$t" -lt "$a" ]; then
      t=$a
    fi

    c=$((t + b))
    tat=$((c - a))
    w=$((tat - b))
    t=$c

    sumw=$((sumw + w))
    sumt=$((sumt + tat))

    printf "%s,%s,%s,%s,%s,%s\n" "$pid" "$a" "$b" "$c" "$tat" "$w"
  done

  n=${#S[@]}
  printf "Avg Turnaround=%.2f Avg Waiting=%.2f\n" $(echo "$sumt/$n" | bc -l) $(echo "$sumw/$n" | bc -l)
}

sjf() {
  mapfile -t REM < <(printf "%s\n" "${LINES[@]}")
  t=0
  out=()

  while [ ${#REM[@]} -gt 0 ]; do
    avail=()

    for i in "${!REM[@]}"; do
      a=$(echo "${REM[$i]}" | cut -d',' -f2)
      if [ $a -le $t ]; then
        avail+=("$i")
      fi
    done

    if [ ${#avail[@]} -eq 0 ]; then
      a=$(echo "${REM[0]}" | cut -d',' -f2)
      t=$a
      continue
    fi

    best=-1
    bmin=999999

    for idx in "${avail[@]}"; do
      burst=$(echo "${REM[$idx]}" | cut -d',' -f3)
      if [ $burst -lt $bmin ]; then
        bmin=$burst
        best=$idx
      fi
    done

    ln=${REM[$best]}
    pid=$(echo "$ln" | cut -d',' -f1)
    a=$(echo "$ln" | cut -d',' -f2)
    b=$(echo "$ln" | cut -d',' -f3)

    c=$((t + b))
    out+=("$pid,$a,$b,$c")
    t=$c

    unset 'REM[$best]'
    REM=("${REM[@]}")
  done

  sumw=0
  sumt=0
  n=${#out[@]}

  printf "PID,A,B,C,TAT,W\n"
  for ln in "${out[@]}"; do
    pid=$(echo "$ln" | cut -d',' -f1)
    a=$(echo "$ln" | cut -d',' -f2)
    b=$(echo "$ln" | cut -d',' -f3)
    c=$(echo "$ln" | cut -d',' -f4)

    tat=$((c - a))
    w=$((tat - b))
    sumt=$((sumt + tat))
    sumw=$((sumw + w))

    printf "%s,%s,%s,%s,%s,%s\n" "$pid" "$a" "$b" "$c" "$tat" "$w"
  done

  printf "Avg Turnaround=%.2f Avg Waiting=%.2f\n" $(echo "$sumt/$n" | bc -l) $(echo "$sumw/$n" | bc -l)
}

rr() {
  q=${2:-2}

  mapfile -t Q < <(printf "%s\n" "${LINES[@]}" | awk -F, '{print $1","$2","$3","$4}' | sort -t, -k2n)

  declare -A rem
  for ln in "${Q[@]}"; do
    pid=$(echo "$ln" | cut -d',' -f1)
    rem[$pid]=$(echo "$ln" | cut -d',' -f3)
  done

  t=0
  queue=()
  mapfile -t ARR < <(printf "%s\n" "${Q[@]}")

  while true; do
    for ln in "${ARR[@]}"; do
      pid=$(echo "$ln" | cut -d',' -f1)
      a=$(echo "$ln" | cut -d',' -f2)

      if [ $a -le $t ]; then
        if [[ ! " ${queue[*]} " =~ " $pid " ]]; then
          queue+=("$pid")
        fi
      fi
    done

    if [ ${#queue[@]} -eq 0 ]; then
      anyleft=0
      for v in "${!rem[@]}"; do
        anyleft=1
        break
      done

      if [ $anyleft -eq 0 ]; then
        break
      fi

      t=$((t + 1))
      continue
    fi

    cur=${queue[0]}
    burst=${rem[$cur]}
    use=$(( burst < q ? burst : q ))
    burst=$((burst - use))
    rem[$cur]=$burst
    t=$((t + use))

    if [ ${rem[$cur]} -le 0 ]; then
      unset rem[$cur]
      queue=("${queue[@]:1}")
      echo "$cur finished at $t"
    else
      queue=("${queue[@]:1}" "$cur")
    fi
  done
}

priority() {
  mapfile -t REM < <(printf "%s\n" "${LINES[@]}")
  t=0
  out=()

  while [ ${#REM[@]} -gt 0 ]; do
    avail=()

    for i in "${!REM[@]}"; do
      a=$(echo "${REM[$i]}" | cut -d',' -f2)
      if [ $a -le $t ]; then
        avail+=("$i")
      fi
    done

    if [ ${#avail[@]} -eq 0 ]; then
      a=$(echo "${REM[0]}" | cut -d',' -f2)
      t=$a
      continue
    fi

    best=-1
    pmin=999999
    for idx in "${avail[@]}"; do
      pr=$(echo "${REM[$idx]}" | cut -d',' -f4)
      if [ $pr -lt $pmin ]; then
        pmin=$pr
        best=$idx
      fi
    done

    ln=${REM[$best]}
    pid=$(echo "$ln" | cut -d',' -f1)
    a=$(echo "$ln" | cut -d',' -f2)
    b=$(echo "$ln" | cut -d',' -f3)
    c=$((t + b))
    out+=("$pid,$a,$b,$c")
    t=$c

    unset 'REM[$best]'
    REM=("${REM[@]}")
  done

  sumw=0
  sumt=0
  n=${#out[@]}

  printf "PID,A,B,C,TAT,W\n"
  for ln in "${out[@]}"; do
    pid=$(echo "$ln" | cut -d',' -f1)
    a=$(echo "$ln" | cut -d',' -f2)
    b=$(echo "$ln" | cut -d',' -f3)
    c=$(echo "$ln" | cut -d',' -f4)

    tat=$((c - a))
    w=$((tat - b))
    sumt=$((sumt + tat))
    sumw=$((sumw + w))

    printf "%s,%s,%s,%s,%s,%s\n" "$pid" "$a" "$b" "$c" "$tat" "$w"
  done

  printf "Avg Turnaround=%.2f Avg Waiting=%.2f\n" $(echo "$sumt/$n" | bc -l) $(echo "$sumw/$n" | bc -l)
}

preemptive_priority() {
    mapfile -t ALL < <(printf "%s\n" "${LINES[@]}")
    declare -A rem
    declare -A arr
    declare -A prio
    
    for ln in "${ALL[@]}"; do
        pid=$(echo "$ln" | cut -d',' -f1)
        a=$(echo "$ln" | cut -d',' -f2)
        b=$(echo "$ln" | cut -d',' -f3)
        p=$(echo "$ln" | cut -d',' -f4)
        rem[$pid]=$b
        arr[$pid]=$a
        prio[$pid]=$p
    done

    t=0
    declare -A completion
    echo "Preemptive Priority Scheduling (lower number = higher priority)"

    while [ ${#rem[@]} -gt 0 ]; do
        avail=()
        for pid in "${!rem[@]}"; do
            if [ ${arr[$pid]} -le $t ]; then
                avail+=("$pid")
            fi
        done

        if [ ${#avail[@]} -eq 0 ]; then
            t=$((t + 1))
            continue
        fi

        best=""
        bprio=999999
        for pid in "${avail[@]}"; do
            if [ ${prio[$pid]} -lt $bprio ]; then
                bprio=${prio[$pid]}
                best=$pid
            fi
        done

        rem[$best]=$((rem[$best] - 1))
        t=$((t + 1))

        if [ ${rem[$best]} -le 0 ]; then
            completion[$best]=$t
            unset rem[$best]
            echo "$best completed at time $t"
        fi
    done

    echo
    sumw=0
    sumt=0
    n=0
    printf "PID,Arrival,Completion,TAT,Waiting\n"
    for ln in "${ALL[@]}"; do
        pid=$(echo "$ln" | cut -d',' -f1)
        a=${arr[$pid]}
        c=${completion[$pid]}
        tat=$((c - a))
        b=$(echo "$ln" | cut -d',' -f3)
        w=$((tat - b))
        sumt=$((sumt + tat))
        sumw=$((sumw + w))
        n=$((n + 1))
        printf "%s,%s,%s,%s,%s\n" "$pid" "$a" "$c" "$tat" "$w"
    done
    printf "Avg Turnaround=%.2f Avg Waiting=%.2f\n" $(echo "$sumt/$n" | bc -l) $(echo "$sumw/$n" | bc -l)
}

echo "Algorithms: 1=FCFS 2=SJF 3=RR 4=PRIORITY 5=PREEMPTIVE_PRIORITY"
read -p "choice: " ch

case $ch in
    1)
        fcfs
        ;;
    2)
        sjf
        ;;
    3)
        read -p "quantum: " q
        rr "$file" "$q"
        ;;
    4)
        priority
        ;;
    5)
        preemptive_priority
        ;;
    *)
        echo "bad choice"
        ;;
esac