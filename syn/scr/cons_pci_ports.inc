/* PCI input delay constraints definition*/
if ( PCI_CLK_PERIOD == 15 ){

    /* 3ns setup time constraint */
    set_input_delay -max 12 -clock PCI_CLK {AD}
    set_input_delay -max 12 -clock PCI_CLK {CBE}
    set_input_delay -max 12 -clock PCI_CLK {FRAME}
    set_input_delay -max 12 -clock PCI_CLK {IRDY}
    set_input_delay -max 12 -clock PCI_CLK {IDSEL}
    set_input_delay -max 12 -clock PCI_CLK {DEVSEL}
    set_input_delay -max 12 -clock PCI_CLK {TRDY}
    set_input_delay -max 12 -clock PCI_CLK {STOP}
    set_input_delay -max 12 -clock PCI_CLK {PAR}
    set_input_delay -max 12 -clock PCI_CLK {PERR}

    /* 0ns hold time constraints */
    set_input_delay -min 0 -clock PCI_CLK {AD}
    set_input_delay -min 0 -clock PCI_CLK {CBE}
    set_input_delay -min 0 -clock PCI_CLK {FRAME}
    set_input_delay -min 0 -clock PCI_CLK {IRDY}
    set_input_delay -min 0 -clock PCI_CLK {IDSEL}
    set_input_delay -min 0 -clock PCI_CLK {DEVSEL}
    set_input_delay -min 0 -clock PCI_CLK {TRDY}
    set_input_delay -min 0 -clock PCI_CLK {STOP}
    set_input_delay -min 0 -clock PCI_CLK {PAR}
    set_input_delay -min 0 -clock PCI_CLK {PERR}

    /* GNT has 5ns constraint */
    set_input_delay -max 10 -clock PCI_CLK {GNT}
    set_input_delay -min 0  -clock PCI_CLK {GNT}

    /* 6ns output delay constraints */
    set_output_delay -max 9 -clock PCI_CLK {AD}
    set_output_delay -max 9 -clock PCI_CLK {CBE}
    set_output_delay -max 9 -clock PCI_CLK {FRAME}
    set_output_delay -max 9 -clock PCI_CLK {IRDY}
    set_output_delay -max 9 -clock PCI_CLK {DEVSEL}
    set_output_delay -max 9 -clock PCI_CLK {TRDY}
    set_output_delay -max 9 -clock PCI_CLK {STOP}
    set_output_delay -max 9 -clock PCI_CLK {PAR}
    set_output_delay -max 9 -clock PCI_CLK {PERR}
    set_output_delay -max 9 -clock PCI_CLK {SERR}
    set_output_delay -max 9 -clock PCI_CLK {REQ}

}else if ( PCI_CLK_PERIOD == 30 ){

    /* 7ns setup time constraint */
    set_input_delay -max 23 -clock PCI_CLK {AD}
    set_input_delay -max 23 -clock PCI_CLK {CBE}
    set_input_delay -max 23 -clock PCI_CLK {FRAME}
    set_input_delay -max 23 -clock PCI_CLK {IRDY}
    set_input_delay -max 23 -clock PCI_CLK {IDSEL}
    set_input_delay -max 23 -clock PCI_CLK {DEVSEL}
    set_input_delay -max 23 -clock PCI_CLK {TRDY}
    set_input_delay -max 23 -clock PCI_CLK {STOP}
    set_input_delay -max 23 -clock PCI_CLK {PAR}
    set_input_delay -max 23 -clock PCI_CLK {PERR}
 
    /* 0ns hold time constraints */
    set_input_delay -min 0 -clock PCI_CLK {AD}
    set_input_delay -min 0 -clock PCI_CLK {CBE}
    set_input_delay -min 0 -clock PCI_CLK {FRAME}
    set_input_delay -min 0 -clock PCI_CLK {IRDY}
    set_input_delay -min 0 -clock PCI_CLK {IDSEL}
    set_input_delay -min 0 -clock PCI_CLK {DEVSEL}
    set_input_delay -min 0 -clock PCI_CLK {TRDY}
    set_input_delay -min 0 -clock PCI_CLK {STOP}
    set_input_delay -min 0 -clock PCI_CLK {PAR}
    set_input_delay -min 0 -clock PCI_CLK {PERR}

    /* GNT has 10ns constraint */
    set_input_delay -max 20 -clock PCI_CLK {GNT}
    set_input_delay -min 0  -clock PCI_CLK {GNT}
 
    /* 11ns output delay constraints */
    set_output_delay -max 19 -clock PCI_CLK {AD}
    set_output_delay -max 19 -clock PCI_CLK {CBE}
    set_output_delay -max 19 -clock PCI_CLK {FRAME}
    set_output_delay -max 19 -clock PCI_CLK {IRDY}
    set_output_delay -max 19 -clock PCI_CLK {DEVSEL}
    set_output_delay -max 19 -clock PCI_CLK {TRDY}
    set_output_delay -max 19 -clock PCI_CLK {STOP}
    set_output_delay -max 19 -clock PCI_CLK {PAR}
    set_output_delay -max 19 -clock PCI_CLK {PERR}
    set_output_delay -max 19 -clock PCI_CLK {SERR}

    /* REQ has 12ns output delay constraint */
    set_output_delay -max 12 -clock PCI_CLK {REQ}

}else{
    echo "Error: Unsupported PCI clock period specified!"
    exit
}

set_false_path -from PCI_CLK -to WB_CLK
set_false_path -from WB_CLK -to PCI_CLK
set_false_path -from {bridge/configuration/*} -to {SDAT_O}

