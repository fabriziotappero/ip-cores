vlog Top_PipelinedCipher_tb.v
vlog ../syn/netgen/par/Top_PipelinedCipher_timesim.v
vsim +define+GATES -novopt -sdfmax /U/=../syn/netgen/par/Top_PipelinedCipher_timesim.sdf -novopt work.Top_PipelinedCipher_tb glbl
run -a