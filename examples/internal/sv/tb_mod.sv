
module tb_prg (dut_if.tb_conn tif);

  import tb_pkg::*;

  //  package and container
  cmd_lst  cmds;
  tb_trans r;

  integer  in_fh;
  integer  stat;
  integer  fi;
  logic    clock;
  lst_item  ti;

  string STM_FILE = "../stm/stimulus_file.stm";
  string tmp_fn;

  //  Handle plus args
  initial begin : file_select
    if($value$plusargs("STM_FILE=%s", tmp_fn)) begin
      STM_FILE = tmp_fn;
    end
  end

  //////////////////////////////////////////////
  //   DUT signals
  logic ack;
  logic [31:0] datai;
  logic [31:0] datao;
  logic [31:0] addr;
  logic w_n  =  1'b1;
  logic clk;
  logic rst_n;
  logic [31:0] tdut_out;
  logic [31:0] tdut_in = 0;

  ////////////////////////////////////////////////////////
  //  drive / read DUT  signals by hierarchy connection
  assign tif.rst_n = rst_n;
  assign tif.clk = clock;
  assign tb_top.U1.cpu.w_n = w_n;
  assign tb_top.U1.cpu.addr = addr;
  assign tb_top.U1.cpu.datao = datao;
  assign datai = tb_top.U1.cpu.datai;
  assign tb_top.U1.in1 = tdut_in;
  assign tdut_out = tb_top.U1.out1;
  assign ack = tb_top.U1.cpu.ack;

  ////////////////////////////////////////////////////
  //  instruction variables
  integer  was_def     = 0;
  string   cmd_string;
  logic  [31:0]  tmp_vec;

  ////////////////////////////////////////////////////////////////////
  //   clock driver
  initial begin
    clock = 1;
    while(1) begin
      #10 clock = 0;
      #10 clock = 1;
    end
  end

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
    cmds.define_instruction("SET_I", 1);
    cmds.define_instruction("READ_O", 1);

    //  load the stimulus file
    cmds.load_stm(STM_FILE);

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
      // get the command string
      cmd_string = r.cmd.lst_cmds.cmd;
      //  output the dynamic text if there is some. (Note:  before command runs.)
      r.cmd.print_str_wvar();

      ///////////////////////////////////////////////////////////////////////////
      //  RESET
      if (cmd_string == "RESET") begin
        rst_n  =  1'b1;
        @(posedge clock);
        rst_n  =  1'b0;
        @(posedge clock);
        @(posedge clock);
        @(posedge clock);
        rst_n  =  1'b1;
        @(posedge clock);
      ///////////////////////////////////////////////////////////////////////////
      //  READ
      end else if (cmd_string == "READ") begin
        @(posedge clock);
        addr = r.rtn_val.par1;
        @(posedge clock);
        @(posedge clock);
        addr = 0;
        tmp_vec = datai;
      ///////////////////////////////////////////////////////////////////////////
      //  WRITE
      end else if (cmd_string == "WRITE") begin
        @(posedge clock);
        addr = r.rtn_val.par1;
        datao = r.rtn_val.par2;
        @(posedge clock)
        w_n  =  1'b0;
        @(posedge clock);
        w_n  =  1'b1;
        addr = 0;
        #1;
      ///////////////////////////////////////////////////////////////////////////
      //  VERIFY
      end else if (cmd_string == "VERIFY") begin
        verify_command : assert (tmp_vec == r.rtn_val.par1) else begin
          fi = r.cmd.lst_cmds.file_idx;
          ti = r.cmd.file_lst.get(fi);
          $fatal(0,"VERIFY failed expected: %x  Got: %x\nOn line number %3d of file %s", 
                 r.rtn_val.par1, tmp_vec, r.cmd.lst_cmds.line_num, ti.txt);
        end
      ///////////////////////////////////////////////////////////////////////////
      //  SET_I
      end else if (cmd_string == "SET_I") begin
        tdut_in  =  r.rtn_val.par1;
        #0;
      end else if (cmd_string == "READ_O") begin
        tmp_vec = tdut_out;
        #0;
      end else begin
        $display("ERROR:  Command not found in the else if chain. Is it spelled correctly in the else if?");
      end //  end of else if chain
    end  //  end main while loop
    //  should never end up outside the while loop.
    $display("ERROR:  Some how, a run off the beginning or end of the instruction sequence, has not been caught!!");
  end   //  end Process_STM

endmodule // tb_prg

