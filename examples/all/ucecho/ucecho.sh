#make -C ../../../java distclean all || exit
#make || exit
#rm ucecho.ihx
java -cp UCEcho.jar UCEcho $@
