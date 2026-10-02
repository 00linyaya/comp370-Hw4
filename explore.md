# HW4 Exploration: My Little Pony Dialog

All commands were run from the repository root on an Ubuntu EC2 instance, with the dataset at `data/clean_dialog.csv`.

## How big is the dataset?

- `ls -lh data/clean_dialog.csv` → 4.7 MB (about 2 MB as a zip on Kaggle)
- `wc -l data/clean_dialog.csv` → 36860 lines
- `csvtool height data/clean_dialog.csv` → 36860 rows, including the header, so 36859 dialog lines
- `csvtool width data/clean_dialog.csv` → 4 columns

`wc -l` and `csvtool height` agree, so no dialog field contains an embedded newline.

## What is the structure of the data?

Commands:
- `head -n 5 data/clean_dialog.csv`
- `csvtool head 6 data/clean_dialog.csv | csvtool readable -`

Fields (every value is wrapped in double quotes):

| Field | Description | Example |
|---|---|---|
| title | Episode title | "Friendship is Magic, part 1" |
| writer | Episode writer | "Lauren Faust" |
| pony | Speaker of the line | "Twilight Sparkle", "Narrator" |
| dialog | The spoken line | "...sun and moon..." |

Titles and dialog contain commas, so a naive `cut -d, -f1` breaks fields apart. csvtool parses the quoting correctly.

## How many episodes does it cover?

- `csvtool col 1 data/clean_dialog.csv | tail -n +2 | sort -u | wc -l` → 197 episodes

## Unexpected aspects

Commands:
- `csvtool col 3 data/clean_dialog.csv | tail -n +2 | sort -u | wc -l` → 842 distinct speakers
- `csvtool col 3 data/clean_dialog.csv | tail -n +2 | grep " and " | sort | uniq -c | sort -rn | head -n 10`
- `csvtool col 3 data/clean_dialog.csv | tail -n +2 | grep -i "twilight" | sort | uniq -c | sort -rn`
- `csvtool col 1 data/clean_dialog.csv | tail -n +2 | sort | uniq -c | sort -n | head -n 10`

1. **Multi-speaker lines.** The `pony` field can list several speakers (e.g. "Fluttershy and Rainbow Dash"), so it is unclear whom to credit.
2. **Exclusion labels.** Entries such as "All sans Twilight Sparkle", "Ponies except Twilight Sparkle" and "Everyone but Twilight" contain her name but mean she did *not* speak. A substring search would count them for her.
3. **Inconsistent naming.** The same character appears as "Twilight", "Young Twilight Sparkle", "Future Twilight Sparkle", etc., while "Twilight Velvet" is a different character who also matches "twilight".
4. **Missing episodes.** Only 197 titles, fewer than the ~221 episodes of the show. Every episode has at least 109 lines, so whole episodes are missing rather than partially transcribed.

## Speaker frequency (Task 4)

Script: `scripts/line_percentages.sh`, which produces `Line_percentages.csv`.

Each count uses an exact match on the speaker column:

    csvtool col 3 data/clean_dialog.csv | grep -cx "Twilight Sparkle"

**Why exact matching (`grep -x`):** a substring match (`grep -c "Twilight Sparkle"`) returns 4831 instead of 4745. The 86 extra lines include exclusion labels ("All sans Twilight Sparkle") and multi-speaker lines, which should not be credited to her alone. Exact matching slightly undercounts (e.g. "Young Twilight Sparkle" is excluded), but it is consistent and reproducible.

The denominator is all 36859 dialog lines (header excluded), across all characters. `percent_all_lines` is a percentage (12.87 means 12.87%).

| pony_name | total_line_count | percent_all_lines |
|---|---|---|
| Twilight Sparkle | 4745 | 12.87 |
| Rarity | 2660 | 7.22 |
| Pinkie Pie | 2833 | 7.69 |
| Rainbow Dash | 3072 | 8.33 |
| Fluttershy | 2109 | 5.72 |
