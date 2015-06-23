#-----------------------------------------------------------------
#--                                                             --
#-----------------------------------------------------------------
#--                                                             --
#-- Copyright (C) 2013 Stefano Tonello                          --
#--                                                             --
#-- This source file may be used and distributed without        --
#-- restriction provided that this copyright statement is not   --
#-- removed from the file and that any derivative work contains --
#-- the original copyright notice and the associated disclaimer.--
#--                                                             --
#-- THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY         --
#-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   --
#-- TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   --
#-- FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      --
#-- OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         --
#-- INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    --
#-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   --
#-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        --
#-- BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  --
#-- LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  --
#-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  --
#-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         --
#-- POSSIBILITY OF SUCH DAMAGE.                                 --
#--                                                             --
#-----------------------------------------------------------------

#---------------------------------------------------------------
# G.729A Codec self-test module simulation script for Modelsim
# simulator.
#---------------------------------------------------------------

# VHDL source file directory path
set SRC_DIR C:/Archive/G729A/G729A_CODEC_V1_0/VHDL

vcom $SRC_DIR/G729A_asip_pkg.vhd
vcom $SRC_DIR/G729A_asip_basic_pkg.vhd
vcom $SRC_DIR/G729A_asip_arith_pkg.vhd
vcom $SRC_DIR/G729A_asip_op_pkg.vhd
vcom $SRC_DIR/G729A_asip_idec_2w_pkg.vhd
vcom $SRC_DIR/G729A_asip_cfg_pkg.vhd
vcom $SRC_DIR/G729A_codec_intf_pkg.vhd
vcom $SRC_DIR/G729A_asip_lcstk.vhd
vcom $SRC_DIR/G729A_asip_lcstklog_ix.vhd
vcom $SRC_DIR/G729A_asip_lcstklog_2w.vhd
vcom $SRC_DIR/G729A_asip_ftchlog_2w.vhd
vcom $SRC_DIR/G729A_asip_idec.vhd
vcom $SRC_DIR/G729A_asip_idec_2w.vhd
vcom $SRC_DIR/G729A_asip_ifq.vhd
vcom $SRC_DIR/G729A_asip_pstllog_2w_p6.vhd
vcom $SRC_DIR/G729A_asip_adder_f.vhd
vcom $SRC_DIR/G729A_asip_addsub_pipeb.vhd
vcom $SRC_DIR/G729A_asip_mulu_pipeb.vhd
vcom $SRC_DIR/G729A_asip_shftu.vhd
vcom $SRC_DIR/G729A_asip_logic.vhd
vcom $SRC_DIR/G729A_asip_pipe_a_2w.vhd
vcom $SRC_DIR/G729A_asip_pipe_b.vhd
vcom $SRC_DIR/G729A_asip_lsu.vhd
vcom $SRC_DIR/G729A_asip_lu.vhd
vcom $SRC_DIR/G729A_asip_regfile_16x16_2w.vhd
vcom $SRC_DIR/G729A_asip_rams.vhd
vcom $SRC_DIR/G729A_asip_bjxlog.vhd
vcom $SRC_DIR/G729A_asip_pxlog.vhd
vcom $SRC_DIR/G729A_asip_fwdlog_2w_p6.vhd
vcom $SRC_DIR/G729A_asip_cpu_2w_p6.vhd
vcom $SRC_DIR/G729A_asip_top_2w.vhd
vcom $SRC_DIR/G729A_asip_spc.vhd
vcom $SRC_DIR/G729A_codec_sdp.vhd
# Simulation ROM model files
vcom $SRC_DIR/G729A_asip_romi_pkg.vhd
vcom $SRC_DIR/G729A_asip_romd_pkg.vhd
vcom $SRC_DIR/G729A_asip_roms.vhd
# Self-test module files
vcom $SRC_DIR/SELF_TEST/G729A_codec_st_rom_pkg.vhd
vcom $SRC_DIR/SELF_TEST/G729A_codec_st_roms.vhd
vcom $SRC_DIR/SELF_TEST/G729A_codec_selftest.vhd
vcom $SRC_DIR/SELF_TEST/G729A_codec_selftest_TB.vhd
# Self-test simulation test-bench
vsim work.g729a_codec_selftest_TB
# Waveforms...
add wave /g729a_codec_selftest_tb/clk
add wave /g729a_codec_selftest_tb/rst
add wave /g729a_codec_selftest_tb/done
add wave /g729a_codec_selftest_tb/pass
add wave -noupdate -format Literal /g729a_codec_selftest_tb/u_dut/pkt_cnt_q
add wave -noupdate -format Literal /g729a_codec_selftest_tb/u_dut/err_cnt_q

run 27ms