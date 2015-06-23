#package require ::quartus::project
package require ::quartus::flow

if { [is_project_open ] == 0 } {
project_open  mAlt8b10bdec
}

set need_to_close_project 0
set make_assignments 1

set_global_assignment -name AUTO_ROM_RECOGNITION OFF

  set_instance_assignment -name VIRTUAL_PIN ON -to ena
  set_instance_assignment -name VIRTUAL_PIN ON -to idle_ins
  set_instance_assignment -name VIRTUAL_PIN ON -to kerr
  set_instance_assignment -name VIRTUAL_PIN ON -to kin
  set_instance_assignment -name VIRTUAL_PIN ON -to rdcascade
  set_instance_assignment -name VIRTUAL_PIN ON -to rdforce
  set_instance_assignment -name VIRTUAL_PIN ON -to rdin
  set_instance_assignment -name VIRTUAL_PIN ON -to rdout
  set_instance_assignment -name VIRTUAL_PIN ON -to reset_n
  set_instance_assignment -name VIRTUAL_PIN ON -to valid

export_assignments
execute_module -tool map 
# need to re-run quartus_map because
# the netlist is changed by the AUTO_ROM
