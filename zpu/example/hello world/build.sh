set -e
zpu-elf-gcc -O3 -phi "`pwd`/hello.c" -o hello.elf -Wl,--relax -Wl,--gc-sections  -g
zpu-elf-objcopy -O binary hello.elf hello.bin
cat >../helloworld.vhd helloworld.vhd_header
./zpuromgen hello.bin >>../helloworld.vhd
cat >>../helloworld.vhd helloworld.vhd_footer
