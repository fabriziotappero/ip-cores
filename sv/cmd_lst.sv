////////////////////////////////////////////////////////////////////////////
//
// Copyright 2014  Ken Campbell
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
/////////////////////////////////////
//  command list  class
class cmd_lst;
  tb_cmd   lst_cmds;
  lst_item file_lst;
  lst_item var_lst;
  lst_item inst_lst;
  
  integer lst_sz;
  integer lst_idx;
  integer last_idx;
  integer curr_line_num;
  string  file_name;
  string  include_name;
  
  integer  call_stack [8:1];
  integer  call_index  = 0;
  integer  loop_cnt   [7:0];
  integer  loop_term  [7:0];
  integer  loop_line  [7:0];
  integer  loop_num    = 0;
  integer  if_state    = 0;
  integer  wh_state    = 0;
  integer  wh_top      = 0;

  //prototypes
  extern function void define_instruction(string inst_txt, int args);
  extern function void define_defaults();
  extern function void load_stm(string stm_file);
  extern function void load_include();
  extern function void add_cmd(tb_cmd cmd);
  extern function void check_cmds();
  extern function tb_trans get(tb_trans inst);
  extern function integer exec_defaults(tb_trans r);
  extern function new();
  extern function void print_cmds();
  extern function void print_str();
  extern function void print_str_wvar();
endclass // cmd_lst

////////////////////////////////////////////////////////////////////////////////////////
// method definitions.
///////////////////////////////////////////////////////////
//   function cmd_lst::new
function cmd_lst::new();
  lst_cmds  =  new();
  file_lst  =  new("Files");
  var_lst   =  new("Variables");
  inst_lst  =  new("Instructions");
  lst_sz  = 0;
  lst_idx  = 0;
  last_idx  = 0;
  curr_line_num = 0;
  file_name  = "";
  include_name  = "";
endfunction // new

///////////////////////////////////////////////////////////
//  function cmd_lst::get
function tb_trans cmd_lst::get(tb_trans inst);
  tb_trans  rtn;
  cmd_lst   tmp_cmd;
  lst_item  tmp_item;
  integer   int_val;
  integer   tmp_int;
  integer   len;
  string    tmp_str;

  rtn  =  inst;
  rtn.rtn_val.par1  = 0;
  rtn.rtn_val.par2  = 0;
  rtn.rtn_val.par3  = 0;
  rtn.rtn_val.par4  = 0;
  rtn.rtn_val.par5  = 0;
  rtn.rtn_val.par6  = 0;

  if(rtn.next > rtn.cmd.lst_cmds.idx) begin
    while (rtn.next > rtn.cmd.lst_cmds.idx  && rtn.cmd.lst_cmds != null) begin
      rtn.cmd.lst_cmds = rtn.cmd.lst_cmds.next;
      check_get_next : assert (rtn.cmd.lst_cmds != null) else begin
        $fatal(0, "cmd_lst::get failed due to attemped access to commands behond the end of the script.");
      end
    end
  end else if (rtn.next < rtn.cmd.lst_cmds.idx) begin
    while (rtn.next < rtn.cmd.lst_cmds.idx  && rtn.cmd.lst_cmds != null) begin
      rtn.cmd.lst_cmds = rtn.cmd.lst_cmds.prev;
      check_get_prev : assert (rtn.cmd.lst_cmds != null) else begin
        $fatal(0, "cmd_lst::get failed due to attemped access to commands before the beginning of the script.");
      end
    end
  end

  rtn.rtn_val.cmd  = rtn.cmd.lst_cmds.cmd;
  for (int i = 1; i <= rtn.cmd.lst_cmds.valid_fld - 1; i++) begin
    case (i)
      1: tmp_str = rtn.cmd.lst_cmds.var1;
      2: tmp_str = rtn.cmd.lst_cmds.var2;
      3: tmp_str = rtn.cmd.lst_cmds.var3;
      4: tmp_str = rtn.cmd.lst_cmds.var4;
      5: tmp_str = rtn.cmd.lst_cmds.var5;
      6: tmp_str = rtn.cmd.lst_cmds.var6;
      default: $display("ERROR:  more than six parameters ????");
    endcase
    tmp_int = is_var(tmp_str);
    if (tmp_int == 0) begin
      tmp_int = stm2_int(tmp_str);
    end else if (tmp_int == 1) begin
      len = tmp_str.len();
      tmp_str = tmp_str.substr(1, len - 1);
      tmp_item = rtn.cmd.var_lst.find(tmp_str);
      tmp_int  = tmp_item.val;
    end else if (tmp_int == 2) begin
      tmp_item = rtn.cmd.var_lst.find(tmp_str);
      tmp_int  = tmp_item.index;
    end else if (tmp_int == 3) begin
      case (tmp_str)
        "==" : tmp_int = 0;
        "!=" : tmp_int = 1;
        ">"  : tmp_int = 2;
        "<"  : tmp_int = 3;
        ">=" : tmp_int = 4;
        "<=" : tmp_int = 5;
        default : $display("Condition text not found ???");
      endcase
    end else begin
      $display("is_var() returned an unknown value???");
    end

    case (i)
      1: rtn.rtn_val.par1 = tmp_int;
      2: rtn.rtn_val.par2 = tmp_int;
      3: rtn.rtn_val.par3 = tmp_int;
      4: rtn.rtn_val.par4 = tmp_int;
      5: rtn.rtn_val.par5 = tmp_int;
      6: rtn.rtn_val.par6 = tmp_int;
      default: $display("ERROR:  more than six parameters ????");
    endcase
  end
  
  return rtn;
