#!/usr/bin/env bash
set -euo pipefail

base_url="https://library.frenschan.org"

UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36"

fetch() {
  curl -fsSL --retry 5 --retry-delay 5 -A "$UA" "$@"
}

sanitize() {
  # Replace unsafe chars with underscores, collapse repeats, trim leading/trailing underscores/dots
  sed 's/[^a-zA-Z0-9. -]/_/g' |
    tr ' ' '_' |
    tr -s '_' |
    sed 's/^[_\.]*//; s/[_\.]*$//'
}

echo "Fetching categories…"

category_ids="$(
  fetch "${base_url}/category" |
    grep -oE '/category/stored/[0-9]+' |
    cut -d'/' -f4 |
    sort -un
)"

if [ -z "$category_ids" ]; then
  echo "No categories found — site structure may have changed." >&2
  exit 1
fi

printf '%s\n' "$category_ids" | while read -r id; do
  echo "Processing category ID ${id}"

  cat_page="$(fetch "${base_url}/category/stored/${id}")"

  cat_name="$(
    printf '%s\n' "$cat_page" |
      { grep -m1 -oE '<h2>Category: [^<]*</h2>' || true; } |
      sed 's/<h2>Category: //' |
      sed 's=</h2>==' |
      sanitize
  )"

  [ -z "$cat_name" ] && cat_name="Category_${id}"
  mkdir -p "$cat_name"

  book_ids="$(
    printf '%s\n' "$cat_page" |
      grep -oE '/book/[0-9]+' |
      cut -d'/' -f3 |
      sort -un
  )"

  if [ -z "$book_ids" ]; then
    echo "  (No books in this category)"
    continue
  fi

  printf '%s\n' "$book_ids" | while read -r book_id; do
    book_page="$(fetch "${base_url}/book/${book_id}")"

    title="$(
      printf '%s\n' "$book_page" |
        { grep -m1 -oE '<h2 id="title">[^<]*</h2>' || true; } |
        sed 's/<h2 id="title">//' |
        sed 's=</h2>==' |
        sanitize
    )"

    [ -z "$title" ] && title="${book_id}"

    outfile="${cat_name}/${title}.pdf"

    if [ -s "$outfile" ]; then
      echo "✓ Exists: ${outfile}"
      continue
    fi

    echo "↓ Downloading ${outfile}"

    if ! curl -C - \
      --retry 5 \
      --retry-delay 5 \
      --fail \
      --location \
      -A "$UA" \
      -e "${base_url}/book/${book_id}" \
      -o "$outfile" \
      "${base_url}/download/${book_id}/pdf/${book_id}.pdf"
    then
      echo "⚠ Failed: ${book_id}" >&2
    fi

    sleep 1
  done
done

echo "Download complete."
