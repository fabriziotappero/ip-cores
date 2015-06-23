Rosta rsp517 Mitrion platform Integration project
pre-beta version
www.rosta.ru

mvp - mitrion.vhd & mitrionwrapper.vhd placement
rtl - vhdl library : 
ctrl_types.vhd - types definition
rsp517_lib.vhd - mvp-host interface cores
rsp517_exp.vhd - mvp-external ram & host-external ram interface cores
system.vhd - Clock generator & MPMC Instantiation, MPMC 4 ports configured as NPI, 32-Bit, 
first 2 ports used by host read/write, 3,4 ports used by mvp read/write
blk_mem_gen_v2_6.vhd - BRAM wrapper
rsp517_top.vhd - top design module

ucf - rsp517 constraints
xst - temprary folder

NGC - files:

blk_mem_gen_v2_6.ngc - bram
clock_generator_0_wrapper.ngc - clock generator
mpmc3_ddr_wrapper.ngc - MPMC DDR


project files:

rsp517_top.lso
rsp517_top.prj
rsp517_top.xst
rsp517_top.ut

Makefile - this design make-file
