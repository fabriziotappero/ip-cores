add wave -noupdate -divider {COPYBLAZE}
add wave -noupdate -format Logic	-label {COPYBLAZE reset}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Rst_i_n
add wave -noupdate -format Logic	-label {COPYBLAZE clk}				-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Clk_i

add wave -noupdate -format Literal	-label {COPYBLAZE address}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Address_o
add wave -noupdate -format Literal	-label {COPYBLAZE instruction}		-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Instruction_i

add wave -noupdate -format Literal	-label {COPYBLAZE port_id}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/PORT_ID_o
add wave -noupdate -format Logic	-label {COPYBLAZE write_strobe}	-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/WRITE_STROBE_o
add wave -noupdate -format Literal	-label {COPYBLAZE out_port}		-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/OUT_PORT_o
add wave -noupdate -format Logic	-label {COPYBLAZE read_strobe}		-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/READ_STROBE_o
add wave -noupdate -format Literal	-label {COPYBLAZE in_port}			-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/IN_PORT_i

add wave -noupdate -format Logic	-label {COPYBLAZE interrupt}		-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Interrupt_i
add wave -noupdate -format Logic	-label {COPYBLAZE interrupt_ack}	-radix hexadecimal /tb_copyBlaze_ecoSystem/uut/processor/Interrupt_Ack_o
