#!/bin/sh
xst -ifn aes.xst -ofn ../log/aes.log
ngdbuild -dd ../out -uc aes.ucf ../out/aes.ngc ../out/aes.ngd
map -w -timing -ol high -cm speed ../out/aes.ngd -o ../out/aes.ncd
par -w -ol high ../out/aes.ncd ../out/aes.map.ncd
mv ../out/aes.bld ../log/aes.bld
mv ../out/aes.mrp ../log/aes.mrp
mv ../out/aes.map.par ../log/aes.map.par
mv *.xrpt ../log/
mv *.twr ../log/
mv *.xml ../log/
trce -v 10 -fastpaths -xml ../log/aes.twx ../out/aes.map.ncd -o ../log/aes.twr ../out/aes.pcf
