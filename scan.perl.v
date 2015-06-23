

////////////////////////////////////////////////////////////////////////////////

module scan (

              // Inputs & outputs to the chip
             PERL begin
             /*              
              DEPERLIFY_INCLUDE(scan_signal_list.pl);
              
              for (my $i = 0; $i < scalar @signal_list; $i++) {
                 print "              $signal_list[$i]{name},\n";
              }
              
              */
             end
             
              // To the pads
              scan_phi,
              scan_phi_bar,
              scan_data_in,
              scan_data_out,
              scan_load_chip,
              scan_load_chain
             
              );

   
   // /////////////////////////////////////////////////////////////////////
   // Ports

   // Scans
   input   scan_phi;
   input   scan_phi_bar;
   input   scan_data_in;
   output  scan_data_out;
   input   scan_load_chain;
   input   scan_load_chip;

   
   PERL begin
      /*              
       DEPERLIFY_INCLUDE(scan_signal_list.pl);
       
       for (my $i = 0; $i < scalar @signal_list; $i++) {
           if ($signal_list[$i]{writable} == 1) {
                print "   output reg ";
           } else {
                print "   input      ";
           }
       
            print "[$signal_list[$i]{size}-1:0]  $signal_list[$i]{name};\n";
       }
       
       */
   end

   
   // /////////////////////////////////////////////////////////////////////
   // Implementation

   // The scan chain is comprised of two sets of latches: scan_master and scan_slave.
   
   PERL begin
      /*
       
       ##############################################################
       # Modify scan_signal_list.pl in order to change the signals. #
       ##############################################################
       
       DEPERLIFY_INCLUDE(scan_signal_list.pl);
       
       # Print scan chain latches
       print "   reg [$scan_chain_length-1:0] scan_master;\n";
       print "   reg [$scan_chain_length-1:0] scan_slave;\n\n";

       # Print scan_load and scan_next logic
       print "   reg  [$scan_chain_length-1:0] scan_load;\n";
       print "   wire [$scan_chain_length-1:0] scan_next;\n\n";
       
       print "   always @ (*) begin\n";
       
       for (my $i = 0; $i < scalar @signal_list; $i++) {

          my $name      = $signal_list[$i]{name};
          my $size      = $signal_list[$i]{size};
          my $addr_bits = $signal_list[$i]{addr_bits};
          my $data_bits = $signal_list[$i]{data_bits};
       
          my $size_begin = $signal_list[$i]{start};
          my $size_end   = $size_begin + $size - 1;
       
          my $addr_begin = $signal_list[$i]{start};
          my $addr_end   = $addr_begin + $addr_bits - 1;
          
          my $data_begin = $addr_end + 1;
          my $data_end   = $data_begin + $data_bits - 1;

          if ($signal_list[$i]{addr_bits} == 0) {
             print "      scan_load[$size_end:$size_begin] = ${name};\n";
          } else {
             print "      scan_load[$addr_end:$addr_begin] = scan_slave[$addr_end:$addr_begin];\n";
             print "      case (scan_slave[$addr_end:$addr_begin])\n";
             for (my $a = 0; ($a+1-1)*$data_bits < $size; $a++) {
                print "         ${addr_bits}'d${a}: scan_load[$data_end:$data_begin] = ${name}[$a*$data_bits +: $data_bits];\n";
             }
             print "      endcase\n";
          } 
       }
       
       print "   end\n\n";
       
       print "   assign scan_next = scan_load_chain ? scan_load : {scan_data_in, scan_slave[$'$scan_chain_length-1:1]};\n\n";
           
       # Print latches
       print "   //synopsys one_hot \"scan_phi, scan_phi_bar\"\n";
       print "   always @ (*) begin\n";
       print "       if (scan_phi)\n";
       print "          scan_master = scan_next;\n";
       print "       if (scan_phi_bar)\n";
       print "          scan_slave  = scan_master;\n";
       print "   end\n\n";
       
       # Print input latches
       print "   always @ (*) if (scan_load_chip) begin\n";
       
       for (my $i = 0; $i < scalar @signal_list; $i++) {
          if ($signal_list[$i]{writable} == 1) {
       
             my $name      = $signal_list[$i]{name};
             my $size      = $signal_list[$i]{size};
             my $addr_bits = 0 + $signal_list[$i]{addr_bits};
             my $data_bits = 0 + $signal_list[$i]{data_bits};
             my $reset   = 0 + $signal_list[$i]{reset};
             
             my $size_begin = $signal_list[$i]{start};
             my $size_end   = $size_begin + $size - 1;
             
             my $addr_begin = $signal_list[$i]{start};
             my $addr_end   = $addr_begin + $addr_bits - 1;
             
             my $data_begin = $addr_end + 1;
             my $data_end   = $data_begin + $data_bits - 1;
       
             if ($signal_list[$i]{addr_bits} == 0) {
                 if ($signal_list[$i]{name} ne $scan_reset_name) {
                    print "      $name = scan_slave[$scan_reset_bit] ? ${size}'d${reset} : scan_slave[$size_end:$size_begin];\n";
                 } else {
                    print "      $name = scan_slave[$scan_reset_bit];\n";
                 }
             } else {
                if ($scan_reset_exists) {
                   print "      if (scan_slave[$scan_reset_bit]) ${name} = ${size}'d${reset}; else\n";
                }
                print "      case (scan_slave[$addr_end:$addr_begin])\n";
                for (my $a = 0; ($a+1-1)*$data_bits < $size; $a++) {
                   print "         ${addr_bits}'d${a}: ${name}[$a*$data_bits +: $data_bits] = scan_slave[$data_end:$data_begin];\n";
                }
                print "      endcase\n";
             }
          }
       }
       
       print "   end\n\n";
       
       # Print data_out
       print "   assign scan_data_out = scan_slave[0];\n";
       
       */
   end

   
   // /////////////////////////////////////////////////////////////////////
   
endmodule
