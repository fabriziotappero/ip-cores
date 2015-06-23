#!/bin/bash

#DOCUTILS_PATH="/usr/local/bin/docutils/tools"
#DOCUTILS_PATH="/cygdrive/c/docutils-0.11/tools"
#DOCUTILS_PATH="/usr/local/bin/docutils/tools"
DOCUTILS_PATH="/c/docutils-0.11/tools"

${DOCUTILS_PATH}/rst2html.py <$1 >$1.html
${DOCUTILS_PATH}/rst2latex.py <$1 >$1.tex
pdflatex --shell-escape $1.tex
rm -rf $1.aux $1.log $1.out $1.tex

exit 0
