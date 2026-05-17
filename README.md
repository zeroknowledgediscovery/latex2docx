# Quickstart

```
python generate_docx_submission.py main.tex \
  --outdir submission_build \
  --bibliography-style apa-numbered

```

```
./run_submission_build.sh main.tex submission_build --bibliography-style apa-numbered
```

```
--bibliography-style apa
APA-like author-date style.

--bibliography-style apa-numbered
APA-like reference formatting, but citations are numbered and references are ordered by first appearance.

--bibliography-style vancouver
Vancouver-like numbered references.

--bibliography-style ama
AMA-like numbered references.

--csl /path/to/style.csl
Overrides the named styles with a custom CSL file.

```


# LaTeX-to-DOCX submission builder

This package creates journal-submission DOCX files from a complete LaTeX source while preserving manuscript text.

It performs four steps:

1. Expands `\input{...}` and `\include{...}` files.
2. Extracts `table` and `figure` environments.
3. Creates a clean LaTeX manuscript with `\ref{...}` values hard-coded, floats removed, and figure captions moved to the back.
4. Runs Pandoc or a supplied `todocx.sh` to create the main Word file, then separately creates a Word document containing parsed Word tables.

## Files

- `generate_docx_submission.py`: main generator.
- `run_submission_build.sh`: convenience wrapper.
- `todocx.sh`: optional Pandoc converter supplied by the user.

## Basic usage

```bash
./run_submission_build.sh main.tex submission_build
```

or directly:

```bash
python generate_docx_submission.py main.tex --outdir submission_build --todocx todocx.sh
```

## Outputs

Inside `submission_build/`:

- `main_expanded_inputs.tex`: input-expanded LaTeX source.
- `main_clean_refs_hardcoded.tex`: main source with floats removed and references hard-coded.
- `tables_extracted.tex`: raw table environments only, no preamble.
- `figure_captions.tex`: figure captions only, no preamble.
- `figures/`: figure files copied from `\includegraphics{...}` when found.
- `manuscript.docx`: main Word document if Pandoc succeeds.
- `tables.docx`: separate Word document with parsed tables.
- `manifest.json`: labels, captions, figure paths, and conversion status.

## Notes

The script does not rewrite, shorten, or JAMA-structure the manuscript text. It only removes floats, moves figure legends to the back, hard-codes cross-references, and converts the resulting document.

The table parser is deliberately conservative. It handles ordinary `tabular` tables, `\hline`, `\rowcolor`, basic formatting commands, `\newline`, and common math symbols. If a table is too complex, the table block is preserved as raw LaTeX in `tables.docx` for manual cleanup.

If `todocx.sh` fails because a custom reference document is not available, the generator falls back to direct Pandoc conversion.
