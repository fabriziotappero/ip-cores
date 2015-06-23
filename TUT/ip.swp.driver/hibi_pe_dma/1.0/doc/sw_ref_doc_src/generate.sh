#!/bin/bash

doxygen
cp -f swdocstyle.sty doxy/latex/doxygen.sty
make -C doxy/latex
cp doxy/latex/refman.pdf hpd_sw_ref.pdf