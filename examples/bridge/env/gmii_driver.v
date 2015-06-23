// Send an ethernet packet over GMII

module gmii_driver
  (output reg [7:0] rxd,
   output reg       rx_dv,
   output reg       rx_clk);

  integer 	    startup_skew;

  reg [7:0] 	    rxbuf [0:2048];
  reg [31:0] 	    crc32_result;

  // begin start clock with random skew amount
  initial
    begin
      startup_skew = {$random} % 200;
      rx_clk = 0;
      rx_dv = 0;
      rxd   = 0;
      repeat (startup_skew) #0.1;
      forever rx_clk = #4 ~rx_clk;
    end

  task gencrc32;
    input [7:0]   length;
    output [31:0] icrc;
    reg [31:0]    nxt_icrc;
    integer       i, len;
    begin
      icrc = {32{1'b1}};
      
      for (len=0; len<length; len=len+1)
        begin
          nxt_icrc[7:0] = icrc[7:0] ^ rxbuf[len];
          nxt_icrc[31:8] = icrc[31:8];

          for (i=0; i<8; i=i+1)
	    begin
	      if (nxt_icrc[0])
	        nxt_icrc = nxt_icrc[31:1] ^ 32'hEDB88320;
	      else
	        nxt_icrc = nxt_icrc[31:1];
	    end

          icrc = nxt_icrc;
	  $display ("DEBUG: byte %02d data=%x crc=%x", len, rxbuf[len], icrc);
        end // for (len=0; len<length; len=len+1)

      icrc = ~icrc;
    end
  endtask
      
/* -----\/----- EXCLUDED -----\/-----
  // Copied from: http://www.mindspring.com/~tcoonan/gencrc.v
  // 
  // Generate a (DOCSIS) CRC32.
  //
  // Uses the GLOBAL variables:
  //
  //    Globals referenced:
  //       parameter	CRC32_POLY = 32'h04C11DB7;
  //       reg [ 7:0]	crc32_packet[0:255];
  //       integer	crc32_length;
  //
  //    Globals modified:
  //       reg [31:0]	crc32_result;
  //
  localparam	CRC32_POLY = 32'h04C11DB7;
  task gencrc32;
    input [31:09] crc32_length;
    integer	cbyte, cbit;
    reg		msb;
    reg [7:0] 	current_cbyte;
    reg [31:0] 	temp;
    begin
      crc32_result = 32'hffffffff;
      for (cbyte = 0; cbyte < crc32_length; cbyte = cbyte + 1) begin
        current_cbyte = rxbuf[cbyte];
         for (cbit = 0; cbit < 8; cbit = cbit + 1) begin
            msb = crc32_result[31];
            crc32_result = crc32_result << 1;
            if (msb != current_cbyte[cbit]) begin
               crc32_result = crc32_result ^ CRC32_POLY;
               crc32_result[0] = 1;
            end
         end
      end
      
      // Last step is to "mirror" every bit, swap the 4 bytes, and then complement each bit.
      //
      // Mirror:
      for (cbit = 0; cbit < 32; cbit = cbit + 1)
         temp[31-cbit] = crc32_result[cbit];
         
      // Swap and Complement:
      crc32_result = ~{temp[7:0], temp[15:8], temp[23:16], temp[31:24]};
   end
endtask
 -----/\----- EXCLUDED -----/\----- */

  task print_packet;
    input [31:0] length;
    integer      i;
    begin
      for (i=0; i<length; i=i+1)
	begin
	  if (i % 16 == 0) $write ("%x: ", i[15:0]);
	  $write ("%x ", rxbuf[i]);
	  if (i % 16 == 7) $write ("| ");
	  if (i % 16 == 15) $write ("\n");
	end
      if (i % 16 != 0) $write ("\n");
    end
  endtask

  task send_packet;
    input [47:0] da, sa;
    input [15:0] length;
    integer 	 p;
    begin
      { rxbuf[0],rxbuf[1],rxbuf[2],rxbuf[3],rxbuf[4],rxbuf[5] } = da;
      { rxbuf[6],rxbuf[7],rxbuf[8],rxbuf[9],rxbuf[10],rxbuf[11] } = sa;
      for (p=12; p<length; p=p+1)
	rxbuf[p] = $random;

      //gencrc32 (length);
      gencrc32 (length-4, crc32_result);
      { rxbuf[length-1], rxbuf[length-2],
        rxbuf[length-3], rxbuf[length-4] } = crc32_result;

      $display ("%m : Sending packet DA=%x SA=%x of length %0d", da, sa, length);
      print_packet (length);
      
      repeat (7)
	begin
	  @(posedge rx_clk);
	  rx_dv <= #1 1;
	  rxd   <= #1 `GMII_PRE;
	end

      @(posedge rx_clk);
      rxd <= #1 `GMII_SFD;

      p = 0;
      while (p < length)
	begin
	  @(posedge rx_clk);
	  rxd <= #1 rxbuf[p];
	  p = p + 1;
	end

      // complete 12B inter frame gap
      repeat (12)
	begin
	  @(posedge rx_clk);
	  rx_dv <= #1 0;
	  rxd   <= #1 0;
	end
    end
  endtask // send_packet

      
endmodule // gmii_driver
