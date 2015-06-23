# AFCK - MUX PCA9547 under 112
# should be written 12 to enable access from FPGA to other chips
#
set vio_path "i2c_vio_ctrl_1"
proc read_vio {name} {
  global vio_path
  refresh_hw_vio [get_hw_vios hw_vio_1]
  set res [get_property INPUT_VALUE [get_hw_probes $vio_path/$name -of_objects [get_hw_vios hw_vio_1]]]
  return $res
}

proc set_vio_now {name val} {
  global vio_path
  #puts "val=$val name=$name"
  set_property OUTPUT_VALUE $val [get_hw_probes $vio_path/$name -of_objects [get_hw_vios hw_vio_1]]
  commit_hw_vio [get_hw_probes $vio_path/$name -of_objects [get_hw_vios hw_vio_1]]
}

proc set_vio {name val} {
  global vio_path
  set_property OUTPUT_VALUE $val [get_hw_probes $vio_path/$name -of_objects [get_hw_vios hw_vio_1]]
}
proc com_set_vio {} {
  global vio_path
  commit_hw_vio [get_hw_probes [list $vio_path/vrst_n $vio_path/i2c_rst_n $vio_path/din $vio_path/addr $vio_path/rd_nwr $vio_path/cs]]
}

proc i2c_reg_write {ad dana} {
  set_vio addr $ad
  set_vio din $dana
  set_vio rd_nwr 0
  com_set_vio
  set_vio_now cs 1
  set_vio_now cs 0
}

proc i2c_reg_read {ad } {
  set_vio addr $ad
  set_vio rd_nwr 1
  com_set_vio
  set_vio_now cs 1
  set_vio_now cs 0
  refresh_hw_vio [get_hw_vios hw_vio_1]
  set res [read_vio dout]
  return $res
}

proc i2c_write {ad dta} {
    i2c_reg_write 3 [expr $ad << 1] 
    # Transmit
    i2c_reg_write 4 [expr 128 | 16] 
    # Cmd: STA+WR
    #Wait for ACK
    while { 1 } {
       set st [i2c_reg_read 4]
       if {[expr ($st & 2) == 0]} break
       if {[expr ($st & 128) != 0]} {
          #Error - NACK
          error "NACK in address"
       }
    }
    set i [llength $dta]
    foreach d $dta {
       set i [expr $i - 1]
       i2c_reg_write 3 [expr $d]
       if {[expr $i == 0]} { 
	 i2c_reg_write 4 [expr 64 | 16]
       } else {
         i2c_reg_write 4 16
       }
       while { 1 } {
          set st [i2c_reg_read 4]
          if {[expr ($st & 2) == 0]} break
          }
       if {[expr ($st & 0x80) != 0]} {
          #Error - NACK
          error "NACK in data"
          }
     }
}

proc i2c_single_read {ad} {
    i2c_reg_write 3 [expr ($ad << 1)|1]
    # Receive
    i2c_reg_write 4 [expr 128 | 16]
    # Cmd: STA+WR
    #Wait for ACK
    while { 1 } {
       set st [i2c_reg_read 4]
       #puts "st=$st in addr"
       if {[expr ($st & 2) == 0]} break
    }
    if {[expr ($st & 128) != 0]} {
          #Error - NACK
          error "NACK in address"
    }
    i2c_reg_write 4 [expr 64 | 32 | 8] 
    while { 1 } {
       set st [i2c_reg_read 4]
       #puts "st=$st in data"
       if {[expr ($st & 2) == 0]} break
       }
    #if {[expr ($st & 128) != 0]} {
    #      #Error - NACK
    #      error "NACK in data"
    #}
    set res [i2c_reg_read 3]
    return $res
}

proc i2c_multi_read {ad num} {
    i2c_reg_write 3 [expr ($ad << 1)|1]
    # Receive
    i2c_reg_write 4 [expr 128 | 16]
    # Cmd: STA+WR
    #Wait for ACK
    while { 1 } {
       set st [i2c_reg_read 4]
       puts "st=$st in addr"
       if {[expr ($st & 2) == 0]} break
    }
    if {[expr ($st & 128) != 0]} {
          #Error - NACK
          error "NACK in address"
    }
    set res [list ]
    while {$num > 0} {
       if {[expr $num == 1]} {
          i2c_reg_write 4 [expr 64 | 32 | 8 ] 
       } else {
          i2c_reg_write 4 [expr 32 ] 
       }
       while { 1 } {
         set st [i2c_reg_read 4]
         puts "st=$st in data"
         if {[expr ($st & 2) == 0]} break
         }
       lappend res [i2c_reg_read 3]
       if {[expr ($st & 128) != 0]} {
          # NACK - no more data
          break
          }
       set num [expr $num - 1]
    }
    return $res
}

open_hw
current_hw_target [get_hw_targets *]
current_hw_device [lindex [get_hw_devices] 0]
foreach node [list vrst_n i2c_rst_n din addr rd_nwr cs] {
   set_property OUTPUT_VALUE_RADIX UNSIGNED [get_hw_probes $vio_path/$node -of_objects [get_hw_vios hw_vio_1]]
}
foreach node [list dout] {
   set_property INPUT_VALUE_RADIX UNSIGNED [get_hw_probes $vio_path/$node -of_objects [get_hw_vios hw_vio_1]]
}
set_vio_now vrst_n 0
set_vio_now vrst_n 1
set_vio_now i2c_rst_n 1
i2c_reg_write 0 200
i2c_reg_write 1 0
i2c_reg_write 2 128
#i2c_write 112 [list 12]
#i2c_single_read 76

