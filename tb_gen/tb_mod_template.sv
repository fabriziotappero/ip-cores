/////////////////////////////////////////////////////////////////
//   Copyright  2014 Ken Campbell
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//
//   test bench module file  template.
////////////////////////////////////////////////////////////////
>>header
//  The package.
  `include "../sv/tb_pkg.sv"

module tb_mod (dut_if.tb_conn tif);

  import tb_pkg::*;

  //  package and container
  cmd_lst  cmds;
  tb_trans r;

  integer  in_fh;
  integer  stat;
  logic    clock;

  //////////////////////////////////////////////
  //   DUT signals
>>insert sigs

  ////////////////////////////////////////////////////////
  //  drive DUT  signals through interface
>>drive sigs

  ////////////////////////////////////////////////////
  //  instruction variables
  integer  was_def     = 0;
  string   cmd_string;
  logic  [31:0]  tmp_vec;

  ////////////////////////////////////////////////////////////////////
  //   clock driver
  initial begin
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
    //cmds.define_instruction("READ", 1);
    //cmds.define_instruction("WRITE", 2);
    //cmds.define_instruction("VERIFY", 1);

    //  load the stimulus file
    cmds.load_stm(`STM_FILE);

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
        @(posedge clock)
      ///////////////////////////////////////////////////////////////////////////
      //  READ
      //end else if (cmd_string == "READ") begin
      //  @(posedge clock)
      ///////////////////////////////////////////////////////////////////////////
      //  WRITE
      //end else if (cmd_string == "WRITE") begin
      //////////////////////////////////////////////////////////////////////////
      //  VERIFY
      //end else if (cmd_string == "VERIFY") begin
      //  verify_command : assert (tmp_vec == r.rtn_val.par1) else begin
      //    $fatal(0,"VERIFY failed expected: %x  Got: %x", r.rtn_val.par1, tmp_vec);
      //  end
      end else begin
        $display("ERROR:  Command not found in the else if chain. Is it spelled correctly in the else if?");
      end //  end of else if chain
    end  //  end main while loop
    //  should never end up outside the while loop.
    $display("ERROR:  Some how, a run off the beginning or end of the instruction sequence, has not been caught!!");
  end   //  end Process_STM

endmodule // tb_mod
