$Author: gvozden $
$Date: 2003-08-01 09:08:41 $
$Revision: 1.2 $  
$Name: not supported by cvs2svn $

|-- apps                    : wb2hpi core applications
|    |
|    |--pci2hpi             : pci2hpi application. DSP connected
|         |                   on PCI bus!
|         |-- pci           : PCI core
|         |
|         |-- rtl           : HDL source files (pci2hpi related)
|         | 
|         |-- sw            : software (drivers, etc...)         
|         |
|         -- syn            : files needed for synthesis and implementation
|              |
|              |--synplify  : Synplify project
|              |    |
|              |    |-- log         
|              |    |
|              |    |-- out         
|              |    | 
|              |    |-- src         
|              |
|              |--xilinxISE : Xilinx ISE (4.1) project (Spartan II implementation)
|              |
|              |-- src          
|              |
|              |-- ucf      : UCF files    
|   
|                           
|-- doc                     : documentation
|       
|-- rtl                     : HDL source files (wb2hpi related)
|    |                     
|    |
|    |--vhdl                : VHDL files
 