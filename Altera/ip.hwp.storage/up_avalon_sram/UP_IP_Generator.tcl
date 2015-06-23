# +----------------------------------------------------------------------------+
# | License Agreement                                                          |
# |                                                                            |
# | Copyright (c) 1991-2009 Altera Corporation, San Jose, California, USA.     |
# | All rights reserved.                                                       |
# |                                                                            |
# | Any megafunction design, and related net list (encrypted or decrypted),    |
# |  support information, device programming or simulation file, and any other |
# |  associated documentation or information provided by Altera or a partner   |
# |  under Altera's Megafunction Partnership Program may be used only to       |
# |  program PLD devices (but not masked PLD devices) from Altera.  Any other  |
# |  use of such megafunction design, net list, support information, device    |
# |  programming or simulation file, or any other related documentation or     |
# |  information is prohibited for any other purpose, including, but not       |
# |  limited to modification, reverse engineering, de-compiling, or use with   |
# |  any other silicon devices, unless such use is explicitly licensed under   |
# |  a separate agreement with Altera or a megafunction partner.  Title to     |
# |  the intellectual property, including patents, copyrights, trademarks,     |
# |  trade secrets, or maskworks, embodied in any such megafunction design,    |
# |  net list, support information, device programming or simulation file, or  |
# |  any other related documentation or information provided by Altera or a    |
# |  megafunction partner, remains with Altera, the megafunction partner, or   |
# |  their respective licensors.  No other licenses, including any licenses    |
# |  needed under any third party's intellectual property, are provided herein.|
# |  Copying or modifying any file, or portion thereof, to which this notice   |
# |  is attached violates this copyright.                                      |
# |                                                                            |
# | THIS FILE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    |
# | IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,   |
# | FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL    |
# | THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER |
# | LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING    |
# | FROM, OUT OF OR IN CONNECTION WITH THIS FILE OR THE USE OR OTHER DEALINGS  |
# | IN THIS FILE.                                                              |
# |                                                                            |
# | This agreement shall be governed in all respects by the laws of the State  |
# |  of California and by the laws of the United States of America.            |
# |                                                                            |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# | Created by the Altera University Program                                   |
# |  for use with the Altera University Program IP Cores                       |
# |                                                                            |
# | Version: 1.0                                                               |
# |                                                                            |
# +----------------------------------------------------------------------------+

proc up_generate {dest_path src_path new_module_name params_str sections_str} {
#	send_message info "Starting UP Generation from $src_path to $dest_path"

	set src_file [ open "$src_path" "r" ]
	set dest_file [ open "$dest_path" "w" ]

	set src_module [ read $src_file ]

	set dest_module [ up_modify_sections $src_module $sections_str ]
	set dest_module [ up_modify_module_name $dest_module $new_module_name ]
	set dest_module [ up_modify_params $dest_module $params_str ]
	set dest_module [ string trim $dest_module ]
	set dest_module "$dest_module\n"

	puts $dest_file $dest_module

	close $dest_file
	close $src_file
}

proc up_modify_module_name {module_str new_module_name} {
	set module_list [ split $module_str "\n" ]

	foreach line $module_list {
		if { [ string match "module*" $line ] } {
			append dest_module "\n" "module $new_module_name ("
		} else {
			append dest_module "\n" $line
		}
	}

	return $dest_module
}

proc up_modify_params {module_str params_str} {
	set params_list [ split $params_str ":;" ]
	set module_list [ split $module_str "\n" ]

	foreach line $module_list {
		if { [ string match "parameter*" $line ] } {
			set param [ split $line "=;" ]
			set param_name [ string trim [ join [ split [ lindex $param 0 ] "parameter" ] "" ] ]
			
			append dest_module "\n" [ lindex $param 0 ]
			if { [ string match "*$param_name:*" $params_str ] } {
				append dest_module "= " [ string map $params_list $param_name ]
			} else {
				append dest_module "=" [ lindex $param 1 ]
			}
			append dest_module ";" [ lindex $param 2 ]
		} else {
			append dest_module "\n" $line
		}
	}

	return $dest_module
}

proc up_modify_sections {module_str sections_str} {
	set sections_list [ split $sections_str ":;" ]
	set module_list [ split $module_str "\n" ]

#	send_message info "Starting UP Modify Sections with $sections_list"

	set recursive_ifs "0:1:1"
	set in_ifdef 0
	set allow_lines 1
	set valid_lines 1

	set line_num 0

	foreach line $module_list {
		set line_num [ expr $line_num + 1 ]
		if { [ string match "`if*" $line ] } {
			lappend recursive_ifs "$in_ifdef:$allow_lines:$valid_lines"
#			send_message info "In ifdef |$recursive_ifs| at $line_num"
			set in_ifdef 1
			set allow_lines [ expr ($valid_lines && $allow_lines) ]
			if { [ string match "`ifdef*" $line ] } {
				set section_name [ string trim [ join [ split $line "`ifdef" ] "" ] ]
				set valid_lines [ expr ([ string match "*$section_name:*" $sections_str ] && [ string map $sections_list $section_name ]) ]
			} else {
				set section_name [ string trim [ join [ split $line "`ifndef" ] "" ] ]
				set valid_lines [ expr ([ string match "*$section_name:*" $sections_str ] && (!([ string map $sections_list $section_name ])) ]
			}
			set valid_lines [ expr ($valid_lines && $allow_lines) ]

#			if { $valid_lines } {
#				send_message info "$section_name is a valid section $in_ifdef:$allow_lines:$valid_lines"
#			} else {
#				send_message info "$section_name is NOT a valid section $in_ifdef:$allow_lines:$valid_lines"
#			}
			
		} elseif { [ string match "`elsif*" $line ] } {
			if { !($in_ifdef) } {
				send_message error "Unexpected `elsif statement at line $line_num"
			}
			set allow_lines [ expr (!($valid_lines) & $allow_lines) ] 
			set section_name [ string trim [ join [ split $line "`elsif" ] "" ] ]
			set valid_lines [ expr ([ string match "*$section_name:*" $sections_str ] && [ string map $sections_list $section_name ]) ]
			set valid_lines [ expr ($valid_lines && $allow_lines) ]

		} elseif { [ string match "`else*" $line ] } {
			if { !($in_ifdef) } {
				send_message error "Unexpected `else statement at line $line_num"
			}
			set allow_lines [ expr (!($valid_lines) & $allow_lines) ] 
			set valid_lines $allow_lines

		} elseif { [ string match "`endif*" $line ] } {
			if { !($in_ifdef) } {
				send_message error "Unexpected `endif statement at line $line_num"
			}
			set old_if [ split [ lindex $recursive_ifs end ] ":" ]
#			send_message info "New data |$recursive_ifs| |$old_if| at $line_num"
			set in_ifdef [ lindex $old_if 0 ]
			set allow_lines [ lindex $old_if 1 ]
			set valid_lines [ lindex $old_if 2 ]
			set recursive_ifs [ lrange $recursive_ifs 0 end-1 ] 
#			send_message info "New data $in_ifdef $valid_lines $allow_lines at $line_num"

		} elseif { $valid_lines } {
			append dest_module "\n" $line
		}
	}

	return $dest_module
}

