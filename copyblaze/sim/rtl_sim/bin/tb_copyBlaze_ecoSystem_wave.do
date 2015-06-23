onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {SYSTEM}
add wave -noupdate /tb_copyBlaze_ecoSystem/*
add wave -noupdate -divider {TOGGLE}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/U_Toggle/*

add wave -noupdate -divider {INTERRUPT MODULE}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_interrupt/*
add wave -noupdate -divider {INTERRUPT}
add wave sim:/tb_copyBlaze_ecoSystem/iClk
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/iPhase1
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/iPhase2
add wave sim:/tb_copyBlaze_ecoSystem/iExtIntEvent
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/address_o
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/instruction_i
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/interrupt_i
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/U_Interrupt/iIE
#add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/iIRecognized
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/iIEvent
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/Interrupt_Ack_o
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/iReturnI


add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_programflowcontrol/u_stack/istackmem

#add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/interrupt_ack_o
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_bancregister/ibancregmem

add wave -noupdate -divider {ALU}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_alu/*

add wave -noupdate -divider {FLAGS}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/U_Flags/*

add wave -noupdate -divider {BANC REGISTER}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_bancregister/*

do wave_copyBlaze.do

do wave_WISHBONE.do

add wave -noupdate -divider {FLOW CONTROL}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/U_ProgramFlowControl/*

add wave -noupdate -divider {STACK}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_programflowcontrol/u_stack/*

add wave -noupdate -divider {SCRATCH PAD MEMORY}
add wave sim:/tb_copyBlaze_ecoSystem/uut/processor/u_scratchpad/*

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 370
configure wave -valuecolwidth 67
configure wave -justifyvalue left
configure wave -signalnamewidth 0
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
WaveRestoreZoom {0 ps} {4203665 ps}
