===================================================
Installation steps to run socgen on Ubuntu 10.10
===================================================

Install ubuntu 10.10

sudo apt-get  install -y subversion;

svn co --username <<>> --password <<>> http://opencores.org/ocsvn/socgen/socgen/trunk socgen;\

cd socgen/tools/install/Ubuntu_10.10

make install  ( adds ~/bin into your $PATH)


cd socgen/tools/JtagProgrammer

make install  ( adds urjtag tools)

reboot

cd socgen

make build_soc

make run_sims

make build_fpgas     (if you have xilinx webpack 12.4 installed)

---------------------------

Enable HW drivers
update
Install  make composite
Install_cmp make   crasm, or-32 msp430
install  fpga  
