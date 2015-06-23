set_project_params -directory ./
set_project_params -results myboard.txt
set_project_params -sources "synth_src/connect6.cpp synth_src/connect6_synth.cpp synth_src/main.cpp synth_src/q.cpp synth_src/state.cpp synth_src/threats.cpp synth_src/util.cpp"
set_project_params -headers "synth_src/connect6.h synth_src/connect6_synth.h synth_src/q.hpp synth_src/shared.h synth_src/threats.h synth_src/util.h"
set_project_params -cache_result_files no
set_project_params -cache_data_files yes

if [file exists imp_line] { delete_implementation imp_line }
create_implementation imp_board

set_implementation_params -systemc_source no
set_implementation_params -memory_return_path_external_delay 0%
set_implementation_params -memory_forward_path_external_delay 0%
set_implementation_params -instream_forward_path_external_delay 0%
set_implementation_params -sccompiler_args "-DDONT_VERIFY_PPAID -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g -g"
set_implementation_params -outstream_return_path_external_delay 0%
set_implementation_params -appfiles "synth_src/state.cpp"
set_implementation_params -proc board_copy
set_implementation_params -memory_forward_boundary_register infer
set_implementation_params -cppcompiler_args "-g -DPICO_SYNTH -fpermissive"
set_implementation_params -task_ii 441
set_implementation_params -techlib altera-cyclone3
set_implementation_params -device ep3c25-ea144-7
set_implementation_params -init_data_registers yes
set_implementation_params -memory_return_boundary_register infer
set_implementation_params -cexec_args "-port /dev/ttyS0 -player L"
set_implementation_params -host_memory_access never
set_implementation_params -outstream_forward_path_external_delay 0%
set_implementation_params -build_tcab yes
set_implementation_params -reset_data_registers yes
set_implementation_params -task_overlap 0
set_implementation_params -instream_return_path_external_delay 0%
set_implementation_params -simulator modelsim
set_implementation_params -clock_freq 50


setvar preprocess_auxopts "-L"

 
csim  -golden  -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -cexec_args "-port /dev/ttyS0 -player L"
preprocess 
csim  -preprocess  -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -cexec_args "-port /dev/ttyS0 -player L"
schedule 
csim  -schedule  -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -cexec_args "-port /dev/ttyS0 -player L"
synthesize 
create_rtl_package  -force 

