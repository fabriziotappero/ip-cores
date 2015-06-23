BSC_COMP = bsc
vdir=./build/vdir
srcdir=../
blddir=build/bdir
VER_OPTS =  +RTS -K100000000 --RTS -u -verilog -elab -no-show-method-conf \
	-aggressive-conditions -vdir $(vdir) -bdir $(blddir) -dschedule 
SIM_OPTS =  +RTS -K100000000 --RTS -u -sim -aggressive-conditions -dschedule -vdir $(vdir) -bdir $(blddir) -show-schedule
EXE_OPTS =  +RTS -K100000000 --RTS -sim -v -bdir $(blddir)

files: clean
	mkdir -p build
	mkdir -p build/bdir
	mkdir -p build/vdir

CReg.o: $(srcdir)/CReg.c files
	gcc -c -m32 -fPIC -o $(blddir)/CReg.o $(srcdir)/CReg.c


CRegBaseTester: files CReg.o
	$(BSC_COMP) $(SIM_OPTS) -p +:$(srcdir):./build/bdir -g mkCRegBaseTester $(srcdir)/CRegBaseTester.bsv > out.log
	$(BSC_COMP) $(EXE_OPTS)  -o CRegBaseTeseter.exe -e mkCRegBaseTester -p +:$(srcdir):./build/bdir $(blddir)/*.ba $(blddir)/*.o

.PHONY: clean
.PHONY: files

clean:
	rm -rf build
	rm -f *.cxx *.h *.o *.exe  *~ *.log *.so