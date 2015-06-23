The batch script tasmtb.bat will assemble the test bench source and then build a
VHDL test bench from the template tb_template.vhdl, with the assembled program
encoded in a simulated ROM. 

For example, to build the test bench 0 do:

tasmtb tb0

The script assumes you have installed TASM in local/TASM. You may need to edit 
the path to TASM in the script.
Besides, it uses the perl script hexconv.pl, so you need to have Perl installed 
too. You can find them here:

Telemark cross assembler (TASM):
http://home.comcast.net/~tasm/

Perl for windows (ActivePerl):
http://www.activestate.com/activeperl/

There are other versions of Perl for windows, this is the one I worked with.

See more details about these test benches in the design notes and in the 
sources.
