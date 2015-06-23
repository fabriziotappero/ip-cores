===================================================
Installation steps to run socgen on Ubuntu 10.4
===================================================

Install ubuntu 10.04 

sudo apt-get  install -y subversion;

svn co --username <<>> --password <<>> http://opencores.org/ocsvn/socgen/socgen/trunk socgen;\

cd socgen/tools/install/Ubuntu_10.4

make install

reboot

build_cmp socgen

cd socgen_cmp

make run_sims




