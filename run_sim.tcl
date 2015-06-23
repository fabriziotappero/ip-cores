vlib work
vmap work work

alias com {
vlog -sv "./mem.sv"
vlog -sv "./package.sv"
vlog -sv "./qrisc32_EX.sv"
vlog -sv "./qrisc32_ID.sv"
vlog -sv "./qrisc32_IF.sv"
vlog -sv "./qrisc32_MEM.sv"
vlog -sv "./qrisc32.sv"
vlog -sv "./qrisc32_TB.sv"
}


alias tb_run {
vsim -novopt work.qrisc32_tb
onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /qrisc32_tb/UUT/clk
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/reset
add wave -noupdate -divider {pipe stalled}
add wave -noupdate /qrisc32_tb/UUT/pipe_stall
add wave -noupdate -divider {Instruction bus}
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_instructions_data
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_instructions_addr
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_instructions_rd
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_instructions_wait_req
add wave -noupdate -divider {Data Read Bus}
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_datar_data
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_datar_addr
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_datar_rd
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_datar_wait_req
add wave -noupdate -divider {Data Write Bus}
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_dataw_data
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_dataw_addr
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_dataw_wr
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/avm_dataw_wait_req
add wave -noupdate -divider Registers
add wave -noupdate -radix hexadecimal /qrisc32_tb/UUT/qrisc32_ID/rf
run -all
}


echo "For compile type command com"
echo "For run simulation type command tb_run"

