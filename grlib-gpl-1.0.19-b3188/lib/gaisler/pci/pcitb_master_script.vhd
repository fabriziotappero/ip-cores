------------------------------------------------------------------------------
--  This file is a part of the GRLIB VHDL IP LIBRARY
--  Copyright (C) 2003, Gaisler Research
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; either version 2 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
-----------------------------------------------------------------------------
-- Entity:      pcitb_master_script
-- File:        pcitb_master_script.vhd
-- Author:      Kristoffer Glembo, Alf Vaerneus, Gaisler Research
-- Description: PCI Master emulator. Can act as a system host
------------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library grlib;
use grlib.stdlib.all;
library gaisler;
use gaisler.pcitb.all;
use gaisler.pcilib.all;
use gaisler.ambatest.all;

entity pcitb_master_script is
  generic (
    slot      : integer := 0;
    tval      : time := 7 ns;
    dbglevel  : integer := 2;
    maxburst  : integer := 1024;
    filename  : string := "pci.cmd");
  port (
    pciin     : in pci_type;
    pciout    : out pci_type);
end pcitb_master_script;

architecture behav of pcitb_master_script is

type cmd_state_type is (idle, parse, execute, done, finished);

type pci_data_type is record
  data  : std_logic_vector(31 downto 0);
  cbe   : std_logic_vector(3 downto 0);
  ws    : integer;
end record;

type databuf_type is array (0 to maxburst) of pci_data_type;

type cmd_type is (rcfg, wcfg, rmem, wmem, idle, comp, ill, print, estop, stop);

type command is record
  cmd   : cmd_type;
  pcicmd: std_logic_vector(3 downto 0);
  addr  : std_logic_vector(31 downto 0);
  len   : integer;
  file1 : string(1 to 18);
  file2 : string(1 to 18);
  msg   : string(1 to 80);
  check : integer; -- 0 ignore, 1 check, 2 save to file
  estop : integer;
  data  : databuf_type;
  pci   : boolean;
  started : std_logic;
  done    : std_logic;

end record; 

type script_reg_type is record
  cmd_state     : cmd_state_type;
  cmd_done      : std_logic;
  idle_count    : integer;
  cmd_count     : integer;
end record;

signal sr,srin : script_reg_type;

signal cmd : command;

file cmd_file : text open read_mode is filename; 

---------------------------------
--- PCI MASTER TYPES AND SIGNALS
---------------------------------
constant T_O : integer := 9;

constant INT_ACK      : word4 := "0000";
constant SPEC_CYCLE   : word4 := "0001";
constant IO_READ      : word4 := "0010";
constant IO_WRITE     : word4 := "0011";
constant MEM_READ     : word4 := "0110";
constant MEM_WRITE    : word4 := "0111";
constant CONF_READ    : word4 := "1010";
constant CONF_WRITE   : word4 := "1011";
constant MEM_R_MULT   : word4 := "1100";
constant DAC          : word4 := "1101";
constant MEM_R_LINE   : word4 := "1110";
constant MEM_W_INV    : word4 := "1111";

type state_type is(idle,active,done);
type status_type is (OK, ERR, TIMEOUT, RETRY);

type reg_type is record
  state         : state_type;
  pcien         : std_logic_vector(3 downto 0);
  paren         : std_logic;
  read          : std_logic;
  burst         : std_logic;
  grant         : std_logic;
  address       : std_logic_vector(31 downto 0);
  data          : std_logic_vector(31 downto 0);
  current_word  : integer;
  tocnt         : integer;
  running       : std_logic;
  pci           : pci_type;
  ready         : std_logic;
  last          : std_logic;
  f_open        : std_logic;
  ws_count      : integer;
  ws_done       : boolean;
  status        : status_type;
end record;

signal r,rin : reg_type;

----------------------------------------------------------------
-- PROCEDURES
----------------------------------------------------------------

function cbe2mask(cbe : std_logic_vector(3 downto 0)) return std_logic_vector is
    variable mask : std_logic_vector(31 downto 0);
