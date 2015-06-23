`timescale 1ns/1ns

module sb_bench;

  localparam width = 32;
  localparam items = 32;
  localparam use_txid = 1;
  localparam use_mask = 1;
  localparam asz=$clog2(items);
  localparam txid_sz = asz;

  reg clk, reset;

  initial
    begin
      clk = 0;
      forever #5 clk = ~clk;
    end
  
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  wire [width-1:0]	c_data;			// From driver of sb_driver.v
  wire			c_drdy;			// From sboard of sd_scoreboard.v
  wire [asz-1:0]	c_itemid;		// From driver of sb_driver.v
  wire [width-1:0]	c_mask;			// From driver of sb_driver.v
  wire			c_req_type;		// From driver of sb_driver.v
  wire			c_srdy;			// From driver of sb_driver.v
  wire [txid_sz-1:0]	c_txid;			// From driver of sb_driver.v
  wire [width-1:0]	p_data;			// From sboard of sd_scoreboard.v
  wire			p_drdy;			// From monitor of sb_monitor.v
  wire			p_srdy;			// From sboard of sd_scoreboard.v
  wire [txid_sz-1:0]	p_txid;			// From sboard of sd_scoreboard.v
  // End of automatics

/* sb_driver AUTO_TEMPLATE
 (
 .p_\(.*\)   (c_\1[]),
 );
 */
  sb_driver #(/*AUTOINSTPARAM*/
	      // Parameters
	      .width			(width),
	      .items			(items),
	      .use_txid			(use_txid),
	      .use_mask			(use_mask),
	      .txid_sz			(txid_sz),
	      .asz			(asz)) driver
    (/*AUTOINST*/
     // Outputs
     .p_srdy				(c_srdy),		 // Templated
     .p_req_type			(c_req_type),		 // Templated
     .p_txid				(c_txid[txid_sz-1:0]),	 // Templated
     .p_mask				(c_mask[width-1:0]),	 // Templated
     .p_itemid				(c_itemid[asz-1:0]),	 // Templated
     .p_data				(c_data[width-1:0]),	 // Templated
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .p_drdy				(c_drdy));		 // Templated
  
/* sd_scoreboard AUTO_TEMPLATE
 (
 );
 */
  sd_scoreboard #(
                  // Parameters
                  .width                (width),
                  .items                (items),
                  .use_txid             (use_txid),
                  .use_mask             (use_mask),
                  .txid_sz              (txid_sz)) sboard
    (/*AUTOINST*/
     // Outputs
     .c_drdy				(c_drdy),
     .p_srdy				(p_srdy),
     .p_txid				(p_txid[txid_sz-1:0]),
     .p_data				(p_data[width-1:0]),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(c_srdy),
     .c_req_type			(c_req_type),
     .c_txid				(c_txid[txid_sz-1:0]),
     .c_mask				(c_mask[width-1:0]),
     .c_data				(c_data[width-1:0]),
     .c_itemid				(c_itemid[asz-1:0]),
     .p_drdy				(p_drdy));

  sb_monitor #(/*AUTOINSTPARAM*/
	       // Parameters
	       .width			(width),
	       .items			(items),
	       .use_txid		(use_txid),
	       .use_mask		(use_mask),
	       .txid_sz			(txid_sz),
	       .asz			(asz)) monitor
    (/*AUTOINST*/
     // Outputs
     .p_drdy				(p_drdy),
     // Inputs
     .clk				(clk),
     .reset				(reset),
     .c_srdy				(c_srdy),
     .c_drdy				(c_drdy),
     .c_req_type			(c_req_type),
     .c_txid				(c_txid[txid_sz-1:0]),
     .c_mask				(c_mask[width-1:0]),
     .c_data				(c_data[width-1:0]),
     .c_itemid				(c_itemid[asz-1:0]),
     .p_srdy				(p_srdy),
     .p_txid				(p_txid[txid_sz-1:0]),
     .p_data				(p_data[width-1:0]));

/* -----\/----- EXCLUDED -----\/-----
  task send;
    input req_type;
    input [txid_sz-1:0] txid;
    input [width-1:0]   mask;
    input [width-1:0]   data;
    input [asz-1:0]     itemid;
 -----/\----- EXCLUDED -----/\----- */
  integer               i, entry;
  integer               op;
 
  initial
    begin
`ifdef VCS
      $vcdpluson;
`else
      $dumpfile ("sb.lxt");
      $dumpvars;
`endif
      reset = 1;
      #200;
      reset = 0;

      repeat (5) @(posedge clk);

      // fill up scoreboard with random data
      for (i=0; i<items; i=i+1)
        begin
          driver.send (1, {width{1'b1}}, $random, i);
        end

      // request random entries from scoreboard
      for (i=0; i<64; i=i+1)
        begin
          entry = {$random} % items;
          
          driver.send (0, 0, 0, entry);
        end

      // mix updates with requests
      for (i=0; i<4096; i=i+1)
        begin
	  // choose random entry but space requests apart
	  //entry = {$random} % items;
	  case (i%2)
	    0 : entry = {$random} % (items/2);
	    1 : entry = {$random} % (items/2) + items/2;
	    //2 : entry = {$random} % (items/4) + 2*(items/4);
	    //3 : entry = {$random} % (items/4) + 3*(items/4);
	  endcase

          op = {$random} % 8;

	  case (i)
	    512  : monitor.drdy_pat = 8'h55;
	    1024 : monitor.drdy_pat = 8'h0F;
	    1500 : monitor.drdy_pat = 8'h82;
	    2000 : monitor.drdy_pat = 8'hFE;
	  endcase

          if (op == 0)
            driver.send (1, {width{1'b1}}, $random, entry);
          else if (op == 1)
            driver.send (1, 32'h0000FFFF, $random, entry);            
          else if (op == 2)
            driver.send (1, $random, $random, entry);            
          else
            driver.send (0, 0, 0, entry);
        end
      
      
      #500;
      $finish;
    end
        
      
  
endmodule // sb_bench
// Local Variables:
// verilog-library-directories:("." "../../../rtl/verilog/utility")
// End:  

