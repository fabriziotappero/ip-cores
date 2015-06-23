SHELL=/bin/sh
MAKE=make
CUR_DIR=$(shell pwd)
home=$(CUR_DIR)/..

all:   install


.PHONY install:
install:
	(\
	cp -r bin ~;\
	cp dot_profile ~/.profile;\
	sudo apt-get  install -y emacs23;\
	sudo apt-get  install -y k3b;\
        sudo apt-get  install -y cvs;\
        sudo apt-get  install -y subversion;\
        sudo apt-get  install -y git;\
	sudo apt-get  install -y perl-tk\
        sudo apt-get  install -y iverilog;\
	sudo apt-get  install -y verilator;\
        sudo apt-get  install -y covered;\
	sudo apt-get  install -y gtkterm;\
	sudo apt-get  install -y gtkwave;\
	sudo apt-get  install -y crasm;\
	sudo apt-get  install -y libverilog-perl;\
	sudo apt-get  install -y libxml-libxml-perl;\
	)


