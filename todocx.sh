#!/usr/bin/env bash
set -euo pipefail

# Legacy-compatible pandoc wrapper.
# Optional environment variables:
#   CSL=/path/to/style.csl
#   REFERENCE_DOC=/path/to/reference.docx

CSL_ARGS=()
if [[ -n "${CSL:-}" ]]; then
  CSL_ARGS=(--csl "$CSL")
fi

REFDOC="${REFERENCE_DOC:-custom_military_medicine_reference.docx}"
REF_ARGS=()
if [[ -f "$REFDOC" ]]; then
  REF_ARGS=(--reference-doc="$REFDOC")
fi

pandoc "$1" \
  --from=latex \
  --to=docx \
  --mathml \
  --citeproc \
  "${CSL_ARGS[@]}" \
  "${REF_ARGS[@]}" \
  -o manuscript.docx
