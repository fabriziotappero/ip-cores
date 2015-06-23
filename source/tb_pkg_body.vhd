-------------------------------------------------------------------------------
--             Copyright 2014  Ken Campbell
--               All rights reserved.
-------------------------------------------------------------------------------
-- $Author: sckoarn $
--
-- $Date:  $
--
-- $Id:  $
--
-- $Source:  $
--
-- Description :  The the testbench package body file.
--
------------------------------------------------------------------------------
--  This file is part of The VHDL Test Bench Package.
--
--  Redistribution and use in source and binary forms, with or without
--  modification, are permitted provided that the following conditions are met:
--
--  1. Redistributions of source code must retain the above copyright notice,
--     this list of conditions and the following disclaimer.
--
--  2. Redistributions in binary form must reproduce the above copyright notice,
--     this list of conditions and the following disclaimer in the documentation
--     and/or other materials provided with the distribution.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

package body tb_pkg is

-------------------------------------------------------------------------------
-- FUNCTION Defs
-------------------------------------------------------------------------------
--  is_digit
 function is_digit(constant c: in character) return boolean is
   variable rtn : boolean;
 begin
   if (c >= '0' and c <= '9') then
        rtn := true;
   else
        rtn := false;
   end if;
   return rtn;
 end is_digit;
--------------------------------------
-- is_space
 function is_space(constant c: in character) return boolean is
   variable rtn : boolean;
 begin
   if(c = ' ' or c = ht) then
        rtn := true;
   else
        rtn := false;
   end if;
   return rtn;
 end is_space;
------------------------------------------------------------------------------
--  to_char
  function ew_to_char(int: integer) return character is
    variable c: character;
  begin
    c := nul;
    case int is
      when 0 => c := '0';
      when 1 => c := '1';
      when 2 => c := '2';
      when 3 => c := '3';
      when 4 => c := '4';
      when 5 => c := '5';
      when 6 => c := '6';
      when 7 => c := '7';
      when 8 => c := '8';
      when 9 => c := '9';
      when 10 => c := 'A';
      when 11 => c := 'B';
      when 12 => c := 'C';
      when 13 => c := 'D';
      when 14 => c := 'E';
      when 15 => c := 'F';
      when others =>
         assert(false)
           report LF & "Error: ew_to_char was given a non Number didgit."
         severity failure;
    end case;

    return c;
  end ew_to_char;

-------------------------------------------------------------------------------
--  to_string function  integer
  function to_str(int: integer) return string is
  begin
    return ew_to_str(int,dec) ;
  end to_str ;

-------------------------------------------------------------------------------
--  ew_str_cat
  function ew_str_cat(s1: stm_text;
                      s2: text_field) return stm_text is

    variable i:  integer;
    variable j:  integer;
    variable sc: stm_text;

  begin
    sc := s1;
    i := 1;
    while(sc(i) /= nul) loop
      i := i + 1;
    end loop;
    j := 1;
    while(s2(j) /= nul) loop
      sc(i) := s2(j);
      i := i + 1;
      j := j + 1;
    end loop;

    return sc;
  end ew_str_cat;

-------------------------------------------------------------------------------
-- fld_len    field length
--          inputs :  string of type text_field
--          return :  integer number of non 'nul' chars
function fld_len(s : in text_field) return integer is
    variable i:  integer := 1;
  begin
    while(s(i) /= nul) loop
      i := i + 1;
    end loop;
    return (i - 1);
  end fld_len;
------------------------------------------------------------------------------
-- c2int   convert character to integer
function c2int(c: in character) return integer is
  variable i:  integer;
begin
  i := -1;
  case c is
    when '0' => i := 0;
    when '1' => i := 1;
    when '2' => i := 2;
    when '3' => i := 3;
    when '4' => i := 4;
    when '5' => i := 5;
    when '6' => i := 6;
    when '7' => i := 7;
    when '8' => i := 8;
    when '9' => i := 9;
    when others =>
      assert(false)
        report LF & "Error: c2int was given a non Number didgit."
      severity failure;
  end case;
  return i;
end c2int;
-------------------------------------------------------------------------------
-- str2integer   Convert a string to integer number.
--   inputs  :  string
--   output  :  int value
function str2integer(str: in string) return integer is
  variable l:   integer;
  variable j:   integer := 1;
  variable rtn: integer := 0;
begin
  l := fld_len(str);

  for i in l downto 1 loop
    rtn := rtn + (c2int(str(j)) *(10**(i - 1)));
    j := j + 1;
  end loop;

  return rtn;
