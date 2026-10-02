#!/bin/bash
f=data/clean_dialog.csv
total=$(( $(csvtool height "$f") - 1 ))
echo "pony_name,total_line_count,percent_all_lines" > Line_percentages.csv
for p in "Twilight Sparkle" "Rarity" "Pinkie Pie" "Rainbow Dash" "Fluttershy"; do
  c=$(csvtool col 3 "$f" | grep -cx "$p")
  pct=$(awk -v c="$c" -v t="$total" 'BEGIN{printf "%.2f", c/t*100}')
  echo "$p,$c,$pct" >> Line_percentages.csv
done