endfunction

///////////////////////////////////////////////////////////
//  function  cmd_lst::define_instruction
function void cmd_lst::define_instruction(string inst_txt, int args);
  lst_item  tmp_lst;
  lst_item  new_itm;
  integer   stat = 0;
  //  search the list for this instruction
  tmp_lst = new("");
  tmp_lst = this.inst_lst;
  while(tmp_lst != null) begin
    if(tmp_lst.txt != inst_txt) begin
      tmp_lst = tmp_lst.next;
    end else begin
      check_duplicate_inst : assert (0) else begin
        $fatal(0, "Duplicate instruction definition attempted : %s", inst_txt);
      end
      //$display("ERROR: Duplicate instruction definition attempted : %s", inst_txt);
      //stat = 1;
      //return stat;
    end
  end
  // all good lets add this instruction to the list
  new_itm = new("");
  new_itm.txt = inst_txt;
  new_itm.val = args;
  inst_lst.add_itm(new_itm);
  
  //return stat;
endfunction  //  define_instruction

/////////////////////////////////////////////////////////
//  function cmd_lst::add_cmd
//    INPUT:  tb_cmd   cmd
function void cmd_lst::add_cmd(tb_cmd cmd);
  tb_cmd   tmp_cmd;
  tb_cmd   new_cmd;
  integer  stat  = 0;

  tmp_cmd  =  new();
  tmp_cmd  =  this.lst_cmds;

  // first 
  if((this.lst_cmds.next == null) && (this.lst_cmds.cmd == "")) begin
    new_cmd       = new();
    new_cmd       = cmd;
    new_cmd.idx   = 0;
    this.lst_cmds = new_cmd;
  // second
  end else if(this.lst_cmds.next == null) begin
    new_cmd      =  new();
    new_cmd      =  cmd;
    new_cmd.idx  = 1;
    tmp_cmd.next = new_cmd;
    new_cmd.prev = tmp_cmd;
  // rest
  end else begin
    while (tmp_cmd.next != null) begin
       tmp_cmd   = tmp_cmd.next;
    end
    new_cmd      = new();
    new_cmd      = cmd;
    new_cmd.idx  = tmp_cmd.idx + 1;
    tmp_cmd.next = new_cmd;
    new_cmd.prev = tmp_cmd;
  end
  this.lst_sz++;
  this.last_idx  = new_cmd.idx;
endfunction

