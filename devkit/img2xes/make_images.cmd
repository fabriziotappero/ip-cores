perl img2xes.pl -x 320 -y 240 -d 3+2+3 -pixelwidth 8 -memwidth 16 -address 0x25800 -i boot.png -o boot.xes
perl img2xes.pl -x 320 -y 3520 -d 3+2+3 -pixelwidth 8 -memwidth 16 -address 0x6ED000 -i boot_movie.png -o boot_mv.xes
perl img2xes.pl -x 320 -y 3840 -d 3+2+3 -pixelwidth 8 -memwidth 16 -address 0x38400 -i intro_composite.png -o intro.xes
