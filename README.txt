
============================
FFR16 - FIRST FILE READER 16
============================

  - AUGUST 2003
  - UPV / EHU.  

  - APPLIED ELECTRONICS RESEARCH TEAM (APERT)-
  - Armando Astarloa - email : jtpascua@bi.ehu.es
  - DEPARTMENT OF ELECTRONICS AND TELECOMMUNICATIONS - BASQUE COUNTRY UNIVERSITY -
 
 THE ASSEMBLER CODE IS DISTRIBUTED UNDER GPL License

 THE VHDL CODE IS DISTRIBUTED UNDER :
 OpenIPCore Hardware General Public License "OHGPL" 
 http://www.opencores.org/OIPC/OHGPL.shtml

============================
030811

DIRECTORIES:

	\SOURCES
	
		\FPU : FAT PROCESSOR UNIT
			FAT16RD.PSM - SOURCE CODE
			\COMPILE : DO.BAT to compile and generate VHD file for the BlockRAM 
		\HAU : HOST ATAPI UNIT
			CFREADER.PSM - SOURCE CODE
			\COMPILE : DO.BAT to compile and generate VHD file for the BlockRAM

	\RTL

		CF_FILE_READER.VHD : FFR16 vhdl top file.
			CF_FAT16_READER.VHD : FPU vhdl file.
				FAT16RD.VHD : BlockRAM (SOFT) for FPU.
			CF_SECTOR_READER.VHD : HAU vhdl file.
				FAT16RD.VHD : BlockRAM (SOFT) for HAU.
			CF_PACKAGE.VHD : Package for high level VHDL functions.
		KCPSM : Ken Chapman KCPSM (Picoblaze) microprocessor. See Xilinx web site (http://www.xilinx.com)

	\TEST
	\DOC 

============================
030825

ADDED:
	\TEST
		CF_FILE_READ_TB.VHD : FFR16 testbench
		CF_EMULATOR.VHD : Compact Flash model for functional co-debug/co-design. 
				Partially implemented :
							Only read command.
							Binary image of the IDE volume support.
		EXAMPLE FILES FOR DEBUG:
				RAW0_255.CHK 	: File stored into the FAT16 volumed used for simulaton.
				ET0_511.BIN	: Binary dump of the 512 fisrt LBA sectors of a FAT16 formatted 
						  Compact Flash with RAW0_255.CHK file stored into the root dir.
============================
040507

corrected:
	\RTL
		Updated and zipped
	\TEST
		Minor bugs corrected and zipped
		CF_FILE_READ_TB.VHD : FFR16 testbench - Minor changes (bus and files)
		CF_EMULATOR.VHD : Compact Flash model for functional co-debug/co-design. 
				Partially implemented :
							Only read command.
							Binary image of the IDE volume support.
		EXAMPLE FILES FOR DEBUG:
				RAW0_255.CHK 	: File stored into the FAT16 volumed used for simulaton.
				DUM0511.BIN	: Binary dump of the 512 fisrt LBA sectors of a FAT16 formatted 
						  Compact Flash with RAW0_255.CHK file stored into the root dir.
added modelsim project