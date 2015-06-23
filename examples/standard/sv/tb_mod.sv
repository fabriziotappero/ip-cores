
  `include "../sv/tb_pkg.sv"

module tb_mod (dut_if.tb_conn tif);

  import tb_pkg::*;
  
  integer  in_fh;
  integer  stat;
  integer  idx = 0;
  logic    clock;

  //////////////////////////////////////////////
  //   DUT signals
  logic  rst_n;
  logic  clk;
  logic  sel;
  logic  ack;
  logic  [31:0] out1;
  logic  [31:0] out2;
  logic  [31:0] addr;
  logic  [31:0] data_in;
  logic  [31:0] data_out;

  ////////////////////////////////////////////////////
  //  instruction variables
  integer  was_def     = 0;
  string   cmd_string;
  logic  [31:0]  tmp_vec;
  
  //  package and container
  cmd_lst  cmds;
  tb_trans r;

  ////////////////////////////////////////////////////////////////////
  //   clock driver
  initial begin
    while(1) begin
      #10 clock = 0;
      #10 clock = 1;
    end
  end
  
  ////////////////////////////////////////////////////////
  //  drive DUT  signals through interface
  assign tif.clk = clock;
  assign tif.sel = sel;
  assign tif.rst_n = rst_n;
  assign tif.addr  = addr;
  assign tif.data_in  =  data_in;
  assign data_out  = tif.data_out;
  assign ack  =  tif.ack;
  assign out1 =  tif.out1;
  assign out2 =  tif.out2;

  //////////////////////////////////////////////////////////
  //  stimulus_file processing
  initial begin : Process_STM
    cmds = new();
    r    = new();
    //  define the default instructions
    cmds.define_defaults();
    //  User instructions
    cmds.define_instruction("RESET", 0);
    cmds.define_instruction("READ", 1);
    cmds.define_instruction("WRITE", 2);
    cmds.define_instruction("VERIFY", 1);
    cmds.define_instruction("TEST_CMD", 7);
    
    //  load the stimulus file
    cmds.load_stm(tb_top.stm_file);
    
    r.cmd = cmds;
    /////////////////////////////////////////////////////
    //  the main loop.
    while (r.cmd != null) begin
      r      = r.cmd.get(r);
      r.next++;
      
      //  process default instructions
      was_def  =  r.cmd.exec_defaults(r);
      if(was_def) begin
        continue;
      end

      ///////////////////////////////////////////////////////
      //   Process User  instructions.
      //  output any dynamic string
      r.cmd.print_str_wvar();
      // get the command string
      cmd_string = r.cmd.lst_cmds.cmd;

      ///////////////////////////////////////////////////////////////////////////
      //  RESET
      if (cmd_string == "RESET") begin
        @(posedge clock)
          #1;
          rst_n  =  0;
          sel    =  0;
          addr   =  0;
          data_in  =  0;
        @(posedge clock)
        @(posedge clock)
           rst_n  =  1;
        //@(posedge clock)
      ///////////////////////////////////////////////////////////////////////////
      //  READ
      end else if (cmd_string == "READ") begin
        @(posedge clock)
          #1;
          if(r.rtn_val.par1 == 0) begin
            tmp_vec  =  out1;
          end else begin
            tmp_vec  =  out2;
          end
          #1;
      ///////////////////////////////////////////////////////////////////////////
      //  WRITE
      end else if (cmd_string == "WRITE") begin
        @(posedge clock)
          addr    = r.rtn_val.par1;
          data_in = r.rtn_val.par2;
          sel  =  1;
        @(posedge ack)
          #1;
          sel  =  0;
      //////////////////////////////////////////////////////////////////////////
      //  VERIFY
      end else if (cmd_string == "VERIFY") begin
        verify_command : assert (tmp_vec == r.rtn_val.par1) else begin
          $warning("VERIFY failed expected: %x  Got: %x", r.rtn_val.par1, tmp_vec);
        end
      //////////////////////////////////////////////////////////////////////////
      //  TEST_CMD
      end else if (cmd_string == "TEST_CMD") begin
        //#1;
      end else begin
        $display("ERROR:  Command  %s not found in the else if chain. Is it spelled correctly in the else if?", cmd_string);
      end //  end of else if chain
    end  //  end main while loop
    //  should never end up outside the while loop.
    $display("ERROR:  Some how, a run off the beginning or end of the instruction sequence, has not been caught!!");
  end   //  end Process_STM
  
endmodule // tb_mod
