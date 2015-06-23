add wave -noupdate -divider {WISHBONE}
add wave -noupdate -format Logic	-label {WISHBONE reset}				-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Rst_i_n
add wave -noupdate -format Logic	-label {WISHBONE clk}				-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Clk_i

add wave -noupdate -format Logic	-label {WISHBONE Phase1}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iPhase1
add wave -noupdate -format Logic	-label {WISHBONE Phase2}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iPhase2

add wave -noupdate -format Logic	-label {WISHBONE InstReadSing}		-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iWbRdSing
add wave -noupdate -format Logic	-label {WISHBONE InstWriteSing}		-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iWbWrSing


add wave -noupdate -format Logic	-label {WISHBONE ACK_I}				-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iwbACK_I
add wave -noupdate -format Logic	-label {WISHBONE validHandshake}	-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iWB_vHs
add wave -noupdate -format Logic	-label {WISHBONE CYC}				-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iwbCYC
add wave -noupdate -format Logic	-label {WISHBONE validPC}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iWB_vPC
add wave -noupdate -format Logic	-label {WISHBONE validOperation}	-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/iWB_vOp
