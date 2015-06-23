echo "Generate makefile --->"
qmake

#echo "Cleaning ------------>"
#make clean

echo "Building ------------>"
make

echo "Running converter --->"
./fonter test.ttf

echo "Exporting ----------->"
cp test_font.h ../../examples/bare/

echo "Done ---------------->"
