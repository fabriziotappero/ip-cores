
$Id: readme.txt 2002 2011-10-04 13:18:30Z ege $

** Testbench for hibi v3 **

 Written in SystemC, so you need SystemC support for Modelsim which is
probably not enabled by default (you need to extract the compiler zip
to Modelsim's installation directory).

 To compile, run 
 > tb/sad_tb/compile.sh 
 Paths are relative to hibi_v3 root directory (.../interconnections/hibi_v3/). 
 Modelsim's executables must be found in $PATH.

 By default, it creates 3 segments with 4 agents in each.  Two
wrappers types are supported: r4 and r3, and both addressing modes:
norm and sad. Hence, there are 4 system setups each with 12 wrappers are
generated.

If you want more or less edit both hibiv3.vhd and constants.hh and
make sure that address and the related tables are the same in
both. Most of the generics can be changed by editing only
constants.hh.

 To change the stimuli edit stimuli.hh. It contains the main stimuli
creation process and various helper functions to create different kind
of packets to be sent through hibi.

 TB checks that incoming packets are meant for the receiving agent
(only warning is printed so "cat transcript | grep warn" after
simulation. Also packets that haven't received all words are printed.

 run -all works. TB will timeout after some time even if all packets
have not been received.


-----------------
Lasse Lehtonen, 2011-09-30
