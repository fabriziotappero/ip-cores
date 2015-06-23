
FILES
        scan.perl.v
        scan_signal_list.pl
        scan_testbench.perl.v

AUTHOR
        David Fick - dfick@umich.edu

VERSION
        1.0 - June 27, 2010
        1.1 - January 7, 2011
        1.2 - Feb 7, 2013

SCAN DESCRIPTION
        This is a simple scan chain implemented with deperlify. It has been
        used, successfully, on multiple tapeouts.

        This scan chain is designed to safely and easily  move data onto and 
        off of a chip with a minimal number of pins. Performance is not a
        priority, however, we have found it to be sufficiently fast for
        any student project.

        For safety, this scan uses two non-overlapping "clocks" that operate 
        out of phase. Each bit in the scan chain has a master latch and
        a slave latch. The master latch is connected to the signal "phi",
        and the slave latch is connected to the signal "phi_bar". To clock
        in one bit (and out another), "data_in" is first set to the correct
        value, then "phi" is *pulsed*, afterward "phi_bar" is *pulsed*. The
        process then repeats for the next bit. Since each clock is pulsed
        individually, they will never overlap. Note that this design
        is immune to signal bouncing.

        Every data_bit coming out of the scan chain unit is first buffered
        with a latch. This latch is transparent when "scan_load_chip" is
        high. Thus, data is loaded onto the chip by first clocking in all
        of the data as described above, then pulsing "scan_load_chip".
        This means that the signals coming out of the scan unit to the
        rest of the chip do not toggle randomly when the scan chain is
        being loaded, and therefore the scan chain can be operated while
        the chip is running.

        The signal "scan_load_chain" controls a mux on the input of each
        latch pair. If "scan_load_chain" is high, then data from the chip
        is loaded into the scan chain when the two clocks are pulsed,
        instead of data from the preceding bit. Thus, to read data
        from the chip, first raise "scan_load_chain" high, pulse the two
        clocks once as normal, then lower "scan_load_chain". Now that
        the chip data has been loaded into the scan chain, clock out the
        data as normal.

        To create a large number of bits, address and data fields may
        be created for a signal. 2^addr_bits*data_bits must be greater
        than the size. In this way, only addr_bits+data_bits number of
        bits may be generated in the scan chain, which reduces the
        length of the scan chain, as well as the area, since latches
        are much smaller than the muxing elements needed for the
        chain. Since this is a new feature, the size specified by the
        address and data bits should most likely match the total size
        in order to avoid bugs.

        An optional research field is included in the scan signal list.
        When the scan reset bet is set to 1, all bits in the scan chain
        are set to their optional reset value when specified, or zero
        when it is not specified.

        Due to the buffering latches, complex internal interfaces can be
        emulated using the scan chain. For instance, an SRAM could be
        connected to a clock, chip select, write enable, 64-bit data-in, 
        and 64-bit data-out, all of which are connected to the scan
        chain. The scan chain would need to be used a few times for each
        "cycle" of the SRAM. For instance, each time the clock signal
        toggles the scan chain would need to be completely reloaded.
        Although this process is slow, it works reliably.

        The example description below has additional information about
        how to use the scan chain.

        
EXAMPLE DESCRIPTION
        To run the example, call "make". The example uses Synopsys VCS.

        This example takes advantage of the DEPERLIFY_INCLUDE command. The
        scan.perl.v file reads in the data structure scan_signal_list.pl
        in order to generate the scan chain. The file scan_testbench.perl.v
        uses the same data structure to generate variables and functions
        to access the scan chain.

        The testbench generates a write variable and read variable for
        each element in the scan chain. The write variable is called
        <NAME> and the read variable is called <NAME>_read. The values
        with the name <NAME> are what is scanned into the scan chain
        by the task "rotate_chain". The task "rotate_chain" writes the
        variables with the name <NAME>_read with the data that is scanned
        out by the scan chain. Note that data is simultaneously scanned
        in and out.

        To write a value:
        1. Set the value of <NAME> to what you desire
        2. Call "rotate_chain"
        3. Call "load_chip"

        To read a value:
        1. Call "load_chain"
        2. Call "rotate_chain"
        3. Read the value of <NAME>_read
        
        
        

        
