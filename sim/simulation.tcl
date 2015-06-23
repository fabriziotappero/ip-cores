
#default type
if { ! [info exists type] } {
	set type "functional";
}

#default arguments
if { ! [info exists infile] } {
	set infile "sim/vectors.txt";
}
if { ! [info exists outfile] } {
	set outfile "sim/results.txt";
}
if { ! [info exists sdffile] } {
	set sdffile "./rep/nom.sdf";
}
if { ! [info exists vcdfile] } {
	set vcdfile "./post_syn/nom.vcd";
}

puts "Modelsim starting $type simulation"

#functional simulation
if { ! [ string compare -nocase $type "FUNCTIONAL" ] } {
	vsim -gINFILE=${infile} -gOUTFILE=${outfile} -t ns -novopt work.tb(post_syn) -novopt

#timing simulation
} else {
	vsim -gINFILE=${infile} -gOUTFILE=${outfile} -sdfmax /tb/dut/=$sdffile -sdfnoerror -t ps -novopt work.tb(post_syn) +no_notifier
	vcd file $vcdfile
	vcd add -r /tb/dut/*
}

run -all;
quit -sim
exit

