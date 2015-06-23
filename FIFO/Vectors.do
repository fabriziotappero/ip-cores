
echo Copyright Jamil Khatib 1999
echo
echo This test vector file is an open design, you can redistribute it and/or
echo modify it under the terms of the Openip Hardware General Public
echo License as as published by the OpenIP organization and any 
echo coming versions of this license.
echo You can check the draft license at
echo http://www.openip.org/oc/license.html
echo
echo contact me at khatib@ieee.org
echo
echo
echo Creator : Jamil Khatib
echo Date 16/11/99
echo
echo version 0.19991219
echo =============================


view source 
view signals
view wave
add wave *

#init clk
force clk 1 10, 0 20 -r 20

# init reset 
force reset 0 0
run 40

force reset 1 0
run 40

#No read nor write
force data_in 00000000 0
force we 0 0
force re 0 0
run 40 

# write only cycles
force data_in 00001111 0
force we 1 0
run 20

force data_in 00000001 0
force we 1 0
run 20

force data_in 00000011 0
force we 1 0
run 20

# Read only cycles
force data_in 00000000 0
force we 0 0
force re 1 0
run 20

force re 1 0
run 20

force re 1 0
run 20


# Read and write from different addresses
force data_in 00000111 0
force we 1 0
force re 1 0
run 20

# Read and write from different addresses
force data_in 00001111 0
force we 1 0
force re 1 0
run 20


# Read and Write from the same address
force data_in 00000000 0
force we 1 0
force re 1 0
run 20

force data_in 00000000 0
force we 1 0
force re 1 0
run 20

# reset system during Operation
run 10
force reset 0 0
force data_in 00000000 0
force we 1 0
force re 1 0
run 20

force reset 1 0
force data_in 11111111 0
force we 1 0
force re 1 0
run 20
run 20