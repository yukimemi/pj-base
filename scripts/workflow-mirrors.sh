#!/bin/sh
# Keep pj-base's own workflow copies in step with the templates it ships.
#
# `.github/workflows/{claude,claude-review}.yml` are mirrors of the `.tera`
# files beside them. pj-base has no `.kata` state, so nothing renders them —
# which is how both drifted: one lost the corepack step and the pnpm entries
# in `--allowedTools`, the other lost the author_association gate that keeps a
# stranger's `@claude` from starting a job with the repository's token, and
# both were pinning action versions older than `vars.toml` says.
#
# A comment asking the next editor to remember is not a guard. This is:
#
#   sh scripts/workflow-mirrors.sh            # rewrite the mirrors
#   sh scripts/workflow-mirrors.sh --check    # fail if they have drifted
#
# Rendering matches what a consumer's `kata apply` produces: the `{% raw %}`
# markers go, and the two `vars.actions.*` pins are read from `vars.toml` so
# this script never becomes a third place a version is written down.
#
# Only the header above `on:` may differ between a mirror and its template —
# each mirror carries a trimmed one plus a note saying what it is. Everything
# from `on:` down has to match byte for byte.
set -eu

PAIRS="claude-review claude"
CHECK=0
[ "${1:-}" = "--check" ] && CHECK=1

pin() {
  # `name = "value"` out of vars.toml's [actions] table.
  grep -E "^$1 = " vars.toml | head -1 | sed 's/.*"\(.*\)".*/\1/'
}

CHECKOUT=$(pin checkout)
CLAUDE_ACTION=$(pin claude_code_action)

if [ -z "$CHECKOUT" ] || [ -z "$CLAUDE_ACTION" ]; then
  echo "error: could not read the action pins out of vars.toml" >&2
  exit 2
fi

render() {
  sed \
    -e 's/{% raw %}//g' \
    -e 's/{% endraw %}//g' \
    -e "s|{{ vars\.actions\.checkout }}|$CHECKOUT|g" \
    -e "s|{{ vars\.actions\.claude_code_action }}|$CLAUDE_ACTION|g" \
    "$1"
}

status=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

for name in $PAIRS; do
  tera=".github/workflows/$name.yml.tera"
  yml=".github/workflows/$name.yml"

  # The mirror keeps its own header; only the body is regenerated.
  sed '/^on:/,$d' "$yml" > "$tmp/header"
  render "$tera" | sed -n '/^on:/,$p' > "$tmp/body"
  cat "$tmp/header" "$tmp/body" > "$tmp/$name.yml"

  if [ "$CHECK" -eq 1 ]; then
    if ! diff -u "$yml" "$tmp/$name.yml" > "$tmp/$name.diff"; then
      echo "::error file=$yml::$yml has drifted from $tera — run 'sh scripts/workflow-mirrors.sh' and commit the result"
      cat "$tmp/$name.diff"
      status=1
    else
      echo "ok: $yml matches $tera"
    fi
  else
    cp "$tmp/$name.yml" "$yml"
    echo "wrote: $yml"
  fi
done

exit "$status"
