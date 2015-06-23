g++ -I$SYSTEMC_HOME/include -L$SYSTEMC_HOME/lib-linux firTF.cpp -lsystemc -o firTF.o
./firTF.o
gtkwave wave.vcd &
gedit fir_output.txt &
