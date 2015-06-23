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

//////////////////////////////////////////
//  type definitions for the  sv  tb_pkg
/////////////////////////////////////////
  typedef class lst_item;
  typedef class cmd_lst;
  typedef class tb_cmd;
  typedef class tb_trans;

  ////////////////////////////////////
  typedef struct {
    string cmd;
    integer par1;
    integer par2;
    integer par3;
    integer par4;
    integer par5;
    integer par6;
    string dym_str;
    integer valid;
  } cmd_val_t;
  

  typedef struct {
    string  txt;
    integer val;
  } lst_item_t;
  
//////////////////////////////////////////////////////////////
//  this class is a container class that is used to
//    pass in information and get information from the 
//    command list.
class tb_trans;
  cmd_lst     cmd;
  cmd_val_t  rtn_val;
  integer    next;
  
  extern function new();
endclass  //  class tb_trans


function tb_trans::new();
  cmd             = new();
  rtn_val.cmd     = "";
  rtn_val.dym_str = "";
  rtn_val.par1    = 0;
  rtn_val.par2    = 0;
  rtn_val.par3    = 0;
  rtn_val.par4    = 0;
  rtn_val.par5    = 0;
  rtn_val.par6    = 0;
  rtn_val.valid   = 0;
  next            = 0;
endfunction
