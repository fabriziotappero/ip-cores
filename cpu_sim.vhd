--Mango DSP Ltd. Copyright (C) 2006
--Creator: Nachum Kanovsky

library ieee;
use ieee.std_logic_1164.all;
use work.design_top_constants.all;
use std.textio.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity cpu_sim is
  port(
    fname    : in    filename;
    clk      : out std_logic;
    rstN     : out   std_logic;
    cpu_cs1  : out   std_logic;
    cpu_cs2  : out   std_logic;
    cpu_cs3  : out   std_logic;
    cpu_we   : out   std_logic;
    cpu_a    : out std_logic_vector(4 downto 0);
    cpu_d    : inout std_logic_vector(7 downto 0);
    cpu_irq4 : in    std_logic;
    cpu_irq7 : in    std_logic
    );
end;

architecture cpu_sim_simple of cpu_sim is
  signal sig_clk : std_logic := '0';
  shared variable tclk : time    := 0 ns;
  shared variable rl   : integer := 1;
  
  function to_lower (
    constant c : character)
    return character is
  begin  -- to_lower
    if c >= 'A' and c <= 'Z' then
      return character'val(character'pos(c) - character'pos('A') + character'pos('a'));
    else
      return c;
    end if;
  end to_lower;

  procedure eat_white (
    variable l : inout line) is
    variable old_l : line := l;
    variable p     : integer;
  begin
    if l = null then
      return;
    end if;
    if l'length = 0 then
      --string is empty
      deallocate(l);
      return;
    end if;
    p := l'left;
    while l'length > p - l'left and (l(p) = ' ' or l(p) = HT) loop
      p := p + 1;
    end loop;
    if p = l'left then
      --no whitespace
      return;
    elsif l'length <= p - l'left then
      --only whitespace - p passed the whole string
      deallocate(l);
    else
      l := new string'(old_l(p to old_l'right));
      deallocate(old_l);
    end if;
  end eat_white;

  procedure shrink_line (
    variable l : inout line;
    variable p : inout integer) is
    variable old_l : line := l;
  begin
    assert l /= null report "shrink_line l equals null" severity failure;
    if p = 0 then
      return;
    elsif p = l'length then
      deallocate(l);
    else
      l := new string'(old_l(old_l'left + p + 1 to old_l'right));
      deallocate(old_l);
    end if;
  end shrink_line;

  procedure read_word (
    l     : inout line;
    value : inout line) is
    variable size : integer := 0;
    variable p    : integer;
  begin
    if value /= null then
      deallocate(value);
    end if;
    eat_white(l);
    if l = null then
      return;
    end if;
    p := l'left;
    while l'length > p - l'left and (l(p) /= ' ' and l(p) /= HT) loop
      l(p) := to_lower(l(p));
      p    := p + 1;
    end loop;
    p     := p - 1;
    value := new string'(l(l'left to p));
    p     := p + 1 - l'left;
    shrink_line(l, p);
  end read_word;

  procedure get_line(
    file f     :       text;
    variable l : inout line) is
  begin
    if l /= null then
      deallocate(l);
    end if;
    loop
      if endfile(f) then
        return;
      end if;
      readline(f, l);
      eat_white(l);
      if l /= null and l(l'left) /= '#' then
        return;
      else
        deallocate(l);
      end if;
    end loop;
  end get_line;

  type dfile is record
    fn : line;
    ln : integer;
  end record;
  type dfile_access is access dfile;

  procedure readline(
    variable dfa : inout dfile_access;
    l            : inout line) is
    file fl    : text;
    variable c : integer := 0;
  begin
    file_open(fl, dfa.fn.all, read_mode);
    if l /= null then
      deallocate(l);
    end if;
    while c /= dfa.ln loop
      if endfile(fl) then
        if l /= null then
          deallocate(l);
        end if;
        file_close(fl);
        return;
      end if;
      readline(fl, l);
      c := c + 1;
    end loop;
    if endfile(fl) then
      if l /= null then
        deallocate(l);
      end if;
      file_close(fl);
      return;
    end if;
    readline(fl, l);
    file_close(fl);
    dfa.ln := dfa.ln + 1;
  end readline;

  --writeline deallocates the line
  procedure write(
    variable fn : in    line;
    variable l  : inout line) is
    file fl        : text;
    file fl_tmp    : text;
    variable l_tmp : line;
  begin
    file_open(fl_tmp, "tmp.txt", write_mode);
    file_open(fl, fn.all, read_mode);
    while not endfile(fl) loop
      readline(fl, l_tmp);
      writeline(fl_tmp, l_tmp);
    end loop;
    l_tmp := new string'(l(l'left to l'right));
    writeline(fl_tmp, l_tmp);
    file_close(fl_tmp);
    file_close(fl);
    file_open(fl_tmp, "tmp.txt", read_mode);
    file_open(fl, fn.all, write_mode);
    while not endfile(fl_tmp) loop
      readline(fl_tmp, l_tmp);
      writeline(fl, l_tmp);
    end loop;
    file_close(fl_tmp);
    file_close(fl);
  end write;

  procedure write(
    variable fn : in line;
    variable sl : in std_logic) is
    file fl        : text;
    file fl_tmp    : text;
    variable b     : bit;
    variable l_tmp : line;
  begin
    file_open(fl_tmp, "tmp.txt", write_mode);
    file_open(fl, fn.all, read_mode);
    while not endfile(fl) loop
      readline(fl, l_tmp);
      writeline(fl_tmp, l_tmp);
    end loop;
    if sl = '1' then
      b := '1';
    else
      b := '0';
    end if;
    write(l_tmp, b);
    writeline(fl, l_tmp);
    file_close(fl_tmp);
    file_close(fl);
    file_open(fl_tmp, "tmp.txt", read_mode);
    file_open(fl, fn.all, write_mode);
    while not endfile(fl_tmp) loop
      readline(fl_tmp, l_tmp);
      writeline(fl, l_tmp);
    end loop;
    file_close(fl_tmp);
    file_close(fl);
  end write;

  procedure write(
    variable fn   : in line;
    variable slv8 : in std_logic_vector(7 downto 0)) is
    file fl        : text;
    file fl_tmp    : text;
    variable l_tmp : line;
  begin
    file_open(fl_tmp, "tmp.txt", write_mode);
    file_open(fl, fn.all, read_mode);
    while not endfile(fl) loop
      readline(fl, l_tmp);
      writeline(fl_tmp, l_tmp);
    end loop;
    write(l_tmp, to_bitVector(slv8));
    writeline(fl_tmp, l_tmp);
    file_close(fl_tmp);
    file_close(fl);
    file_open(fl_tmp, "tmp.txt", read_mode);
    file_open(fl, fn.all, write_mode);
    while not endfile(fl_tmp) loop
      readline(fl_tmp, l_tmp);
      writeline(fl, l_tmp);
    end loop;
    file_close(fl_tmp);
    file_close(fl);
  end write;

  procedure get_line(
    variable dfa : inout dfile_access;
    variable l   : inout line) is
    variable l_temp : line;
  begin
    if l /= null then
      deallocate(l);
    end if;
    loop
      readline(dfa, l_temp);
      if l_temp = null then
        l := null;
        return;
      end if;
      eat_white(l_temp);
      if l_temp /= null and l_temp(l_temp'left) /= '#' then
        l := l_temp;
        return;
      end if;
    end loop;
  end get_line;

  type wait_commands is (wt_done, wt_time, wt_irq4, wt_irq7);

  type waiter is record
    cmd    : wait_commands;
    tm_end : time;
    v      : std_logic;
  end record;
  type waiter_access is access waiter;

  procedure check_wait(
    variable w : inout waiter) is
  begin
    case w.cmd is
      when wt_time =>
        if now >= w.tm_end then
          w.cmd := wt_done;
        end if;
      when wt_irq4 =>
        if cpu_irq4 = w.v then
          w.cmd := wt_done;
        end if;
      when wt_irq7 =>
        if cpu_irq7 = w.v then
          w.cmd := wt_done;
        end if;
      when others => null;
    end case;
  end check_wait;

  type var_types is (vt_string, vt_bit, vt_vector8);
  type var;
  type var_access is access var;
  type var_accessx16 is array (15 downto 0) of var_access;
  type var is record
    n    : line;
    vt   : var_types;
    s    : line;
    sl   : std_logic;
    slv8 : std_logic_vector(7 downto 0);
  end record;
  type vars;
  type vars_access is access vars;
  type vars is record
    va16     : var_accessx16;
    next_vsa : vars_access;
  end record;
  
  procedure get_var(
    variable n   : in  line;
    variable vsa : in  vars_access;
    variable va  : out var_access) is
  begin
    if vsa = null then
      return;
    end if;
    va := null;
    for i in vsa.va16'range loop
      if vsa.va16(i) /= null and vsa.va16(i).n.all = n.all then
        va := vsa.va16(i);
        return;
      end if;
    end loop;
    get_var(n, vsa.next_vsa, va);
  end get_var;

  procedure add_var(
    variable vsa : inout vars_access;
    variable n   : in    line;
    variable vt  : in    var_types) is
    variable vsa_temp : vars_access;
    variable v_temp   : var_access;
  begin
    vsa_temp     := vsa.next_vsa;
    vsa.next_vsa := null;
    get_var(n, vsa, v_temp);
    vsa.next_vsa := vsa_temp;
    vsa_temp     := null;
    if v_temp /= null then
      return;
    end if;
    for i in vsa.va16'range loop
      if vsa.va16(i) = null then
        vsa.va16(i)    := new var;
        vsa.va16(i).n  := new string'(n(n'left to n'right));
        vsa.va16(i).vt := vt;
        return;
      end if;
    end loop;
    report "too many variables" severity failure;
  end add_var;
  
  procedure add_var(
    variable vsa : inout vars_access;
    variable n   : in    line;
    variable s   : in    line) is
    variable v_temp : var_access;
    variable vt     : var_types;
  begin
    vt       := vt_string;
    add_var(vsa, n, vt);
    get_var(n, vsa, v_temp);
    v_temp.s := new string'(s(s'left to s'right));
  end add_var;

  procedure add_var(
    variable vsa : inout vars_access;
    variable n   : in    line;
    variable sl  : in    std_logic) is
    variable v_temp : var_access;
    variable vt     : var_types;
  begin
    vt        := vt_string;
    add_var(vsa, n, vt);
    get_var(n, vsa, v_temp);
    v_temp.sl := sl;
  end add_var;

  procedure add_var(
    variable vsa  : inout vars_access;
    variable n    : in    line;
    variable slv8 : in    std_logic_vector(7 downto 0)) is
    variable v_temp : var_access;
    variable vt     : var_types;
  begin
    vt          := vt_string;
    add_var(vsa, n, vt);
    get_var(n, vsa, v_temp);
    v_temp.slv8 := slv8;
  end add_var;

  type thread_states is (st_ready, st_done);
  type thread;
  type thread_access is access thread;
  type thread is record
    dfa      : dfile_access;
    ln_start : integer;
    st       : thread_states;
    w        : waiter_access;
    vsa      : vars_access;
    next_tha : thread_access;
  end record;

  type tholder;
  type tholder_access is access tholder;
  type tholder is record
    th : thread_access;
    n  : tholder_access;
    p  : tholder_access;
  end record;
  
  procedure init_thread (
    variable tha : inout thread_access;
    variable dfa : in    dfile_access;
    variable ln  : in    integer;
    variable w   : in    waiter_access;
    variable vsa : in    vars_access) is
    variable int : integer;
  begin
    tha.dfa          := dfa;
    tha.ln_start     := ln;
    tha.st           := st_ready;
    tha.w            := w;
    tha.vsa          := new vars;
    tha.vsa.next_vsa := vsa;
    tha.w.cmd        := wt_done;
  end init_thread;

  procedure declare_var(
    variable l_type    : inout line;
    variable l_varname : inout line;
    variable vsa       : inout vars_access) is
    variable vt : var_types;
  begin
    assert l_type /= null and l_varname /= null report "declare_var bad parameters" severity failure;
    if l_type.all = "bit" then
      vt := vt_bit;
      add_var(vsa, l_varname, vt);
    elsif l_type.all = "vector8" then
      vt := vt_vector8;
      add_var(vsa, l_varname, vt);
    elsif l_type.all = "string" then
      vt := vt_string;
      add_var(vsa, l_varname, vt);
    else
      report "l_type is not bit, vector8, or string" severity failure;
    end if;
  end declare_var;

  procedure var_test(
    variable l_left  : inout line;
    variable l_op    : inout line;
    variable l_right : inout line;
    variable bl_good : inout boolean;
    variable vsa     : inout vars_access) is
    variable va_left  : var_access;
    variable va_right : var_access;
    variable sl       : std_logic;
    variable slv8     : std_logic_vector(7 downto 0);
    variable b        : bit;
    variable bv8      : bit_vector(7 downto 0);
    variable s        : line;
  begin
    assert l_left /= null and l_op /= null and l_right /= null report "var_test invalid null parameters" severity failure;
    get_var(l_left, vsa, va_left);
    assert va_left /= null report "var_test left variable not found" severity failure;
    get_var(l_right, vsa, va_right);
    if va_right /= null then
      assert va_left.vt = va_right.vt report "var_test var types not the same" severity failure;
      case va_right.vt is
        when vt_bit =>
          sl := va_right.sl;
        when vt_vector8 =>
          slv8 := va_right.slv8;
        when vt_string =>
          s := va_right.s;
      end case;
    else
      case va_left.vt is
        when vt_bit =>
          read(l_right, b, bl_good);
          assert bl_good = true report "var_test last parameter failed read" severity failure;
          if b = '1' then
            sl := '1';
          else
            sl := '0';
          end if;
        when vt_vector8 =>
          read(l_right, bv8, bl_good);
          assert bl_good = true report "var_test last parameter failed read" severity failure;
          slv8 := to_stdlogicvector(bv8);
        when vt_string =>
          s := l_right;
      end case;
    end if;
    bl_good := false;
    case va_left.vt is
      when vt_bit =>
        assert l_op.all = "==" or l_op.all = ">" or l_op.all = "<" or l_op.all = "&" or l_op.all = "|" report "var_test invalid operation for bit, use ==,>,<,&,|" severity failure;
        if l_op.all = "==" then
          if va_left.sl = sl then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = ">" then
          if va_left.sl > sl then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = "<" then
          if va_left.sl < sl then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = "&" then
          if (va_left.sl and sl) /= '0' then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = "|" then
          if (va_left.sl or sl) /= '0' then
            bl_good := true;
            return;
          end if;
        end if;
      when vt_vector8 =>
        assert l_op.all = "==" or l_op.all = ">" or l_op.all = "<" or l_op.all = "&" or l_op.all = "|" report "var_test invalid operation for vector8, use ==,>,<,&,|" severity failure;
        if l_op.all = "==" then
          if va_left.slv8 = slv8 then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = ">" then
          if va_left.slv8 > slv8 then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = "<" then
          if va_left.slv8 < slv8 then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = "&" then
          if (va_left.slv8 and slv8) /= "00000000" then
            bl_good := true;
            return;
          end if;
        elsif l_op.all = "|" then
          if (va_left.slv8 or slv8) /= "00000000" then
            bl_good := true;
            return;
          end if;
        end if;
      when vt_string =>
        assert l_op.all = "==" report "var_test string has only == operation" severity failure;
        if va_left.s = s then
          bl_good := true;
          return;
        end if;
      when others => null;
    end case;
  end var_test;

--variables are deallocated in this function
  procedure var_op (
    variable l_left  : inout line;
    variable l_op    : inout line;
    variable l_right : inout line;
    variable vsa     : inout vars_access) is
    variable va_left  : var_access;
    variable va_right : var_access;
    variable slv8     : std_logic_vector(7 downto 0);
    variable slv16    : std_logic_vector(15 downto 0);
    variable b        : bit;
    variable bv8      : bit_vector(7 downto 0);
    variable bl_good  : boolean;
  begin
    assert l_left /= null and l_op /= null and l_right /= null report "l_left or l_op or l_right are null" severity failure;
    if l_left.all = "bit" or l_left.all = "vector8" or l_left.all = "string" then
      declare_var(l_left, l_op, vsa);
      l_left := l_op;
      l_op   := null;
      read_word(l_right, l_op);
    end if;
    get_var(l_left, vsa, va_left);
    assert va_left /= null report "variable not found" severity failure;
    case va_left.vt is
      when vt_string =>
        assert l_op.all = "=" report "illegal op, string has only = operation" severity failure;
        if va_left.s /= null then
          deallocate(va_left.s);
        end if;
        get_var(l_right, vsa, va_right);
        if va_right /= null then
          va_left.s := new string'(va_right.s(va_right.s'left to va_right.s'right));
        else
          read_word(l_right, va_left.s);
        end if;
      when vt_bit =>
        assert l_op.all = "=" report "illegal op, bit has only = operation" severity failure;
        get_var(l_right, vsa, va_right);
        if va_right /= null then
          assert va_right.vt = vt_bit report "non bit variable being op'ed with bit variable" severity failure;
          va_left.sl := va_right.sl;
        else
          read(l_right, b, bl_good);
          if bl_good = true then
            if b = '1' then
              va_left.sl := '1';
            else
              va_left.sl := '0';
            end if;
          else
            report "bit operation missing bit value" severity failure;
          end if;
        end if;
      when vt_vector8 =>
        get_var(l_right, vsa, va_right);
        if va_right /= null then
          assert va_right.vt = vt_vector8 report "non vector8 variable being op'ed with vector8 variable" severity failure;
          slv8 := va_right.slv8;
        else
          read(l_right, bv8);
          slv8 := to_stdlogicvector(bv8);
        end if;
        if l_op.all = "=" then
          va_left.slv8 := slv8;
        elsif l_op.all = "+=" then
          va_left.slv8 := va_left.slv8 + slv8;
        elsif l_op.all = "-=" then
          va_left.slv8 := va_left.slv8 - slv8;
        elsif l_op.all = "*=" then
          slv16        := va_left.slv8 * slv8;
          va_left.slv8 := slv16(7 downto 0);
        elsif l_op.all = "&=" then
          va_left.slv8 := va_left.slv8 and slv8;
        elsif l_op.all = "|=" then
          va_left.slv8 := va_left.slv8 or slv8;
        else
          report "illegal op, vector8 has only =, +, -, &, | operations" severity failure;
        end if;
    end case;
    deallocate(l_left);
    deallocate(l_op);
    deallocate(l_right);
  end var_op;

  procedure clear(
    variable fn : inout line) is
    file fl : text;
  begin
    file_open(fl, fn.all, write_mode);
    file_close(fl);
  end clear;

  procedure find_match (
    variable dfa     : inout dfile_access;
    constant s_open  : in    string;
    constant s_close : in    string) is
    variable l   : line;
    variable cmd : line;
  begin
    get_line(dfa, l);
    read_word(l, cmd);
    while cmd.all /= s_close loop
      if cmd.all = s_open then
        find_match(dfa, s_open, s_close);
      end if;
      get_line(dfa, l);
      read_word(l, cmd);
    end loop;
  end find_match;

  procedure find_match (
    variable dfa     : inout dfile_access;
    constant s_open  : in    string;
    constant s_other  : in    string;
    constant s_close : in    string) is
    variable l   : line;
    variable cmd : line;
  begin
    get_line(dfa, l);
    read_word(l, cmd);
    while cmd.all /= s_close and cmd.all /= s_other loop
      if cmd.all = s_open then
        find_match(dfa, s_open, s_close);
      end if;
      get_line(dfa, l);
      read_word(l, cmd);
    end loop;
  end find_match;

  procedure read_dma (
    variable l       : inout line;
    variable vsa     : inout vars_access;
    signal   cpu_cs1 : out   std_logic;
    signal   cpu_we  : out   std_logic;
    signal   cpu_a   : out std_logic_vector(4 downto 0);
    signal   cpu_d   : inout std_logic_vector(7 downto 0)) is
    variable l_tmp : line;
    variable va : var_access;
    variable addr : std_logic_vector(7 downto 0);
    variable size : integer;
    variable incr : integer;
    variable bl_good : boolean;
    variable bv8 : bit_vector(7 downto 0);
    variable filename : line;
    variable slv8 : std_logic_vector(7 downto 0);
  begin
    read_word(l, l_tmp);
    assert l_tmp /= null report "read_dma parameter missing" severity failure;
    get_var(l_tmp, vsa, va);
    if va = null then
      read(l_tmp, bv8, bl_good);
      assert bl_good report "read_dma address invalid" severity failure;
      addr := to_stdlogicvector(bv8);
    else
      assert va.vt = vt_vector8 report "read_dma address variable not found" severity failure;
      addr := va.slv8;
    end if;
    read_word(l, l_tmp);
    assert l_tmp /= null report "read_dma parameter missing" severity failure;
    get_var(l_tmp, vsa, va);
    if va = null then
      read(l_tmp, bv8, bl_good);
      assert bl_good report "read_dma size invalid" severity failure;
      size := to_integer(unsigned(to_stdlogicvector(bv8)));
    else
      assert va /= null and va.vt = vt_vector8 report "read_dma size variable not found" severity failure;
      size := to_integer(unsigned(va.slv8));
    end if;
    read_word(l, l_tmp);
    assert l_tmp /= null report "read_dma parameter missing" severity failure;
    get_var(l_tmp, vsa, va);
    if va = null then
      read(l_tmp, bv8, bl_good);
      assert bl_good report "read_dma incr invalid" severity failure;
      incr := to_integer(unsigned(to_stdlogicvector(bv8)));
    else
      assert va /= null and va.vt = vt_vector8 report "read_dma incr variable not found" severity failure;
      incr := to_integer(unsigned(va.slv8));
    end if;
    read_word(l, l_tmp);
    assert l_tmp /= null report "read_dma parameter missing" severity failure;
    filename := l_tmp;
    l_tmp := null;

    for i in 0 to size - 1 loop
      if i < (size + rl) then
        cpu_cs1 <= '1';
        cpu_a <= addr(cpu_a'range);
        addr := addr + incr;
      end if;
      if i > rl then
        slv8 := cpu_d;
        write(filename, slv8);
      end if;
      wait for 1 ps;
      wait until rising_edge(sig_clk);
    end loop;
    cpu_cs1 <= '0';
    cpu_a   <= (others => '0');
    for i in 0 to rl - 1 loop
      if (size + i) > rl then
        slv8 := cpu_d;
        write(filename, slv8);
      end if;
      wait for 1 ps;
      wait until rising_edge(sig_clk);
    end loop;
    slv8 := cpu_d;
    write(filename, slv8);
--        cpu_cs1 <= '1';
--        wait for 1 ps;
--        wait until rising_edge(sig_clk);
--        cpu_cs1 <= '0';
--        cpu_a   <= (others => '0');
--        for i in 1 to rl loop
--          --waiting for data to get back
--          wait for 1 ps;
--          wait until rising_edge(sig_clk);
--        end loop;  -- i
--        read_word(l, l_first);
--        if l_first = null then
--          exit;
--        end if;
--        get_var(l_first, tha.vsa, va);
--        assert va /= null and va.vt = vt_vector8 report "illegal address for read" severity failure;
--        va.slv8 := cpu_d;
--        va      := null;
  end read_dma;
  
  procedure process_thread (
    variable tha     : inout thread_access;
    signal   cpu_cs1 : out   std_logic;
    signal   cpu_we  : out   std_logic;
    signal   cpu_a   : out std_logic_vector(4 downto 0);
    signal   cpu_d   : inout std_logic_vector(7 downto 0)) is
    variable va       : var_access;
    variable l        : line;
    variable tm       : time;
    variable b        : bit;
    variable l_first  : line;
    variable l_second : line;
    variable bl_good  : boolean;
    variable bv8      : bit_vector(7 downto 0);
  begin
    while tha.st = st_ready and tha.w.all.cmd = wt_done loop
      if tha.next_tha /= null then
        if tha.next_tha.st = st_done then
          find_match(tha.dfa, "while", "while_end");
          deallocate(tha.next_tha);
        else
          process_thread(tha.next_tha, cpu_cs1, cpu_we, cpu_a, cpu_d);
          exit;
        end if;
      end if;
      if tha.st = st_ready then
        get_line(tha.dfa, l);
        read_word(l, l_first);
      end if;
      tha.st := st_ready;
      if l_first = null then
        tha.st := st_done;
      elsif l_first.all = "wait" then
        read(l, tm);
        tha.w.cmd    := wt_time;
        tha.w.tm_end := tm + now;
        check_wait(tha.w.all);
      elsif l_first.all = "wait_interrupt4" then
        tha.w.cmd := wt_irq4;
        read(l, b, bl_good);
        if bl_good then
          if b = '1' then
            tha.w.v := '1';
          else
            tha.w.v := '0';
          end if;
        else
          tha.w.v := '1';
        end if;
        check_wait(tha.w.all);
      elsif l_first.all = "while" then
        tha.next_tha := new thread;
        init_thread(tha.next_tha, tha.dfa, tha.dfa.ln, tha.w, tha.vsa);
      elsif l_first.all = "while_exit" then
        tha.st := st_done;
      elsif l_first.all = "while_end" then
        tha.dfa.ln := tha.ln_start;
      elsif l_first.all = "if" then
        read_word(l, l_first);
        read_word(l, l_second);
        var_test(l_first, l_second, l, bl_good, tha.vsa);
        if bl_good = false then
          find_match(tha.dfa, "if", "if_else", "if_end");
        end if;
      elsif l_first.all = "if_else" then
        find_match(tha.dfa, "if", "if_end");
      elsif l_first.all = "if_end" then
      elsif l_first.all = "clear" then
        read_word(l, l_first);
        assert l_first /= null report "clear without file or variable name" severity failure;
        get_var(l_first, tha.vsa, va);
        if va /= null then
          assert va.vt = vt_string report "non string variable name" severity failure;
          clear(va.s);
        else
          clear(l_first);
        end if;
        deallocate(l_first);
        va := null;
      elsif l_first.all = "read" then
        cpu_cs1 <= '1';
        read_word(l, l_first);
        assert l_first /= null report "read parameter missing" severity failure;
        get_var(l_first, tha.vsa, va);
        assert va = null or va.vt = vt_vector8 report "illegal address for read" severity failure;
        if va = null then
          read(l_first, bv8);
          cpu_a <= to_stdlogicvector(bv8)(cpu_a'left downto 0);
        else
          cpu_a <= va.slv8(cpu_a'left downto 0);
          va    := null;
        end if;
        --waiting for request to get to cpu block
        wait for 1 ps;
        wait until rising_edge(sig_clk);
        cpu_cs1 <= '0';
        cpu_a   <= (others => '0');
        for i in 1 to rl loop
          --waiting for data to get back
          wait for 1 ps;
          wait until rising_edge(sig_clk);
        end loop;  -- i
        read_word(l, l_first);
        if l_first = null then
          exit;
        end if;
        get_var(l_first, tha.vsa, va);
        assert va /= null and va.vt = vt_vector8 report "illegal address for read" severity failure;
        va.slv8 := cpu_d;
        va      := null;
      elsif l_first.all = "write" then
        cpu_cs1 <= '1';
        cpu_we  <= '1';
        read_word(l, l_first);
        assert l_first /= null report "write parameter missing" severity failure;
        get_var(l_first, tha.vsa, va);
        assert va = null or va.vt = vt_vector8 report "illegal address for write" severity failure;
        if va = null then
          read(l_first, bv8);
          cpu_a <= to_stdlogicvector(bv8)(cpu_a'left downto 0);
        else
          cpu_a <= va.slv8(cpu_a'left downto 0);
          va    := null;
        end if;
        deallocate(l_first);
        read_word(l, l_first);
        assert l_first /= null report "write parameter missing" severity failure;
        get_var(l_first, tha.vsa, va);
        assert va = null or va.vt = vt_vector8 report "illegal data for write" severity failure;
        if va = null then
          read(l_first, bv8);
          cpu_d <= to_stdlogicvector(bv8)(cpu_d'left downto 0);
        else
          cpu_d <= va.slv8(cpu_d'left downto 0);
          va    := null;
        end if;
        deallocate(l_first);
        wait for 1 ps;
        wait until rising_edge(sig_clk);
        cpu_cs1 <= '0';
        cpu_we  <= '0';
        cpu_a   <= (others => '0');
        cpu_d   <= (others => 'Z');
      elsif l_first.all = "read_dma" then
        read_dma(l, tha.vsa, cpu_cs1, cpu_we, cpu_a, cpu_d);
      elsif l_first.all = "write" then
--        write_dma(l, tha.vsa, cpu_cs1, cpu_we, cpu_a, cpu_d);
      elsif l_first.all = "print" then
        read_word(l, l_first);
        assert l_first /= null report "no file or variable name for print" severity failure;
        get_var(l_first, tha.vsa, va);
        if va /= null then
          deallocate(l_first);
          l_first := va.s;
          va      := null;
        end if;
        read_word(l, l_second);
        assert l_second /= null report "no variable name for print" severity failure;
        get_var(l_second, tha.vsa, va);
        l_second := null;
        assert va /= null report "invalid variable for print" severity failure;
        if va.vt = vt_string then
          write(l_first, va.s);
        elsif va.vt = vt_bit then
          write(l_first, va.sl);
        elsif va.vt = vt_vector8 then
          write(l_first, va.slv8);
        end if;
        l_first := null;
        va      := null;
      elsif l_first.all = "breakpoint" then
        deallocate(l_first);
      else
        read_word(l, l_second);
        var_op(l_first, l_second, l, tha.vsa);
      end if;
    end loop;
    deallocate(l);
    deallocate(l_first);
  end process_thread;

begin
  sig_clk <= not sig_clk after tclk;
  clk <= sig_clk;
  process
    file fl               : text;
    variable l            : line;
    variable l_params     : line;
    variable tm           : time;
    variable bl_alldone   : boolean;
    variable vsa          : vars_access;
    variable l_first      : line;
    variable l_second     : line;
    variable l_third      : line;
    variable wa           : waiter_access;
    variable dfa          : dfile_access;
    variable tholda_start : tholder_access;
    variable tholda       : tholder_access;
    variable tholda_prev  : tholder_access;
  begin
    rstN    <= '0';
    cpu_cs1 <= '0';
    cpu_cs2 <= '0';
    cpu_cs3 <= '0';
    cpu_we  <= '0';
    cpu_a   <= (others => '0');
    cpu_d   <= (others => 'Z');
    file_open(fl, fname, read_mode);
    vsa     := new vars;
    loop
      get_line(fl, l);
      read_word(l, l_first);
      if l_first = null then
        exit;
      elsif l_first.all = "clock" then
        read(l, tm);
        tclk := tm;
      elsif l_first.all = "reset" then
        read(l, tm);
        wait for tm;
        rstN <= '1';
      elsif l_first.all = "read_latency" then
        read(l, rl);
      elsif l_first.all = "thread" then
        tholda := new tholder;
        if tholda_start = null then
          tholda_start := tholda;
          tholda_prev  := tholda_start;
        else
          tholda_prev.n := tholda;
          tholda_prev   := tholda;
        end if;
        tholda.th := new thread;
        read_word(l, l_second);
        wa        := new waiter;
        dfa       := new dfile;
        dfa.fn    := l_second;
        l_second  := null;
        dfa.ln    := 0;
        init_thread(tholda.th, dfa, dfa.ln, wa, vsa);
        while l_first /= null and l_first.all /= "parameters" loop
          get_line(tholda.th.dfa, l_params);
          read_word(l_params, l_first);
        end loop;
        if l_first /= null and l_first.all = "parameters" then
          loop
            read_word(l_params, l_first);
            if l_first = null then
              exit;
            end if;
            assert l_first.all = "bit" or l_first.all = "vector8" or l_first.all = "string" report "illegal variable type in parameter list" severity failure;
            read_word(l_params, l_second);
            assert l_second /= null report "variable name missing in parameter list" severity failure;
            declare_var(l_first, l_second, tholda.th.vsa);
            deallocate(l_first);
            l_first  := l_second;
            l_second := new string'("=");
            read_word(l, l_third);
            assert l_third /= null report "variable value missing in thread spawn call" severity failure;
            var_op(l_first, l_second, l_third, tholda.th.vsa);
          end loop;
        else
          tholda.th.dfa.ln := 0;
        end if;
        tholda := tholda.n;
      else
        read_word(l, l_second);
        var_op(l_first, l_second, l, vsa);
      end if;
    end loop;
    wait for 1 ps;
    wait until rising_edge(sig_clk);
    loop
      bl_alldone := true;
      tholda     := tholda_start;
      while tholda /= null loop
        if tholda.th.w.cmd /= wt_done then
          check_wait(tholda.th.w.all);
          bl_alldone := false;
        end if;
        tholda := tholda.n;
      end loop;
      tholda      := tholda_start;
      tholda_prev := null;
      while tholda /= null loop
        if tholda.th.w.cmd = wt_done then
          process_thread(tholda.th, cpu_cs1, cpu_we, cpu_a, cpu_d);
          bl_alldone := false;
        end if;
        if tholda.th.st = st_done then
          if tholda_prev /= null then
            tholda_prev.n := tholda.n;
          else
            tholda_start := tholda.n;
          end if;
          deallocate(tholda.th.w);
          deallocate(tholda.th.vsa);
          deallocate(tholda.th.dfa);
          deallocate(tholda.th);
        end if;
        tholda_prev := tholda;
        tholda      := tholda.n;
      end loop;
      wait for 1 ps;
      wait until rising_edge(sig_clk);
      if bl_alldone then
        cpu_cs1 <= '0';
        cpu_we  <= '0';
        cpu_a   <= (others => '0');
        cpu_d   <= (others => 'Z');
        wait;
      end if;
    end loop;
  end process;
end cpu_sim_simple;

