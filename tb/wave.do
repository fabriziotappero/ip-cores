onerror {resume}
quietly virtual signal -install /jpeg_tb/U_JpegEnc/U_FDCT { /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_waddr(5 downto 0)} wad
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider HostBFM
add wave -noupdate -divider JpegEnc
add wave -noupdate -divider CtrlSM
add wave -noupdate -divider BUF_FIFO
add wave -noupdate -divider FDCT
add wave -noupdate -divider ZZ_TOP
add wave -noupdate -divider {zigzag core}
add wave -noupdate -divider QUANT_TOP
add wave -noupdate -divider quantizer
add wave -noupdate -divider RLE_TOP
add wave -noupdate -divider rle_core
add wave -noupdate -divider DoubleFIFO
add wave -noupdate -divider RLE_DoubleFIFO
add wave -noupdate -divider HUFFMAN
add wave -noupdate -divider BYTE_STUFFER
add wave -noupdate -divider JFIFGen
add wave -noupdate -divider OutMux
add wave -noupdate -divider HostBFM
add wave -noupdate /jpeg_tb/U_HostBFM/CLK
add wave -noupdate /jpeg_tb/U_HostBFM/RST
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_ABus
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_BE
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_DBus_in
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_RNW
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_select
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_DBus_out
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_XferAck
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_retry
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_toutSup
add wave -noupdate /jpeg_tb/U_HostBFM/OPB_errAck
add wave -noupdate /jpeg_tb/U_HostBFM/iram_wdata
add wave -noupdate /jpeg_tb/U_HostBFM/iram_wren
add wave -noupdate /jpeg_tb/U_HostBFM/fifo_almost_full
add wave -noupdate /jpeg_tb/U_HostBFM/sim_done
add wave -noupdate /jpeg_tb/U_HostBFM/num_comps
add wave -noupdate -radix unsigned /jpeg_tb/U_HostBFM/addr_inc
add wave -noupdate -divider JpegEnc
add wave -noupdate /jpeg_tb/U_JpegEnc/outif_almost_full
add wave -noupdate /jpeg_tb/U_JpegEnc/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_ABus
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_BE
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_DBus_in
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_RNW
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_select
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_DBus_out
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_XferAck
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_retry
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_toutSup
add wave -noupdate /jpeg_tb/U_JpegEnc/OPB_errAck
add wave -noupdate /jpeg_tb/U_JpegEnc/iram_wdata
add wave -noupdate /jpeg_tb/U_JpegEnc/iram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/ram_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/ram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/ram_wraddr
add wave -noupdate /jpeg_tb/U_JpegEnc/qdata
add wave -noupdate /jpeg_tb/U_JpegEnc/qaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/qwren
add wave -noupdate /jpeg_tb/U_JpegEnc/jpeg_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/jpeg_busy
add wave -noupdate /jpeg_tb/U_JpegEnc/outram_base_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/num_enc_bytes
add wave -noupdate /jpeg_tb/U_JpegEnc/img_size_x
add wave -noupdate /jpeg_tb/U_JpegEnc/img_size_y
add wave -noupdate /jpeg_tb/U_JpegEnc/sof
add wave -noupdate /jpeg_tb/U_JpegEnc/jpg_iram_rden
add wave -noupdate /jpeg_tb/U_JpegEnc/jpg_iram_rdaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/jpg_iram_rdata
add wave -noupdate /jpeg_tb/U_JpegEnc/fdct_start
add wave -noupdate /jpeg_tb/U_JpegEnc/fdct_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/zig_start
add wave -noupdate /jpeg_tb/U_JpegEnc/zig_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/rle_start
add wave -noupdate /jpeg_tb/U_JpegEnc/rle_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_start
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_start
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/zz_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/zz_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/zz_data
add wave -noupdate /jpeg_tb/U_JpegEnc/rle_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/rle_rdaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/rle_data
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_rdaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_rden
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_runlength
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_size
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_amplitude
add wave -noupdate /jpeg_tb/U_JpegEnc/huf_dval
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_rd_req
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_packed_byte
add wave -noupdate -divider CtrlSM
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/sof
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/img_size_x
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/img_size_y
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/jpeg_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/jpeg_busy
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/fdct_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/fdct_ready
add wave -noupdate -childformat {{/jpeg_tb/U_JpegEnc/U_CtrlSM/fdct_sm_settings.y_cnt -radix unsigned}} -expand -subitemconfig {/jpeg_tb/U_JpegEnc/U_CtrlSM/fdct_sm_settings.y_cnt {-height 15 -radix unsigned}} /jpeg_tb/U_JpegEnc/U_CtrlSM/fdct_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/zig_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/zig_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/zig_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/qua_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/qua_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/qua_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/rle_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/rle_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/rle_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/huf_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/huf_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/huf_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/bs_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/bs_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/bs_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/jfif_start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/jfif_ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/jfif_eoi
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/out_mux_ctrl
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/Reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/main_state
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/idle
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/start_PB
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/ready_PB
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/fsm
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/start1_d
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/RSM
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/out_mux_ctrl_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_CtrlSM/out_mux_ctrl_s2
add wave -noupdate -divider BUF_FIFO
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/img_size_x
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/img_size_y
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/sof
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/iram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/iram_wdata
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fifo_almost_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fdct_fifo_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fdct_fifo_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fdct_fifo_hf_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/pixel_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/line_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/pix_inblk_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/pix_inblk_cnt_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/line_inblk_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/read_block_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/read_block_cnt_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/write_block_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/ramraddr_int
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/raddr_base_line
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/raddr_tmp
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/line_lock
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memwr_line_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memrd_offs_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memrd_line
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/wr_line_idx
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/rd_line_idx
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/image_write_end
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/img_size_x
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/img_size_y
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/sof
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/iram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/iram_wdata
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fifo_almost_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fdct_fifo_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fdct_fifo_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/fdct_fifo_hf_full
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_BUF_FIFO/pixel_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/line_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/pix_inblk_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/read_block_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/write_block_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/ramraddr_int
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/raddr_base_line
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/raddr_tmp
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/line_lock
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memwr_line_cnt
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memwr_line_cnt
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_BUF_FIFO/wr_line_idx
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/line_inblk_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memrd_offs_cnt
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_BUF_FIFO/memrd_line
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_BUF_FIFO/rd_line_idx
add wave -noupdate /jpeg_tb/U_JpegEnc/U_BUF_FIFO/image_write_end
add wave -noupdate -divider FDCT
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/ready_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/writing_en
add wave -noupdate -radix unsigned -childformat {{/jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings.x_cnt -radix unsigned} {/jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings.y_cnt -radix unsigned} {/jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings.cmp_idx -radix unsigned}} -expand -subitemconfig {/jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings.x_cnt {-height 15 -radix unsigned} /jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings.y_cnt {-height 15 -radix unsigned} /jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings.cmp_idx {-height 15 -radix unsigned}} /jpeg_tb/U_JpegEnc/U_FDCT/fdct_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/bf_fifo_rd
add wave -noupdate -format Literal /jpeg_tb/U_JpegEnc/U_FDCT/bf_dval
add wave -noupdate -radix hexadecimal /jpeg_tb/U_JpegEnc/U_FDCT/bf_fifo_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/bf_fifo_hf_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/start_int
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_we
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/fram1_waddr
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/fram1_raddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_q_vld
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_rd_d(4)
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_rd_d
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_line_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fram1_pix_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/input_rd_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/rd_started
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/zz_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/zz_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/zz_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/zz_rden
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/img_size_x
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/img_size_y
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/sof
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/mdct_data_in
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/mdct_idval
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/mdct_odval
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_FDCT/mdct_data_out
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/odv1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dcto1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cmp_idx
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/rd_en_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/eoi_fdct
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/x_pixel_cnt
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/y_line_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/rdaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/wr_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_we
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_waddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_raddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/xw_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/yw_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/dbuf_q_z1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/sim_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Y_reg_1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Y_reg_2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Y_reg_3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cb_reg_1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cb_reg_2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cb_reg_3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cr_reg_1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cr_reg_2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cr_reg_3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Y_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cb_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cr_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/R_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/G_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/B_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Y_8bit
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cb_8bit
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/Cr_8bit
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d4
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d5
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d6
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d7
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d8
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/cur_cmp_idx_d9
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_empty
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_count
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_rd_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo1_q_dval
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo_data_in
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/fifo_rd_arm
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/eoi_fdct
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/bf_fifo_rd_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/wad
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/clk
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/rst
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/dcti
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/idv
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/odv
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/dcto
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/odv1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/dcto1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramdatao_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramraddro_s
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramwaddro_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramdatai_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramwe_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/romedatao_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/romodatao_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/romeaddro_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/romoaddro_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/rome2datao_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/romo2datao_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/rome2addro_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/romo2addro_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/odv2_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/dcto2_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/trigger2_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/trigger1_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramdatao1_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramdatao2_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramwe1_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/ramwe2_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/memswitchrd_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/memswitchwr_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/wmemsel_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/rmemsel_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/dataready_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/datareadyack_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/clk
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/rst
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/dcti
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/idv
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romedatao
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romodatao
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/odv
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/dcto
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romeaddro
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romoaddro
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramdatai
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwe
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/databuf_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/latchbuf_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/col_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/row_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/rowr_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/inpcnt_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwe_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/stage2_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/stage2_cnt_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/col_2_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/even_not_odd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/even_not_odd_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/even_not_odd_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/even_not_odd_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwe_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwe_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwe_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwe_d4
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_d4
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_d5
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/ramwaddro_d6
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_d4
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_d5
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/wmemsel_d6
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romedatao_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romodatao_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romedatao_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romodatao_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romedatao_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/romodatao_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/dcto_1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/dcto_2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/dcto_3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/dcto_4
add wave -noupdate /jpeg_tb/U_JpegEnc/U_FDCT/U_MDCT/U_DCT1D/fpr_out
add wave -noupdate -divider ZZ_TOP
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/ready_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/zig_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/qua_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/qua_rdaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/qua_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fdct_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fdct_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fdct_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fdct_rden
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/dbuf_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/dbuf_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/dbuf_we
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/dbuf_waddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/dbuf_raddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/zigzag_di
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/zigzag_divalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/zigzag_dout
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/zigzag_dovalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/wr_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/rd_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/rd_en_d
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fdct_buf_sel_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/zz_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/fifo_rden
add wave -noupdate -divider {zigzag core}
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/rst
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/clk
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/di
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/divalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_rden
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_empty
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/dout
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/dovalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/zz_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_count
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ZZ_TOP/U_zigzag/fifo_data_in
add wave -noupdate -divider QUANT_TOP
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/ready_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/qua_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/rle_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/rle_rdaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/rle_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zig_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zig_rd_addr
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zig_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/qdata
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/qaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/qwren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/dbuf_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/dbuf_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/dbuf_we
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/dbuf_waddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/dbuf_raddr
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zigzag_di
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zigzag_divalid
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_QUANT_TOP/quant_dout
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/quant_dovalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/wr_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/rd_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/rd_en_d
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zig_buf_sel_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/zz_rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/fifo_empty
add wave -noupdate -divider quantizer
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/rst
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/clk
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/di
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/divalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/qdata
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/qwaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/qwren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/cmp_idx
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/do
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/dovalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/romaddr_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/slv_romaddr_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/romdatao_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/divisor_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/remainder_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/do_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/round_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/di_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/pipeline_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/sign_bit_pipe
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/do_rdiv
add wave -noupdate /jpeg_tb/U_JpegEnc/U_QUANT_TOP/U_quantizer/table_select
add wave -noupdate -divider RLE_TOP
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/ready_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/qua_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/qua_buf_sel_s
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/qua_data
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/qua_rd_addr
add wave -noupdate -expand /jpeg_tb/U_JpegEnc/rle_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_rden
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_runlength
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_size
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_amplitude
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_dval
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/dbuf_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/dbuf_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/dbuf_we
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/rle_runlength
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/rle_size
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/rle_amplitude
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/rle_dovalid
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/wr_cnt
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/rle_di
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/rle_divalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/huf_dval_p0
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/data_in
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/rd_req
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/data_out
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_count
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_count
add wave -noupdate -divider rle_core
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/rst
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/clk
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/di
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/divalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/zrl_di
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/sof
add wave -noupdate -expand /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/rle_sm_settings
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/runlength
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/size
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/amplitude
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/dovalid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/rd_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/prev_dc_reg_0
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/prev_dc_reg_1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/prev_dc_reg_2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/prev_dc_reg_3
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/acc_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/size_reg
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/ampli_vli_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/runlength_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/dovalid_reg
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/zero_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/wr_cnt_d1
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/wr_cnt
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/rd_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_rle/zrl_proc
add wave -noupdate -divider DoubleFIFO
add wave -noupdate -divider RLE_DoubleFIFO
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/data_in
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/rd_req
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/data_out
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo1_count
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_rd
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_full
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo2_count
add wave -noupdate /jpeg_tb/U_JpegEnc/U_RLE_TOP/U_RleDoubleFifo/fifo_data_in
add wave -noupdate -divider HUFFMAN
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/ready_pb
add wave -noupdate -expand /jpeg_tb/U_JpegEnc/huf_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/sof
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/runlength
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_size
add wave -noupdate -radix decimal /jpeg_tb/U_JpegEnc/U_Huffman/VLI
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/img_size_x
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/img_size_y
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/rle_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/rle_fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/state
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/rle_buf_sel_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/first_rle_word
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/word_reg
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_Huffman/bit_ptr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/num_fifo_wrs
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/fifo_wbyte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/fifo_wrt_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/fifo_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/last_block
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_Huffman/image_area_size
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_Huffman/block_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_size_d
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_d
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLC_size
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLC
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_ext
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_ext_size
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLC_DC_size
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLC_DC
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLC_AC_size
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLC_AC
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/d_val
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/d_val_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/d_val_d2
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/d_val_d3
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/ready_HFW
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/HFW_running
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_size_r
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/VLI_r
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/bs_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/bs_fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/bs_rd_req
add wave -noupdate /jpeg_tb/U_JpegEnc/U_Huffman/bs_packed_byte
add wave -noupdate -divider BYTE_STUFFER
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/start_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/ready_pb
add wave -noupdate /jpeg_tb/U_JpegEnc/bs_sm_settings
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/sof
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_ByteStuffer/num_enc_bytes
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/outram_base_addr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_buf_sel
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_fifo_empty
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_rd_req
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_packed_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/latch_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/data_valid
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/wait_for_ndata
add wave -noupdate -expand /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_data_val
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/wdata_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/wraddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/wr_n_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_buf_sel_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/huf_rd_req_s
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/ram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/ram_wraddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_ByteStuffer/ram_byte
add wave -noupdate /jpeg_tb/sim_done
add wave -noupdate -divider JFIFGen
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/start
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/ready
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/eoi
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/qwren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/qwaddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/qwdata
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/image_size_reg
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/image_size_reg_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/ram_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/ram_wren
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_JFIFGen/ram_wraddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/hr_data
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/hr_waddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/hr_raddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/hr_we
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/hr_q
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/size_wr_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/size_wr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/rd_cnt
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/rd_en
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/rd_en_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/rd_cnt_d1
add wave -noupdate /jpeg_tb/U_JpegEnc/U_JFIFGen/rd_cnt_d2
add wave -noupdate -divider OutMux
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/CLK
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/RST
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/out_mux_ctrl
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/bs_ram_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/bs_ram_wren
add wave -noupdate -radix unsigned /jpeg_tb/U_JpegEnc/U_OutMux/bs_ram_wraddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/jfif_ram_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/jfif_ram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/jfif_ram_wraddr
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/ram_byte
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/ram_wren
add wave -noupdate /jpeg_tb/U_JpegEnc/U_OutMux/ram_wraddr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 4} {261424 ps} 0} {{Cursor 3} {59735000 ps} 0}
configure wave -namecolwidth 220
configure wave -valuecolwidth 83
configure wave -justifyvalue left
configure wave -signalnamewidth 2
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {59040694 ps} {61355034 ps}