end str2integer;
-------------------------------------------------------------------------------
-- hex2integer    convert hex Stimulus field to integer
--          inputs :  string of type text_field containing only Hex numbers
--          return :  integer value
function hex2integer(hex_number:  in text_field;
                     file_name:   in text_line;
                     line:        in integer) return integer is
    variable len:         integer;
    variable temp_field:  text_field;
    variable temp_int:    integer;
    variable power:       integer;
    variable int_number:  integer;
  begin
     len      := fld_len(hex_number);
     power    := 0;
     temp_int := 0;
     for i in len downto 1 loop
       case hex_number(i) is
         when '0' =>
           int_number  := 0;
         when '1' =>
           int_number  := 1;
         when '2' =>
           int_number  := 2;
         when '3' =>
           int_number  := 3;
         when '4' =>
           int_number  := 4;
         when '5' =>
           int_number  := 5;
         when '6' =>
           int_number  := 6;
         when '7' =>
           int_number  := 7;
         when '8' =>
           int_number  := 8;
         when '9' =>
           int_number  := 9;
         when 'a' | 'A'=>
           int_number  := 10;
         when 'b' | 'B'=>
           int_number  := 11;
         when 'c' | 'C'=>
           int_number  := 12;
         when 'd' | 'D'=>
           int_number  := 13;
         when 'e' | 'E'=>
           int_number  := 14;
         when 'f' | 'F'=>
           int_number  := 15;
         when others =>
         assert(false)
           report LF & "Error: hex2integer found non Hex didgit on line "
                     & (integer'image(line)) & " of file " & file_name
         severity failure;
       end case;

       temp_int  := temp_int + (int_number *(16 ** power));
       power     := power + 1;
     end loop;

     return temp_int;
  end hex2integer;
-------------------------------------------------------------------------------
-- convert character to 4 bit vector
--   input    character
--   output   std_logic_vector  4 bits
function c2std_vec(c: in character) return std_logic_vector is
begin
  case c is
    when '0' =>  return "0000";
    when '1' =>  return "0001";
    when '2' =>  return "0010";
    when '3' =>  return "0011";
    when '4' =>  return "0100";
    when '5' =>  return "0101";
    when '6' =>  return "0110";
    when '7' =>  return "0111";
    when '8' =>  return "1000";
    when '9' =>  return "1001";
    when 'a' | 'A' =>  return "1010";
    when 'b' | 'B' =>  return "1011";
    when 'c' | 'C' =>  return "1100";
    when 'd' | 'D' =>  return "1101";
    when 'e' | 'E' =>  return "1110";
    when 'f' | 'F' =>  return "1111";
    when others =>
     assert(false)
       report LF & "Error: c2std_vec found non Hex didgit on file line "
     severity failure;
     return "XXXX";
  end case;
end c2std_vec;
-------------------------------------------------------------------------------
--  std_vec2c  convert 4 bit std_vector to a character
--     input  std_logic_vector 4 bits
--     output  character
function std_vec2c(vec: in std_logic_vector(3 downto 0)) return character is
begin
  case vec is
    when "0000" => return '0';
    when "0001" => return '1';
    when "0010" => return '2';
    when "0011" => return '3';
    when "0100" => return '4';
    when "0101" => return '5';
    when "0110" => return '6';
    when "0111" => return '7';
    when "1000" => return '8';
    when "1001" => return '9';
    when "1010" => return 'A';
    when "1011" => return 'B';
    when "1100" => return 'C';
    when "1101" => return 'D';
    when "1110" => return 'E';
    when "1111" => return 'F';
    when others =>
     assert(false)
       report LF & "Error: std_vec2c found non-binary didgit in vec "
     severity failure;
     return 'X';
  end case;
end std_vec2c;
-------------------------------------------------------------------------------
-- bin2integer    convert bin Stimulus field to integer
--          inputs :  string of type text_field containing only binary numbers
--          return :  integer value
function bin2integer(bin_number:  in text_field;
                     file_name:   in text_line;
                     line:        in integer) return integer is
    variable len:         integer;
    variable temp_field:  text_field;
    variable temp_int:    integer;
    variable power:       integer;
    variable int_number:  integer;
  begin
     len      := fld_len(bin_number);
     power    := 0;
     temp_int := 0;
     for i in len downto 1 loop
       case bin_number(i) is
         when '0' =>
           int_number  := 0;
         when '1' =>
           int_number  := 1;
         when others =>
         assert(false)
           report LF & "Error: bin2integer found non Binary didgit on line "
                     & (integer'image(line)) & " of file " & file_name
         severity failure;
       end case;

       if (int_number = 1) then
         temp_int  := temp_int + (int_number *(2 ** power));
       end if;
       power     := power + 1;
     end loop;

     return temp_int;
  end bin2integer;
-------------------------------------------------------------------------------
-- stim_to_integer    convert Stimulus field to integer
--          inputs :  string of type text_field "stimulus format of number"
--          return :  integer value
function stim_to_integer(field:      in text_field;
                         file_name:  in text_line;
                         line:       in integer) return integer is
    variable len:       integer;
    variable value:     integer := 1;
    variable temp_str : string(1 to 48);
  begin
    len := fld_len(field);

    case field(1) is
      when 'x' | 'h' =>
        value := 2;
        while(field(value) /= nul) loop
          temp_str(value - 1) := field(value);
          value := value + 1;
        end loop;
        value  := hex2integer(temp_str,file_name,line);
      when 'b' =>
        value := 2;
        while(field(value) /= nul) loop
          temp_str(value - 1) := field(value);
          value := value + 1;
        end loop;
        value  := bin2integer(temp_str,file_name,line);
      when others =>
--        value  := from_string(field(1 to len));
        value  := str2integer(field);
    end case;
    return value;
  end stim_to_integer;

-------------------------------------------------------------------------------
--  to_str function  with base parameter
--     Convert integer to number base
  function ew_to_str(int: integer; b: base) return text_field is

    variable temp  : text_field ;
    variable temp1 : text_field ;
    variable radix : integer := 0;
    variable num   : integer := 0;
    variable power : integer := 1;
    variable len   : integer := 1;
    variable pre   : string(1 to 2);
    variable i     : integer;
    variable j     : integer;
    variable vec   : std_logic_vector(31 downto 0);

  begin

    num := int;
    temp := (others => nul);
    case b is
      when bin =>
        radix := 2;                -- depending on what
        pre := "0b";
      when oct =>
        radix := 8;                -- base the number is
        pre := "0o";
      when hex =>
        radix := 16;               -- to be displayed as
        pre := "0x";
      when dec =>
        radix := 10;               -- choose a radix range
        pre := (others => nul);
    end case ;
    -- Now jump through Hoops because of sign
    if(num < 0 and b = hex) then
      vec := std_logic_vector(conv_unsigned(int, 32));
      temp(1) := std_vec2c(vec(31 downto 28));
      temp(2) := std_vec2c(vec(27 downto 24));
      temp(3) := std_vec2c(vec(23 downto 20));
      temp(4) := std_vec2c(vec(19 downto 16));
      temp(5) := std_vec2c(vec(15 downto 12));
      temp(6) := std_vec2c(vec(11 downto 8));
      temp(7) := std_vec2c(vec(7 downto 4));
      temp(8) := std_vec2c(vec(3 downto 0));
    else
      while num >= radix loop                   -- determine how many
        len := len + 1;                        -- characters required
        num := num / radix;                    -- to represent the
      end loop ;                                -- number.
      for i in len downto 1 loop                -- convert the number to
        temp(i) := ew_to_char(int/power mod radix); -- a string starting
        power := power * radix;                 -- with the right hand
      end loop ;                                -- side.
    end if;
    -- add prefix if is one
    if(pre(1) /= nul) then
      temp1 := temp;
      i := 1;
      j := 3;
      temp(1 to 2) := pre;
      while(temp1(i) /= nul) loop
        temp(j) := temp1(i);
        i := i + 1;
        j := j + 1;
      end loop;
    end if;

    return temp;

  end ew_to_str ;

---------------------------------------------------------------------------------------
-- convert std_logic_vector to an unsigned integer
  function to_uninteger ( constant vect     : in std_logic_vector
                        ) return integer is
    variable result   : integer := 0;
    variable len      : integer := vect'length;
    variable idx      : integer;
    variable tmp_str  : text_field;
    variable file_name: text_line;
  begin
    -- point to start of string
    idx  :=  1;
    -- convert std_logic_vector to text_field
    for i in len - 1 downto 0 loop
      if(vect(i) = '1') then
        tmp_str(idx) := '1';
      elsif(vect(i) = '0') then
        tmp_str(idx) := '0';
      else
        assert(false)
          report LF & "ERROR:  Non 0/1 value found in std_logic_vector passed to to_uninteger function!!" & LF &
                "Returning 0."
        severity note;
        return result;
      end if;
      idx := idx + 1;
    end loop;
    -- call bin txt to int fuction with dummy fn and sequ idx
    result := bin2integer(tmp_str, file_name, idx);
    return result;

  end to_uninteger;


--------------------
-- stm neut
  function stm_neut return stm_sctl is
    variable tmp  : stm_sctl;
  begin
    tmp.rst_n    :=  '1';
    tmp.addr     := (others => 'Z');
    tmp.wdat     := (others => 'Z');
    tmp.rwn      := 'Z';
    tmp.req_n    := 'Z';
    return tmp;
  end stm_neut;

  function stm_neut return stm_sack is
    variable tmp  : stm_sack;
  begin
    tmp.rdat     := (others => 'Z');
    tmp.ack_n    := '1';
    tmp.rdy_n    := '1';
    tmp.irq_n    := '1';
    return tmp;
  end stm_neut;
--------------------------------------------------------------------------------
--  access_variable
--     inputs:
--               Text field containing variable
--     outputs:
--               value  $VAR  returns Value of VAR
--               value  VAR   returns index of VAR
--
--               valid  is 1 if valid 0 if not
  procedure access_variable(variable var_list : in  var_field_ptr;
                            variable var      : in text_field;
                            variable value    : out integer;
                            variable valid    : out integer) is
    variable l          : integer;
    variable l_2        : integer;
    variable var_ptr    : var_field_ptr;
    variable temp_field : text_field;
    variable ptr        : integer := 0;  -- 0 is index, 1 is pointer
  begin
    l      := fld_len(var);
    valid  := 0;
    -- if the variable is a special
    if(var(1) = '=') then
          value  := 0;
          valid  := 1;
    elsif(var(1 to 2) = ">=") then
          value  := 4;
          valid  := 1;
    elsif(var(1 to 2) = "<=") then
          value  := 5;
          valid  := 1;
    elsif(var(1) = '>') then
          value  := 1;
          valid  := 1;
    elsif(var(1) = '<') then
          value  := 2;
          valid  := 1;
    elsif(var(1 to 2) = "!=") then
          value  := 3;
          valid  := 1;

    else
      if(var(1) = '$') then
        ptr := 1; -- this is a pointer
        for i in 2 to l loop
          temp_field(i-1) := var(i);
        end loop;
      else
        temp_field  :=  var;
      end if;

      var_ptr := var_list;
      while(var_ptr.next_rec  /= null) loop
        -- if we have a match
        if(temp_field = var_ptr.var_name) then
          if(ptr = 1) then
            value  := var_ptr.var_value;
            valid  := 1;
          else
            value  := var_ptr.var_index;
            valid  := 1;
          end if;
          exit;
        end if;
        var_ptr := var_ptr.next_rec;
      end loop;

      -- if we have a match and was the last record
      if(var_ptr.next_rec  = null and temp_field = var_ptr.var_name) then
        if(ptr = 1) then
          value  := var_ptr.var_value;
          valid  := 1;
        else
          value  := var_ptr.var_index;
          valid  := 1;
        end if;
      end if;
    end if;
  end access_variable;
--------------------------------------------------------------------------------
--  index_variable
--     inputs:
--               index:  the index of the variable being accessed
--     outputs:
--               Variable Value
--               valid  is 1 if valid 0 if not
  procedure index_variable(variable var_list : in  var_field_ptr;
                           variable index    : in  integer;
                           variable value    : out integer;
                           variable valid    : out integer) is
    variable ptr:  var_field_ptr;
  begin
    ptr    :=  var_list;
    valid  :=  0;
    while(ptr.next_rec  /= null) loop
      if(ptr.var_index = index) then
        value :=  ptr.var_value;
        valid :=  1;
        exit;
      end if;
      ptr  :=  ptr.next_rec;
    end loop;
    if(ptr.var_index = index) then
      value :=  ptr.var_value;
      valid :=  1;
    end if;
  end index_variable;

--------------------------------------------------------------------------------
--  update_variable
--     inputs:
--               index:  the index of the variable being updated
--     outputs:
--               valid  is 1 if valid 0 if not
  procedure update_variable(variable var_list : in  var_field_ptr;
                            variable index    : in  integer;
                            variable value    : in  integer;
                            variable valid    : out integer) is
    variable ptr:  var_field_ptr;
  begin
    ptr    :=  var_list;
    valid  :=  0;
    while(ptr.next_rec  /= null) loop
      if(ptr.var_index = index) then
        ptr.var_value :=  value;
        valid :=  1;
        exit;
      end if;
      ptr  :=  ptr.next_rec;
    end loop;
    -- check the current one
    if(ptr.var_index = index) then
      ptr.var_value :=  value;
      valid :=  1;
    end if;
  end update_variable;

-------------------------------------------------------------------------------
-- Read a line from a file
--   inputs  :   file of type text
--   outputs :   The line of type text_line
  procedure file_read_line(file file_name: text;
                           variable file_line: out text_line
                          ) is
    variable index:  integer;             -- index into string
    variable rline:  line;

  begin

    index := 1;  -- set index to begin of string
    file_line := (others => nul);
    if(not endfile(file_name)) then
      readline(file_name,rline);

      while(rline'right /= (index - 1) and rline'length /= 0) loop
        file_line(index) := rline(index);
        index    := index + 1;
      end loop;
    end if;
  end file_read_line;

  ------------------------------------------------------------------------------
  -- procedure to break a line down in to text fields
  procedure tokenize_line(variable text_line:   in  text_line;
                          variable token1:      out text_field;
                          variable token2:      out text_field;
                          variable token3:      out text_field;
                          variable token4:      out text_field;
                          variable token5:      out text_field;
                          variable token6:      out text_field;
                          variable token7:      out text_field;
                          variable txt_ptr:     out stm_text_ptr;
                          variable valid:       out integer) is
    variable token_index:     integer  :=  0;
    variable current_token:   text_field;
    variable token_number:    integer  :=  0;
    variable c:               string(1 to 2);
    variable comment_found:   integer  :=  0;
    variable txt_found:       integer  :=  0;
    variable j:               integer;

  begin
    -- null outputs
    token1  :=  (others => nul);
    token2  :=  (others => nul);
    token3  :=  (others => nul);
    token4  :=  (others => nul);
    token5  :=  (others => nul);
    token6  :=  (others => nul);
    token7  :=  (others => nul);
    txt_ptr :=  null;
    valid   :=  0;
    txt_found  :=  0;
    j := 1;

    -- loop for max number of char
    for i in 1 to text_line'high loop
      -- collect for comment test ** assumed no line will be max 256
      c(1)  := text_line(i);
      c(2)  := text_line(i + 1);  -- or this line will blow up
      if(c = "--") then
        comment_found  :=  1;
        exit;
      end if;
      -- if is begin text char '"'
      if(c(1) = '"') then  --"  <-- this double quote is just to fix highlighting.
        txt_found := 1;
        txt_ptr := new stm_text;
        next;
      end if;

      -- if we have found a txt string
      if (txt_found = 1 and text_line(i) /= nul) then
        -- if string too long, prevent tool hang, truncate and notify
        if(j > c_stm_text_len) then
          print("tokenize_line: truncated txt line, it was larger than c_stm_text_len");
          exit;
        end if;
        txt_ptr(j) := text_line(i);
        j := j + 1;
      -- if is a character store in the right token
      elsif(is_space(text_line(i)) = false and text_line(i) /= nul) then
        token_index  := token_index + 1;
        current_token(token_index)    := text_line(i);
      -- else is a space, deal with pointers
      elsif(is_space(text_line(i + 1)) = false and text_line(i + 1) /= nul) then
        case token_number is
          when 0 =>
            if(token_index /= 0) then
              token1  :=  current_token;
              current_token  :=  (others => nul);
              token_number := 1;
              valid        := 1;
              token_index  := 0;
            end if;
          when 1 =>
            token2  :=  current_token;
            current_token  :=  (others => nul);
            token_number := 2;
            valid        := 2;
            token_index  := 0;
          when 2 =>
            token3  :=  current_token;
            current_token  :=  (others => nul);
            token_number := 3;
            valid        := 3;
            token_index  := 0;
          when 3 =>
            token4  :=  current_token;
            current_token  :=  (others => nul);
            token_number := 4;
            valid        := 4;
            token_index  := 0;
          when 4 =>
            token5  :=  current_token;
            current_token  :=  (others => nul);
            token_number := 5;
            valid        := 5;
            token_index  := 0;
          when 5 =>
            token6  :=  current_token;
            current_token  :=  (others => nul);
            token_number := 6;
            valid        := 6;
            token_index  := 0;
          when 6 =>
            token7  :=  current_token;
            current_token  :=  (others => nul);
            token_number := 7;
            valid        := 7;
            token_index  := 0;
          when 7 =>
          when others =>
            null;
        end case;
      end if;
      -- break from loop if is null
      if(text_line(i) = nul) then
        if(token_index /= 0) then
          case token_number is
            when 0 =>
              token1  :=  current_token;
              valid   := 1;
            when 1 =>
              token2  :=  current_token;
              valid   := 2;
            when 2 =>
              token3  :=  current_token;
              valid   := 3;
            when 3 =>
              token4  :=  current_token;
              valid   := 4;
            when 4 =>
              token5  :=  current_token;
              valid   := 5;
            when 5 =>
              token6  :=  current_token;
              valid   := 6;
            when 6 =>
              token7  :=  current_token;
              valid   := 7;
            when others =>
              null;
          end case;
        end if;
        exit;
      end if;
    end loop;
    -- did we find a comment and there is a token
    if(comment_found = 1) then
      if(token_index /= 0) then
        case token_number is
          when 0 =>
            token1  :=  current_token;
            valid   := 1;
          when 1 =>
            token2  :=  current_token;
            valid   := 2;
          when 2 =>
            token3  :=  current_token;
            valid   := 3;
          when 3 =>
            token4  :=  current_token;
            valid   := 4;
          when 4 =>
            token5  :=  current_token;
            valid   := 5;
          when 5 =>
            token6  :=  current_token;
            valid   := 6;
          when 6 =>
            token7  :=  current_token;
            valid   := 7;
          when others =>
            null;
        end case;
      end if;
    end if;
  end tokenize_line;
-------------------------------------------------------------------------------
-- Add a new instruction to the instruction list
--   inputs  :   the linked list of instructions
--               the instruction
--               the number of args
--   outputs :   Updated instruction set linked list
  procedure define_instruction(variable inst_set: inout inst_def_ptr;
                               constant inst:     in    string;
                               constant args:     in    integer) is
    variable v_inst_ptr:    inst_def_ptr;
    variable v_prev_ptr:    inst_def_ptr;
    variable v_new_ptr:     inst_def_ptr;
    variable v_temp_inst:   inst_def_ptr;
    variable v_length:      integer;
    variable v_list_size:   integer;
    variable v_dup_error:   boolean;

  begin
    assert(inst'high <= max_field_len)
      report LF & "Error: Creation of Instruction of length greater than Max_field_len attemped!!" &
             LF & "This Max is currently set to " & (integer'image(max_field_len))
    severity failure;
    -- get to the last element and test is not exsiting
    v_temp_inst :=  inst_set;
    v_inst_ptr  :=  inst_set;
    -- zero the size
    v_list_size :=  0;
    while(v_inst_ptr /= null) loop
      -- if there is a chance of a duplicate command
      if(v_inst_ptr.instruction_l = inst'high) then
        v_dup_error := true;
        for i in 1 to inst'high loop
          if(v_inst_ptr.instruction(i) /= inst(i)) then
            v_dup_error := false;
          end if;
        end loop;
        -- if we find a duplicate, die
        assert(v_dup_error = false)
          report LF & "Error: Duplicate instruction definition attempted!"
        severity failure;
      end if;
      v_prev_ptr  := v_inst_ptr;  -- store for pointer updates
      v_inst_ptr  := v_inst_ptr.next_rec;
      v_list_size :=  v_list_size + 1;
    end loop;

    -- add the new instruction
    v_new_ptr   := new inst_def;
    -- if this is the first command return new pointer
    if(v_list_size = 0) then
      v_temp_inst :=  v_new_ptr;
    -- else write new pointer to next_rec
    else
      v_prev_ptr.next_rec  :=  v_new_ptr;
    end if;
    v_new_ptr.instruction_l := inst'high;
    v_new_ptr.params        := args;
    -- copy the instruction text into field
    for i in 1 to v_new_ptr.instruction_l loop
      v_new_ptr.instruction(i) := inst(i);
    end loop;
    -- return the pointer
    inst_set  :=  v_temp_inst;

  end define_instruction;

--------------------------------------------------------------------------------
--  Check for valid instruction in the list of instructions
procedure check_valid_inst(variable inst     :  in text_field;
                           variable inst_set :  in inst_def_ptr;
                           variable token_num:  in integer;
                           variable line_num :  in integer;
                           variable name     :  in text_line) is
    variable l :     integer  := 0;
    variable seti:   inst_def_ptr;
    variable match:  integer  := 0;
    variable ilv:    integer  := 0;  -- inline variable
  begin
    -- create useable pointer
    seti  := inst_set;
    -- count up the characters in inst
    l := fld_len(inst);
      -- if this is a referance variable -- handle in add variable Proc
    if(inst(l) = ':') then
      match  := 1;
      ilv    := 1;
    else
      -- process list till null next
      while (seti.next_rec /= null) loop
        if(seti.instruction_l = l) then
          match  := 1;
          for j in 1 to l loop
            if(seti.instruction(j) /= inst(j)) then
              match  := 0;
            end if;
          end loop;
        end if;
        if(match = 0) then
          seti  := seti.next_rec;
        else
          exit;
        end if;
      end loop;
      -- check current one
      if(seti.instruction_l = l and match = 0) then
        match  := 1;
        for j in 1 to l loop
          if(seti.instruction(j) /= inst(j)) then
            match  := 0;
          end if;
        end loop;
      end if;
    end if;

    -- if instruction was not found, die
    assert(match = 1)
      report LF & "Error: Undefined Instruction on line " & (integer'image(line_num)) &
                  " found in input file " & name & LF
    severity failure;

      -- if the definition of the number of parameters is > 6 skip testing
      --   this is how the variable number of parameters is implemented
      --   just skip testing for specified number
      if(seti.params > 6) then
        return;
      end if;
    -- if we had a match, check the number of paramiters
    if(match = 1 and ilv = 0) then
      assert(seti.params = (token_num - 1))
        report LF & "Error: Undefined Instruction was found, incorrect number of fields passed!" & LF &
                    "This is found on line " & (integer'image(line_num)) & " in file " & name & LF
      severity failure;
    end if;
  end check_valid_inst;

--------------------------------------------------------------------------------
--  add_variable
--    This procedure adds a variable to the variable list.  This is localy
--    available at this time.
procedure add_variable(variable var_list  :   inout  var_field_ptr;
                       variable p1        :  in text_field;  -- should be var name
                       variable p2        :  in text_field;  -- should be value
                       variable token_num :  in integer;
                       variable sequ_num  :  in integer;
                       variable line_num  :  in integer;
                       variable name      :  in text_line;
                       variable length    :  in integer) is

    variable temp_var:       var_field_ptr;
    variable current_ptr:    var_field_ptr;
    variable index:          integer := 1;
    variable len:            integer := 0;

  begin
    -- if this is NOT the first one
    if(var_list /= null) then
      current_ptr  := var_list;
      index        := index + 1;
      if(p1(length) /= ':') then  -- is not an inline variable
        while(current_ptr.next_rec /= null) loop
          -- if we have defined the current before then die
          assert(current_ptr.var_name /= p1)
            report LF & "Error: Attemping to add a duplicate Variable definition "
                      & " on line " & (integer'image(line_num)) & " of file " & name
          severity failure;

          current_ptr  :=  current_ptr.next_rec;
          index  := index + 1;
        end loop;
        -- if we have defined the current before then die. This checks the last one
        assert(current_ptr.var_name /= p1)
          report LF & "Error: Attemping to add a duplicate Variable definition "
                    & " on line " & (integer'image(line_num)) & " of file " & name
        severity failure;

        temp_var              := new var_field;
        temp_var.var_name     := p1;  -- direct write of text_field
        temp_var.var_value    := stim_to_integer(p2,name,line_num); -- convert text_field to integer
        temp_var.var_index    := index;
        current_ptr.next_rec  :=  temp_var;
      else  -- this is an inline variable
        while(current_ptr.next_rec /= null) loop
          -- if we have defined the current before then die
          len  :=  fld_len(current_ptr.var_name);
          assert(current_ptr.var_name(1 to len) /= p1(1 to (length - 1)))
            report LF & "Error: Attemping to add a duplicate Inline Variable definition "
                      & " on line " & (integer'image(line_num)) & " of file " & name
          severity failure;

          current_ptr  :=  current_ptr.next_rec;
          index  := index + 1;
        end loop;
        -- if we have defined the current before then die. This checks the last one
        len  :=  fld_len(current_ptr.var_name);
        assert(current_ptr.var_name(1 to len) /= p1(1 to (length - 1)))
          report LF & "Error: Attemping to add a duplicate Inline Variable definition "
                    & " on line " & (integer'image(line_num)) & " of file " & name
        severity failure;

        temp_var              := new var_field;
        temp_var.var_name(1 to (length - 1))     := p1(1 to (length - 1));
        temp_var.var_value    := sequ_num;
        temp_var.var_index    := index;
        current_ptr.next_rec  :=  temp_var;
      end if;
    -- this is the first one
    else
      if(p1(length) /= ':') then  -- is not an inline variable
        temp_var            := new var_field;
        temp_var.var_name   := p1;  -- direct write of text_field
        temp_var.var_index  := index;
        temp_var.var_value  := stim_to_integer(p2,name,line_num); -- convert text_field to integer
        var_list  :=  temp_var;
      else
        temp_var              := new var_field;
        temp_var.var_name(1 to (length - 1))     := p1(1 to (length - 1));
        temp_var.var_value    := sequ_num;
        temp_var.var_index    := index;
        var_list              :=  temp_var;
      end if;
    end if;
  end add_variable;
--------------------------------------------------------------------------------
--  add_instruction
--    This is the procedure that adds the instruction to the linked list of
--    instructions.  Also Variable addition are called and or handled.
--    the instruction sequence Link list.
--     inputs:
--               stim_line_ptr   is the pointer to the instruction List
--               inst            is the instruction token
--               p1              paramitor one, corrisponds to field one of stimulus
--               p2              paramitor one, corrisponds to field two of stimulus
--               p3              paramitor one, corrisponds to field three of stimulus
--               p4              paramitor one, corrisponds to field four of stimulus
--               p5              paramitor one, corrisponds to field three of stimulus
--               p6              paramitor one, corrisponds to field four of stimulus
--               str_ptr         pointer to string for print instruction
--               token_num       the number of tokens, including instruction
--               sequ_num        is the stimulus file line referance  ie program line number
--               line_num        Line number in the text file
--     outputs:
--               none.  Error will terminate sim
  procedure add_instruction(variable inst_list  :  inout stim_line_ptr;
                            variable var_list   :  inout var_field_ptr;
                            variable inst       :  in text_field;
                            variable p1         :  in text_field;
                            variable p2         :  in text_field;
                            variable p3         :  in text_field;
                            variable p4         :  in text_field;
                            variable p5         :  in text_field;
                            variable p6         :  in text_field;
                            variable str_ptr    :  in stm_text_ptr;
                            variable token_num  :  in integer;
                            variable sequ_num   :  inout integer;
                            variable line_num   :  in integer;
                            variable file_name  :  in text_line;
                            variable file_idx   :  in integer) is
   variable temp_stim_line:  stim_line_ptr;
   variable temp_current:    stim_line_ptr;
   variable valid:           integer;
   variable l:               integer;
 begin
   valid  := 1;
   l := fld_len(inst);
   temp_current  :=  inst_list;
   -- take care of special cases
   if(inst(1 to l) = "DEFINE_VAR") then
     l := fld_len(p1);
     --  Add the variable to the Variable pool, not considered an instruction
     add_variable(var_list,p1,p2,token_num,sequ_num,line_num,file_name,l);
     valid := 0;  --Removes this from the instruction list
   elsif(inst(l) = ':') then
     add_variable(var_list,inst,p1,token_num,sequ_num,line_num,file_name,l);
     valid := 0;
   end if;

   if(valid = 1) then
     -- prepare the new record
     temp_stim_line  := new stim_line;
     temp_stim_line.instruction   := inst;
     temp_stim_line.inst_field_1  := p1;
     temp_stim_line.inst_field_2  := p2;
     temp_stim_line.inst_field_3  := p3;
     temp_stim_line.inst_field_4  := p4;
     temp_stim_line.inst_field_5  := p5;
     temp_stim_line.inst_field_6  := p6;
     temp_stim_line.txt           := str_ptr;
     temp_stim_line.line_number   := sequ_num;
     temp_stim_line.file_idx     := file_idx;
     temp_stim_line.file_line     := line_num;

     -- if is not the first instruction
     if(inst_list /= null) then
       while(temp_current.next_rec /= null) loop
         temp_current  := temp_current.next_rec;
       end loop;
       temp_current.next_rec  :=  temp_stim_line;
       inst_list.num_of_lines :=  inst_list.num_of_lines + 1;
     -- other wise is first instruction to be added
     else
       inst_list  :=  temp_stim_line;
       inst_list.num_of_lines := 1;
     end if;
     sequ_num  :=  sequ_num + 1;
--     print_inst(temp_stim_line);  -- for debug
   end if;

 end add_instruction;
------------------------------------------------------------------------------
-- test_inst_sequ
--  This procedure accesses the full instruction sequence and checks for valid
--   variables.  This is prior to the simulation run start.
  procedure test_inst_sequ(variable inst_sequ  :  in  stim_line_ptr;
                           variable file_list  :  in  file_def_ptr;
                           variable var_list   :  in  var_field_ptr
                          ) is
    variable temp_text_field:     text_field;
    variable temp_var:            text_field;
    variable inst_ptr:            stim_line_ptr;
    variable valid:               integer;
    variable line:                integer;  -- value of the file_line
    variable file_name:           text_line;
    variable v_p:                 integer;
    variable inst       :         text_field;
    variable txt        :         stm_text_ptr;
    variable inst_len   :         integer;
    variable fname      :         text_line;
    variable file_line  :         integer;
    variable temp_fn_prt:         file_def_ptr;
    variable tmp_int    :         integer;

  begin
    inst_ptr  :=  inst_sequ;
    -- go through all the instructions
    while(inst_ptr.next_rec /= null) loop
      inst := inst_ptr.instruction;
      inst_len := fld_len(inst_ptr.instruction);
      file_line := inst_ptr.file_line;
      line      := inst_ptr.file_line;
      -- recover the file name this line came from
      temp_fn_prt := file_list;
      tmp_int   :=  inst_ptr.file_idx;
      while (temp_fn_prt.next_rec /= null) loop
        if(temp_fn_prt.rec_idx = tmp_int) then
          exit;
        end if;
        temp_fn_prt  :=  temp_fn_prt.next_rec;
      end loop;
      for i in 1 to fname'high loop
        file_name(i) :=  temp_fn_prt.file_name(i);
      end loop;

      txt       := inst_ptr.txt;
      -- load parameter one
      temp_text_field  :=  inst_ptr.inst_field_1;
      if(temp_text_field(1) /= nul) then
        -- if this is a numaric  do nothing
        if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
           temp_text_field(1) = 'b' or is_digit(temp_text_field(1)) = true) then
           null;
        else  -- else is a variable, get the value or halt incase of error
          access_variable(var_list,temp_text_field,v_p,valid);
          assert(valid = 1)
            report LF & "Error: First variable on stimulus line " & (integer'image(line))
                      & " is not valid!!" & LF & "In file " & file_name
          severity failure;
        end if;
      end if;
      -- load parameter two
      temp_text_field  :=  inst_ptr.inst_field_2;
      if(temp_text_field(1) /= nul) then
        -- if this is a numaric do nothing
        if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
           temp_text_field(1) = 'b' or is_digit(temp_text_field(1)) = true) then
           null;
        else  -- else is a variable, get the value or halt incase of error
          access_variable(var_list,temp_text_field,v_p,valid);
          assert(valid = 1)
            report LF & "Error: Second variable on stimulus line " & (integer'image(line))
                      & " is not valid!!" & LF & "In file " & file_name
          severity failure;
        end if;
      end if;
      -- load parameter three
      temp_text_field  :=  inst_ptr.inst_field_3;
      if(temp_text_field(1) /= nul) then
        -- if this is a numaric do nothing
        if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
           temp_text_field(1) = 'b' or is_digit(temp_text_field(1)) = true) then
           null;
        else  -- else is a variable, get the value or halt incase of error
          access_variable(var_list,temp_text_field,v_p,valid);
          assert(valid = 1)
            report LF & "Error: Third variable on stimulus line " & (integer'image(line))
                      & " is not valid!!" & LF & "In file " & file_name
          severity failure;
        end if;
      end if;
      -- load parameter four
      temp_text_field  :=  inst_ptr.inst_field_4;
      if(temp_text_field(1) /= nul) then
        -- if this is a numaric do nothing
        if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
           temp_text_field(1) = 'b'or is_digit(temp_text_field(1)) = true) then
           null;
        else  -- else is a variable, get the value or halt incase of error
          access_variable(var_list,temp_text_field,v_p,valid);
          assert(valid = 1)
            report LF & "Error: Forth variable on stimulus line " & (integer'image(line))
                      & " is not valid!!" & LF & "In file " & file_name
          severity failure;
        end if;
      end if;
      -- load parameter five
      temp_text_field  :=  inst_ptr.inst_field_5;
      if(temp_text_field(1) /= nul) then
        -- if this is a numaric do nothing
        if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
          temp_text_field(1) = 'b' or is_digit(temp_text_field(1)) = true) then
          null;
        else  -- else is a variable, get the value or halt incase of error
          access_variable(var_list,temp_text_field,v_p,valid);
          assert(valid = 1)
            report LF & "Error: Fifth variable on stimulus line " & (integer'image(line))
                      & " is not valid!!" & LF & "In file " & file_name
          severity failure;
        end if;
      end if;
      -- load parameter six
      temp_text_field  :=  inst_ptr.inst_field_6;
      if(temp_text_field(1) /= nul) then
        -- if this is a numaric field convert to integer
        if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
           temp_text_field(1) = 'b' or is_digit(temp_text_field(1)) = true) then
           null;
        else  -- else is a variable, get the value or halt incase of error
          access_variable(var_list,temp_text_field,v_p,valid);
          assert(valid = 1)
            report LF & "Error: Sixth variable on stimulus line " & (integer'image(line))
                      & " is not valid!!" & LF & "In file " & file_name
          severity failure;
        end if;
      end if;
      -- point to next record
      inst_ptr := inst_ptr.next_rec;
    end loop;

  end test_inst_sequ;
--------------------------------------------------------------------------------
--  The read include file procedure
--    This is the main procedure for reading, parcing, checking and returning
--    the instruction sequence Link list.
  procedure read_include_file(variable name:       text_line;
                              variable sequ_numb:  inout integer;
                              variable file_list:  inout file_def_ptr;
                              variable inst_set:   inout inst_def_ptr;
                              variable var_list:   inout var_field_ptr;
                              variable inst_sequ:  inout stim_line_ptr;
                              variable status:     inout integer) is
    variable l:          text_line; -- the line
    variable l_num:      integer;   -- line number file
    variable sequ_line:  integer;   -- line number program
    variable t1:         text_field;
    variable t2:         text_field;
    variable t3:         text_field;
    variable t4:         text_field;
    variable t5:         text_field;
    variable t6:         text_field;
    variable t7:         text_field;
    variable t_txt:      stm_text_ptr;
    variable valid:      integer;
    variable v_inst_ptr: inst_def_ptr;
    variable v_var_prt:  var_field_ptr;
    variable v_sequ_ptr: stim_line_ptr;
    variable v_len:      integer;
    variable v_stat:     file_open_status;
    variable idx:        integer;
    variable v_tmp:      text_line;

    variable v_tmp_fn_ptr: file_def_ptr;
    variable v_new_fn:     integer;
    variable v_tmp_fn:   file_def_ptr;
    variable v_txt:      stm_text; --stm_text_ptr;

  begin
    sequ_line     :=  sequ_numb;
    v_tmp_fn_ptr  :=  file_list;
    -- for linux systems, trailing spaces need to be removed
    --    from file names
    --  copy text string to temp
    for i in 1 to c_stm_text_len loop
      if(name(i) = nul) then
        v_tmp(i) := name(i);
        exit;
      else
        v_tmp(i) := name(i);
      end if;
    end loop;
    --fix up any trailing white space in txt
    idx  :=  0;
    --    get to the end of the string
    for i in 1 to c_stm_text_len loop
      if(v_tmp(i) /= nul) then
        idx  :=  idx + 1;
      else
        exit;
      end if;
    end loop;
    --  now nul out spaces
    for i in idx downto 1 loop
      if(is_space(v_tmp(i)) = true) then
        v_tmp(i) := nul;
      else
        exit;
      end if;
    end loop;
    --  open include file
    file_open(v_stat, include_file, v_tmp, read_mode);
    if(v_stat /= open_ok) then
      print("Error: Unable to open include file  " & name);
      status   :=  1;
      return;
    end if;
    l_num      :=  1;  -- initialize line number

    --  the file is opened, put it on the file name LL
    while (v_tmp_fn_ptr.next_rec /= null) loop
      v_tmp_fn_ptr :=  v_tmp_fn_ptr.next_rec;
    end loop;
    v_new_fn   :=  v_tmp_fn_ptr.rec_idx + 1;
    v_tmp_fn            :=  new file_def;
    v_tmp_fn_ptr.next_rec  :=  v_tmp_fn;
    v_tmp_fn.rec_idx    := v_new_fn;

    --  nul the text line
    v_tmp_fn.file_name  := (others => nul);
    for i in 1 to name'high loop
      v_tmp_fn.file_name(i)  := name(i);
    end loop;
    v_tmp_fn.next_rec  :=  null;


    v_inst_ptr :=  inst_set;
    v_var_prt  :=  var_list;
    v_sequ_ptr :=  inst_sequ;

    -- while not the end of file read it
    while(not endfile(include_file)) loop
      file_read_line(include_file,l);
      --  tokenize the line
      tokenize_line(l,t1,t2,t3,t4,t5,t6,t7,t_txt,valid);
      v_len  := fld_len(t1);
      if(t1(1 to v_len) = "INCLUDE") then
        print("Nested INCLUDE statement found in " & v_tmp & " on line " &
              (integer'image(l_num)));
        assert(false)
          report LF & "Error: Nested INCLUDE statements are not supported at this time."
        severity failure;

      -- if there was valid tokens
      elsif(valid /= 0) then
        check_valid_inst(t1, v_inst_ptr, valid, l_num, name);
        add_instruction(v_sequ_ptr,v_var_prt,t1,t2,t3,t4,t5,t6,t7,t_txt,valid,
                        sequ_line,l_num,name,v_new_fn);
      end if;
      l_num  :=  l_num + 1;
    end loop; -- end loop read file
    file_close(include_file);
    sequ_numb  :=  sequ_line;
    inst_set   :=  v_inst_ptr;
    var_list   :=  v_var_prt;
    inst_sequ  :=  v_sequ_ptr;
  end read_include_file;

--------------------------------------------------------------------------------
--  The read instruction file procedure
--    This is the main procedure for reading, parcing, checking and returning
--    the instruction sequence Link list.
  procedure read_instruction_file(constant file_name:  string;
                                  variable inst_set:   inout inst_def_ptr;
                                  variable var_list:   inout var_field_ptr;
                                  variable inst_sequ:  inout stim_line_ptr;
                                  variable file_list:  inout file_def_ptr) is
    variable l:          text_line; -- the line
    variable l_num:      integer;   -- line number file
    variable sequ_line:  integer;   -- line number program
    variable t1:         text_field;
    variable t2:         text_field;
    variable t3:         text_field;
    variable t4:         text_field;
    variable t5:         text_field;
    variable t6:         text_field;
    variable t7:         text_field;
    variable t_txt:      stm_text_ptr;
    variable valid:      integer;
    variable v_ostat:    integer;
    variable v_inst_ptr: inst_def_ptr;
    variable v_var_prt:  var_field_ptr;
    variable v_sequ_ptr: stim_line_ptr;
    variable v_len:      integer;
    variable v_stat:     file_open_status;
    variable v_name:     text_line;
    variable v_iname:    text_line;
    variable v_tmp_fn:   file_def_ptr;
    variable v_fn_idx:   integer;
    variable v_idx:      integer;

  begin
    -- open the stimulus_file and check
    file_open(v_stat, stimulus, file_name, read_mode);
    assert(v_stat = open_ok)
      report LF & "Error: Unable to open stimulus_file  " & file_name
    severity failure;
    -- copy file name to type text_line
    for i in 1 to file_name'high loop
      v_name(i)  := file_name(i);
    end loop;
    -- the first item on the file names link list
    file_list           :=  null;
    v_tmp_fn            :=  new file_def;
    v_tmp_fn.rec_idx    := 1;
    v_fn_idx            := 1;
    v_idx               := 1;
    --  nul the text line
    v_tmp_fn.file_name  := (others => nul);
    for i in 1 to file_name'high loop
      v_tmp_fn.file_name(i)  := file_name(i);
    end loop;
    v_tmp_fn.next_rec  :=  null;

    l_num      :=  1;
    sequ_line  :=  1;
    v_ostat    :=  0;

    v_inst_ptr :=  inst_set;
    v_var_prt  :=  var_list;
    v_sequ_ptr :=  inst_sequ;

    -- while not the end of file read it
    while(not endfile(stimulus)) loop
      file_read_line(stimulus,l);
      --  tokenize the line
      tokenize_line(l,t1,t2,t3,t4,t5,t6,t7,t_txt,valid);
      v_len  := fld_len(t1);
      -- if there is an INCLUDE instruction
      if(t1(1 to v_len) = "INCLUDE") then
        -- if file name is in par2
        if(valid = 2) then
          v_iname  := (others => nul);
          for i in 1 to max_field_len loop
            v_iname(i) := t2(i);
          end loop;
        -- elsif the text string is not null
        elsif(t_txt /= null) then
          v_iname  := (others => nul);
          for i in 1 to c_stm_text_len loop
            v_iname(i) := t_txt(i);
            if(t_txt(i) = nul) then
              exit;
            end if;
          end loop;
        else
          assert(false)
            report LF & "Error:  INCLUDE instruction has not file name included.  Found on" & LF &
                        "line " & (integer'image(l_num)) & " in file " & file_name & LF
          severity failure;
        end if;
        print("INCLUDE found: Loading file " & v_iname);
        read_include_file(v_iname,sequ_line,v_tmp_fn,v_inst_ptr,v_var_prt,v_sequ_ptr,v_ostat);
        -- if include file not found
        if(v_ostat = 1) then
          exit;
        end if;
      -- if there was valid tokens
      elsif(valid /= 0) then
        check_valid_inst(t1, v_inst_ptr, valid, l_num, v_name);
        add_instruction(v_sequ_ptr,v_var_prt,t1,t2,t3,t4,t5,t6,t7,t_txt,valid,
                        sequ_line,l_num,v_name,v_fn_idx);
      end if;
      l_num  :=  l_num + 1;
    end loop; -- end loop read file

    file_close(stimulus);  -- close the file when done

    assert(v_ostat = 0)
      report LF & "Include file specified on line " & (integer'image(l_num)) &
                  " in file " &  file_name &
                  " was not found! Test Terminated" & LF
    severity failure;

    inst_set   :=  v_inst_ptr;
    var_list   :=  v_var_prt;
    inst_sequ  :=  v_sequ_ptr;
    file_list  :=  v_tmp_fn;

    --  Now that all the stimulus is loaded, test for invalid variables
    test_inst_sequ(inst_sequ, v_tmp_fn, var_list);

  end read_instruction_file;

------------------------------------------------------------------------------
-- access_inst_sequ
--  This procedure accesses the instruction sequence and returns the parameters
--  as they exsist related to the variables state.
--  INPUTS:   inst_sequ  link list of instructions from stimulus
--            var_list   link list of variables
--            file_list  link list of file names
--            sequ_num   the sequence number to recover
--
--  OUTPUTS:  inst  instruction text
--            p1    paramiter 1 in integer form
--            p2    paramiter 2 in integer form
--            p3    paramiter 3 in integer form
--            p4    paramiter 4 in integer form
--            p5    paramiter 5 in integer form
--            p6    paramiter 6 in integer form
--            txt   pointer to any text string of this sequence
--            inst_len  the lenth of inst in characters
--            fname  file name this sequence came from
--            file_line  the line number in fname this sequence came from
--
  procedure access_inst_sequ(variable inst_sequ  :  in  stim_line_ptr;
                             variable var_list   :  in  var_field_ptr;
                             variable file_list  :  in  file_def_ptr;
                             variable sequ_num   :  in  integer;
                             variable inst       :  out text_field;
                             variable p1         :  out integer;
                             variable p2         :  out integer;
                             variable p3         :  out integer;
                             variable p4         :  out integer;
                             variable p5         :  out integer;
                             variable p6         :  out integer;
                             variable txt        :  out stm_text_ptr;
                             variable inst_len   :  out integer;
                             variable fname      :  out text_line;
                             variable file_line  :  out integer;
                             variable last_num   :  inout integer;
                             variable last_ptr   :  inout stim_line_ptr
                             ) is
    variable temp_text_field:     text_field;
    variable temp_var:            text_field;
    variable inst_ptr:            stim_line_ptr;
    variable valid:               integer;
    variable line:                integer;  -- value of the file_line
    variable file_name:           text_line;
    variable tmp_int:             integer;
    variable temp_fn_prt:         file_def_ptr;
  begin
   -- get to the instruction indicated by sequ_num
   -- check to see if this sequence is before the last
   --    so search from start
    if(last_num  > sequ_num) then
      inst_ptr  :=  inst_sequ;
      while(inst_ptr.next_rec /= null) loop
        if(inst_ptr.line_number = sequ_num) then
          exit;
        else
          inst_ptr := inst_ptr.next_rec;
        end if;
      end loop;
    -- else is equal or greater, so search forward
    else
      inst_ptr  :=  last_ptr;
      while(inst_ptr.next_rec /= null) loop
        if(inst_ptr.line_number = sequ_num) then
          exit;
        else
          inst_ptr := inst_ptr.next_rec;
        end if;
      end loop;
    end if;

    -- update the last sequence number and record pointer
    last_num  :=  sequ_num;
    last_ptr  :=  inst_ptr;

    -- output the instruction and its length
    inst := inst_ptr.instruction;
    inst_len := fld_len(inst_ptr.instruction);
    file_line := inst_ptr.file_line;
    line      := inst_ptr.file_line;
    -- recover the file name this line came from
    temp_fn_prt := file_list;
    tmp_int   :=  inst_ptr.file_idx;
    while (temp_fn_prt.next_rec /= null) loop
      if(temp_fn_prt.rec_idx = tmp_int) then
        exit;
      end if;
      temp_fn_prt  :=  temp_fn_prt.next_rec;
    end loop;
    for i in 1 to fname'high loop                       --<<<<<<<<<<<<<  Fix for file name output Apr 2011.
      file_name(i) :=  temp_fn_prt.file_name(i);
      fname(i)     :=  temp_fn_prt.file_name(i);
      if(temp_fn_prt.file_name(i) = nul) then
        exit;
      end if;
    end loop;

    txt       := inst_ptr.txt;
    -- load parameter one
    temp_text_field  :=  inst_ptr.inst_field_1;
    if(temp_text_field(1) /= nul) then
      -- if this is a numaric field convert to integer
      if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
         temp_text_field(1) = 'b') then
        p1 := stim_to_integer(temp_text_field,file_name,line);
      elsif(is_digit(temp_text_field(1)) = true) then
        p1 := stim_to_integer(temp_text_field,file_name,line);
      else  -- else is a variable, get the value or halt incase of error
        access_variable(var_list,temp_text_field,p1,valid);
        assert(valid = 1)
          report LF & "Error: First variable on stimulus line " & (integer'image(line))
                    & " is not valid!!" & LF & "In file " & file_name
        severity failure;
      end if;
    end if;
    -- load parameter two
    temp_text_field  :=  inst_ptr.inst_field_2;
    if(temp_text_field(1) /= nul) then
      -- if this is a numaric field convert to integer
      if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
         temp_text_field(1) = 'b') then
        p2 := stim_to_integer(temp_text_field,file_name,line);
      elsif(is_digit(temp_text_field(1)) = true) then
        p2 := stim_to_integer(temp_text_field,file_name,line);
      else  -- else is a variable, get the value or halt incase of error
        access_variable(var_list,temp_text_field,p2,valid);
        assert(valid = 1)
          report LF & "Error: Second variable on stimulus line " & (integer'image(line))
                    & " is not valid!!" & LF & "In file " & file_name
        severity failure;
      end if;
    end if;
    -- load parameter three
    temp_text_field  :=  inst_ptr.inst_field_3;
    if(temp_text_field(1) /= nul) then
      -- if this is a numaric field convert to integer
      if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
         temp_text_field(1) = 'b') then
        p3 := stim_to_integer(temp_text_field,file_name,line);
      elsif(is_digit(temp_text_field(1)) = true) then
        p3 := stim_to_integer(temp_text_field,file_name,line);
      else  -- else is a variable, get the value or halt incase of error
        access_variable(var_list,temp_text_field,p3,valid);
        assert(valid = 1)
          report LF & "Error: Third variable on stimulus line " & (integer'image(line))
                    & " is not valid!!" & LF & "In file " & file_name
        severity failure;
      end if;
    end if;
    -- load parameter four
    temp_text_field  :=  inst_ptr.inst_field_4;
    if(temp_text_field(1) /= nul) then
      -- if this is a numaric field convert to integer
      if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
         temp_text_field(1) = 'b') then
        p4 := stim_to_integer(temp_text_field,file_name,line);
      elsif(is_digit(temp_text_field(1)) = true) then
        p4 := stim_to_integer(temp_text_field,file_name,line);
      else  -- else is a variable, get the value or halt incase of error
        access_variable(var_list,temp_text_field,p4,valid);
        assert(valid = 1)
          report LF & "Error: Forth variable on stimulus line " & (integer'image(line))
                    & " is not valid!!" & LF & "In file " & file_name
        severity failure;
      end if;
    end if;
    -- load parameter five
    temp_text_field  :=  inst_ptr.inst_field_5;
    if(temp_text_field(1) /= nul) then
      -- if this is a numaric field convert to integer
      if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
         temp_text_field(1) = 'b') then
        p5 := stim_to_integer(temp_text_field,file_name,line);
      elsif(is_digit(temp_text_field(1)) = true) then
        p5 := stim_to_integer(temp_text_field,file_name,line);
      else  -- else is a variable, get the value or halt incase of error
        access_variable(var_list,temp_text_field,p5,valid);
        assert(valid = 1)
          report LF & "Error: Fifth variable on stimulus line " & (integer'image(line))
                    & " is not valid!!" & LF & "In file " & file_name
        severity failure;
      end if;
    end if;
    -- load parameter six
    temp_text_field  :=  inst_ptr.inst_field_6;
    if(temp_text_field(1) /= nul) then
      -- if this is a numaric field convert to integer
      if(temp_text_field(1) = 'x' or temp_text_field(1) = 'h' or
         temp_text_field(1) = 'b') then
        p6 := stim_to_integer(temp_text_field,file_name,line);
      elsif(is_digit(temp_text_field(1)) = true) then
        p6 := stim_to_integer(temp_text_field,file_name,line);
      else  -- else is a variable, get the value or halt incase of error
        access_variable(var_list,temp_text_field,p6,valid);
        assert(valid = 1)
          report LF & "Error: Sixth variable on stimulus line " & (integer'image(line))
                    & " is not valid!!" & LF & "In file " & file_name
        severity failure;
      end if;
    end if;
  end access_inst_sequ;

-------------------------------------------------------------------------------
-- Procedure to print messages to stdout
  procedure print(s: in string) is
    variable l: line;
  begin
    write(l, s);
    writeline(output,l);
  end print;

-------------------------------------------------------------------------------
--  procedure to print to the stdout the txt pointer
  procedure txt_print(variable ptr: in stm_text_ptr) is
    variable txt_str      : stm_text;
  begin

    if (ptr /= null) then
      txt_str := (others => nul);
      for i in 1 to c_stm_text_len loop
        if (ptr(i) = nul) then
          exit;
        end if;
        txt_str(i) := ptr(i);
      end loop;
      print(txt_str);
    end if;
  end txt_print;

-------------------------------------------------------------------------------
--  procedure to print to the stdout the txt pointer, and
--     sub any variables found
  procedure txt_print_wvar(variable var_list : in var_field_ptr;
                           variable ptr      : in stm_text_ptr;
                           constant b        : in base) is

    variable i:          integer;
    variable j:          integer;
    variable k:          integer;
    variable txt_str:    stm_text;
    variable tmp_str:    stm_text;
    variable v1:         integer;
    variable valid:      integer;
    variable tmp_field:  text_field;
    variable tmp_i:      integer;

  begin
    if(ptr /= null) then
      i := 1;
      j := 1;
      txt_str := (others => nul);
      while(i <= c_stm_text_len and j <= c_stm_text_len) loop
        if(ptr(i) /= '$') then
          txt_str(j) := ptr(i);
          i := i + 1;
          j := j + 1;
        else
          tmp_field := (others => nul);
          tmp_i := 1;
          tmp_field(tmp_i) := ptr(i);
          i := i + 1;
          tmp_i := tmp_i + 1;
          -- parse to the next space
          while(ptr(i) /= ' ' and ptr(i) /= nul) loop
            tmp_field(tmp_i) := ptr(i);
            i := i + 1;
            tmp_i := tmp_i + 1;
          end loop;
          access_variable(var_list,tmp_field,v1,valid);
          assert(valid = 1)
            report LF & "Invalid Variable found in stm_text_ptr: ignoring."
          severity warning;

          if(valid = 1) then

            txt_str :=  ew_str_cat(txt_str, ew_to_str(v1, b));
            k := 1;
            while(txt_str(k) /= nul) loop
              k := k + 1;
            end loop;
            j := k;
          end if;
        end if;
      end loop;
      -- print the created string
      print(txt_str);
    end if;
  end txt_print_wvar;

end tb_pkg;

-------------------------------------------------------------------------------
--  Revision  1.3
-- Revision History:
-- $Log: not supported by cvs2svn $
-- Revision 1.2  2007/09/02 04:04:04  sckoarn
-- Update of version 1.2 tb_pkg
-- See documentation for details
--
-- Revision 1.1.1.1  2007/04/06 04:06:48  sckoarn
-- Import of the vhld_tb
-------------------------------------------------------------------------------
