# Makefile for fifo - Functionality Testing and Regression Testing 
RTL = ../rtl/fifo.v
work = work
COVOP = -coveropt 3 +cover=bcft +acc
SVTB1= ../env/fifo_if.sv ../env/fifo_top.sv
INC = +incdir+../env +incdir+../lib
TEST = ../test/fifo_testcase.sv
#TEST1 = ../test/test1.sv
#TEST2 = ../test/test2.sv
VSIMOPT= -coverage -novopt -sva -sv_seed random -l sim_log.txt work.fifo_top
VSIMCOV= coverage save -onexit -assert -directive -cvg -codeAll mem_cov
VSIMBATCH= -c -do "$(VSIMCOV); run -all; exit"

report:
	firefox covhtmlreport/pages/__frametop.htm

lib:
	vlib $(work)
	vmap work $(work)

sv_cmp: lib comp0
         
run_sim:
	vsim $(VSIMOPT) $(VSIMBATCH)    
	vcover report -html mem_cov

gui:
	vsim $(VSIMOPT)
	
comp0:
	vlog -work $(work) $(COVOP) $(RTL) $(SVTB1) $(INC) $(TEST) 
comp1:
	vlog -work $(work) $(COVOP) $(RTL) $(SVTB1) $(INC) $(TEST1) 
comp2:
	vlog -work $(work) $(COVOP) $(RTL) $(SVTB1) $(INC) $(TEST2) 

run_gui: clean lib comp0 gui
run_test: clean lib comp0 run_sim
run_test1: clean lib comp1 run_sim
run_test2: clean lib comp2 run_sim
        

clean:
	rm -rf modelsim.* transcript* vlog.* work vsim.wlf fcover* covhtml* mem_cov* *.txt
	
