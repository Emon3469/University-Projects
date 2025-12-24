#!/usr/bin/env bash

file=${1:-"$(dirname "$0")/../data/process_sizes.txt"}

mapfile -t L < <(sed '/^$/d' "$file")

memsize=100

declare -A alloc

first_fit() {
  holes=("0:${memsize}")

  for ln in "${L[@]}"; do
    p=$(echo "$ln" | awk '{print $1}')
    size=$(echo "$ln" | awk '{print $2}')
    placed=0

    for i in "${!holes[@]}"; do
      h=${holes[$i]}
      off=${h%%:*}
      len=${h##*:}

      if [ $len -ge $size ]; then
        alloc[$p]="${off},${size}"
        off2=$((off + size))
        len2=$((len - size))

        if [ $len2 -gt 0 ]; then
          holes[$i]="${off2}:${len2}"
        else
          unset 'holes[$i]'
        fi

        placed=1
        break
      fi
    done
  done

    echo "First-fit allocations:"
    for k in "${!alloc[@]}"; do
        echo "$k -> ${alloc[$k]}"
    done

    ext_frag=0
    for i in "${!holes[@]}"; do
        h=${holes[$i]}
        len=${h##*:}
        ext_frag=$((ext_frag + len))
    done
    echo "External Fragmentation: ${ext_frag} units"
}

best_fit() {
  holes=("0:${memsize}")
  alloc=()

  for ln in "${L[@]}"; do
    p=$(echo "$ln" | awk '{print $1}')
    size=$(echo "$ln" | awk '{print $2}')
    best=-1
    bsize=999999

    for i in "${!holes[@]}"; do
      h=${holes[$i]}
      off=${h%%:*}
      len=${h##*:}

      if [ $len -ge $size ] && [ $len -lt $bsize ]; then
        bsize=$len
        best=$i
      fi
    done

    if [ $best -ge 0 ]; then
      h=${holes[$best]}
      off=${h%%:*}
      len=${h##*:}
      alloc[$p]="${off},${size}"
      off2=$((off + size))
      len2=$((len - size))

      if [ $len2 -gt 0 ]; then
        holes[$best]="${off2}:${len2}"
      else
        unset 'holes[$best]'
      fi
    fi
  done

    echo "Best-fit allocations:"
    for k in "${!alloc[@]}"; do
        echo "$k -> ${alloc[$k]}"
    done

    ext_frag=0
    for i in "${!holes[@]}"; do
        h=${holes[$i]}
        len=${h##*:}
        ext_frag=$((ext_frag + len))
    done
    echo "External Fragmentation: ${ext_frag} units"
}

worst_fit() {
  holes=("0:${memsize}")
  alloc=()

  for ln in "${L[@]}"; do
    p=$(echo "$ln" | awk '{print $1}')
    size=$(echo "$ln" | awk '{print $2}')
    best=-1
    bsize=-1

    for i in "${!holes[@]}"; do
      h=${holes[$i]}
      off=${h%%:*}
      len=${h##*:}

      if [ $len -ge $size ] && [ $len -gt $bsize ]; then
        bsize=$len
        best=$i
      fi
    done

    if [ $best -ge 0 ]; then
      h=${holes[$best]}
      off=${h%%:*}
      len=${h##*:}
      alloc[$p]="${off},${size}"
      off2=$((off + size))
      len2=$((len - size))

      if [ $len2 -gt 0 ]; then
        holes[$best]="${off2}:${len2}"
      else
        unset 'holes[$best]'
      fi
    fi
  done

    echo "Worst-fit allocations:"
    for k in "${!alloc[@]}"; do
        echo "$k -> ${alloc[$k]}"
    done

    ext_frag=0
    for i in "${!holes[@]}"; do
        h=${holes[$i]}
        len=${h##*:}
        ext_frag=$((ext_frag + len))
    done
    echo "External Fragmentation: ${ext_frag} units"
}

echo "1) First-fit 2) Best-fit 3) Worst-fit"
read -p "choice: " c

case $c in
  1)
    first_fit
    ;;
  2)
    best_fit
    ;;
  3)
    worst_fit
    ;;
  *)
    echo "bad"
    ;;
esac
