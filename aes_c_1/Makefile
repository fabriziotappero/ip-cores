DEVICE=xc6slx75-3csg484

sim_aes: scripts/aes_enc.do
	vsim -do scripts/aes_enc.do

sim_aes_fsm: scripts/aes_fsm_enc.do
	vsim -do scripts/aes_fsm_enc.do

syn_aes: 
	  echo "run -ifn synthesis/aes_enc.prj -ifmt VHDL -ofn aes_enc -p \
	        $(DEVICE) -opt_mode Speed -opt_level 1" | xst
syn_aes_fsm: 
	  echo "run -ifn synthesis/aes_fsm_enc.prj -ifmt VHDL -ofn aes_enc -p \
	        $(DEVICE) -opt_mode Speed -opt_level 1" | xst	     
clean:
	rm -rf transcript work vsim.wlf *.rlf *.vstf *~ *.xrpt *.ngc _xmsgs  xst .lso

	
		