#make -C ../../../java distclean all || exit
#cd fpga
#./promgen.sh
#cd ..
#make distclean all || exit
java -cp MemTest.jar MemTest $@
