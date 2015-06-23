rm *.o *.vcd

export HEADER=$PWD/header
export SOURCE=./source

g++ -I$SYSTEMC_HOME/include -I$HEADER -L$SYSTEMC_HOME/lib-linux $SOURCE/cicDecimator.cpp -lsystemc -lm -o cic.o
./cic.o
gtkwave wave.vcd
