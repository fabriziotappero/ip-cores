set_global_assignment -name ROOT "|ClaiRISC_core" -remove 
set_global_assignment -name FAMILY -remove 
set_global_assignment -section_id clk_setting -name DUTY_CYCLE "50.00" -remove 
set_instance_assignment -entity ClaiRISC_core -to clk -name GLOBAL_SIGNAL ON -remove 
set_instance_assignment -entity ClaiRISC_core -to clk -name USE_CLOCK_SETTINGS clk_setting -remove 
set_global_assignment -section_id clk_setting -name FMAX_REQUIREMENT "120.7MHZ" -remove 
set_global_assignment -name TAO_FILE "myresults.tao" -remove
set_global_assignment -name SOURCES_PER_DESTINATION_INCLUDE_COUNT "1000" -remove 
set_global_assignment -name ROUTER_REGISTER_DUPLICATION ON -remove 
set_global_assignment -name REMOVE_DUPLICATE_LOGIC "OFF" -remove 
set_global_assignment -name REMOVE_DUPLICATE_REGISTERS "OFF" -remove 
set_global_assignment -name REMOVE_REDUNDANT_LOGIC_CELLS "ON" -remove 
set_global_assignment -name EDA_RESYNTHESIS_TOOL "AMPLIFY" -remove
