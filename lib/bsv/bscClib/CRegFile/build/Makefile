BSC_COMP = bsc
vdir=./build/vdir
srcdir=../
blddir=build/bdir
VER_OPTS =  +RTS -K100000000 --RTS -u -verilog -elab -no-show-method-conf \
	-aggressive-conditions -vdir $(vdir) -bdir $(blddir) -dschedule 
SIM_OPTS =  +RTS -K100000000 --RTS -u -sim -aggressive-conditions -dschedule -vdir $(vdir) -bdir $(blddir) -show-schedule
EXE_OPTS =  +RTS -K100000000 --RTS -sim -v -bdir $(blddir) -Xc++ -m32 -Xc -m32

files: clean
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir

CRegFileFull.o: $(srcdir)/CRegFileFull.c files
	gcc -c -m64 -g -fPIC -o $(blddir)/CRegFileFull.o $(srcdir)/CRegFileFull.c


CRegFileBaseTester: files CRegFileFull.o
	$(BSC_COMP) $(SIM_OPTS) -p +:$(srcdir):./build/bdir -g mkCRegFileBaseTester $(srcdir)/CRegFileBaseTester.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS)  -o CRegFileBaseTeseter.exe -e mkCRegFileBaseTester -p +:$(srcdir):./build/bdir $(blddir)/*.ba $(blddir)/*.o

.PHONY: clean
.PHONY: files

clean:
	rm -rf build
	rm -f *.cxx *.h *.o *.exe  *~ *.log *.so