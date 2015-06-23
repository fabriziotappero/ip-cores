configure wave -signalnamewidth 1

add wave -divider "LFSR"
add wave -position end  sim:/user/clk
add wave -position end  sim:/user/reset
add wave -position end  sim:/user/parallelLoad
add wave -position end  sim:/user/loadEn
add wave -position end  sim:/user/computeClk
add wave -position end  sim:/user/d
add wave -position end  -hexadecimal sim:/user/crc32
add wave -position end  -hexadecimal sim:/user/i_lfsr/i_d
add wave -position end  -hexadecimal sim:/user/i_lfsr/i_q
add wave -position end  -hexadecimal sim:/user/i_lfsr/x
add wave -position end  -hexadecimal sim:/user/msg
add wave -position end  sim:/user/i_loaded
add wave -position end  sim:/user/i_computed

run 80 ns;

wave zoomfull
#.wave.tree zoomfull	# with some versions of ModelSim
