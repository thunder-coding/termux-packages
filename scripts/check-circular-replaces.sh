#!/usr/bin/env bash

set -euo pipefail

usage() {
echo "Usage: $0 [repo_root] [text|json|csv]" >&2
}

repo_root="${1:-$(pwd)}"
output_format="${2:-text}"

case "$output_format" in
text|json|csv) ;;
*)
usage
exit 1
;;
esac

repo_root="$(realpath "$repo_root")"

if [[ ! -d "$repo_root" ]]; then
echo "Repository path does not exist: $repo_root" >&2
exit 1
fi

declare -A edge_set
declare -A replaces_map
declare -A circular_set

tmp_file="$(mktemp)"
trap 'rm -f "$tmp_file"' EXIT

find \
"$repo_root/packages" \
"$repo_root/x11-packages" \
"$repo_root/root-packages" \
"$repo_root/disabled-packages" \
-type f -name build.sh 2>/dev/null | sort > "$tmp_file"

while IFS= read -r build_sh; do
pkg_name="$(basename "$(dirname "$build_sh")")"
raw_replaces="$({
awk '
/^[[:space:]]*TERMUX_PKG_REPLACES=/ {
line=$0
sub(/^[[:space:]]*TERMUX_PKG_REPLACES=/, "", line)
while (line ~ /\\[[:space:]]*$/) {
sub(/\\[[:space:]]*$/, "", line)
if (getline next_line <= 0) break
line = line next_line
}
print line
exit
}
' "$build_sh"
} || true)"

[[ -z "$raw_replaces" ]] && continue

raw_replaces="$(sed -E "s/^[[:space:]]+//; s/[[:space:]]+$//" <<< "$raw_replaces")"

if [[ "$raw_replaces" == \"*\" ]]; then
raw_replaces="${raw_replaces#\"}"
raw_replaces="${raw_replaces%\"}"
elif [[ "$raw_replaces" == \'*\' ]]; then
raw_replaces="${raw_replaces#\'}"
raw_replaces="${raw_replaces%\'}"
fi

replaces_map["$pkg_name"]="$raw_replaces"

while IFS= read -r replaced_pkg; do
replaced_pkg="$(sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//; s/[[:space:]]*\(.*\)$//' <<< "$replaced_pkg")"
[[ -z "$replaced_pkg" ]] && continue
edge_set["$pkg_name|$replaced_pkg"]=1
done < <(tr ',' '\n' <<< "$raw_replaces")
done < "$tmp_file"

for edge in "${!edge_set[@]}"; do
a="${edge%%|*}"
b="${edge#*|}"
[[ "$a" == "$b" ]] && continue
if [[ -n "${edge_set["$b|$a"]:-}" ]]; then
if [[ "$a" < "$b" ]]; then
circular_set["$a|$b"]=1
else
circular_set["$b|$a"]=1
fi
fi
done

mapfile -t circular_pairs < <(printf '%s\n' "${!circular_set[@]}" | sort)
count="${#circular_pairs[@]}"

case "$output_format" in
text)
if [[ "$count" -eq 0 ]]; then
echo "No circular TERMUX_PKG_REPLACES dependencies found."
exit 0
fi

echo "Found $count circular TERMUX_PKG_REPLACES relationship(s):"
echo
for pair in "${circular_pairs[@]}"; do
pkg_a="${pair%%|*}"
pkg_b="${pair#*|}"
echo "- $pkg_a <-> $pkg_b"
echo "  $pkg_a replaces: ${replaces_map[$pkg_a]}"
echo "  $pkg_b replaces: ${replaces_map[$pkg_b]}"
done
;;
json)
echo '{'
echo '  "circular_replaces": ['
for i in "${!circular_pairs[@]}"; do
pair="${circular_pairs[$i]}"
pkg_a="${pair%%|*}"
pkg_b="${pair#*|}"
printf '    {"package_a":"%s","package_b":"%s"}' "$pkg_a" "$pkg_b"
if (( i + 1 < count )); then
echo ','
else
echo
fi
done
echo '  ],'
printf '  "count": %s\n' "$count"
echo '}'
;;
csv)
echo 'package_a,package_b'
for pair in "${circular_pairs[@]}"; do
echo "${pair%%|*},${pair#*|}"
done
;;
esac
