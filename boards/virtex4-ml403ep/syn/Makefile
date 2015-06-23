all: kotku_ml403.bit

run: tmp/kotku_ml403.bit
	(cd tmp/ && ../../../../bin/ml403 kotku_ml403.bit)

debug: tmp/mult.v tmp/icon.v tmp/ila.v kotku-dbg.prj kotku-dbg.xst
	(cd tmp/ && xst -ifn ../kotku-dbg.xst)

tmp/icon.v: icon.xco
	mkdir -p tmp
	(cd tmp/ && coregen -b ../icon.xco)

tmp/ila.v: ila.xco
	mkdir -p tmp
	(cd tmp/ && coregen -b ../ila.xco)

Zet.ace: tmp/kotku_ml403.bit
	(cd tmp/ && ../../ace/ml40x_bit2ace kotku_ml403.bit ../Zet.ace ../../ace/)

tmp/mult.v: mult.xco
	mkdir -p tmp
	(cd tmp/ && coregen -b ../mult.xco)

tmp/kotku_ml403.ngc: tmp/mult.v kotku.prj kotku.xst
	(cd tmp/ && xst -ifn ../kotku.xst)

tmp/kotku_ml403.ngd: tmp/kotku_ml403.ngc ml403.ucf tmp/mult.ngc
	(cd tmp/ && ngdbuild -uc ../ml403.ucf kotku_ml403.ngc)

tmp/kotku_ml403.ncd: tmp/kotku_ml403.ngd
	(cd tmp/ && map kotku_ml403.ngd)

tmp/kotku_ml403-par.ncd: tmp/kotku_ml403.ncd
	(cd tmp/ && par -w kotku_ml403.ncd kotku_ml403-par.ncd)

tmp/kotku_ml403.bit: tmp/kotku_ml403-par.ncd
	(cd tmp/ && bitgen -w kotku_ml403-par.ncd kotku_ml403.bit)

kotku_ml403.bit: tmp/kotku_ml403.bit
	cp tmp/kotku_ml403.bit /home/zeus/tmp

clean:
	rm -fR Zet.ace tmp/
