load/r '/home/bahadir/codezero/build/final.elf'
load/ni/np '/home/bahadir/codezero/build/kernel.elf'
bexec platform_init
bexec smp_start_cores
