#!/bin/bash
mkdir -p {doc,bin}
cd doc
wget -nc http://www.opencores.com/cvsweb.cgi/~checkout~/uart16550/doc/UART_spec.pdf
cd ..
gcc ../src/splitlh.c -o ./bin/splitlh
