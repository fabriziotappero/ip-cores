g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux fir.cpp -lsystemc -lm -o fir.o
./fir.o
gtkwave wave.vcd
