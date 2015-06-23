SHELL=/bin/sh
MAKE=make
CUR_DIR=$(shell pwd)
home=$(CUR_DIR)/..

all:   install


.PHONY install:
install:
	(\
	mkdir ~/bin;\
	cp ../../bin/* ~/bin;\
	chmod 755 ~/bin/* ;\
        sudo apt-get  install -y subversion;\
        sudo apt-get  install -y libverilog-perl;\
        sudo apt-get  install -y iverilog;\
        sudo apt-get  install -y covered;\
	sudo apt-get  install -y xutils-dev;\
        sudo apt-get  install -y gputils;\
	sudo apt-get  install -y gtkterm;\
	sudo apt-get  install -y gtkwave;\
	sudo apt-get  install -y eclipse;\
	sudo apt-get  install -y perl-tk;\
	sudo apt-get  install -y perl-doc;\
	sudo apt-get  install -y texinfo;\
	sudo apt-get  install -y libncurses5-dev;\
	sudo apt-get  install -y build-essential;\
	sudo apt-get  install -y tkdiff;\
	sudo apt-get  install -y librxtx-java;\
	)


