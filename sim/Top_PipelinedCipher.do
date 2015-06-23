vlib work
vlog ../rtl/SBox.v
vlog ../rtl/SubBytes.v
vlog ../rtl/ShiftRows.v
vlog ../rtl/MixColumns.v
vlog ../rtl/AddRoundKey.v
vlog ../rtl/Round.v
vlog ../rtl/RoundKeyGen.v
vlog ../rtl/KeyExpantion.v
vlog ../rtl/Top_PipelinedCipher.v
vlog ../sim/Top_PipelinedCipher_tb.v
vsim -novopt Top_PipelinedCipher_tb
run -a
