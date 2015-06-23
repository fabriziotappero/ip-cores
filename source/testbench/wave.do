onerror {resume}
quietly WaveActivateNextPane {} 0
quietly virtual signal -install /tb_mdct/u_mdct/u_dct1d { /tb_mdct/u_mdct/u_dct1d/col_reg(2 downto 1)} coLreg2
add wave -noupdate -format Literal /tb_mdct/u_inpimage/outimage_proc/error_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/outimage_proc/dcto_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/test_stim
add wave -noupdate -format Literal /tb_mdct/u_inpimage/test_inp
add wave -noupdate -format Literal /tb_mdct/u_inpimage/ycon_s
add wave -noupdate -format Literal /tb_mdct/u_inpimage/xcon_s
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_inpimage/testend
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/rst
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/dcti
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/idv
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u1_rome0/datao
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/clk
add wave -noupdate -format Logic /tb_mdct/u_mdct/odv1
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/dcto1
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/ramwe
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/ramwaddro
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u_dct1d/ramdatai
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/inpcnt_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/coLreg2
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/col_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/col_2_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/row_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/stage2_cnt_reg
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dct1d/stage2_reg
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u_dct1d/databuf_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct1d/latchbuf_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/col_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/row_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/memswitchwr
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/memswitchrd
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dct2d/rst
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dct2d/odv
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u_dct2d/dcto
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dct2d/stage1_reg
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dct2d/stage2_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct2d/stage2_cnt_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct2d/colram_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct2d/rowram_reg
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u_dct2d/ramraddro
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u_dct2d/ramdatao
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u_dct2d/latchbuf_reg
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u_dct2d/databuf_reg
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dct1d/wmemsel
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct2d/col_reg
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct2d/row_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/dataready
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dct2d/clk
add wave -noupdate -format Literal -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/ramdatai_s
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dct1d/ramwe_s
add wave -noupdate -format Literal /tb_mdct/u_inpimage/inpimage_proc/i
add wave -noupdate -format Literal /tb_mdct/u_inpimage/inpimage_proc/j
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/error_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/error_dct_matrix_s
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u1_ram/mem
add wave -noupdate -format Literal /tb_mdct/u_mdct/u2_ram/mem
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dbufctl/clk
add wave -noupdate -format Logic /tb_mdct/u_mdct/u_dbufctl/rst
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/memswitchwr
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/memswitchrd
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/memswitchwr_reg
add wave -noupdate -format Logic -radix hexadecimal /tb_mdct/u_mdct/u_dbufctl/memswitchrd_reg
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/i
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/j
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/error_cnt
add wave -noupdate -format Literal /tb_mdct/u_inpimage/outimage_proc/i
add wave -noupdate -format Literal /tb_mdct/u_inpimage/outimage_proc/j
add wave -noupdate -format Literal /tb_mdct/u_inpimage/outimage_proc/error_cnt
add wave -noupdate -format Literal /tb_mdct/u_inpimage/outimage_proc/raport_str
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/ref_matrix_1d
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/ref_matrix_2d
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/dcto_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/test_out
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/error_idct_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/ref_idct_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/idcto_matrix
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/psnr
add wave -noupdate -format Literal /tb_mdct/u_inpimage/inpimage_proc/i
add wave -noupdate -format Literal /tb_mdct/u_inpimage/inpimage_proc/j
add wave -noupdate -format Literal /tb_mdct/u_inpimage/error_dcto1_matrix_s
add wave -noupdate -format Logic -radix decimal /tb_mdct/u_mdct/u1_ram/clk
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u1_ram/d
add wave -noupdate -format Literal -radix unsigned /tb_mdct/u_mdct/u1_ram/raddr
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u1_ram/waddr
add wave -noupdate -format Logic /tb_mdct/u_mdct/u1_ram/we
add wave -noupdate -format Logic /tb_mdct/u_mdct/u1_ram/clk
add wave -noupdate -format Literal -radix decimal /tb_mdct/u_mdct/u1_ram/q
add wave -noupdate -format Literal /tb_mdct/u_mdct/u1_ram/mem
add wave -noupdate -format Literal /tb_mdct/u_mdct/u1_ram/read_addr
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/i
add wave -noupdate -format Literal /tb_mdct/u_inpimage/final_outimage_proc/j
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7596588 ps} 0}
configure wave -namecolwidth 155
configure wave -valuecolwidth 103
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
update
WaveRestoreZoom {6158584 ps} {9141416 ps}