/////////////////////////////////////////////////////////
//  function  cmd_lst::load stimulus
function void cmd_lst::load_stm(string stm_file);
  tb_cmd   new_cmd;
  tb_cmd   tst_cmd;
  integer  in_fh;
  integer  stat = 0;
  integer  fstat = 0;
  integer  idx = 0;
  integer  len;
  integer  i, ilen;
  string   input_str;
  string   tstr;
  lst_item tmp_item;
  // open the file passed and test for existance.
  in_fh  = $fopen(stm_file, "r");
  check_file_open : assert (in_fh != 0) else begin
     $fatal(0, "ERROR: File not found in cmd_lst::load_stm : %s", stm_file);
  end
  
  this.file_name = stm_file;
  //  this is the main file, add to file list.
  tmp_item = new("");
  tmp_item.txt = stm_file;
  file_lst.add_itm(tmp_item);
  
  this.curr_line_num  = 0;
  //  new the test results storage ...
  tmp_item = new("");
  
  while (! $feof(in_fh)) begin
    fstat = $fgets(input_str, in_fh);
    // increment the line number
    this.curr_line_num++;
    tst_cmd = new();
    if (input_str == "\n" || input_str == "")
      continue;
    // check for special commands DEFINE_VAR and INCLUDE
    tst_cmd = tst_cmd.parse_cmd(input_str);
    len = tst_cmd.cmd.len();
    if (tst_cmd.cmd == "DEFINE_VAR") begin
      tmp_item.txt =  tst_cmd.var1;
      tmp_item.val =  stm2_int(tst_cmd.var2);
      var_lst.add_itm(tmp_item);
    //  check for  INCLUDE file def
    end else if (tst_cmd.cmd == "INCLUDE") begin
      if(tst_cmd.var1 != "") begin
        this.include_name = tst_cmd.var1;
      end else if (tst_cmd.cmd_str != "") begin
        tstr  = tst_cmd.cmd_str;
        ilen = tstr.len();
        i  =  ilen-1;
        //  strip any  trailing spaces
        while(tstr[i] == " ") begin
          tstr = tstr.substr(0,i-1);
          i--;
        end
        this.include_name = tstr;
      end else begin
        check_include : assert (0) else begin
          $fatal(0, "No INCLUDE file found in command on\n line:  %4d in file: %s", curr_line_num, stm_file);
        end
      end
      this.load_include();
    //  check for inline variable.
    end else if(tst_cmd.cmd[len-1] == ":") begin
      tmp_item.txt =  tst_cmd.cmd.substr(0, len-2);
      tmp_item.val =  this.last_idx + 1;
      var_lst.add_itm(tmp_item);
    //  else is a standard command
    end else begin
      //  parse out the command
      new_cmd = new();
      new_cmd = new_cmd.parse_cmd(input_str);
      if (new_cmd.valid_fld > 0) begin
        new_cmd.line_num = curr_line_num;
        new_cmd.file_idx =  0;
        this.add_cmd(new_cmd);
      end
    end
  end // while (! $feof(in_fh))

  check_cmds();
