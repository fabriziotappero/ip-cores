


vlib work

vcom -check_synthesis -pedantic ../../basic_tester/vhd/txt_util.vhd
vcom -check_synthesis -pedantic ../../basic_tester/vhd/basic_tester_pkg.vhd
vcom -check_synthesis -pedantic ../../basic_tester/vhd/basic_tester_tx.vhd
vcom -check_synthesis -pedantic ../../basic_tester/vhd/basic_tester_rx.vhd

vcom -check_synthesis -pedantic ../../fifo/vhd/fifo.vhd
vcom -check_synthesis -pedantic ../../fifo/vhd/multiclk_fifo.vhd

vcom -check_synthesis -pedantic ../../packet_codec/vhd/addr_lut_pkg.vhd
vcom -check_synthesis -pedantic ../../packet_codec/vhd/addr_lut.vhd
vcom -check_synthesis -pedantic ../../packet_codec/vhd/pkt_counter.vhd
vcom -check_synthesis -pedantic ../../packet_codec/vhd/pkt_enc.vhd
vcom -check_synthesis -pedantic ../../packet_codec/vhd/pkt_dec.vhd
vcom -check_synthesis -pedantic ../../packet_codec/vhd/pkt_enc_dec.vhd
vcom -check_synthesis -pedantic ../../packet_codec/vhd/enc_dec_1d.vhd

vcom -check_synthesis -pedantic ../../mesh_2d/vhd/mesh_router.vhd
vcom -check_synthesis -pedantic ../../mesh_2d/vhd/mesh_2d.vhd
vcom -check_synthesis -pedantic ../../mesh_2d/vhd/mesh_2d_with_pkt_codec_top.vhd

vcom -check_synthesis -pedantic simple_test_mesh_2d.vhd

vsim -novopt simple_test_mesh_2d

