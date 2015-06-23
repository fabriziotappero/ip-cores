DEVICE=xc6slx75-3csg484

all: sim

sim_key: scripts/sim.do
	vsim -do scripts/sim.do
syn_key: 
	  echo "run -ifn synthesis/key_schedule.prj -ifmt VHDL -ofn aes_enc -p \
	        $(DEVICE) -opt_mode Speed -opt_level 1" | xst	     
clean:
	rm -rf transcript work vsim.wlf *.rlf *.vstf *~ *.xrpt *.ngc _xmsgs  xst .lso

	
		