endfunction // load_stm
//////////////////////////////////////////////////////
//  function cmd_lst::load_include
function void cmd_lst::load_include();
  tb_cmd   tmp_cmd;
  tb_cmd   new_cmd;
  tb_cmd   tst_cmd;
  integer  inc_fh;
  integer  stat = 0;
  integer  idx = 0;
  string   input_str;
  lst_item tmp_item;
  lst_item var_item;
  integer  file_idx;
  integer  len;
  integer  file_line = 0;
  
  // open the file passed and test for existance.
  inc_fh  = $fopen(this.include_name, "r");
  check_include_open : assert(inc_fh != 0) else begin
    $fatal(0, "INCLUDE File not found: %s\nFound in file:  %s\nOn line:  %4d", this.include_name, this.file_name, this.curr_line_num);
  end
  
  //  this is an include file, add to list.
  tmp_item = new("");
  tmp_item.txt = this.include_name;
  file_lst.add_itm(tmp_item);
  tmp_item = file_lst.find(this.include_name);
  file_idx = tmp_item.index;
  
  //  new the test results storage ...
  var_item = new("");
  
  while (! $feof(inc_fh)) begin
    file_line++;
    stat = $fgets(input_str, inc_fh);
    tst_cmd = new();
    // skip  blank lines
    if (input_str == "\n" || input_str == "")
      continue;
    // check for special commands DEFINE_VAR, INCLUDE and inline variables
    tst_cmd = tst_cmd.parse_cmd(input_str);
    len = tst_cmd.cmd.len();
    //  DEFINE_VAR
    if (tst_cmd.cmd == "DEFINE_VAR") begin
      var_item.txt =  tst_cmd.var1;
      var_item.val =  stm2_int(tst_cmd.var2);
      var_lst.add_itm(var_item);
      continue;
    //  INCLUDE  Not nested.
    end else if (tst_cmd.cmd == "INCLUDE") begin
        check_nest_include : assert (0) else begin
          $fatal(0, "INCLUDE can not be nested!!\nFound in file:  %s\nOn line:  %4d", this.include_name, file_line);
        end
    //  In line VAR
    end else if (tst_cmd.cmd[len - 1] == ":") begin
      var_item.txt =  tst_cmd.cmd.substr(0, len-2);
      var_item.val =  this.last_idx + 1;
      var_lst.add_itm(var_item);
      continue;
    end
    //  parse out the command
    new_cmd = new();
    new_cmd = new_cmd.parse_cmd(input_str);
    if (new_cmd.valid_fld > 0) begin
      new_cmd.file_idx = file_idx;
      new_cmd.line_num = file_line;
      this.add_cmd(new_cmd);
    end
  end // while (! $feof(inc_fh))
endfunction // load_include

////////////////////////////////////////////////////////////
//  function  check_cmds
//    checks that the commands loaded exist, have correct # params and
//    variable names exist
function void cmd_lst::check_cmds();
  tb_cmd   tmp_cmd;
  tb_cmd   dum;
  int      found;
  string   cname;
  string   fname;
  string   t_var;
  byte     c;
  int      num_params;
  lst_item tmp_lst;
  lst_item flst;
  lst_item tmp_item;
  integer  stat = 0;
  integer  file_idx;
  integer  len;
  integer  vtype;
  
  tmp_cmd = this.lst_cmds;
  //  go through all the commands from the stimulus file.
  while(tmp_cmd != null) begin
    cname      = tmp_cmd.cmd;
    num_params = tmp_cmd.valid_fld;
    tmp_lst    = this.inst_lst;
    found      = 0;
    //  get the file name from this command
    file_idx   = tmp_cmd.file_idx;
    flst       = this.file_lst;
    while (flst != null) begin
      if(flst.index == file_idx) begin
        fname = flst.txt;
      end
      flst  = flst.next;
    end
    //  go through the  list of valid commands
    while (tmp_lst != null  &&  found == 0) begin
      if (tmp_lst.txt == cname) begin
	      found = 1;
	      check_num_params : assert ((tmp_lst.val == num_params - 1) || (tmp_lst.val >= 7)) else begin
	        $fatal(0, "Incorrect number of parameters found in command on\n        line: %4d   in file: %s", tmp_cmd.line_num, fname);
	      end
      end
      tmp_lst = tmp_lst.next;
    end
    //  if we did not find a command
    check_valid_instruction : assert (found != 0) else begin
      $fatal(0, "Command  %s  was not found in the list of valid commands on\n        line: %4d   in file: %s", cname, tmp_cmd.line_num, fname);
    end

    //  Check the line for invalid variable names
    if(num_params != 0) begin
      tmp_lst = this.var_lst;
      for (int i = 1; i <= num_params - 1; i++) begin
        case (i)
          1: t_var = tmp_cmd.var1;
          2: t_var = tmp_cmd.var2;
          3: t_var = tmp_cmd.var3;
          4: t_var = tmp_cmd.var4;
          5: t_var = tmp_cmd.var5;
          6: t_var = tmp_cmd.var6;
          default: $display("ERROR: num_params greater than six???");
        endcase
        c = t_var[0];
        vtype = is_var(t_var);
        if(vtype) begin
          if(c == "$") begin
            len   = t_var.len();
            t_var = t_var.substr(1, len - 1);
          end
          //  if condition operator skip
          if(vtype == 3) begin
            continue;
          end
        end else begin
          continue;
        end
        tmp_item  =  var_lst.find(t_var);
        check_valid_variable : assert (tmp_item != null) else begin
          $fatal(0, "Variable number: %2d >>> %s <<< on line %4d   in file: %s   Is NOT defined!!", i, t_var, tmp_cmd.line_num, fname);
        end
      end
    end
    
    tmp_cmd = tmp_cmd.next;
  end
