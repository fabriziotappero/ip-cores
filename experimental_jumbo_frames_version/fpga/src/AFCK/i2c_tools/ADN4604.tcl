global ADN4604_adr
set ADN4604_adr 75
proc ADN4604_read { reg_nr } {
  global ADN4604_adr
  i2c_write $ADN4604_adr [list $reg_nr]
  return [i2c_single_read $ADN4604_adr	]
}

proc ADN4604_write { reg_nr val} {
  global ADN4604_adr
  i2c_write $ADN4604_adr [list $reg_nr $val]
}


proc ADN4604_dump_regs {first last step} {
  global ADN4604_adr
  for {set ad [expr $first]} {$ad <= [expr $last]} {set ad [expr $ad + $step]} {
    puts "[format "0x%x:0x%x" $ad [ADN4604_read $ad]]"
  }
}



