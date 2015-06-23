# Script compiles all vhdl-files and generates a makefile for them
# This script is tested for Modelsim version 6.6a 

.main clear

echo " Generating libraries for files"

echo "Processing component TUT:ip.hwp.accelerator:port_blinker:1.0"
echo "Processing file set hdlSources of component TUT:ip.hwp.accelerator:port_blinker:1.0."
echo " Adding library work"
vlib work
vcom -quiet -check_synthesis D:/user/ege/Svn/daci_ip/trunk/ip.hwp.accelerator/port_blinker/1.0/vhd/port_blinker.vhd

echo "Processing component TUT:ip.hwp.accelerator:sig_gen:1.0"
echo "Processing file set hdlSources of component TUT:ip.hwp.accelerator:sig_gen:1.0."
vcom -quiet -check_synthesis D:/user/ege/Svn/daci_ip/trunk/ip.hwp.accelerator/sig_gen/1.0/vhd/sig_gen.vhd

echo "Processing component TUT:soc:altera_de_II_demo:1.0"
echo "Processing file set vhdlSource of component TUT:soc:altera_de_II_demo:1.0."
echo " Adding library soc"
vlib soc
vcom -quiet -check_synthesis -work work D:/user/ege/Svn/daci_ip/trunk/soc/altera_de_II_demo/1.0/vhd/altera_de_II_demo.vhd

echo " Creating a new Makefile"

# remove the old makefile
rm -f Makefile
vmake work > Makefile
echo " Script has been executed "
