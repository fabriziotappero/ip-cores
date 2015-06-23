===================================================
Installation steps to run socgen on Ubuntu 12.10
===================================================

Install ubuntu 12.10

update software

sudo apt-get  install -y subversion;

svn co --username <<>> --password <<>> http://opencores.org/ocsvn/socgen/socgen/trunk socgen;\

sudo sed -i  "s/enabled=1/enabled=0/g"   /etc/default/apport    ( this stops error messaging pop-ups  )

cd  ~/socgen/tools/install/Ubuntu12.10  
make install                                         ( Note: this overwrites ~/.profile !!!!)

Install or32-elf toolchain in ~
Install Xilinx webpack 13.3


reboot

cd ~/socgen

./test





