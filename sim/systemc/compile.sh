
clear

verilator --trace -f verilator.cmd

cd obj_dir

make -f Vxge_mac.mk Vxge_mac__ALL.a

make -f ../sc.mk crc.o

make -f ../sc.mk sc_packet.o

make -f ../sc.mk sc_pkt_generator.o

make -f ../sc.mk sc_scoreboard.o

make -f ../sc.mk sc_xgmii_if.o

make -f ../sc.mk sc_pkt_if.o

make -f ../sc.mk sc_cpu_if.o

make -f ../sc.mk sc_testbench.o

make -f ../sc.mk sc_testcases.o

make -f ../sc.mk sc_main.o

make -f ../sc.mk verilated.o

make -f ../sc.mk verilated_vcd_c.o

make -f ../sc.mk verilated_vcd_sc.o

g++ -L$SYSTEMC/lib-linux -L$SYSTEMC/lib-linux64 sc_main.o sc_testcases.o sc_testbench.o sc_pkt_if.o sc_xgmii_if.o sc_cpu_if.o sc_pkt_generator.o sc_scoreboard.o sc_packet.o crc.o Vxge_mac__ALLcls.o Vxge_mac__ALLsup.o verilated.o verilated_vcd_c.o verilated_vcd_sc.o -o Vxge_mac -lsystemc

cd ..
