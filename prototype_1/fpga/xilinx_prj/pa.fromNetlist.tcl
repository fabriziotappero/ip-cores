
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name proto1 -dir "J:/projekty/elektronika/GPIB/prototype_1/fpga/proto1/planAhead_run_1" -part xc3s200tq144-4
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "J:/projekty/elektronika/GPIB/prototype_1/fpga/proto1/main.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {J:/projekty/elektronika/GPIB/prototype_1/fpga/proto1} }
set_param project.paUcfFile  "J:/projekty/elektronika/GPIB/prototype_1/fpga/proto1/src/main.ucf"
add_files "J:/projekty/elektronika/GPIB/prototype_1/fpga/proto1/src/main.ucf" -fileset [get_property constrset [current_run]]
open_netlist_design
