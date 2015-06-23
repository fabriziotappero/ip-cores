
module env_io (/*AUTOARG*/
  // Inouts
  DI,
  // Inputs
  clk, iorq_n, rd_n, wr_n, addr, D_OUT
  );
  
  input clk;
  input iorq_n;
  input rd_n;
  input wr_n;
  input [7:0] addr;
  input [7:0] D_OUT;
  inout [7:0] DI;

  reg [7:0]    io_data;

  reg [7:0]    str_buf [0:255];
  reg 	       io_cs;
  integer      buf_ptr, i;

  reg [7:0]    timeout_ctl;
  reg [15:0]   cur_timeout;
  reg [15:0]   max_timeout;

  reg [7:0]    int_countdown;
  reg [7:0]    nmi_countdown;
  reg [7:0]    checksum;
  reg [7:0]    ior_value;  // increment-on-read value
  reg [7:0]    nmi_trigger; // trigger nmi when IR = this value
  
  assign       DI = (!iorq_n & !rd_n & io_cs) ? io_data : {8{1'bz}};

  initial
    begin
      io_cs = 0;
      buf_ptr = 0;
      cur_timeout = 0;
      max_timeout = 10000;
      timeout_ctl = 1;
      int_countdown = 0;
      nmi_countdown = 0;
      nmi_trigger = 0;
    end

  always @*
    begin
      if (!iorq_n & !rd_n)
        begin
          io_cs = (addr[7:5] == 3'b100);

          case (addr)
            8'h82 : io_data = timeout_ctl;
	    8'h83 : io_data = max_timeout[7:0];
	    8'h84 : io_data = max_timeout[15:8];

	    8'h90 : io_data = int_countdown;
            8'h91 : io_data = checksum;
            8'h93 : io_data = ior_value;
            8'h94 : io_data = {$random};
            8'h95 : io_data = nmi_countdown[7:0];
            8'hA0 : io_data = nmi_trigger;
            default : io_data = 8'hzz;
          endcase // case(addr)
        end // if (!iorq_n & !rd_n)
    end // always @ *

  wire wr_stb;
  reg last_iowrite;

  assign wr_stb = (!iorq_n & !wr_n);
  
  always @(posedge clk)
    begin
      last_iowrite <= #1 wr_stb;
      if (!wr_stb & last_iowrite)
	case (addr)
	  8'h80 :
	    begin
	      case (D_OUT)
		1 : 
                  begin
                    tb_top.test_pass;
                  end

		2 : 
                  begin
                    tb_top.test_fail;
                  end

		3 : tb_top.dumpon;

		4 : tb_top.dumpoff;

		default :
		  begin
		    $display ("%t: ERROR   : Unknown I/O command %x", $time, D_OUT);
		  end
	      endcase // case(D_OUT)
	    end // case: :...

	  8'h81 :
	    begin
	      str_buf[buf_ptr] = D_OUT;
	      buf_ptr = buf_ptr + 1;

	      //$display ("%t: DEBUG   : Detected write of character %x", $time, D_OUT);
	      if (D_OUT == 8'h0A)
		begin
		  $write ("%t: PROGRAM : ", $time);

		  for (i=0; i<buf_ptr; i=i+1)
		    $write ("%s", str_buf[i]);
		      
		  buf_ptr = 0;
		end
	    end // case: 8'h81

	  8'h82 :
	    begin
	      timeout_ctl = D_OUT;
  	    end

	  8'h83 : max_timeout[7:0] = D_OUT;
	  8'h84 : max_timeout[15:8] = D_OUT;

	  8'h90 : int_countdown = D_OUT;
          8'h91 : checksum = D_OUT;
          8'h92 : checksum = checksum + D_OUT;
          8'h93 : ior_value = D_OUT;
          8'h95 : nmi_countdown[7:0] = D_OUT;
          8'hA0 : nmi_trigger = D_OUT;
	endcase // case(addr)
    end // always @ (posedge clk)

  always @(posedge clk)
    begin
      if (timeout_ctl[1])
	cur_timeout = 0;
      else if (timeout_ctl[0])
	cur_timeout = cur_timeout + 1;

      if (cur_timeout >= max_timeout)
	begin
	  $display ("%t: ERROR   : Reached timeout %d cycles", $time, max_timeout);
	  tb_top.test_fail;
	end
    end // always @ (posedge clk)

  always @(posedge clk)
    begin
      if (int_countdown == 0)
        begin
          tb_top.int_n  <= #1 1'b1;
        end
      else if (int_countdown == 1)
	begin
	  tb_top.int_n  <= #1 1'b0;
	  //int_countdown = 0;
	end
      else if (int_countdown > 1)
        begin
	  int_countdown = int_countdown - 1;
	  tb_top.int_n  <= #1 1'b1;
        end

      // when nmi countdown reaches 1, an NMI will be issued.
      // to clear the interrupt, write nmi_countdown to 0.
      if ((nmi_countdown == 0) && (nmi_trigger == 0))
        begin
          tb_top.nmi_n  <= #1 1'b1;
        end
      else if (nmi_countdown == 1)
	begin
	  tb_top.nmi_n  <= #1 1'b0;
	end
      else if (nmi_countdown > 1)
        begin
	  nmi_countdown = nmi_countdown - 1;
	  tb_top.nmi_n  <= #1 1'b1;
        end

      // when IR equals the target instruction, an NMI will be
      // issued.  To clear the interrupt, write nmi_trigger to
      // zero.
      if (nmi_trigger != 0)
        begin
          if (nmi_trigger === tb_top.tv80s_inst.i_tv80_core.IR[7:0])
            begin
              tb_top.nmi_n <= #80 0;
              tb_top.nmi_n <= #160 1;
            end
        end
      else if (nmi_countdown == 0)
        tb_top.nmi_n <= #1 1;
    end
  
endmodule // env_io
