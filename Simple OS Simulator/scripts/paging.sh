#!/usr/bin/env bash
file=${1:-"$(dirname "$0")/../data/reference.txt"}
ref=($(tr -s ' \n' ' ' < "$file"))
frames=${2:-3}
fifo(){
  #!/usr/bin/env bash

  file=${1:-"$(dirname "$0")/../data/reference.txt"}
  ref=( $(tr -s ' \n' ' ' < "$file") )
  frames=${2:-3}

  fifo() {
    declare -a F
    misses=0
    head=0

    for r in "${ref[@]}"; do
      found=0
      for v in "${F[@]}"; do
        if [ "$v" = "$r" ]; then
          found=1
          break
        fi
      done

      if [ $found -eq 0 ]; then
        misses=$((misses + 1))
        F[$head]=$r
        head=$(((head + 1) % frames))
      fi
    done

    total=${#ref[@]}
    hit_rate=$(echo "scale=2; (($total - $misses) * 100) / $total" | bc)
    echo "FIFO misses=$misses hits=$((total - misses)) hit_rate=${hit_rate}%"
    
    if [ $misses -gt $((total * 70 / 100)) ]; then
        echo "WARNING: Thrashing detected! Page fault rate is ${misses}/${total} (>70%)"
    fi
}  lru() {
    declare -A last
    declare -a F
    misses=0
    t=0

    for r in "${ref[@]}"; do
      if [[ " ${F[*]} " =~ " $r " ]]; then
        last[$r]=$t
      else
        misses=$((misses + 1))

        if [ ${#F[@]} -lt $frames ]; then
          F+=("$r")
          last[$r]=$t
        else
          oldest=""
          oldt=999999
          for v in "${F[@]}"; do
            if [ ${last[$v]} -lt $oldt ]; then
              oldt=${last[$v]}
              oldest=$v
            fi
          done

          for i in "${!F[@]}"; do
            if [ "${F[$i]}" = "$oldest" ]; then
              F[$i]="$r"
              break
            fi
          done

          last[$r]=$t
        fi
      fi

      t=$((t + 1))
    done

    total=${#ref[@]}
    hit_rate=$(echo "scale=2; (($total - $misses) * 100) / $total" | bc)
    echo "LRU misses=$misses hits=$((total - misses)) hit_rate=${hit_rate}%"
    
    if [ $misses -gt $((total * 70 / 100)) ]; then
        echo "WARNING: Thrashing detected! Page fault rate is ${misses}/${total} (>70%)"
    fi
}  lfu() {
    declare -A cnt
    declare -a F
    misses=0

    for r in "${ref[@]}"; do
      if [[ " ${F[*]} " =~ " $r " ]]; then
        cnt[$r]=$((cnt[$r] + 1))
      else
        misses=$((misses + 1))

        if [ ${#F[@]} -lt $frames ]; then
          F+=("$r")
          cnt[$r]=1
        else
          least=""
          min=999999
          for v in "${F[@]}"; do
            if [ ${cnt[$v]} -lt $min ]; then
              min=${cnt[$v]}
              least=$v
            fi
          done

          for i in "${!F[@]}"; do
            if [ "${F[$i]}" = "$least" ]; then
              F[$i]="$r"
              break
            fi
          done

          cnt[$r]=1
        fi
      fi
    done

    total=${#ref[@]}
    hit_rate=$(echo "scale=2; (($total - $misses) * 100) / $total" | bc)
    echo "LFU misses=$misses hits=$((total - misses)) hit_rate=${hit_rate}%"
    
    if [ $misses -gt $((total * 70 / 100)) ]; then
        echo "WARNING: Thrashing detected! Page fault rate is ${misses}/${total} (>70%)"
    fi
}  echo "Frames default=$frames"
  echo "1) FIFO 2) LRU 3) LFU"
  read -p "choice: " ch

  case $ch in
    1)
      fifo
      ;;
    2)
      lru
      ;;
    3)
      lfu
      ;;
    *)
      echo "bad"
      ;;
  esac
