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

  ////////////////////////////////////
  //  command  class
  typedef class tb_cmd;
class tb_cmd;
  integer idx;         // the index in the list
  integer valid_fld;   // number of valid fields
  string  cmd;         // instruction text
  string  var1;        // variable field one
  string  var2;
  string  var3;
  string  var4;
  string  var5;
  string  var6;
  string  cmd_str;      // any Dynamic text

  integer line_num;     // file line number
  integer file_idx;     // index of file name

  tb_cmd  next;         // ref to next command
  tb_cmd  prev;         // ref to prev command

  // prototypes
  //  function to parse string into fields.
  extern function tb_cmd parse_cmd(string str);
  //  function print this data.
  extern function void print();
  extern function new();
  
endclass // tb_cmd

///  tb_cmd  methods
  //  new function   init members.
  function tb_cmd::new();
    idx = 0;
    valid_fld = 0;
    cmd = "";
    var1 = "";
    var2 = "";
    var3 = "";
    var4 = "";
    var5 = "";
    var6 = "";
    cmd_str = "";
    line_num = 0;
    file_idx = 0;
    next = null;
    prev = null;
  endfunction

  //  print function intended for debug and developent.
  function void tb_cmd::print();
    $display("***************");
    $display("idx is: %d", this.idx);
    $display("valid_fld is: %d", this.valid_fld);
    $display("cmd is: %s", this.cmd);
    $display("var1 is: %s", this.var1);
    $display("var2 is: %s", this.var2);
    $display("var3 is: %s", this.var3);
    $display("var4 is: %s", this.var4);
    $display("var5 is: %s", this.var5);
    $display("var6 is: %s", this.var6);
    $display("cmd_str is: %s", this.cmd_str);
    $display("line_num is: %d", this.line_num);
    $display("file_idx is: %d", this.file_idx);
  endfunction

  ///////////
  //  function parse_cmd
  function tb_cmd tb_cmd::parse_cmd(string str);
    byte c = 0;
    byte c1 = 0;
    integer  err = 0;
    integer  length;
    integer  len;
    integer  idx = 0;
    integer  i;
    integer  tidx;
    integer  nonw;
    integer  gotd;
    string   tmp_str;
    string   sub_str;
    string   com_chars;
    string   dummy;
    integer  done = 0;
    integer  ds_start = 1000;
    integer  cs_start = 0;
    integer  ds_found = 0;
    integer  cs_found = 0;

    //  get length of string could include new line
    length = str.len();
    tmp_str = str.substr(0,length-2);
    //  if there is a comment get the start location.
    //   then strip off the comment.
    idx = 0;
    while((tmp_str.substr(idx,idx+1) != "--") && (idx < length-1)) begin
      idx++;
    end
    if(idx != length) begin
      cs_start = idx;
      cs_found = 1;
      tmp_str  = tmp_str.substr(0, cs_start-1);
      length = tmp_str.len();
    end
    //   Look for dynamic text.
    // if there is a dynamic text string, locate its start
    idx = 0;
    while((tmp_str.getc(idx) != "\"") && (idx < length)) begin
      idx++;
    end
    if(idx < length) begin
      ds_start = idx+1;
      ds_found = 1;
      dummy = tmp_str.substr(ds_start, length-2);
    end
    this.valid_fld = 0;
    //  if this is a full line comment, zero valid fields
    if(cs_start == 0 && cs_found) begin
      this.valid_fld = 0;
    end else begin
      // if there was a dynamic string ...
      if(ds_found) begin
        sub_str = tmp_str.substr(0, ds_start-2);
        this.cmd_str = tmp_str.substr(ds_start, length-1);
      end else begin
        sub_str = tmp_str;
        this.cmd_str = "";
      end
      // now parse the string into fields.
      //  get the sub string length
      len = sub_str.len();
      dummy = "";
      tidx  = 0;
      idx   = 0;
      nonw  = 0;
      gotd  = 0;

      //  extract fields
      for (i = 0; i <= len; i++) begin
        if (is_ws(sub_str[i])) begin
          if (nonw) begin
            nonw = 0;
            gotd = 1;
          end else begin
            continue;
          end
        end else begin
          dummy  =  {dummy, sub_str[i]};
          nonw   =  1;
        end
        //  if we transitioned to white from char
        if (gotd == 1) begin
          case(tidx)
            0: this.cmd  = dummy;
            1: this.var1 = dummy;
            2: this.var2 = dummy;
            3: this.var3 = dummy;
            4: this.var4 = dummy;
            5: this.var5 = dummy;
            6: this.var6 = dummy;
            default: err = 1;
          endcase
          if(err == 0) begin
            tidx++;
            this.valid_fld++;
            gotd = 0;
            dummy = "";
          end else begin
            if(this.line_num != 0) begin
              $fatal(0,"ERROR: Found more than six parameters in line: %s\nAt line: %d", tmp_str, this.line_num);
            end
          end
        end
      end  // end for
      //  get any left overs
      if(dummy != "") begin
        case(tidx)
          0: this.cmd  = dummy;
          1: this.var1 = dummy;
          2: this.var2 = dummy;
          3: this.var3 = dummy;
          4: this.var4 = dummy;
          5: this.var5 = dummy;
          6: this.var6 = dummy;
          default: err = 1;
        endcase
        if(err == 0) begin
          this.valid_fld++;
        end else begin
          if(this.line_num != 0) begin
            $fatal(0,"ERROR: Found more than six parameters on line: %s\nAt line: %d", tmp_str, this.line_num);
          end
        end
      end
    end
    
    //this.print();
    return this;
  endfunction // parse_cmd

