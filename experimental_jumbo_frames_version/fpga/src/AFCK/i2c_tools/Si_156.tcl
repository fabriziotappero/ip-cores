set Si57x_adr [expr 0x55]
set I2C_MUX_adr 112

proc Si57x_write_reg {adr val} {
  global Si57x_adr
  i2c_write $Si57x_adr [list $adr $val]
}

proc Si57x_read_reg {adr} {
  global Si57x_adr
  i2c_write $Si57x_adr [list $adr]
  set res [i2c_single_read $Si57x_adr]
  return $res
}

proc SiSetFrq {frq} {
 global I2C_MUX_adr
 #Save old mux setting and set mux to Si57x
 set oldmux [i2c_single_read $I2C_MUX_adr]
 i2c_write $I2C_MUX_adr [list 10]
 #Reset Silabs to initial settings
 Si57x_write_reg 0x87 0x01
 #Now read rfreq
 set r7 [Si57x_read_reg 7]
 set hsdiv [expr ($r7 & 0xe0)>>5]
 set hsdiv [expr $hsdiv+4]
 set n1 [expr ($r7 & 0x1f)<<2]
 set r8 [Si57x_read_reg 8] 
 set n1 [expr $n1 | (($r8 & 192)>>6)]
 set n1 [expr $n1 + 1]
 set rfreq [expr $r8 & 63]
 set adr 9
 while {$adr<=12} {
   set rfreq [expr $rfreq * 256]
   set rfreq [expr [Si57x_read_reg $adr] | $rfreq]
   incr adr
   }
 set fxtal [expr 100e6*(1<<28)/$rfreq*$hsdiv*$n1]
 #Print the xtal frequency
 puts "fxtal=$fxtal frq=$frq"
 #Calculate the new values
 #To minimize the power consumption, we look for the minimal
 #value of N1 and maximum value of HSDIV, keeping the 
 #DCO=frq*N1*HSDIV in range 4.85 to 5.67 GHz
 #We browse possible values of N1 and hsdiv looking for the best
 #combination
 #Below is the list of valid N1 values
 set hsdvals {{7 11.0} {5 9.0} {3 7.0} {2 6.0} {1 5.0} {0 4.0}}
 #set hsdvals {{0 4.0} {1 5.0} {2 6.0} {3 7.0} {5 9.0} {7 11.0}}
 set found 0
 foreach hsdl $hsdvals {
   set hsdr [lindex $hsdl 0]
   set hsdv [lindex $hsdl 1]
   puts "hsdr=$hsdr hsdv=$hsdv"
   #Now we check possible hsdiv values and take the greatest
   #matching the condition
   set n1v 1
   while {$n1v<=128} {
      set fdco [expr $frq * $n1v]
      set fdco [expr $fdco * $hsdv]
      puts "frq=$frq fdco=$fdco n1v=$n1v hsdv=$hsdv"
      if {($fdco >= 4.85e9) & ($fdco <= 5.67e9)} {
         set found 1
         break
      }
      if {$n1v<2} {
        set n1v [expr $n1v+1]
      } else {
        set n1v [expr $n1v+2]
      }
   }
   if {$found==1} {
      break
   }
 }
 #Check if the proper value was found
 if {$found==0} {
   error "Proper values N1 HSDIV not found"
 } else {
   puts "fdco=$fdco N1=$n1v HSDIV=$hsdv"
 }	
 #Calculate the nfreq
 set nfreq [expr int($fdco*(1<<28)/$fxtal + 0.5)]
 puts [format %x $nfreq]
 Si57x_write_reg 0x89 0x10
 Si57x_write_reg 0x87 0x30
 #Decrement n1v, before writing to the register
 set n1v [expr $n1v-1]
 #Now store the values
 set r7 [expr ($hsdr << 5) | ($n1v>>2)]
 puts [format "r7: %x" $r7]
 Si57x_write_reg 7 $r7
 set adr 12
 while {$adr>8} {
   set rval [expr $nfreq & 255]
   puts [format "r%d: %x" $adr $rval]
   Si57x_write_reg $adr $rval
   set nfreq [expr $nfreq >> 8]
   set adr [expr $adr - 1]
 }
 set rval [expr (($n1v & 0x3)<<6) | $nfreq]
 Si57x_write_reg 8 $rval
 puts [format "r8: %x" $rval]
 Si57x_write_reg 0x89 0x00
 Si57x_write_reg 0x87 0x40
 i2c_write $I2C_MUX_adr [list $oldmux] 
}

