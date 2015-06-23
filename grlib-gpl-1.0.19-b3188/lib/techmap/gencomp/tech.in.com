  choice 'Target technology                           ' \
	"Inferred		CONFIG_SYN_INFERRED \
	Altera-all            	CONFIG_SYN_ALTERA \
	Actel-Axcelerator	CONFIG_SYN_AXCEL \
	Actel-Proasic		CONFIG_SYN_PROASIC \
	Actel-ProasicPlus	CONFIG_SYN_PROASICPLUS \
	Actel-Proasic3   	CONFIG_SYN_PROASIC3 \
	Atmel-ATC18		CONFIG_SYN_ATC18 \
	Custom1        		CONFIG_SYN_CUSTOM1 \
        Lattice-EC/ECP/XP   	CONFIG_SYN_LATTICE \
	Xilinx-Spartan2		CONFIG_SYN_SPARTAN2 \
	Xilinx-Spartan3		CONFIG_SYN_SPARTAN3 \
	Xilinx-Spartan3E	CONFIG_SYN_SPARTAN3E \
	Xilinx-Virtex		CONFIG_SYN_VIRTEX \
	Xilinx-VirtexE		CONFIG_SYN_VIRTEXE \
	Xilinx-Virtex2		CONFIG_SYN_VIRTEX2 \
	Xilinx-Virtex4		CONFIG_SYN_VIRTEX4 \
	Xilinx-Virtex5		CONFIG_SYN_VIRTEX5" Inferred
  if [ "$CONFIG_SYN_INFERRED" = "y" -o "$CONFIG_SYN_CUSTOM1" = "y" \
       -o "$CONFIG_SYN_ATC18" = "y" \
	-o "$CONFIG_SYN_RHUMC" = "y" -o "$CONFIG_SYN_ARTISAN" = "y"]; then
    choice 'Memory Library                           ' \
	"Inferred		CONFIG_MEM_INFERRED \
	Artisan			CONFIG_MEM_ARTISAN \
	Custom1			CONFIG_MEM_CUSTOM1 \
	Virage			CONFIG_MEM_VIRAGE" Inferred
  fi
  if [ "$CONFIG_SYN_INFERRED" != "y" ]; then
    bool 'Infer RAM' CONFIG_SYN_INFER_RAM
    bool 'Infer pads' CONFIG_SYN_INFER_PADS
  fi
  bool 'Disable asynchronous reset' CONFIG_SYN_NO_ASYNC
