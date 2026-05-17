#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./run_submission_build.sh /path/to/main.tex [outdir] [extra generator args]
#
# Examples:
#   ./run_submission_build.sh main.tex submission_build --bibliography-style apa-numbered
#   BIB_STYLE=ama ./run_submission_build.sh main.tex submission_build
#   CSL=/path/to/journal.csl ./run_submission_build.sh main.tex submission_build
#
# This wraps generate_docx_submission.py. It preserves manuscript prose, extracts tables,
# moves figure captions to the back, hard-codes \ref{} values, and makes a main DOCX plus
# a standalone Word document containing the extracted tables.

SOURCE=${1:-main.tex}
OUTDIR=${2:-submission_build}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

EXTRA_ARGS=()
if [[ $# -gt 2 ]]; then
  EXTRA_ARGS=("${@:3}")
fi

TODOCX_ARGS=()
if [[ -f "$SCRIPT_DIR/todocx.sh" ]]; then
  TODOCX_ARGS=(--todocx "$SCRIPT_DIR/todocx.sh")
elif [[ -f "todocx.sh" ]]; then
  TODOCX_ARGS=(--todocx "$(pwd)/todocx.sh")
fi

BIB_ARGS=()
if [[ -n "${BIB_STYLE:-}" ]]; then
  BIB_ARGS+=(--bibliography-style "$BIB_STYLE")
fi
if [[ -n "${CSL:-}" ]]; then
  BIB_ARGS+=(--csl "$CSL")
fi

python "$SCRIPT_DIR/generate_docx_submission.py" "$SOURCE" --outdir "$OUTDIR" "${TODOCX_ARGS[@]}" "${BIB_ARGS[@]}" "${EXTRA_ARGS[@]}"
