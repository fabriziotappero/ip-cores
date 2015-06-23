-----------------------------------------------------
-- G.729A codec: simulation & synthesis VHDL files --
-----------------------------------------------------

This folder includes all VHDL source files and memory initialization files
required by G.729A codec core.

The files are divided in six groups:

Group 1: VHDL source files to be used for both simulation and synthesis
(regardless of target synthesis platform). These files are needed by any
instance of G.729A core. 
Codec top-level module is located in file G729A_codec_sdp.vhd.

Group 2: Instruction and data ROM models with content specified as VHDL
constant. These models are suitable for simulation and for synthesis with
Xilinx tools.

Group 3: Instruction and data ROM models with content specified through
Memory Initialization File (MIF). These models are suitable for synthesis
with Altera tools.

Group 4: Core "self-test" files. Self-test module includes an instance
of G.729A codec core, data ROMs providing sample input and (expected) 
output data and logic to interface them. Top-level module is in file 
G729A_codec_selftest.vhd. This module is synthesizable and can therefore
be used as synthesis test-bench too.
A simulation test-bench (file G729A_codec_selftest_TB.vhd) is provided 
to exercise the self-test module.

Group 5: self-test data ROM models with content specified as VHDL
constant. These models are suitable for simulation and for synthesis with
Xilinx tools.

Group 6: self-test data ROM models with content specified through
Memory Initialization File (MIF). These models are suitable for synthesis
with Altera tools.

How to use these files?

Simulation of G.729A codec core alone (no self-test module): use groups
#1 and #2.

Synthesis of G.729A codec core alone (no self-test module) using Xilinx
tools: use groups #1 and #2.

Synthesis of G.729A codec core alone (no self-test module) using Altera
tools: use groups #1 and #3.

Simulation of G.729A codec core inside self-test module: use groups #1,
#2, #4 and #5.

Synthesis of G.729A codec core inside self-test module using Xilinx
tools: use groups #1, #2, #4 and #5.

Synthesis of G.729A codec core inside self-test module using Altera
tools: use groups #1, #3, #4 and #6.

WARNING: As explained in G.729A codec core documentation, use of ROM
models with MIF file requires the setting to '1' of configuration param 
(generic) "USE_ROM_MIF".

SELF_TEST sub-folder holds self-test module file.

-----------------------------------------------------

Group 1: 

G729A_asip_adder.vhd
G729A_asip_adder_f.vhd
G729A_asip_addsub_pipeb.vhd
G729A_asip_arith_pkg.vhd
G729A_asip_basic_pkg.vhd
G729A_asip_bjxlog.vhd
G729A_asip_cfg_pkg.vhd
G729A_asip_cpu_2w_p6.vhd
G729A_asip_ftchlog_2w.vhd
G729A_asip_fwdlog_2w_p6.vhd
G729A_asip_idec.vhd
G729A_asip_idec_2w.vhd
G729A_asip_idec_2w_pkg.vhd
G729A_asip_idec_pkg.vhd
G729A_asip_ifq.vhd
G729A_asip_lcstk.vhd
G729A_asip_lcstklog_2w.vhd
G729A_asip_lcstklog_ix.vhd
G729A_asip_logic.vhd
G729A_asip_lsu.vhd
G729A_asip_lu.vhd
G729A_asip_mulu_pipeb.vhd
G729A_asip_op_pkg.vhd
G729A_asip_pipe_a_2w.vhd
G729A_asip_pipe_b.vhd
G729A_asip_pkg.vhd
G729A_asip_pstllog_2w_p6.vhd
G729A_asip_pxlog.vhd
G729A_asip_rams.vhd
G729A_asip_regfile_16x16_2w.vhd
G729A_asip_romd_pkg.vhd
G729A_asip_romi_pkg.vhd
G729A_asip_roms.vhd
G729A_asip_shftu.vhd
G729A_asip_spc.vhd
G729A_asip_top_2w.vhd
G729A_codec_intf_pkg.vhd
G729A_codec_sdp.vhd (codec top-level module)

Group 2: 

G729A_asip_romd_pkg.vhd
G729A_asip_romi_pkg.vhd
G729A_asip_roms.vhd

Group 3: 

G729A_asip_romd.mif
G729A_asip_romi.mif
G729A_asip_roms_mif.vhd

Group 4: 

G729A_codec_selftest.vhd (self-test top-level module)
G729A_codec_selftest_TB.vhd (self-test simulation test-bench)

Group 5: 

G729A_asip_rom_1r.vhd
G729A_codec_rom_st.vhd

Group 6: 

G729A_asip_sti_rom.mif
G729A_asip_sto_rom.mif
