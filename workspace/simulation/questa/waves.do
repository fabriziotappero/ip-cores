configure wave -signalnamewidth 1

add wave -divider "DUV"
add wave -position end -decimal sim:/user/axiMaster/lastTransaction
add wave -position end  sim:/user/axiMaster/axiTxState
add wave -position end  sim:/user/axiMaster/next_axiTxState

add wave -divider "Tester"
add wave -position end  sim:/user/clk
add wave -position end  sim:/user/reset
add wave -position end  sim:/user/irq_write
add wave -position end  sim:/user/axiMaster/trigger
add wave -position end  sim:/user/axiMaster/i_trigger
add wave -position end  -hexadecimal sim:/bist/prbs
add wave -position end  sim:/bist/isCovered
add wave -position end  sim:/bist/i_isCovered

# Paper publication:
#add wave -position end  sim:/user/irq_write
#add wave -position end  -hexadecimal sim:/user/axiMaster_in.tReady
#add wave -position end  -hexadecimal sim:/user/axiMaster_out.tValid
#add wave -position end  -hexadecimal sim:/user/axiMaster_out.tData
#add wave -position end  -hexadecimal sim:/bist/prbs
#add wave -position end  -hexadecimal sim:/user/writeRequest.trigger
#add wave -position end  -hexadecimal sim:/user/writeResponse.trigger

add wave -position end -expand -hexadecimal sim:/user/axiMaster_in
add wave -position end -expand -hexadecimal sim:/user/axiMaster_out
add wave -position end -decimal sim:/user/readRequest
add wave -position end -expand -hexadecimal sim:/user/writeRequest
add wave -position end -decimal sim:/user/readResponse
add wave -position end -expand -hexadecimal sim:/user/axiMaster/i_writeResponse
add wave -position end -expand -hexadecimal sim:/user/writeResponse
add wave -position end sim:/bist/txFSM
add wave -position end sim:/bist/i_txFSM

#OS-VVM solution:
#add wave -position end -unsigned -format analog-step -height 80 -scale 0.4e-17 sim:/user/axiMaster_out.tData

#LFSR solution:
add wave -position end -unsigned -format analog-step -height 80 -scale 0.18e-7 sim:/user/axiMaster_out.tData

add wave -position end  sim:/bist/i_prbs/isParallelLoad
add wave -position end  sim:/bist/i_prbs/loadEn
add wave -position end  sim:/bist/i_prbs/loaded
add wave -position end  sim:/bist/i_prbs/i_loaded
add wave -position end  sim:/bist/i_prbs/load
add wave -position end  -hexadecimal sim:/bist/i_prbs/d
add wave -position end  -hexadecimal sim:/bist/i_prbs/seed
add wave -position end  -hexadecimal sim:/bist/prbs

run -all;

wave zoomfull
#.wave.tree zoomfull	# with some versions of ModelSim
