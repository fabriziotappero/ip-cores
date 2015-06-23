quit -sim
vlog ./microcodesrc/microcodesrc.v
vlog microcodelogic.v
vlog microcodelogic_tb.v

vsim -L unisims_ver -voptargs=+acc microcodelogic_tb

add wave \
{sim:/microcodelogic_tb/clk } \
{sim:/microcodelogic_tb/rst } \
{sim:/microcodelogic_tb/sof_in } \
{sim:/microcodelogic_tb/eof_in } \
{sim:/microcodelogic_tb/src_rdy_in } \
{sim:/microcodelogic_tb/dst_rdy_out } \
{sim:/microcodelogic_tb/comp_res } \
{sim:/microcodelogic_tb/dst_rdy_in } \
{sim:/microcodelogic_tb/sof_out } \
{sim:/microcodelogic_tb/eof_out } \
{sim:/microcodelogic_tb/src_rdy_out } \
{sim:/microcodelogic_tb/comp_mux_a_s } \
{sim:/microcodelogic_tb/comp_mux_b_s } \
{sim:/microcodelogic_tb/inst_constant } \
{sim:/microcodelogic_tb/sr1_in_en } \
{sim:/microcodelogic_tb/sr2_in_en } \
{sim:/microcodelogic_tb/sr1_out_en } \
{sim:/microcodelogic_tb/sr2_out_en } \
{sim:/microcodelogic_tb/reg_addr } \
{sim:/microcodelogic_tb/reg_wen_high } \
{sim:/microcodelogic_tb/reg_wen_low } \
{sim:/microcodelogic_tb/mux_data_out_s } 

add wave \
{sim:/microcodelogic_tb/DUT/pc } 

run 2000ns