endfunction   //  cmd_lst::check_cmds

/////////////////////////////////////////////////////////////
//  
 function void cmd_lst::define_defaults();
    this.define_instruction("ABORT", 0);
    this.define_instruction("FINISH", 0);
    this.define_instruction("EQU_VAR", 2);
    this.define_instruction("ADD_VAR", 2);
    this.define_instruction("SUB_VAR", 2);
    this.define_instruction("CALL", 1);
    this.define_instruction("RETURN_CALL", 0);
    this.define_instruction("JUMP", 1);
    this.define_instruction("LOOP", 1);
    this.define_instruction("END_LOOP", 0);
    this.define_instruction("IF", 3);
    this.define_instruction("ELSEIF", 3);
    this.define_instruction("ELSE", 0);
    this.define_instruction("END_IF", 0);
    this.define_instruction("WHILE", 3);
    this.define_instruction("END_WHILE", 0);
endfunction  //  define_defaults

///////////////////////////////////////////////////////////////////
//
function integer cmd_lst::exec_defaults(tb_trans r);
  integer rtn  = 0;
  lst_item tmp_item;
  integer  idx = 0;
  string   cmd_string;

  // get the command string
  cmd_string = r.cmd.lst_cmds.cmd;
  //  output the dynamic text if there is some. (Note:  before command runs.)
  r.cmd.print_str_wvar();

  ///  The Main  else if chain  /////////////////////////////////////////////////
  //  ABORT
  if(cmd_string == "ABORT") begin
    $display("The test has aborted due to an error!!");
    $finish(2);
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  FINISH
  end else if (cmd_string == "FINISH") begin
    $display("Test Finished with NO error!!");
    $finish();
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  ADD_VAR
  end else if (cmd_string == "ADD_VAR") begin
    tmp_item = this.var_lst.get(r.rtn_val.par1);
    idx      = tmp_item.index;
    tmp_item.val = tmp_item.val + r.rtn_val.par2;
    r.cmd.var_lst.set(idx, tmp_item.val);
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  SUB_VAR
  end else if (cmd_string == "SUB_VAR") begin
    tmp_item = this.var_lst.get(r.rtn_val.par1);
    idx      = tmp_item.index;
    tmp_item.val = tmp_item.val - r.rtn_val.par2;
    r.cmd.var_lst.set(idx, tmp_item.val);
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  EQU_VAR
  end else if (cmd_string == "EQU_VAR") begin
    tmp_item = this.var_lst.get(r.rtn_val.par1);
    idx      = tmp_item.index;
    tmp_item.val = r.rtn_val.par2;
    r.cmd.var_lst.set(idx, tmp_item.val);
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  CALL
  end else if (cmd_string == "CALL") begin
    call_index++;
    check_call_depth : assert(call_index <= 8) else begin
        $fatal(0,"CALL nesting depth maximum is 7.  On Line: %4d",  r.cmd.lst_cmds.line_num);
    end
    call_stack[call_index] = r.cmd.lst_cmds.idx + 1;
    r.next = r.rtn_val.par1;
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  RETURN_CALL
  end else if (cmd_string == "RETURN_CALL") begin
    check_call_under_run : assert(call_index > 0) else begin
        $fatal(0,"RETURN_CALL causing nesting underflow?.  On Line: %4d",  r.cmd.lst_cmds.line_num);
    end
    r.next = call_stack[call_index];
    call_index--;
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  JUMP
  end else if (cmd_string == "JUMP") begin
    r.next  =  r.rtn_val.par1;
    call_index = 0;
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  LOOP
  end else if (cmd_string == "LOOP") begin
    loop_num++;
    loop_line[loop_num] = r.cmd.lst_cmds.idx + 1;
    loop_cnt[loop_num]  = 0;
    loop_term[loop_num] = r.rtn_val.par1;
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  END_LOOP
  end else if (cmd_string == "END_LOOP") begin
    loop_cnt[loop_num]++;
    if(loop_cnt[loop_num] == loop_term[loop_num]) begin
      loop_num--;
      r.next = r.cmd.lst_cmds.idx + 1;
    end else begin
      r.next = loop_line[loop_num];
    end
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  IF
  end else if (cmd_string == "IF") begin
    if_state = 0;
    case (r.rtn_val.par2)
      0: if(r.rtn_val.par1 == r.rtn_val.par3) if_state = 1;
      1: if(r.rtn_val.par1 != r.rtn_val.par3) if_state = 1;
      2: if(r.rtn_val.par1 >  r.rtn_val.par3) if_state = 1;
      3: if(r.rtn_val.par1 <  r.rtn_val.par3) if_state = 1;
      4: if(r.rtn_val.par1 >= r.rtn_val.par3) if_state = 1;
      5: if(r.rtn_val.par1 <= r.rtn_val.par3) if_state = 1;
      default:  if_op_error : assert (0) else begin
        $fatal(0, "IF statement had unknown operator in par2.  On Line: %4d", r.cmd.lst_cmds.line_num);
      end
    endcase
    
    if (!if_state) begin
      r          = r.cmd.get(r);
      cmd_string = r.cmd.lst_cmds.cmd;
      r.next++;
      while(cmd_string != "ELSE" && cmd_string != "ELSEIF" && cmd_string != "END_IF") begin
        r          = r.cmd.get(r);
        cmd_string = r.cmd.lst_cmds.cmd;
        r.next++;
        check_if_end : assert (r.cmd.lst_cmds.next != null) else begin
          $fatal(0,"Unable to find terminating element for IF statement!!");
        end
      end
      r.next--;
    end
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  ELSEIF
  end else if (cmd_string == "ELSEIF") begin
    if(if_state) begin
      r          = r.cmd.get(r);
      cmd_string = r.cmd.lst_cmds.cmd;
      r.next++;
      while(cmd_string != "END_IF") begin
        r          = r.cmd.get(r);
        cmd_string = r.cmd.lst_cmds.cmd;
        r.next++;
        check_elseif_statement : assert (r.cmd.lst_cmds.next != null) else begin
          $fatal(0,"Unable to find terminating element for ESLEIF statement!!");
        end
      end
      r.next--;
    end else begin
      case (r.rtn_val.par2)
        0: if(r.rtn_val.par1 == r.rtn_val.par3) if_state = 1;
        1: if(r.rtn_val.par1 != r.rtn_val.par3) if_state = 1;
        2: if(r.rtn_val.par1 >  r.rtn_val.par3) if_state = 1;
        3: if(r.rtn_val.par1 <  r.rtn_val.par3) if_state = 1;
        4: if(r.rtn_val.par1 >= r.rtn_val.par3) if_state = 1;
        5: if(r.rtn_val.par1 <= r.rtn_val.par3) if_state = 1;
        default:  elseif_op_error : assert (0) else begin
          $fatal(0, "ELSEIF statement had unknown operator in par2.  On Line: %4d", r.cmd.lst_cmds.line_num);
        end
      endcase
    
      if (!if_state) begin
        r          = r.cmd.get(r);
        cmd_string = r.cmd.lst_cmds.cmd;
        r.next++;
        while(cmd_string != "ELSE" && cmd_string != "ELSEIF" && cmd_string != "END_IF") begin
          r          = r.cmd.get(r);
          cmd_string = r.cmd.lst_cmds.cmd;
          r.next++;
          check_elseif_end : assert (r.cmd.lst_cmds.next != null) else begin
            $fatal(0,"Unable to find terminating element for IF statement!!");
          end
        end
        r.next--;
      end
    end
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  ELSEIF
  end else if (cmd_string == "ELSE") begin
    if(if_state) begin
      r          = r.cmd.get(r);
      cmd_string = r.cmd.lst_cmds.cmd;
      r.next++;
      while(cmd_string != "END_IF") begin
        r          = r.cmd.get(r);
        cmd_string = r.cmd.lst_cmds.cmd;
        r.next++;
        check_else_statement : assert (r.cmd.lst_cmds.next != null) else begin
          $fatal(0,"Unable to find terminating element for ELSE statement!!");
        end
      end
      r.next--;
    end
    rtn = 1;
  ///////////////////////////////////////////////////////////////////////////
  //  END_IF
  end else if (cmd_string == "END_IF") begin
    rtn = 1;
    //  This command is just a place holder, skip to next instruction.
    
  ///////////////////////////////////////////////////////////////////////////
  //  WHILE   non-nested implementation
  end else if (cmd_string == "WHILE") begin
    wh_state = 0;
    wh_top =  r.cmd.lst_cmds.idx;
    case (r.rtn_val.par2)
      0: if(r.rtn_val.par1 == r.rtn_val.par3) wh_state = 1;
      1: if(r.rtn_val.par1 != r.rtn_val.par3) wh_state = 1;
      2: if(r.rtn_val.par1 >  r.rtn_val.par3) wh_state = 1;
      3: if(r.rtn_val.par1 <  r.rtn_val.par3) wh_state = 1;
      4: if(r.rtn_val.par1 >= r.rtn_val.par3) wh_state = 1;
      5: if(r.rtn_val.par1 <= r.rtn_val.par3) wh_state = 1;
      default:  while_op_error : assert (0) else begin
        $fatal(0, "WHILE statement had unknown operator in par2.  On Line: %4d", r.cmd.lst_cmds.line_num);
      end
    endcase
    
    if(!wh_state) begin
      while(cmd_string != "END_WHILE") begin
        r          = r.cmd.get(r);
        cmd_string = r.cmd.lst_cmds.cmd;
        r.next++;
        check_while_statement : assert (r.cmd.lst_cmds.next != null) else begin
          $fatal(0,"Unable to find terminating element for WHILE statement!!");
        end
      end
    end
    rtn = 1;

  ///////////////////////////////////////////////////////////////////////////
  //  END_WHILE
  end else if (cmd_string == "END_WHILE") begin
    r.next  = wh_top;
    rtn = 1;
  end

  return rtn;
