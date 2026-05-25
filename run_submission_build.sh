#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./run_submission_build.sh /path/to/main.tex [outdir] [extra generator args]
#
# Examples:
#   ./run_submission_build.sh main.tex submission_build
#   ./run_submission_build.sh main.tex submission_build --bibliography-style ama
#   AUX_FILE=main.aux BIB_STYLE=ama ./run_submission_build.sh main.tex submission_build
#   CSL=/path/to/journal.csl ./run_submission_build.sh main.tex submission_build
#
# This wraps generate_docx_submission.py. It preserves manuscript prose, extracts tables,
# moves figure captions to the back, hard-codes \ref{} values from the LaTeX .aux file,
# and makes a main DOCX plus a standalone Word document containing the extracted tables.
# Default output is AMA-like, with superscript numeric citations.

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

# Default to AMA for JAMA Network Open-style submission builds unless the
# caller explicitly selected another bibliography style or CSL. The bundled
# AMA CSL emits superscript numeric in-text citations.
HAS_BIB_STYLE=0
for arg in "${EXTRA_ARGS[@]}"; do
  if [[ "$arg" == "--bibliography-style" || "$arg" == "--bib-style" || "$arg" == --bibliography-style=* || "$arg" == --bib-style=* ]]; then
    HAS_BIB_STYLE=1
    break
  fi
done

BIB_ARGS=()
if [[ -n "${BIB_STYLE:-}" ]]; then
  BIB_ARGS+=(--bibliography-style "$BIB_STYLE")
elif [[ $HAS_BIB_STYLE -eq 0 && -z "${CSL:-}" ]]; then
  BIB_ARGS+=(--bibliography-style ama)
fi
if [[ -n "${CSL:-}" ]]; then
  BIB_ARGS+=(--csl "$CSL")
fi

# Prefer the existing LaTeX .aux file when available. This preserves the exact
# rendered labels from LaTeX, including supplementary labels such as S1, SI, SII.
AUX_ARGS=()
if [[ -n "${AUX_FILE:-}" ]]; then
  AUX_ARGS=(--aux-file "$AUX_FILE")
else
  SOURCE_NOEXT="${SOURCE%.*}"
  if [[ -f "${SOURCE_NOEXT}.aux" ]]; then
    AUX_ARGS=(--aux-file "${SOURCE_NOEXT}.aux")
  elif [[ -f "main.aux" ]]; then
    AUX_ARGS=(--aux-file "main.aux")
  fi
fi

python "$SCRIPT_DIR/generate_docx_submission.py" "$SOURCE" --outdir "$OUTDIR" "${TODOCX_ARGS[@]}" "${BIB_ARGS[@]}" "${AUX_ARGS[@]}" "${EXTRA_ARGS[@]}"
