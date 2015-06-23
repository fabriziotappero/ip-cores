g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux ppd.cpp -lsystemc -lm -o ppd.o
./ppd.o
gtkwave wave.vcd