endfunction  //  exec_defaults

//  dynamic print function.
function void cmd_lst::print_str();
  if (this.lst_cmds.cmd_str != "") begin
    $display("%s", this.lst_cmds.cmd_str);
  end
endfunction

//  dynamic print function with variable sub
//    output var in HEX.
function void cmd_lst::print_str_wvar();
  
  integer len;
  integer vlen;
  integer v;
  integer i = 0;
  integer j = 0;
  integer val;
  string  sval;
  string  tmp;
  string  tmpv;
  string  vari;
  string  varv;
  lst_item  lvar;

  if (this.lst_cmds.cmd_str == "") begin
    return;
  end

  len = this.lst_cmds.cmd_str.len();
  tmp = this.lst_cmds.cmd_str;

  while (i < len) begin
    if (tmp[i] == "$") begin
      i++;
      j = 0;
      vari = "";
      while (tmp[i] != " " && i < len) begin
        vari = {vari,tmp[i]};
        i++;
        j++;
      end
      lvar = this.var_lst.find(vari);
      val  = lvar.val;
      //  convert var to str
      $sformat(varv,"%x",val);
      j = 0;
      vlen = varv.len();
      tmpv = varv;
      //  strip pre-padding
      while(varv[j] == "0" && j < vlen) begin
        j++;
        v = tmpv.len();
        tmpv = tmpv.substr(1, v-1);
      end
      
      sval = {sval, "0x", tmpv};
    end else begin
      sval = {sval,tmp[i]};
      i++;
    end
  end
  $display(sval);
  
endfunction

////////////////////////////////////////////////////////////
//  print commands function: intened for debug and dev
function void cmd_lst::print_cmds();
  tb_cmd   tmp_cmd;
  tmp_cmd = this.lst_cmds;
  while(tmp_cmd != null) begin
    tmp_cmd.print();
    tmp_cmd = tmp_cmd.next;
  end
  //tmp_cmd.print();
  $display("List Size:  %s", this.lst_sz);
  $display();
  $display();
endfunction // print_cmds
