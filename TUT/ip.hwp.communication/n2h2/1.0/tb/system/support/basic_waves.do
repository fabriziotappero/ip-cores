onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Top
add wave -noupdate -format Logic /test_bench/clk_0
add wave -noupdate -format Logic /test_bench/cpu_resetrequest_to_the_cpu_0
add wave -noupdate -format Logic /test_bench/cpu_resetrequest_to_the_cpu_1
add wave -noupdate -format Logic /test_bench/cpu_resetrequest_to_the_cpu_2
add wave -noupdate -format Logic /test_bench/cpu_resettaken_from_the_cpu_0
add wave -noupdate -format Logic /test_bench/cpu_resettaken_from_the_cpu_1
add wave -noupdate -format Logic /test_bench/cpu_resettaken_from_the_cpu_2
add wave -noupdate -color Tan -format Logic /test_bench/hibi_av_in_to_the_n2h2_chan_0
add wave -noupdate -color Tan -format Logic /test_bench/hibi_av_in_to_the_n2h2_chan_1
add wave -noupdate -color Tan -format Logic /test_bench/hibi_av_in_to_the_n2h2_chan_2
add wave -noupdate -color Gold -format Logic /test_bench/hibi_av_out_from_the_n2h2_chan_0
add wave -noupdate -color Gold -format Logic /test_bench/hibi_av_out_from_the_n2h2_chan_1
add wave -noupdate -color Gold -format Logic /test_bench/hibi_av_out_from_the_n2h2_chan_2
add wave -noupdate -format Literal /test_bench/hibi_comm_in_to_the_n2h2_chan_0
add wave -noupdate -format Literal /test_bench/hibi_comm_in_to_the_n2h2_chan_1
add wave -noupdate -format Literal /test_bench/hibi_comm_in_to_the_n2h2_chan_2
add wave -noupdate -format Literal /test_bench/hibi_comm_out_from_the_n2h2_chan_0
add wave -noupdate -format Literal /test_bench/hibi_comm_out_from_the_n2h2_chan_1
add wave -noupdate -format Literal /test_bench/hibi_comm_out_from_the_n2h2_chan_2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibi_data_in_to_the_n2h2_chan_0
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibi_data_in_to_the_n2h2_chan_1
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibi_data_in_to_the_n2h2_chan_2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibi_data_out_from_the_n2h2_chan_0
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibi_data_out_from_the_n2h2_chan_1
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibi_data_out_from_the_n2h2_chan_2
add wave -noupdate -format Logic /test_bench/hibi_empty_in_to_the_n2h2_chan_0
add wave -noupdate -format Logic /test_bench/hibi_empty_in_to_the_n2h2_chan_1
add wave -noupdate -format Logic /test_bench/hibi_empty_in_to_the_n2h2_chan_2
add wave -noupdate -color Orchid -format Logic /test_bench/hibi_full_in_to_the_n2h2_chan_0
add wave -noupdate -color Orchid -format Logic /test_bench/hibi_full_in_to_the_n2h2_chan_1
add wave -noupdate -color Orchid -format Logic /test_bench/hibi_full_in_to_the_n2h2_chan_2
add wave -noupdate -format Logic /test_bench/hibi_re_out_from_the_n2h2_chan_0
add wave -noupdate -format Logic /test_bench/hibi_re_out_from_the_n2h2_chan_1
add wave -noupdate -format Logic /test_bench/hibi_re_out_from_the_n2h2_chan_2
add wave -noupdate -color Plum -format Logic /test_bench/hibi_we_out_from_the_n2h2_chan_0
add wave -noupdate -color Plum -format Logic /test_bench/hibi_we_out_from_the_n2h2_chan_1
add wave -noupdate -color Plum -format Logic /test_bench/hibi_we_out_from_the_n2h2_chan_2
add wave -noupdate -format Logic /test_bench/reset_n
add wave -noupdate -format Literal /test_bench/comm_from_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/data_from_n
add wave -noupdate -format Literal /test_bench/av_from_n
add wave -noupdate -format Literal /test_bench/we_from_n
add wave -noupdate -format Literal /test_bench/re_from_n
add wave -noupdate -format Literal /test_bench/comm_to_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/data_to_n
add wave -noupdate -format Literal /test_bench/av_to_n
add wave -noupdate -format Literal /test_bench/full_to_n
add wave -noupdate -format Literal /test_bench/one_p_to_n
add wave -noupdate -format Literal /test_bench/empty_to_n
add wave -noupdate -format Literal /test_bench/one_d_to_n
add wave -noupdate -divider Hibi_0
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_sync_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_sync_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/rst_n
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_data_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_full_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_lock_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_av_in
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_data_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_av_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_we_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_re_in
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_data_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_full_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_lock_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/bus_av_out
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_data_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_av_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_full_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_one_p_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_empty_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/agent_one_d_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/data_dw_h
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/comm_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/av_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/we_0_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/we_1_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/full_0_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/full_1_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/one_p_0_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/one_p_1_h_dw
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/data_0_h_mr
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/comm_0_h_mr
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/data_1_h_mr
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/comm_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/av_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/av_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/re_0_mr_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/re_1_mr_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/empty_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/empty_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/one_d_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__0/wrapper/one_d_1_h_mr
add wave -noupdate -divider Hibi_1
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_sync_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_sync_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/rst_n
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_data_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_full_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_lock_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_av_in
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_data_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_av_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_we_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_re_in
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_data_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_full_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_lock_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/bus_av_out
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_data_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_av_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_full_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_one_p_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_empty_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/agent_one_d_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/data_dw_h
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/comm_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/av_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/we_0_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/we_1_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/full_0_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/full_1_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/one_p_0_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/one_p_1_h_dw
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/data_0_h_mr
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/comm_0_h_mr
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/data_1_h_mr
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/comm_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/av_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/av_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/re_0_mr_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/re_1_mr_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/empty_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/empty_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/one_d_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__1/wrapper/one_d_1_h_mr
add wave -noupdate -divider Hibi_2
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_sync_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_sync_clk
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/rst_n
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_data_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_full_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_lock_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_av_in
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_data_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_av_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_we_in
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_re_in
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_data_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_full_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_lock_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/bus_av_out
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_data_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_av_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_full_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_one_p_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_empty_out
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/agent_one_d_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/data_dw_h
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/comm_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/av_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/we_0_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/we_1_dw_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/full_0_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/full_1_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/one_p_0_h_dw
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/one_p_1_h_dw
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/data_0_h_mr
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/comm_0_h_mr
add wave -noupdate -format Literal -radix hexadecimal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/data_1_h_mr
add wave -noupdate -format Literal /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/comm_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/av_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/av_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/re_0_mr_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/re_1_mr_h
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/empty_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/empty_1_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/one_d_0_h_mr
add wave -noupdate -format Logic /test_bench/hibiv3_r4_1/segments__0/wrappers__2/wrapper/one_d_1_h_mr
add wave -noupdate -divider N2H2_0
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/clk_cfg
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/clk_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/clk_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/rst_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_addr_out_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_we_out_rx
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_be_out_rx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_writedata_out_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_waitrequest_in_rx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_addr_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_writedata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_we_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_readdata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_re_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_cs_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_cfg_waitrequest_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_addr_out_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_re_out_tx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_readdata_in_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_waitrequest_in_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/avalon_readdatavalid_in_tx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_data_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_av_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_empty_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_comm_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_data_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_av_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_full_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_comm_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/hibi_we_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/rx_irq_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/tx_start_from_rx
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/tx_comm_from_rx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/tx_mem_addr_from_rx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/tx_hibi_addr_from_rx
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/tx_amount_from_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/tx_status_done_to_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/real_rst_n
add wave -noupdate -divider {n2h2_0 channels}
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/clk
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/rst_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_addr_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_we_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_be_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_writedata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_waitrequest_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/hibi_data_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/hibi_av_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/hibi_empty_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/hibi_comm_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/hibi_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_addr_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_writedata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_we_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_readdata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_re_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_cs_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_waitrequest_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/rx_irq_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_start_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_mem_addr_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_hibi_addr_out
add wave -noupdate -format Literal -radix unsigned /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_amount_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_status_done_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/mem_addr_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/sender_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/irq_amount_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/control_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_mem_addr_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_hibi_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_amount_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_comm_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/init_chan_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/irq_chan_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/current_mem_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/current_be_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_be_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/status_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/irq_reset_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/hibi_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_we_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/unknown_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/unknown_rx_irq_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/unknown_rx_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_illegal
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/tx_illegal_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/ignore_tx_write
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/ignored_last_tx_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/curr_chan_avalon_we_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_wes
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/matches
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/matches_cmb
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/irq_ack_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_addr_temp
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_be_temp
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_waitrequest_out_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/avalon_cfg_waitrequest_out_s
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/cfg_write
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/cfg_reg
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_rx_chan_1/cfg_tx_reg_used
add wave -noupdate -divider {n2h_0 tx}
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/clk
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/rst_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/avalon_addr_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/avalon_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/avalon_readdata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/avalon_waitrequest_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/avalon_readdatavalid_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_data_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_av_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_full_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_comm_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_we_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/tx_start_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/tx_status_done_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/tx_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/tx_hibi_addr_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/tx_ram_addr_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/tx_amount_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/control_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/addr_cnt_en_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/addr_cnt_value_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/addr_cnt_load_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/amount_cnt_en_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/amount_cnt_value_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/amount_cnt_load_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/amount_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/addr_amount_eq
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/addr_to_stop_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/avalon_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/start_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_write_addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/data_src_sel
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_we_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_0/n2h2_chan_0/n2h2_tx_1/hibi_stop_we_r
add wave -noupdate -divider N2H2_1
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/avalon_cfg_addr_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_cfg_we_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_cfg_re_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_cfg_cs_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/avalon_cfg_writedata_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/avalon_cfg_readdata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/avalon_cfg_waitrequest_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/hibi_data_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/hibi_av_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/hibi_empty_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/hibi_comm_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/hibi_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/hibi_data_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/hibi_av_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/hibi_full_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/hibi_comm_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/hibi_we_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/clk_cfg
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/rst_n
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/clk_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/clk_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/rx_irq_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/avalon_addr_out_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_we_out_rx
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/avalon_be_out_rx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/avalon_writedata_out_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_waitrequest_in_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_readdatavalid_in_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_waitrequest_in_tx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/avalon_readdata_in_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/avalon_re_out_tx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/avalon_addr_out_tx
add wave -noupdate -divider {n2h_1 channels}
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/clk
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/rst_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_addr_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_we_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_be_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_writedata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_waitrequest_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/hibi_data_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/hibi_av_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/hibi_empty_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/hibi_comm_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/hibi_re_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_addr_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_writedata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_we_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_readdata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_re_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_cs_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_waitrequest_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/rx_irq_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_start_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_mem_addr_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_hibi_addr_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_amount_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_status_done_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/mem_addr_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/sender_addr_r
add wave -noupdate -format Literal -radix unsigned /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/irq_amount_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/control_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_mem_addr_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_hibi_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_amount_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_comm_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/init_chan_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/irq_chan_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/current_mem_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/current_be_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_be_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/status_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/irq_reset_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/hibi_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_we_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/unknown_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/unknown_rx_irq_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/unknown_rx_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_illegal
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/tx_illegal_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/ignore_tx_write
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/ignored_last_tx_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/curr_chan_avalon_we_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_wes
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/matches
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/matches_cmb
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/irq_ack_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_addr_temp
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_be_temp
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_waitrequest_out_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/avalon_cfg_waitrequest_out_s
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/cfg_write
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/cfg_reg
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_rx_chan_1/cfg_tx_reg_used
add wave -noupdate -divider {n2h_1 tx}
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/clk
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/rst_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/avalon_addr_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/avalon_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/avalon_readdata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/avalon_waitrequest_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/avalon_readdatavalid_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_data_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_av_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_full_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_comm_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_we_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/tx_start_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/tx_status_done_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/tx_comm_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/tx_hibi_addr_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/tx_ram_addr_in
add wave -noupdate -format Literal -radix unsigned /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/tx_amount_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/control_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/addr_cnt_en_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/addr_cnt_value_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/addr_cnt_load_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/amount_cnt_en_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/amount_cnt_value_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/amount_cnt_load_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/amount_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/addr_amount_eq
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/addr_to_stop_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/avalon_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/start_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_write_addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/data_src_sel
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_we_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_1/n2h2_chan_1/n2h2_tx_1/hibi_stop_we_r
add wave -noupdate -divider N2H2_2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_cfg_addr_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_cfg_we_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_cfg_re_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_cfg_cs_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_cfg_writedata_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_cfg_readdata_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/hibi_data_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/hibi_av_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/hibi_empty_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/hibi_comm_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/hibi_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/hibi_data_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/hibi_av_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/hibi_full_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/hibi_comm_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/hibi_we_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/clk_cfg
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/rst_n
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/clk_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/clk_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/rx_irq_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_addr_out_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_we_out_rx
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/avalon_be_out_rx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_writedata_out_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_waitrequest_in_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_readdatavalid_in_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_waitrequest_in_tx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_readdata_in_tx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/avalon_re_out_tx
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/avalon_addr_out_tx
add wave -noupdate -divider {n2h_2 channels}
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/clk
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/rst_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_addr_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_we_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_be_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_writedata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_waitrequest_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/hibi_data_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/hibi_av_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/hibi_empty_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/hibi_comm_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/hibi_re_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_addr_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_writedata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_we_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_readdata_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_re_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_cs_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_waitrequest_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/rx_irq_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_start_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_comm_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_mem_addr_out
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_hibi_addr_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_amount_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_status_done_in
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/mem_addr_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/sender_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/irq_amount_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/control_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_mem_addr_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_hibi_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_amount_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_comm_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/init_chan_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/irq_chan_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/current_mem_addr_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/current_be_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_be_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/status_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/irq_reset_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/hibi_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_we_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/unknown_rx
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/unknown_rx_irq_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/unknown_rx_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_illegal
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/tx_illegal_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/ignore_tx_write
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/ignored_last_tx_r
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/curr_chan_avalon_we_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_wes
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/matches
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/matches_cmb
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/irq_ack_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_addr_temp
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_be_temp
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_waitrequest_out_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/avalon_cfg_waitrequest_out_s
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/cfg_write
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/cfg_reg
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_rx_chan_1/cfg_tx_reg_used
add wave -noupdate -divider {n2h_2 tx}
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/clk
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/rst_n
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/avalon_addr_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/avalon_re_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/avalon_readdata_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/avalon_waitrequest_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/avalon_readdatavalid_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_data_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_av_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_full_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_comm_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_we_out
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/tx_start_in
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/tx_status_done_out
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/tx_comm_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/tx_hibi_addr_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/tx_ram_addr_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/tx_amount_in
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/control_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/addr_cnt_en_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/addr_cnt_value_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/addr_cnt_load_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/amount_cnt_en_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/amount_cnt_value_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/amount_cnt_load_r
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/amount_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/addr_amount_eq
add wave -noupdate -format Literal /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/addr_to_stop_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/avalon_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/start_re_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_write_addr_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/data_src_sel
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_we_r
add wave -noupdate -format Logic /test_bench/dut/the_n2h2_chan_2/n2h2_chan_2/n2h2_tx_1/hibi_stop_we_r
add wave -noupdate -divider jtag_uart_1
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_1/av_address
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/av_chipselect
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/av_irq
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/av_read_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_1/av_readdata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/av_waitrequest
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/av_write_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_1/av_writedata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/dataavailable
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_1/readyfordata
add wave -noupdate -divider cpu_2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/i_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/i_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/i_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/i_address
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/i_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/clk
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/reset_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/d_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/d_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/d_address
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/d_byteenable
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/d_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/d_write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/d_writedata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/d_irq
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/d_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/cpu_resetrequest
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/cpu_resettaken
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/the_cpu_2_test_bench/w_pcb
add wave -noupdate -format Literal -radix ascii /test_bench/dut/the_cpu_2/the_cpu_2_test_bench/w_vinst
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_2/the_cpu_2_test_bench/w_valid
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_2/the_cpu_2_test_bench/w_iw
add wave -noupdate -divider onchip_memory2_1
add wave -noupdate -format Logic /test_bench/dut/the_onchip_memory2_1/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_onchip_memory2_1/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_1/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_onchip_memory2_1/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_1/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_1/writedata
add wave -noupdate -divider cpu_0
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/i_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/i_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/i_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/i_address
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/i_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/clk
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/reset_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/d_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/d_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/d_address
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/d_byteenable
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/d_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/d_write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/d_writedata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/d_irq
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/d_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/cpu_resetrequest
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/cpu_resettaken
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/the_cpu_0_test_bench/w_pcb
add wave -noupdate -format Literal -radix ascii /test_bench/dut/the_cpu_0/the_cpu_0_test_bench/w_vinst
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_0/the_cpu_0_test_bench/w_valid
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_0/the_cpu_0_test_bench/w_iw
add wave -noupdate -divider jtag_uart_0
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_0/av_address
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/av_chipselect
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/av_irq
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/av_read_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_0/av_readdata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/av_waitrequest
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/av_write_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_0/av_writedata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/dataavailable
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_0/readyfordata
add wave -noupdate -divider onchip_memory2_0
add wave -noupdate -format Logic /test_bench/dut/the_onchip_memory2_0/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_onchip_memory2_0/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_0/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_onchip_memory2_0/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_0/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_0/writedata
add wave -noupdate -divider shared_mem_0
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_0/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_0/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_0/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_shared_mem_0/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_0/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_0/writedata
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_0/chipselect2
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_0/write2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_0/address2
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_shared_mem_0/byteenable2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_0/readdata2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_0/writedata2
add wave -noupdate -divider cpu_1
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/i_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/i_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/i_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/i_address
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/i_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/clk
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/reset_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/d_readdata
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/d_waitrequest
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/d_address
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/d_byteenable
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/d_read
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/d_write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/d_writedata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/d_irq
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/d_readdatavalid
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/cpu_resetrequest
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/cpu_resettaken
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/the_cpu_1_test_bench/w_pcb
add wave -noupdate -format Literal -radix ascii /test_bench/dut/the_cpu_1/the_cpu_1_test_bench/w_vinst
add wave -noupdate -format Logic -radix hexadecimal /test_bench/dut/the_cpu_1/the_cpu_1_test_bench/w_valid
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_cpu_1/the_cpu_1_test_bench/w_iw
add wave -noupdate -divider jtag_uart_2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_2/av_address
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/av_chipselect
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/av_irq
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/av_read_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_2/av_readdata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/av_waitrequest
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/av_write_n
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_jtag_uart_2/av_writedata
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/dataavailable
add wave -noupdate -format Logic /test_bench/dut/the_jtag_uart_2/readyfordata
add wave -noupdate -divider shared_mem_2
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_2/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_2/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_2/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_shared_mem_2/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_2/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_2/writedata
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_2/chipselect2
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_2/write2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_2/address2
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_shared_mem_2/byteenable2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_2/readdata2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_2/writedata2
add wave -noupdate -divider shared_mem_1
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_1/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_1/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_1/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_shared_mem_1/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_1/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_1/writedata
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_1/chipselect2
add wave -noupdate -format Logic /test_bench/dut/the_shared_mem_1/write2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_1/address2
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_shared_mem_1/byteenable2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_1/readdata2
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_shared_mem_1/writedata2
add wave -noupdate -divider onchip_memory2_2
add wave -noupdate -format Logic /test_bench/dut/the_onchip_memory2_2/chipselect
add wave -noupdate -format Logic /test_bench/dut/the_onchip_memory2_2/write
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_2/address
add wave -noupdate -format Literal -radix binary /test_bench/dut/the_onchip_memory2_2/byteenable
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_2/readdata
add wave -noupdate -format Literal -radix hexadecimal /test_bench/dut/the_onchip_memory2_2/writedata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29713541667 ps} 0}
configure wave -namecolwidth 240
configure wave -valuecolwidth 168
configure wave -justifyvalue right
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ps} {105 ms}
