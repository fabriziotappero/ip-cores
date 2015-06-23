#!/usr/bin/tclsh

set fbin [open bin2v.bin r]
fconfigure $fbin -translation binary
set f_out [open bin2v.mem w]

while (1) {
    set line [read  $fbin 1]

    if {[eof $fbin]} {
        break
    }

    binary scan $line H* value
    puts $f_out $value 
}

close $f_out
close $fbin

exit 0

