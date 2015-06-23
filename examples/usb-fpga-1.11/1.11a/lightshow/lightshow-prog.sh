# programms the EEPROM and the FPGA for standalone usage
#make -C ../../../../java distclean all || exit
#make distclean all || exit

java -cp Lightshow.jar Lightshow $@
../../../../java/FWLoader -ue lightshow.ihx -um fpga/lightshow.bit

