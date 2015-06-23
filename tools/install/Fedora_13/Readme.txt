

su
yum groupinstall 'Electronic Lab'
yum install      perl-XML-LibXML
yum install      wget
yum install      patch

(logout  from root)

cd ../crasm
make all


chmod 755 ../../bin/* ;\
mkdir ~/bin;\
cp ../../bin/* ~/bin;\

cd socgen
make build_soc
make run_sims
make build_fgpas  ( if you have xilinx webpack 12.3 installed)




