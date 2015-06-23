# Generate Release Package for the FPGA Ethernet Platform
Remove-Item fpgaep -recurse
New-Item .\fpgaep -ItemType directory
New-Item .\fpgaep\hdl -ItemType directory
New-Item .\fpgaep\hdl\boardsupport -ItemType directory
cp ..\hdl\boardsupport\*.ucf .\fpgaep\hdl\boardsupport
New-Item .\fpgaep\hdl\chipsupport -ItemType directory
cp ..\hdl\boardsupport\* .\fpgaep\hdl\chipsupport -Exclude @("*.svn","*.ucf")
cp ..\hdl\boardsupport\v4\* .\fpgaep\hdl\chipsupport\v4 -Exclude "*.svn"
cp ..\hdl\boardsupport\v5\* .\fpgaep\hdl\chipsupport\v5 -Exclude "*.svn"
New-Item .\fpgaep\hdl\modules -ItemType directory
New-Item .\fpgaep\hdl\modules\md5 -ItemType directory
New-Item .\fpgaep\hdl\modules\sha1 -ItemType directory
New-Item .\fpgaep\hdl\modules\port_icap -ItemType directory
New-Item .\fpgaep\hdl\modules\port_clkcntl -ItemType directory
New-Item .\fpgaep\hdl\modules\port_register -ItemType directory
cp ..\hdl\md5\md5.v .\fpgaep\hdl\modules\md5
cp ..\hdl\md5\port_md5.v .\fpgaep\hdl\modules\md5
cp ..\hdl\port_icap\port_icap_buf.v .\fpgaep\hdl\modules\port_icap
cp ..\hdl\port_icap\shiftr_bram\shiftr_bram.v .\fpgaep\hdl\modules\port_icap
cp ..\hdl\port_register\port_register.v .\fpgaep\hdl\modules\port_register
cp ..\hdl\sha1\*.v .\fpgaep\hdl\modules\sha1
cp ..\hdl\port_clkcntl\port_clkcntl.v .\fpgaep\hdl\modules\port_clkcntl
cp ..\hdl\port_clkcntl\clockcntl.vhd .\fpgaep\hdl\modules\port_clkcntl
New-Item .\fpgaep\hdl\packetprocessor -ItemType directory
cp ..\hdl\PATLPP\alunit\alunit.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\checksum\checksum.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\comparelogic\comparelogic.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\shiftr\gensrl.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\lpm\mux2\lpm_mux2.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\lpm\mux4\lpm_mux4.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\lpm\mux8\lpm_mux8.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\lpm\stopar\lpm_stopar.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\microcodelogic\microcodelogic.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\microcodelogic\microcodesrc\microcodesrc.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\patlpp.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\regfile\regfile.v .\fpgaep\hdl\packetprocessor
cp ..\hdl\PATLPP\shiftr\shiftr.v .\fpgaep\hdl\packetprocessor
New-Item .\fpgaep\hdl\channelif -ItemType directory
cp ..\hdl\channelif\channelif2.v .\fpgaep\hdl\channelif
cp ..\hdl\channelif\channelif4.v .\fpgaep\hdl\channelif
cp ..\hdl\channelif\channelif6.v .\fpgaep\hdl\channelif
New-Item .\fpgaep\hdl\tools -ItemType directory
New-Item .\fpgaep\hdl\tools\ChannelInterfaceGenerator -ItemType directory
New-Item .\fpgaep\hdl\tools\PythonAssembler -ItemType directory
cp ..\tools\ChannelInterfaceGenerator\chifgen.py .\fpgaep\hdl\tools\ChannelInterfaceGenerator
cp ..\tools\PythonAssembler\*.py .\fpgaep\hdl\tools\PythonAssembler -Exclude "testcode.py"
New-Item .\fpgaep\hdl\port_fifo -ItemType directory
cp ..\hdl\port_fifo\port_fifo.v .\fpgaep\hdl\port_fifo
New-Item .\fpgaep\hdl\toplevel -ItemType directory
cp ..\hdl\topv4.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5_md5.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5_simple.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5_sha1.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5_proto.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5_echo.v .\fpgaep\hdl\toplevel
cp ..\hdl\topv5_prototest.v .\fpgaep\hdl\toplevel
New-Item .\fpgaep\java -ItemType directory
cp ..\java\doc .\fpgaep\java -Recurse
New-Item .\fpgaep\java\examples -ItemType directory
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\FCPInteface.java .\fpgaep\java\examples
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\MD5GUI.java .\fpgaep\java\examples
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\PRToolGUI.java .\fpgaep\java\examples
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\Simple.java .\fpgaep\java\examples
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\SimpleOperations.java .\fpgaep\java\examples
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\ThroughputTest.java .\fpgaep\java\examples
New-Item .\fpgaep\java\fcp -ItemType directory
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\fcp\* .\fpgaep\java\fcp -Exclude "FCPTest.java"
New-Item .\fpgaep\java\subapi -ItemType directory
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\examples\SimpleInterface.java .\fpgaep\java\SubAPI
cp ..\java\src\edu\byu\cc\plieber\fpgaenet\icapif\IcapInterface.java .\fpgaep\java\SubAPI
New-Item .\fpgaep\java\util -ItemType directory
cp ..\java\src\edu\byu\cc\plieber\util\StringUtil.java .\fpgaep\java\util\
New-Item .\fpgaep\example -ItemType directory
cp ..\hdl\boardsupport\xupv5.ucf .\fpgaep\example\simple.ucf
cp simple.prj .\fpgaep\example