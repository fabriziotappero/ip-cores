onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic /simple_test_mesh_2d/clk_noc
add wave -noupdate -format Logic /simple_test_mesh_2d/clk_ip
add wave -noupdate -format Logic /simple_test_mesh_2d/rst_n
add wave -noupdate -format Literal /simple_test_mesh_2d/rx_av
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/rx_data
add wave -noupdate -format Literal /simple_test_mesh_2d/rx_we
add wave -noupdate -format Literal /simple_test_mesh_2d/rx_txlen
add wave -noupdate -format Literal /simple_test_mesh_2d/rx_full
add wave -noupdate -format Literal /simple_test_mesh_2d/rx_full_r
add wave -noupdate -format Literal /simple_test_mesh_2d/rx_empty
add wave -noupdate -format Literal /simple_test_mesh_2d/tx_av
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/tx_data
add wave -noupdate -format Literal /simple_test_mesh_2d/tx_re
add wave -noupdate -format Literal /simple_test_mesh_2d/tx_empty
add wave -noupdate -divider router_0_0
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/clk_ip
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/clk_mesh
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/rst_n
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/data_ip_tx_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/we_ip_tx_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/empty_ip_tx_out
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/re_s_in
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__0/map_router_colums__0/router_r_c/data_s_out
add wave -noupdate -divider router_1_0
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__0/router_r_c/data_n_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__0/router_r_c/empty_n_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__0/router_r_c/re_n_out
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__0/router_r_c/re_e_in
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__0/router_r_c/data_e_out
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__0/router_r_c/empty_e_out
add wave -noupdate -divider router_1_1
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__1/router_r_c/data_w_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__1/router_r_c/empty_w_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__1/router_r_c/re_e_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__1/router_r_c/re_w_out
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__1/router_r_c/data_e_out
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__1/router_r_c/empty_e_out
add wave -noupdate -divider router_1_2
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__2/router_r_c/data_w_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__2/router_r_c/empty_w_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__2/router_r_c/re_w_out
add wave -noupdate -format Literal -radix hexadecimal /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__2/router_r_c/data_ip_rx_out
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__2/router_r_c/re_ip_rx_in
add wave -noupdate -format Logic /simple_test_mesh_2d/i_mesh_2d_with_pkt_codec_top/mesh/map_router_rows__1/map_router_colums__2/router_r_c/empty_ip_rx_out
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {198 ns} 0}
configure wave -namecolwidth 172
configure wave -valuecolwidth 100
configure wave -justifyvalue left
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
WaveRestoreZoom {0 ns} {277 ns}
