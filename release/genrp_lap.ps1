# Generate Release Package for the FPGA Ethernet Platform
#Remove-Item fpgaep -recurse
New-Item .\fpgaep -ItemType directory
New-Item .\fpgaep\hdl -ItemType directory
New-Item .\fpgaep\hdl\boardsupport -ItemType directory
cp ..\design_gen\boardsupport\*.ucf .\fpgaep\hdl\boardsupport
New-Item .\fpgaep\hdl\chipsupport -ItemType directory
cp ..\design_gen\boardsupport\* .\fpgaep\hdl\chipsupport -Exclude @("*.svn","*.ucf")
cp ..\design_gen\boardsupport\v4\* .\fpgaep\hdl\chipsupport\v4 -Exclude "*.svn"
cp ..\design_gen\boardsupport\v5\* .\fpgaep\hdl\chipsupport\v5 -Exclude "*.svn"
New-Item .\fpgaep\hdl\modules -ItemType directory
New-Item .\fpgaep\hdl\modules\md5 -ItemType directory
New-Item .\fpgaep\hdl\modules\port_icap -ItemType directory
New-Item .\fpgaep\hdl\modules\port_register -ItemType directory
cp ..\design_gen\md5\md5.v .\fpgaep\hdl\modules\md5
cp ..\design_gen\md5\port_md5.v .\fpgaep\hdl\modules\md5
cp ..\design_gen\port_icap\port_icap_buf.v .\fpgaep\hdl\modules\port_icap
cp ..\design_gen\PATLPP\shiftr_bram\shiftr_bram.v .\fpgaep\hdl\modules\port_icap
cp ..\design_gen\port_register\port_register.v .\fpgaep\hdl\modules\port_register
New-Item .\fpgaep\hdl\packetprocessor -ItemType directory
cp ..\design_gen\PATLPP\alunit\alunit.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\checksum\checksum.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\comparelogic\comparelogic.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\shiftr\gensrl.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\lpm\mux2\lpm_mux2.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\lpm\mux4\lpm_mux4.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\lpm\mux8\lpm_mux8.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\lpm\stopar\lpm_stopar.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\microcodelogic\microcodelogic.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\microcodelogic\microcodesrc\microcodesrc.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\patlpp.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\regfile\regfile.v .\fpgaep\hdl\packetprocessor
cp ..\design_gen\PATLPP\shiftr\shiftr.v .\fpgaep\hdl\packetprocessor
New-Item .\fpgaep\hdl\channelif -ItemType directory
cp ..\design_gen\channelif\channelif2.v .\fpgaep\hdl\channelif
cp ..\design_gen\channelif\channelif4.v .\fpgaep\hdl\channelif
cp ..\design_gen\channelif\channelif6.v .\fpgaep\hdl\channelif
New-Item .\fpgaep\hdl\tools -ItemType directory
New-Item .\fpgaep\hdl\tools\ChannelInterfaceGenerator -ItemType directory
New-Item .\fpgaep\hdl\tools\PythonAssembler -ItemType directory
cp ..\tools\ChannelInterfaceGenerator\chifgen.py .\fpgaep\hdl\tools\ChannelInterfaceGenerator
cp ..\tools\PythonAssembler\*.py .\fpgaep\hdl\tools\PythonAssembler -Exclude "testcode.py"
New-Item .\fpgaep\hdl\toplevel -ItemType directory
cp ..\design_gen\topv4.v .\fpgaep\hdl\toplevel
cp ..\design_gen\topv5.v .\fpgaep\hdl\toplevel
cp ..\design_gen\topv5_md5.v .\fpgaep\hdl\toplevel
cp ..\design_gen\topv5_simple.v .\fpgaep\hdl\toplevel
New-Item .\fpgaep\java -ItemType directory
cp $home\workspace\FCP\doc .\fpgaep\java -Recurse
New-Item .\fpgaep\java\examples -ItemType directory
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\FCPInteface.java .\fpgaep\java\examples
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\MD5GUI.java .\fpgaep\java\examples
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\PRToolGUI.java .\fpgaep\java\examples
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\Simple.java .\fpgaep\java\examples
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\SimpleOperations.java .\fpgaep\java\examples
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\ThroughputTest.java .\fpgaep\java\examples
New-Item .\fpgaep\java\fcp -ItemType directory
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\fcp\* .\fpgaep\java\fcp -Exclude "FCPTest.java"
New-Item .\fpgaep\java\subapi -ItemType directory
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\examples\SimpleInterface.java .\fpgaep\java\SubAPI
cp $home\workspace\FCP\src\edu\byu\cc\plieber\fpgaenet\icapif\IcapInterface.java .\fpgaep\java\SubAPI
New-Item .\fpgaep\java\util -ItemType directory
cp $home\workspace\FCP\src\edu\byu\cc\plieber\util\StringUtil.java .\fpgaep\java\util\
New-Item .\fpgaep\example -ItemType directory
cp ..\design_gen\boardsupport\xupv5.ucf .\fpgaep\example\simple.ucf
cp simple.prj .\fpgaep\example