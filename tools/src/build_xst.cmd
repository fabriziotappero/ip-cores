run
-ifn $FILELIST_XST
-ofn m1_cpu.ngc
-ifmt MIXED
-ofmt NGC
-top m1_cpu
-opt_mode SPEED
-opt_level 1
# Device used in Spartan3E Starter Kit
-p xc3s500e-fg320
# Biggest Spartan3E device
# -p xc3s1600e-fg320
# Biggest Virtex4 device supported by ISE WebPack
# -p xc4vlx25-ff668
# Biggest Virtex5 device supported by ISE WebPack
# -p xc5vlx30-ff676
-vlgincdir { $M1_ROOT/hdl/rtl/m1_cpu }
