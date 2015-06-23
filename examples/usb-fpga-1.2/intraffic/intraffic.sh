#make -C ../../../java distclean all || exit
#cd fpga; ./promgen.sh; cd ..
#make distclean all || exit
#make || exit
java -cp InTraffic.jar InTraffic $@
