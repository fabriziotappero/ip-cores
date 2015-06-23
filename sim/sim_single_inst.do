echo Testing different word lengths...
vsim -novopt -quiet -Ginput_word_size=2 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=3 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=4 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=5 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=6 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=8 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=10 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=12 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=21 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=30 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

echo Testing subtractions...

vsim -novopt -quiet -Ginput_word_size=20 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=20 -Gsubtract_y=false -Gsubtract_z=true -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=20 -Gsubtract_y=true -Gsubtract_z=false -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

vsim -novopt -quiet -Ginput_word_size=20 -Gsubtract_y=true -Gsubtract_z=true -Guse_output_ff=false work.tb_ternary_adder;
run $simtime

echo Testing output FF...

vsim -novopt -quiet -Ginput_word_size=13 -Gsubtract_y=false -Gsubtract_z=false -Guse_output_ff=true work.tb_ternary_adder;
run $simtime

