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
//////////////////////////////////////////////////////////////////////////
//  general functions
//
//  stm2_int:	convert a simulus entry to integer.
//  is_var:   check for and return varable type.
//  is_ws:	  check if character is white space.
//  is_digi:  Check if is decimal character
//  is_alpha: Check if is alphabetic character,  Limited.
//
/////////////////////////////////////////////////////////////////////////
//  stimulus value convert functions
//  to_int  function to convert string to integer
function integer stm2_int(string str);
  integer t, i, len, rtn;
  string  tmp_str;
  
  i = 0;
  t = str.getc(i);
  if ((t == "x") || (t == "h")) begin
    tmp_str = str.substr(1, str.len()-1);
    rtn     = tmp_str.atohex();
  end else if (t == "b") begin
    tmp_str = str.substr(1, str.len()-1);
    rtn     = tmp_str.atobin();
  end else begin
    rtn     = str.atoi();
  end
  return rtn;
endfunction // stm2_int

//////////////////////////////////////////////////////////////////////
//  is_var  function
//   check if the string passed is a variable definition "syntax" wise
//   return  0  if not a variable def
//   return  1  if defined as value
//   return  2  if defined as index
//   retrun  3  if condition operator
function int is_var(string v);
  byte c;
  c = v[0];
  if(is_digi(c)) begin
    return 0;
  end else if(c == "$") begin
    return 1;
  end else if (c == "<" || c == ">" || c == "=" || c == "!") begin
      return 3;
  end else if (c != "x" && c != "h" && c != "b") begin
      return 2;
  end else
    return 0;
endfunction

//////////////////////////////////////////////////////////////////////
//  string functions
//   check character for white space
//   return  1 if is white,   0 other wise.
function int is_ws(byte c);
  if (c == " " || c == "\t" || c == "\n")
    return 1;
  else
    return 0;
endfunction  //  is_ws
//////////////////////////////////////////////////////////////////////
//  check for decimal digit   return 1 if is,  else  0
function int is_digi(byte c);
  if (c >= "0" && c <= "9")
    return 1;
  else
    return 0;
endfunction
//////////////////////////////////////////////////////////////////////
// check for alpha character.
//   includes [ \ ] ^ _ ` { \ } ~
//   return 1 if is,  else  0
function int is_alpha(byte c);
  if(c >= "A" && c <= "~")
    return 1;
  else
    return 0;
endfunction
