#!/bin/bash
export WORKDIR=sandbox
export MAINSHEET=GECKO4com
export TEXINPUTS=$TEXINPUTS:../:../figs
cd figs && (ls *.fig | while read filename; do fig2dev -L eps $filename "${filename%%'.fig'}.eps"; done)
cd ../$WORKDIR && rm -rf * || (mkdir -p ../$WORKDIR && cd ../$WORKDIR )
latex $MAINSHEET.tex
latex $MAINSHEET.tex
dvips -t a5 $MAINSHEET.dvi
ps2pdf  -dPDFSETTINGS=/prepress -dEmbedAllFonts=true $MAINSHEET.ps ../pdf/$MAINSHEET.pdf
cd ..
