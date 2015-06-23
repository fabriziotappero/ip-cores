@echo off
echo ********************************************************
echo Build the Java Class FIle
echo ********************************************************

javac -target 1.5 -g -cp ./;./lib/Muvium-Leros-API.jar;   Blink.java

echo ********************************************************
echo Compile Java Class File into Leros Assembler
echo ********************************************************

java -cp ./;./lib/Muvium-Leros-API.jar;./lib/Muvium-Leros.jar;./lib/jdom.jar;./lib/jaxen.jar;.  MuviumMetal Blink config.xml  muvium.asm

echo ********************************************************
echo Compile Leros Assembler into a ROM binary Image
echo ********************************************************

java -cp ./;./lib/Leros.jar;./../lib/antlr-3.3-complete.jar leros.asm.LerosAsm -s ./ asm muvium.asm 

echo ********************************************************
echo Run the Simulator with the QuickIO Option
echo ********************************************************

java -cp ./;./lib/Leros.jar;  leros.sim.LerosSim -qio rom.txt