begin
    for i in 0 to 3 loop
        mask((i+1)*8-1 downto i*8) := (others => cbe(i));
    end loop;

    return mask;
    
end cbe2mask;

function strlen(str : string) return integer is
    variable i : integer;
begin
    i := 1;
    while (str(i) /= ' ' and str(i) /= nul) loop
        i := i+1;
    end loop;

    return i-1;
    
end strlen;

procedure get_param(str : string; tok : character; param : out string; index : out integer; done : out boolean) is
    variable start_i, end_i : integer;
begin
    start_i := str'left;
    while str(start_i) = ' ' and start_i <= str'right loop
        start_i := start_i + 1;
    end loop;

    end_i := start_i;

    while end_i <= str'right loop   

        if str(end_i) = ' ' or str(end_i) = ';' or str(end_i) = nul  or str(end_i) = tok then
             exit;
        end if;

        end_i := end_i + 1;
    end loop;

    param(1 to (end_i-start_i)) := str(start_i to end_i-1);
    for i in end_i-start_i+1 to param'length loop
        param(i) := ' ';
    end loop;
--    param(end_i-start_i+1 to param'length) := (others => ' ');

    if str(end_i) = ';' or str(end_i) = nul or end_i = str'right then
        done := true;
    else
        done := false;
    end if;

    index := end_i+1;
    
end get_param;

procedure parse_cmd(file cmdfile : text; c : out command) is
    
    variable L : line;
    variable line : string(1 to 80);
    variable cmdname : string(1 to 5);
    variable i,k : integer;
    variable done : boolean;
    variable tmp : string(1 to 8);
    variable tmpstr : string(1 to 18);
    variable slvlen : std_logic_vector(31 downto 0);
    variable len : integer;
    file datafile : text;
    
begin
    
    while not endfile(cmdfile) loop

        c.check := 0;
        c.data(0).cbe := "0000";
        c.data(0).ws := 0;
        done := false;
        line := (others => nul);
        tmp := (others => nul);
        tmpstr := (others => nul);
        line := (others => nul);
        
        readline(cmdfile, L);
        if L'length < cmdname'length then
            read(L, cmdname(1 to L'length));
        else
            read(L, cmdname);
        end if;

        if cmdname(1) = ' ' or cmdname(1) = '#' or cmdname(1) = nul or cmdname(1) = cr then
            next;
        
        elsif cmdname = "rcfg " then
            c.cmd := rcfg;
            c.pci := true;
            c.len := 1;
            c.pcicmd := CONF_READ;
            
            read(L, line(1 to L'length));
            get_param(line, ' ',  tmp, i, done);
            c.addr := conv_std_logic_vector(tmp, 32);
            get_param(line(i to line'length), ' ', tmp, i, done);
            
            if tmp(1) = '*' then
                c.check := 0;
            else
                c.check := 1;
                c.data(0).data := conv_std_logic_vector(tmp, 32);
            end if;

            exit;
            
        elsif cmdname = "wcfg " then
            c.cmd := wcfg;
            c.pci := true;
            c.len := 1;
            c.pcicmd := CONF_WRITE;
            
            read(L, line(1 to L'length));
            get_param(line, ' ',  tmp, i, done);
            c.addr := conv_std_logic_vector(tmp, 32);

            get_param(line(i to line'length), '.', tmp, i, done);
            c.data(0).data := conv_std_logic_vector(tmp, 32);
            
            get_param(line(i to line'length), ' ', tmp, i, done);
            c.data(0).cbe := conv_std_logic_vector(tmp, 4);
            
            exit;
            
        elsif cmdname = "rmem " then
            c.cmd := rmem;
            c.pci := true;
            
            read(L, line(1 to L'length));

            -- Get read command
            get_param(line, ' ', tmp, i, done);
            c.pcicmd := conv_std_logic_vector(tmp, 4);

            -- Get read addr
            get_param(line(i to line'length), ' ', tmp, i, done);
            c.addr := conv_std_logic_vector(tmp, 32);

            -- Get read length
            get_param(line(i to line'length), ' ', tmp, i, done);
            len := to_integer( unsigned(conv_std_logic_vector(tmp, 16)) );
            c.len := len;

            -- Get check data
            get_param(line(i to line'length), ' ', tmpstr, i, done);
            if tmpstr(1) = '*' then
                c.check := 0;
            elsif tmpstr(1) = '{' then
                c.check := 1;
                for j in 1 to line'length loop
                    line(j) := nul;
                end loop;
                for j in 0 to len-1 loop

                    tmpstr := (others => nul);
                    line   := (others => nul);
                    
                    readline(cmdfile, L);
                    read(L, line(1 to L'length));
                    get_param(line, '.', tmpstr, i, done);
                    c.data(j).data := conv_std_logic_vector(tmpstr(1 to 8), 32);
                    
                    get_param(line(i to line'length), '.', tmpstr, i, done);
                    c.data(j).cbe := conv_std_logic_vector(tmpstr(1 to 8), 4);
                    
                    if not done then
                        get_param(line(i to line'length), ' ', tmpstr, i, done);
                        c.data(j).ws := to_integer( unsigned(conv_std_logic_vector(tmpstr(1 to 8), 4)) );
                    else
                        c.data(j).ws := 0;
                    end if;
                    
                end loop;
                
                readline(cmdfile, L);
                
            else
                c.check := 2;
                c.file1 := tmpstr;  
            end if;
           
            exit;
            
        elsif cmdname = "wmem " then
            c.cmd := wmem;
            c.pci := true;
            
            read(L, line(1 to L'length));

            -- Get write command
            get_param(line, ' ', tmp, i, done);
            c.pcicmd := conv_std_logic_vector(tmp, 4);

            -- Get write addr
            get_param(line(i to line'length), ' ', tmp, i, done);
            c.addr := conv_std_logic_vector(tmp, 32);

            -- Get write length
            get_param(line(i to line'length), ' ', tmp, i, done);
            len := to_integer( unsigned(conv_std_logic_vector(tmp, 16)) );
            c.len := len;

            -- Get data
            get_param(line(i to line'length), ' ', tmpstr, i, done);
            if tmpstr(1) = '{' then
                
                for j in 1 to line'length loop
                    line(j) := nul;
                end loop;
                for j in 0 to len-1 loop

                    tmpstr := (others => nul);
                    line   := (others => nul);
                    
                    readline(cmdfile, L);
                    read(L, line(1 to L'length));
                    get_param(line, '.', tmpstr, i, done);
                    c.data(j).data := conv_std_logic_vector(tmpstr(1 to 8), 32);
                    get_param(line(i to line'length), '.', tmpstr, i, done);
                    c.data(j).cbe := conv_std_logic_vector(tmpstr(1 to 8), 4);

                     if not done then
                        get_param(line(i to line'length), ' ', tmpstr, i, done);
                        c.data(j).ws := to_integer( unsigned(conv_std_logic_vector(tmpstr(1 to 8), 4)) );
                     else
                        c.data(j).ws := 0;
                    end if;
                        
                end loop;
                
                readline(cmdfile, L);
                
            else
                c.file1 := tmpstr;
                file_open(datafile, tmpstr(1 to strlen(tmpstr)), read_mode);
                for j in 0 to len-1 loop
                    tmpstr := (others => nul);
                    line   := (others => nul);

                    readline(datafile, L);
                    read(L, line(1 to L'length));

                    get_param(line, '.', tmpstr, i, done);
                    c.data(j).data := conv_std_logic_vector(tmpstr(1 to 8), 32);

                    get_param(line(i to line'length), '.', tmpstr, i, done);
                    c.data(j).cbe := conv_std_logic_vector(tmpstr(1 to 8), 4);

                    if not done then
                        get_param(line(i to line'length), ' ', tmpstr, i, done);
                        c.data(j).ws := to_integer( unsigned(conv_std_logic_vector(tmpstr(1 to 8), 4)) );
                     else
                        c.data(j).ws := 0;
                    end if;
                    
                end loop;
                file_close(datafile);
            end if;

            exit;
            
        elsif cmdname = "wait " then
            c.cmd := idle;
            c.pci := false;
            
            read(L, c.len);
            exit;
            
        elsif cmdname = "comp " then
            c.cmd := comp;
            c.pci := false;
            
            read(L, line(1 to L'length));
            get_param(line, ' ', c.file1, i, done);
            assert done = false report "Illegal compare statement. Missing file2";
            get_param(line(i to line'length), ' ', c.file2, i, done);
            assert done = true report "Illegal compare statement. Missing ;";

            exit;

        elsif cmdname(1 to 4) = "stop" then
            c.cmd := stop;
            c.pci := false;
            exit;
            
        elsif cmdname = "estop" then
            c.cmd := estop;
            c.pci := false;
            read(L, c.estop);
            exit;
            
        elsif cmdname = "print" then
            c.cmd := print;
            c.pci := false;
            read(L, line(1 to L'length));
            i := 1;
            while line(i) /= ';' and line(i) /= nul loop
                i := i + 1;
            end loop;

            c.msg(1 to i-1) := line(1 to i-1);
            c.msg(i to 80) := (others => nul);
            exit;
            
        elsif cmdname(1 to 4) = "halt" then

            print ("");
            assert false report "*** Simulation ended by halt command in pcitb_master_script ***" severity failure;
            print ("");
            
        else
            c.cmd := ill;
            exit;
            
        end if;

        
    end loop;   
              
end parse_cmd;
              

begin

  script_comb : process(sr, cmd, r, pciin)
      
  variable vcmd : command;
  variable v : script_reg_type;
  variable err : boolean;
  
  begin
      
    v := sr;
    vcmd := cmd;

    case sr.cmd_state is

        when idle =>

            v.cmd_state := parse;

        when parse =>

            if cmd.started = '0' then
                parse_cmd(cmd_file, vcmd);
                vcmd.started := '1';

                if vcmd.cmd /= print and dbglevel >= 2 then
                    printf("");
                    printf("Command #%d ", sr.cmd_count+1, timestamp => true);
                end if;
                
                case vcmd.cmd is
                    when idle =>
                        if dbglevel >= 2 then
                            printf("Waiting for %d cycles.", vcmd.len);
                        end if;
                        
                    when comp =>
                        if dbglevel >= 2 then
                            printf("Comparing %s", vcmd.file1(1 to strlen(vcmd.file1)) & " to " & vcmd.file2(1 to strlen(vcmd.file2)));
                        end if;
                        
                    when rcfg =>
                        if dbglevel >= 2 then
                            printf("Configuration read");
                            printf(" Address: 0x%x", vcmd.addr);
                        end if;
                        
                    when wcfg =>
                        if dbglevel >= 2 then
                            printf("Configuration write");
                            printf(" Address: 0x%x", vcmd.addr);
                            printf(" Data   : 0x%x", vcmd.data(0).data);
                            printf(" CBE    : 0x%x", vcmd.data(0).cbe);
                        end if;
                        
                    when rmem =>
                        if dbglevel >= 2 then
                            if vcmd.pcicmd = MEM_READ then
                                printf("Memory read");
                            elsif vcmd.pcicmd = MEM_R_MULT then
                                printf("Memory read multiple");
                            else
                                printf("Memory read line");
                            end if;
                            printf(" Address: 0x%x", vcmd.addr);
                            printf(" Length : %x", vcmd.len);
                        end if;
                        
                    when wmem =>
                        if dbglevel >= 2 then
                            if vcmd.pcicmd = MEM_WRITE then
                                printf("Memory write");
                            else
                                printf("Memory write and invalidate");
                            end if;
                            printf(" Address: 0x%x", vcmd.addr);
                            printf(" Length : %x", vcmd.len);
                            if (vcmd.len = 1) then
                                printf(" Data   : 0x%x", vcmd.data(0).data);
                                printf(" CBE    : 0x%x", vcmd.data(0).cbe);
                            end if;
                        end if;
                        
                    when print =>
                        printf(vcmd.msg);
                        
                    when stop =>
                        if dbglevel >= 1 then
                            printf("PCI Testmaster done with scriptfile");
                        end if;
                                                
                    when others =>  vcmd.done := '1';
                end case;
                
            end if;

            v.cmd_state := execute;

        when execute =>

            if vcmd.done = '0' then
                case vcmd.cmd is
                    when idle =>
                        if sr.idle_count < vcmd.len then
                            v.idle_count := sr.idle_count + 1;
                        else
                            vcmd.done := '1';
                        end if;
                    when comp =>
                        compfiles(vcmd.file1, vcmd.file2, 1, dbglevel, err);
                        if cmd.estop = 1 then
                            printf("");
                            assert err = false 
                                report "Simulation ended due to data compare failure!"
                                severity FAILURE;
                        end if;
                        vcmd.done := '1';
                    when rcfg =>
                        if r.ready = '1' then
                            vcmd.done := '1';
                        end if;
                    when wcfg =>
                        if r.ready = '1' then
                            vcmd.done := '1';
                        end if;
                    when rmem =>
                        if r.ready  = '1' then
                            vcmd.done := '1';
                        end if;
                    when wmem =>
                        if r.ready  = '1' then
                            vcmd.done := '1';
                        end if;
                                                
                    when stop =>
                        v.cmd_state := finished;
                        vcmd.done := '1';

                    when others =>  vcmd.done := '1';
                end case;
            end if;

            v.cmd_done := vcmd.done;
            
            if sr.cmd_done = '1' and vcmd.cmd /= stop then
                v.cmd_count := sr.cmd_count + 1;
                v.cmd_state := done;
            end if;

        when done =>
            vcmd.started := '0';
            vcmd.done    := '0';
            v.cmd_done   := '0';
            v.cmd_state  := idle;
            v.idle_count := 0;
        when others => null;

    end case;
    

    if pciin.syst.rst = '0' then

        vcmd.started := '0';
        vcmd.done    := '0';
        vcmd.estop   := 0;
        v.cmd_state := idle;
        v.idle_count := 0;
        v.cmd_count := 0;
        
    end if;

    cmd <= vcmd;
    srin <= v;
  end process;

  script_regs : process(pciin.syst.clk)
  begin
      if rising_edge(pciin.syst.clk) then
          sr <= srin;
      end if;
  end process;

-----------------------------------------
-- PCI MASTER
-----------------------------------------
  pci_master_comb : process(cmd, pciin)
      
      variable vpci : pci_type;
      variable v : reg_type;
      variable i,count,dataintrans : integer;
      variable status : status_type;
      variable ready,stop : std_logic;
      variable comm : std_logic_vector(3 downto 0);
      
  begin
      v := r; count := count+1; v.tocnt := 0; ready := '0'; stop := '0';
      v.pcien(0) := '1'; v.pcien(3 downto 1) := r.pcien(2 downto 0);

      if cmd.started = '1' and cmd.pci = true then
          if (r.running = '0' and r.state = idle) then
              v.address := cmd.addr(31 downto 2) & "00";
              status := OK;
              v.running := '1';
          end if;
          
          case cmd.pcicmd is
              
              when MEM_READ =>
                  v.burst := '0';
                  v.read := '1';
                  comm := MEM_READ;
                             
              when MEM_R_MULT =>
                  v.burst := '1';
                  v.read := '1';
                  comm := MEM_R_MULT;
                                  
              when MEM_R_LINE =>
                  v.burst := '1';
                  v.read := '1';
                  comm := MEM_R_LINE;
                                  
              when MEM_WRITE =>   
                  if cmd.len = 1 then
                      v.burst := '0';
                  else
                      v.burst := '1';
                  end if;
                  v.read := '0';
                  comm := MEM_WRITE;
                  
              when MEM_W_INV =>
                  v.burst := '1';
                  v.read := '0';
                  comm := MEM_W_INV;
                                  
              when CONF_READ =>
                  v.burst := '0';
                  v.read := '1';
                  comm := CONF_READ;
                             
              when CONF_WRITE =>
                  v.burst := '0';
                  v.read := '0';
                  comm := CONF_WRITE;
                              
              when others =>

          end case;
          
          v.address := (cmd.addr(31 downto 2) + conv_std_logic_vector(v.current_word,30)) & "00";
          comm := cmd.pcicmd;
          v.pci.ad.ad := cmd.data(v.current_word).data;
          v.burst := not r.last;
          stop := r.last;

      end if;

      v.pci.ad.par := xorv(r.pci.ad.ad & r.pci.ad.cbe);
      v.paren := r.read;

      if (pciin.ifc.devsel and not pciin.ifc.stop) = '1' and r.running = '1' then
          status := ERR;
      elsif r.tocnt = T_O then
          status := TIMEOUT;
      else
        status := OK;
      end if;

      case r.state is
          
          when idle =>
              v.ws_count := 0;
              v.ws_done  := false;
              
              v.pci.arb.req(slot) := not (r.running and r.pcien(1));
              v.pci.ifc.irdy := '1'; dataintrans := 0;
              if r.grant = '1' then
                  v.state := active; v.pci.ifc.frame := '0'; v.read := '0';
                  v.pcien(0) := '0'; v.pci.ad.ad := v.address; v.pci.ad.cbe := comm;
              end if;
              
          when active =>
              
              v.tocnt := r.tocnt + 1; v.pcien(0) := '0';
              
              v.pci.ad.cbe := cmd.data(v.current_word).cbe;
              v.pci.arb.req(slot) := not (r.burst and not pciin.ifc.frame);
              
              if (pciin.ifc.irdy or (pciin.ifc.trdy and pciin.ifc.stop)) = '0' then
                  if pciin.ifc.trdy = '0' then
                      v.current_word := r.current_word+1;
                      v.data := pciin.ad.ad;
                      v.pci.ad.ad := cmd.data(v.current_word).data;
                      v.pci.ad.cbe := cmd.data(v.current_word).cbe;
                      dataintrans := dataintrans+1;
                      v.ws_count := 0;
                      v.ws_done := false;
                  end if;
              end if;

              -- Wait state insertion
              if v.ws_done or r.ws_count = cmd.data(v.current_word).ws then
                  v.pci.ifc.irdy := '0';
                  v.ws_count := 0;
                  v.ws_done := true;
              else
                  v.pci.ifc.irdy := '1';
                  v.ws_count := r.ws_count + 1;
              end if;
              
              if pciin.ifc.devsel = '0' then v.tocnt := 0; end if;

              if pciin.ifc.stop = '0' then
                  v.pcien(0) := pciin.ifc.frame; stop := '1'; v.state := idle; v.pci.ifc.irdy := pciin.ifc.frame;
              end if;
              
              if (r.status /= OK or ((pciin.ifc.frame and not pciin.ifc.irdy and not pciin.ifc.trdy) = '1')) then
                  v.state := done; v.pci.ifc.irdy := '1'; v.pcien(0) := '1'; v.pci.arb.req(slot) := '1';
              end if;
              v.pci.ifc.frame := not (r.burst and not stop);
              
          when done =>
              v.running := '0'; ready := '1';
              if cmd.started = '0' and cmd.pci = true then
                  v.state := idle;
                  v.current_word := 0;
              end if;
              
          when others =>
              
      end case;

      v.grant := to_x01(pciin.ifc.frame) and to_x01(pciin.ifc.irdy) and not r.pci.arb.req(slot) and not to_x01(pciin.arb.gnt(slot));

      if pciin.syst.rst = '0' then
          v.ws_count := 0;
          v.ws_done  := false;
          v.pcien := (others => '1');
          v.state := idle;
          v.read := '0';
          v.burst := '0';
          v.grant := '0';
          v.address := (others => '0');
          v.data := (others => '0');
          v.current_word := 0;
          v.running := '0';
          v.pci := pci_idle;
      end if;

      v.ready  := ready;
      v.status := status;
      rin <= v;
      
  end process;

  pci_master_reg : process(pciin.syst)
      
      file writefile : text;
      variable L : line;
      variable datahex : string(1 to 8);
      variable count : integer;
      
  begin
      
      if pciin.syst.rst = '0' then
         
          r.last <= '0';
          r.f_open <= '0';

          r.pcien <= (others => '1');
          r.state <= idle;
          r.read <= '0';
          r.burst <= '0';
          r.grant <= '0';
          r.address <= (others => '0');
          r.data <= (others => '0');
          r.current_word <= 0;
          r.running <= '0';
          r.pci <= pci_idle;
          
      elsif rising_edge(pciin.syst.clk) then

          r <= rin;

          if r.state = active and rin.pci.ifc.irdy = '0' then

              if cmd.len = 2 then
                  if rin.current_word = 1 then
                      r.last <= '1';
                      r.pci.ifc.frame <= '1';
                      r.running <= '0';
                  else
                      r.last <= '0';
                  end if;
              elsif cmd.len = 1 or r.current_word >= (cmd.len-2) then
                  r.last <= '1';
                  r.pci.ifc.frame <= '1';
                  r.running <= '0';
              end if;
              
          else
              r.last <= '0';
          end if;

          case r.state is
              
              when idle =>
                  count := 0;
                  
                  if cmd.check = 2 and (cmd.started and not r.f_open) = '1' then
                      file_open(writefile, cmd.file1(1 to strlen(cmd.file1)), write_mode);
                      r.f_open <= '1';
                  end if;
                  
              when active =>
                  if (pciin.ifc.trdy or pciin.ifc.irdy) = '0' then

                      if cmd.check = 2 then
                          write(L,printhex(pciin.ad.ad,32));
                          writeline(writefile,L);

                      elsif cmd.check = 1 then
                          if (pciin.ad.ad and not cbe2mask(cmd.data(count).cbe)) /= (cmd.data(count).data and not cbe2mask(cmd.data(count).cbe)) then
                              if dbglevel >= 1 then
                                  printf("Comparision error at data phase: %d",count+1);
                                  printf("   Expected data: %d", cmd.data(count).data);
                                  printf("   Expected cbe: %d", to_integer(unsigned(cmd.data(count).cbe)));
                                  printf("   Compared data: %d", pciin.ad.ad);
                                  printf("");

                                  assert cmd.estop /= 1
                                      report "Simulation ended due to data compare failure!"
                                      severity FAILURE;
                                  
                              end if;
                          end if;
                  
                      end if;
                      
                      count := count + 1;
                      
                  end if;
                  
                  if cmd.check = 2 and rin.state = done then
                      file_close(writefile);
                      r.f_open <= '0';
                  end if;
                  
              when others =>
          end case;
          
      end if;
      
  end process;

  pciout.ad.ad     <= r.pci.ad.ad     after tval when (r.read or r.pcien(0)) = '0'  else (others => 'Z') after tval;
  pciout.ad.cbe    <= r.pci.ad.cbe    after tval when r.pcien(0) = '0'              else (others => 'Z') after tval;
  pciout.ad.par    <= r.pci.ad.par    after tval when (r.paren or r.pcien(1)) = '0' else 'Z' after tval;
  pciout.ifc.frame <= r.pci.ifc.frame after tval when r.pcien(0) = '0'              else 'Z' after tval;
  pciout.ifc.irdy  <= r.pci.ifc.irdy  after tval when r.pcien(1) = '0'              else 'Z' after tval;
  pciout.err.perr  <= r.pci.err.perr  after tval when r.pcien(2) = '0'              else 'Z' after tval;
  pciout.err.serr  <= r.pci.err.serr  after tval when r.pcien(2) = '0'              else 'Z' after tval;
  pciout.arb.req(slot) <= r.pci.arb.req(slot) after tval;

end;

-- pragma translate_on
