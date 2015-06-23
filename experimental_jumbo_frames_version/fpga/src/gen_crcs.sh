for i in 8 16 24 32 40 48 56 64; do
  fname=pkg_newcrc32_d$i.vhd
  ./crc_gen2.py newcrc32_d$i L $i 0 1 2 4 5 7 8 10 11 12 16 22 23 26 32 > $fname
done

