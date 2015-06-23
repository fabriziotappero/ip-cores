GCC=g++ -g -DPICO_SYNTH -I/opt/synopsys/scc/synphonycc-fpga-vE-2010.12-SP1/pico/simu/include -I./synth_src
GCC_LINK= g++ -L/opt/synopsys/scc/synphonycc-fpga-vE-2010.12-SP1/pico/simu/src/SimCode/ -lpdextn -lnosimdump -lsimerror -L/opt/synopsys/scc/synphonycc-fpga-vE-2010.12-SP1/pico/edgcpfe/lib/ -lpthread -lm -lstdc++ -lC
SCC=schroot -c centos5-i386 ~/bin/synphonycc_fpga
SCC_SCRIPTS=./scc_scripts
SYNTH_SRC=./synth_src



GCC_LINK=g++ /opt/synopsys/scc/synphonycc-fpga-vE-2010.12-SP1/pico/simu/src/SimCode/golden.o  -L/opt/synopsys/scc/synphonycc-fpga-vE-2010.12-SP1/pico/simu/src/SimCode/ -lpdextn -lnosimdump -lsimerror -L/opt/synopsys/scc/synphonycc-fpga-vE-2010.12-SP1/pico/edgcpfe/lib/ -lpthread -lm -lstdc++ -lC

all: fpt_connect6 test_golden
emul:
	${GCC} -c -g -pg -DEMUL ${SYNTH_SRC}/main.cpp
	${GCC} -c -g -pg -DEMUL ${SYNTH_SRC}/connect6.cpp
	make -C ./ fpt_connect6

fpt_connect6: main.o util.o connect6.o connect6_synth.o state.o threats.o q.o 
	${GCC_LINK} -o connect6 main.o q.o util.o connect6.o connect6_synth.o state.o threats.o  -lpthread -lm -g -pg
main.o:${SYNTH_SRC}/main.cpp
	${GCC} -c -g -pg ${SYNTH_SRC}/main.cpp
connect6_synth.o: ${SYNTH_SRC}/connect6_synth.cpp ${SYNTH_SRC}/connect6_synth.h
	${GCC} -c -g -pg ${SYNTH_SRC}/connect6_synth.cpp
connect6.o: ${SYNTH_SRC}/connect6.cpp ${SYNTH_SRC}/connect6.h
	${GCC} -c -g -pg ${SYNTH_SRC}/connect6.cpp

util.o: ${SYNTH_SRC}/util.cpp ${SYNTH_SRC}/util.h
	${GCC} -c -g -pg ${SYNTH_SRC}/util.cpp
state.o:${SYNTH_SRC}/state.cpp ${SYNTH_SRC}/shared.h
	${GCC} -c -g -pg ${SYNTH_SRC}/state.cpp
	
threats.o:${SYNTH_SRC}/threats.cpp ${SYNTH_SRC}/shared.h
	${GCC} -c -g -pg ${SYNTH_SRC}/threats.cpp
q.o:${SYNTH_SRC}/q.cpp ${SYNTH_SRC}/shared.h
	${GCC} -c -g -pg ${SYNTH_SRC}/q.cpp


test_golden:
	./connect6 -player L

clean:
	rm -f *.o connect6 gmon.out myboard.txt




#first the c/c++ source should be compiled
fpga: synth altera_synth test
	cp cp ./rtl_package/synth/altera_fpga/run/DE2.sof ../DEMO

synth: imp_connect.tag
imp_window.tag:
	#sed -s 's/\\TCAB_NAME/threat_window/g' main.cpp.base >main.cpp
	cp ${SYNTH_SRC}/main.cpp.base ${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_window.tcl
	echo "Done" > imp_window.tag
imp_line.tag: imp_window.tag
	sed -s 's/\\TCAB_NAME/threat_line/g' ${SYNTH_SRC}/main.cpp.base >${SYNTH_SRC}/main.cpp
	#cp ${SYNTH_SRC}/main.cpp.base ${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_line.tcl
	echo "Done" > imp_line.tag
imp_marks.tag:
	sed -s 's/\\TCAB_NAME/ai_marks/g' ${SYNTH_SRC}/main.cpp.base >${SYNTH_SRC}/main.cpp
	#cp ${SYNTH_SRC}/main.cpp.base ${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_marks.tcl
	echo "Done" > imp_marks.tag
imp_sort.tag:
	sed -s 's/\\TCAB_NAME/streamsort/g' ${SYNTH_SRC}/main.cpp.base >${SYNTH_SRC}/main.cpp
	#cp ${SYNTH_SRC}/main.cpp.base ${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_sort.tcl
	echo "Done" > imp_sort.tag
imp_threat.tag: imp_line.tag 
	sed -s 's/\\TCAB_NAME/ai_threats/g' ${SYNTH_SRC}/main.cpp.base >${SYNTH_SRC}/main.cpp
	#cp ${SYNTH_SRC}/main.cpp.base ${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_threat.tcl
	echo "Done" > imp_threat.tag
imp_adjacent.tag:
	#cp ${SYNTH_SRC}/main.cpp.base ${SYNTH_SRC}/main.cpp
	sed -s 's/\\TCAB_NAME/ai_adjacent/g' ${SYNTH_SRC}/main.cpp.base >${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_adjacent.tcl
	echo "Done" > imp_adjacent.tag
imp_connect.tag: imp_threat.tag imp_adjacent.tag
	sed -s 's/\\TCAB_NAME/connect6ai_synth/g' ${SYNTH_SRC}/main.cpp.base >${SYNTH_SRC}/main.cpp
	${SCC} ${SCC_SCRIPTS}/run_imp_connect.tcl
	echo "Done" > imp_connect.tag

xilinx_synth:
	cp -r ./imp_connect/rtl_package/ ./
	cp SP6/SP6.do_synth imp_connect/rtl_package/synth/synplify_fpga/do_synth
	cp SP6/SP6.synplify.tcl imp_connect/rtl_package/synth/synplify_fpga/synplify.tcl
	cp SP6/SP6.ucf imp_connect/rtl_package/synth/synplify_fpga/
	echo -e 'all:\n\t./do_synth' > imp_connect/rtl_package/synth/synplify_fpga/makefile
	make -C imp_connect/rtl_package/synth/synplify_fpga/

test: 
	schroot -c centos5-i386 make emul
	#../scripts/serial_port_setup.sh
	rm -f ./test.result
	for i in `seq 1 100` ; do  ./connect6 -port /dev/ttyS0 -player L >> test.result 2>&1; done
	#grep "FPGA has won" ./test.result | wc -l
	#grep "AI has won" ./test.result | wc -l
	#grep "TIE" ./test.result | wc -l
	python ../scripts/esult.py
pgm:
	cp ./rtl_package/synth/altera_fpga/run/DE2.sof ./
	quartus_pgm -c USB-Blaster -m jtag  -o "p;DE2.sof"


prof:
	valgrind --tool=callgrind  ./connect6 -player L
	kcachegrind
	
altera_clean:
	rm -rf ./rtl_package/
	
ultraclean: altera_clean
	rm -rf *.tag imp_line imp_marks imp_threat imp_choose imp_adjacent imp_connect imp_window Logs
