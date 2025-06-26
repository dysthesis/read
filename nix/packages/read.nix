{
  bash,
  lib,
  r,
  fzf,
  jq,
  sim,
  glow,
  writeShellScriptBin,
  ...
}: let
  inherit (lib) getExe;
in
  writeShellScriptBin "read" ''
    set -euo pipefail
    IFS=$'\n\t'

    LIKED_FILE="liked.txt"
    DISLIKED_FILE="disliked.txt"
    CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/read"
    mkdir -p "$CACHE_DIR"
    ENTRIES_JSON="$CACHE_DIR/entries.json"
    VIEWER="${getExe glow} -p -"
    SHELL="${getExe bash}"
    JQ="${getExe jq}"
    GLOW="${getExe glow}"

    export JQ GLOW ENTRIES_JSON LIKED_FILE DISLIKED_FILE

    die() { echo "[error] $*" >&2; exit 1; }

    fetch_feeds() {
      local feeds_file=$1 conc=''${2:-8}
      [[ -r $feeds_file ]] || die "Cannot read feeds file: $feeds_file"

      echo "[+] Fetching feeds…" >&2
      ${getExe r} "$feeds_file" "$conc" > "$ENTRIES_JSON" || die "r failed"
    }

    score_one() {
      local idx=$1 content=$2 s_like=0 s_dis=0
      if [[ -s $LIKED_FILE ]];   then s_like=$(${getExe sim} <(printf %s "$content") "$LIKED_FILE" | awk '{print $NF+0}') ; fi
      if [[ -s $DISLIKED_FILE ]];then s_dis=$(${getExe sim} <(printf %s "$content") "$DISLIKED_FILE" | awk '{print $NF+0}') ; fi
      # final score = like − dislike  (larger ⇒ better)
      awk -v a="$s_like" -v b="$s_dis" 'BEGIN{printf "%.3f", a-b}'
    }

    build_menu() {
      local idx=0
      ${getExe jq} -c '.[]' "$ENTRIES_JSON" | while read -r line; do
        local title url content pub author
        title=$(${getExe jq} -r '.title' <<< "$line")
        url=$(${getExe jq} -r '.url'   <<< "$line")
        author=$(${getExe jq} -r '.author // empty' <<< "$line")
        content=$(${getExe jq} -r '.content' <<< "$line")

        local score=$(score_one "$idx" "$content")
        printf '%s\t%s\t%s\t%s\n' "$score" "$idx" "$title" "$author|$url"
        idx=$((idx+1))
      done | sort -r -n -k1,1   # highest score first
    }

    preview_cmd() {
        cat <<'EOF'
    idx={2}
    $JQ -r ".[$idx].content" "$ENTRIES_JSON" | CLICOLOR_FORCE=1 COLORTERM=truecolor $GLOW -p -
    EOF
    }

    open_viewer() {
        idx=$1
        line="$($JQ -c ".[$idx]" "$ENTRIES_JSON")"
        $JQ -r '.content' <<<"$line" | CLICOLOR_FORCE=1 COLORTERM=truecolor $GLOW -p -
    }

    append_feedback() {
      idx=$1; tgt=$2
      ${getExe jq} -r ".[''${idx}].content" "$ENTRIES_JSON" >> "$tgt"
      printf '\n' >> "$tgt"
    }

    fzf_loop() {
        build_menu >"$CACHE_DIR/menu.tsv"
        ${getExe fzf} \
          --ansi --multi --no-sort \
          --with-nth=3.. --delimiter='\t' \
          --preview "$(preview_cmd)" \
          --bind "alt-l:ignore+execute-silent($(printf %q "$0") __like {2})+reload($(printf %q "$0") __menu)" \
          --bind "alt-d:execute-silent($(printf %q "$0") __dislike {2})+reload($(printf %q "$0") __menu)" \
          --bind "enter:execute($(printf %q "$0") __view {2})" \
          --preview-window=right:70%:wrap \
          <"$CACHE_DIR/menu.tsv"
    }

    if [[ ''${1:-} == __view   ]]; then shift; open_viewer "$1"; exit; fi
    if [[ ''${1:-} == __like   ]]; then shift; append_feedback "$1" "$LIKED_FILE"; exit; fi
    if [[ ''${1:-} == __dislike ]]; then shift; append_feedback "$1" "$DISLIKED_FILE"; exit; fi
    if [[ ''${1:-} == __menu   ]]; then build_menu; exit; fi

    [[ $# -lt 1 ]] && die "usage: $0 <feeds-file> [concurrency]"

    fetch_feeds "$1" "''${2:-8}"

    fzf_loop
  ''
