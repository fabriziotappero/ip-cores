configure wave -signalnamewidth 1

add wave -position end  sim:/tb_fir/clk
add wave -position end  sim:/tb_fir/count
add wave -position end  sim:/tb_fir/pwrUpCnt
add wave -position end  sim:/tb_fir/reset
add wave -position end -hex  sim:/tb_fir/u
add wave -position end -hex  sim:/tb_fir/y
#add wave -position end -hex  sim:/tb_fir/fir_test/b
add wave -position end -hex  sim:/tb_fir/filter/u_pipe
add wave -position end -hex  sim:/tb_fir/filter/y_pipe

add wave -position end -signed -format analog-step -height 50 -scale 45 sim:/tb_fir/u
add wave -position end -signed -format analog-step -height 100 -scale 0.08 sim:/tb_fir/y

run 5000 ns

wave zoomfull
#.wave.tree zoomfull    # with some versions of ModelSim
