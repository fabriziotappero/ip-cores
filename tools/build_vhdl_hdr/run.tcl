set fNames [glob ../../src/*.vhd]

foreach {fName} "$fNames" {
   set points ...
   puts "Modifying file $fName$points"
   exec build_vhdl_hdr.exe $fName template_hdr
}
