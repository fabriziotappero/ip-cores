
# The list at the beginning defines the scan lists. Defining an input name or output
#                                    name determines what type of scan signal it is.

# This must be defined, whether or not it's used
my $scan_reset_name = 'scan_reset';

# Values are always readable (the buffering latch is what is read if writable)
# Top of the list is first to come out of the scan chain
my @signal_list = ( # Outputs - chip to outside
                    { size =>   1, writable => 0, name => 'read_data_1'},
                    { size =>   2, writable => 0, name => 'read_data_2'},
                    { size =>   3, writable => 0, name => 'read_data_3'},

                    { size =>  16, writable => 0, name => 'read_data_array',  addr_bits => 2, data_bits => 4},

                    # Inputs - outside to chip
                    { size =>   1, writable => 1, name => 'memory_load_mode'},

                    { size =>   9, writable => 1, name => 'addr'},
                    { size =>  64, writable => 1, name => 'input_data'},
                    { size =>  64, writable => 0, name => 'output_data'},
                    { size =>   1, writable => 1, name => 'w1_r0'},

                    { size =>   1, writable => 1, name => 'write_data_1'},
                    { size =>   2, writable => 1, name => 'write_data_2', reset => 3},
                    { size =>   3, writable => 1, name => 'write_data_3'},

                    { size =>  16, writable => 1, name => 'write_data_array', addr_bits => 2, data_bits => 4, reset => 0xAA55},
                    
                    # Scan Reset - Make first bit in chain to allow a quick reset if needed
                    { size =>   1, writable => 1, name => $scan_reset_name},
                    );



# We're going to calculate the total scan chain length.
# We also use this to set some key values and do some error checking, so do not comment out this section.
my $scan_chain_length = 0;
my $reset_exists      = 0;
my $scan_reset_bit    = -1;

for (my $i = 0; $i < scalar @signal_list; $i++) {
    $signal_list[$i]{start} = $scan_chain_length;
    
    # Check to see if we have a reset signal
    if ($signal_list[$i]{name} eq $scan_reset_name) {
        $scan_reset_exists = 1;
        $scan_reset_bit    = $scan_chain_length;
    }

    # Here we set the default values for the addr_bits and data_bits fields
    $signal_list[$i]{addr_bits} = 0 if (!exists $signal_list[$i]{addr_bits});
    $signal_list[$i]{data_bits} = 0 if (!exists $signal_list[$i]{data_bits});
    
    # It's an array if either of these values are set
    if ($signal_list[$i]{addr_bits} == 0 && $signal_list[$i]{data_bits} == 0) {

        # Default case is that nothing is set so we just add the size
        $scan_chain_length += $signal_list[$i]{size};

    } else {
        
        # Let's do some error checking while we're at it:  2^addr_bits * data_bits >= size
        if ((1 << $signal_list[$i]{addr_bits}) * $signal_list[$i]{data_bits} < $signal_list[$i]{size}) {
            print STDERR "SCAN ERROR: addr_bits ($signal_list[$i]{addr_bits}) and data_bits ( $signal_list[$i]{data_bits})";
            print STDERR " are not big enough to fit size ($signal_list[$i]{size}) for $signal_list[$i]{name}\n";
            die;
        }
        
        # Passed the error checking, we're instead going to have address and data fields
        $scan_chain_length += $signal_list[$i]{addr_bits};
        $scan_chain_length += $signal_list[$i]{data_bits};

    }
}
