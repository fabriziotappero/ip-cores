#
#
 quit -sim
#
#
echo Cre WORK lib (and del OLD, if exists)
 if {[file exists "work"]} { vdel -all}
 vlib work

#
#
echo Compile SRC:

 vcom -quiet -f zz_do/files_coregen_vhdl.f
 vlog -quiet -f zz_do/files_design_verilog.f
 vcom -quiet -f zz_do/files_design_vhdl.f

#
#
echo Compile TEST ENV:

 vcom -quiet -f zz_do/files_verification_vhdl.f


#
#
echo Start SIM:
 vsim -t ps -novopt -L secureip -L unisims_ver work.stend_ambpex5_core_m2 glbl

#
#
 log -r /*

#
#
 do wave.do

#
# skip warnings like: Warning: There is an 'U'|'X'|'W'|'Z'|'-' in an arithmetic operand, the result will be 'X'(es).
quietly set StdArithNoWarnings   1
quietly set NumericStdNoWarnings 1

#
#
 run -all

