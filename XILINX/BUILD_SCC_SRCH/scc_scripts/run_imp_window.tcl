
set SYNTH_SRC "synth_src"
set_project_params -directory ./
set_project_params -results myboard.txt
set_project_params -sources "${SYNTH_SRC}/connect6.cpp ${SYNTH_SRC}/connect6_synth.cpp ${SYNTH_SRC}/main.cpp ${SYNTH_SRC}/q.cpp ${SYNTH_SRC}/state.cpp ${SYNTH_SRC}/threats.cpp ${SYNTH_SRC}/util.cpp ${SYNTH_SRC}/search_bfs.cpp"
set_project_params -headers "${SYNTH_SRC}/connect6.h ${SYNTH_SRC}/connect6_synth.h ${SYNTH_SRC}/q.hpp ${SYNTH_SRC}/shared.h ${SYNTH_SRC}/threats.h ${SYNTH_SRC}/util.h"
set_project_params -cache_result_files no
set_project_params -cache_data_files yes

if [file exists imp_window] { delete_implementation imp_window }
create_implementation imp_window

set_implementation_params -systemc_source no
set_implementation_params -memory_return_path_external_delay 0%
set_implementation_params -memory_forward_path_external_delay 0%
set_implementation_params -instream_forward_path_external_delay 0%
set_implementation_params -sccompiler_args "-DDONT_VERIFY_PPAID"
set_implementation_params -outstream_return_path_external_delay 0%
set_implementation_params -appfiles "synth_src/state.cpp synth_src/threats.cpp"
set_implementation_params -proc threat_window
set_implementation_params -memory_forward_boundary_register infer
set_implementation_params -architectural_pipelinability "1"
set_implementation_params -cppcompiler_args "-g -DPICO_SYNTH -fpermissive"
#set_implementation_params -techlib altera-cyclone3
#set_implementation_params -device ep3c25-ea144-7
set_implementation_params -techlib xilinx-spartan6
set_implementation_params -device xc6slx45t-fgg484-3
set_implementation_params -memory_return_boundary_register infer
set_implementation_params -cexec_args "-port /dev/ttyS0 -player L"
set_implementation_params -host_memory_access never
set_implementation_params -init_data_registers yes
set_implementation_params -outstream_forward_path_external_delay 0%
set_implementation_params -build_tcab yes
set_implementation_params -reset_data_registers yes
set_implementation_params -task_overlap infer
set_implementation_params -instream_return_path_external_delay 0%
set_implementation_params -simulator modelsim
set_implementation_params -clock_freq 50



#set_loop_params -ii 1
 
csim  -golden  -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -cexec_args "-port /dev/ttyS0 -player L"
preprocess 
csim  -preprocess  -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -cexec_args "-port /dev/ttyS0 -player L"
schedule 
csim  -schedule  -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -cexec_args "-port /dev/ttyS0 -player L"
synthesize 
create_rtl_package 
#vlogsim  -online  -ccompiler_args "-g" -cppcompiler_args "-g -DPICO_SYNTH -fpermissive" -sccompiler_args "-DDONT_VERIFY_PPAID" -cexec_args "-port /dev/ttyS0 -player L"  -simulator modelsim  -vcompiler_args   -vexec_args 

