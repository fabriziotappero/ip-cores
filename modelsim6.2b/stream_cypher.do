
quit -sim

          vlib work

puts {
          ModelSimSE general compile script version 1.1
            Copyright (c) Doulos June 2004, SD
}

# Simply change the project settings in this section
# for each new project. There should be no need to
# modify the rest of the script.

set library_file_list {
                                   design_library {
                                        ../rtl/stream_cypher.v
                                        ../rtl/stream_iteration.v 
                                        ../rtl/stream_8bytes.v
                                        ../rtl/sboxes.v
                                        ../rtl/sbox1.v
                                        ../rtl/sbox2.v
                                        ../rtl/sbox3.v
                                        ../rtl/stream_byte.v
                                        ../rtl/sbox4.v
                                        ../rtl/sbox5.v
                                        ../rtl/sbox6.v
                                        ../rtl/sbox7.v
                                   }

                                 test_library   {
                                        ../bench/stream_cypher_tb.v
                                        ../bench/decrypt_tb.v
                                         }
}
set top_level              work.stream_cypher_tb

set wave_radices {
                                   hexadecimal {data q}
}


# After sourcing the script from ModelSim for the
# first time use these commands to recompile.

proc r  {} {uplevel #0 source compile.tcl}
proc rr {} {global last_compile_time
            set last_compile_time 0
                        r                            }
                        proc q  {} {quit -force                  }

#Does this installation support Tk?
set tk_ok 1
if [catch {package require Tk}] {set tk_ok 0}

# Prefer a fixed point font for the transcript
set PrefMain(font) {Courier 10 roman normal}

# Compile out of date files
set time_now [clock seconds]
if [catch {set last_compile_time}] {
          set last_compile_time 0
}
foreach {library file_list} $library_file_list {
        vmap work work
                foreach file $file_list {
                        if { $last_compile_time < [file mtime $file] } {
                                if [regexp {.vhdl?$} $file] {
                                        vcom -93 $file
                                } else {
                                        vlog $file
                                }
                                set last_compile_time 0
                        }
                }
}
set last_compile_time $time_now

# Load the simulation
vsim $top_level -pli ../bench/csa_pli.sl


add wave -r /*

radix -hexadecimal 

# Run the simulation
run -all



