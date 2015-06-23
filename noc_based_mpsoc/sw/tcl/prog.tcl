#/usr/bin/tclsh

proc hold_reset {} {
	global device_name usb
	start_insystem_source_probe -device_name $device_name -hardware_name $usb
	write_source_data -instance_index 127 -value 0x1 -value_in_hex
	end_insystem_source_probe
}

proc release_reset {} {
	global device_name usb
	start_insystem_source_probe -device_name $device_name -hardware_name $usb
	write_source_data -instance_index 127 -value 0x0 -value_in_hex
	end_insystem_source_probe
}

## Setup USB hardware - assumes only USB Blaster is installed and
## an FPGA is the only device in the JTAG chain
set usb [lindex [get_hardware_names] 0]
set device_name [lindex [get_device_names -hardware_name $usb] 0]

puts $usb
puts $device_name

#reset all processors
hold_reset 


# Initiate a editing sequence
begin_memory_edit -hardware_name $usb -device_name $device_name

foreach instance \
 [get_editable_mem_instances -hardware_name $usb -device_name $device_name] {
	set inst_name 	[lindex $instance 5]
	set inst_index	[lindex $instance 0]
	#puts $inst_name 
	#puts $inst_index
 	set xx [string range  $inst_name 0 1]
	set yy [string range  $inst_name 2 end]
	#puts $xx
	#puts $yy
	set ram_file_name  ../ram/cpu${xx}_${yy}.mif
	
#update prog memory
	 if {[file exists $ram_file_name] == 1} {
		puts "memory ${inst_name} is programed with  $ram_file_name"
		update_content_to_memory_from_file -instance_index $inst_index -mem_file_path $ram_file_name -mem_file_type mif
	}

}




#set xx 0
#set yy 0
#	for {set yy 0} {$yy<$Y_NODE_NUM} {incr yy} {
#		for {set xx 0} {$xx<$X_NODE_NUM} {incr xx} {
#		set ram_file_name [format "ram/cpu%02d_%02d.mif" $xx $yy]
#		set mem_index	  [format "%02d%02d" $xx $yy]
		
#update prog memory
#		update_content_to_memory_from_file -instance_index $mem_index -mem_file_path $ram_file_name -mem_file_type mif

#puts $ram_file_name\n 
#puts $mem_index\n 
	
#	}}





#End the editing sequence
end_memory_edit

#release reset
release_reset
