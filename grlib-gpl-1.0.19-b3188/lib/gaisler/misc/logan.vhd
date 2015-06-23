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
-- Entity: 	logan
-- File:	logan.vhd
-- Author:	Kristoffer Carlsson, Gaisler Research
-- Description:	On-chip logic analyzer IP core
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library grlib;
use grlib.amba.all;
use grlib.stdlib.all;
use grlib.devices.all;
library techmap;
use techmap.gencomp.all;

entity logan is
  generic (
    dbits       : integer range 0  to 256 := 32;              -- Number of traced signals
    depth       : integer range 256 to 16384 := 1024;         -- Depth of trace buffer
    trigl       : integer range 1 to 63 := 1;                 -- Number of trigger levels
    usereg      : integer range 0 to 1 := 1;                  -- Use input register
    usequal     : integer range 0 to 1 := 0;                  -- Use qualifer bit
    usediv      : integer range 0 to 1 := 1;                  -- Enable/disable div counter
    pindex      : integer := 0;
    paddr       : integer := 0;
    pmask       : integer := 16#F00#;
    memtech     : integer := DEFMEMTECH);                           
  port (
    rstn        : in  std_logic;                              -- Synchronous reset
    clk         : in  std_logic;                              -- System clock 
    tclk        : in  std_logic;                              -- Trace clock
    apbi        : in  apb_slv_in_type;                        -- APB in record
    apbo        : out apb_slv_out_type;                       -- APB out record
    signals     : in  std_logic_vector(dbits - 1 downto 0));  -- Traced signals
end logan;


architecture rtl of logan is
  
  constant REVISION : amba_version_type := 0;
  constant pconfig : apb_config_type := (
    0 => ahb_device_reg ( VENDOR_GAISLER, GAISLER_LOGAN, 0, REVISION, 0),
    1 => apb_iobar(paddr, pmask));

  constant abits: integer := 8 + log2x(depth/256 - 1);
  constant az   : std_logic_vector(abits-1 downto 0) := (others => '0');
  constant dz   : std_logic_vector(dbits-1 downto 0) := (others => '0');
  
  type trig_cfg_type is record         
      pattern    : std_logic_vector(dbits-1 downto 0);           -- Pattern to trig on
      mask       : std_logic_vector(dbits-1 downto 0);           -- trigger mask
      count      : std_logic_vector(5 downto 0);                 -- match counter
      eq         : std_ulogic;                                   -- Trig on match or no match?
  end record;

  type trig_cfg_arr is array (0 to trigl-1) of trig_cfg_type;

  type reg_type is record
       armed       : std_ulogic;
       trig_demet  : std_ulogic;
       trigged     : std_ulogic;
       fin_demet   : std_ulogic;
       finished    : std_ulogic;
       qualifier   : std_logic_vector(7 downto 0);
       qual_val    : std_ulogic;
       divcount    : std_logic_vector(15 downto 0);
       counter     : std_logic_vector(abits-1 downto 0);
       page        : std_logic_vector(3 downto 0);
       trig_conf   : trig_cfg_arr;
  end record;

  type trace_reg_type is record
       armed       : std_ulogic;
       arm_demet   : std_ulogic;
       trigged     : std_ulogic;
       finished    : std_ulogic;
       sample      : std_ulogic;
       divcounter  : std_logic_vector(15 downto 0);
       match_count : std_logic_vector(5 downto 0);
       counter     : std_logic_vector(abits-1 downto 0);
       curr_tl     : integer range 0 to trigl-1;
       w_addr      : std_logic_vector(abits-1 downto 0);
  end record;

  signal r_addr         : std_logic_vector(13 downto 0);
  signal bufout         : std_logic_vector(255 downto 0);
  signal r_en           : std_ulogic;
  signal r, rin         : reg_type;
  signal tr, trin       : trace_reg_type;
  signal sigreg         : std_logic_vector(dbits-1 downto 0);
  signal sigold         : std_logic_vector(dbits-1 downto 0);

begin

  bufout(255 downto dbits) <= (others => '0');
  
  -- Combinatorial process for AMBA clock domain
  comb1: process(rstn, apbi, r, tr, bufout)

    variable v              : reg_type;
    variable rdata          : std_logic_vector(31 downto 0);
    variable tl             : integer range 0 to trigl-1;
    variable pattern, mask  : std_logic_vector(255 downto 0);
    
  begin

    v := r;
    rdata := (others => '0'); tl := 0; 
    pattern := (others => '0'); mask := (others => '0');

    -- Two stage synch
    v.trig_demet := tr.trigged;
    v.trigged := r.trig_demet;
    v.fin_demet := tr.finished;
    v.finished := r.fin_demet;

    if r.finished = '1' then
      v.armed := '0';
    end if;
        
    r_en <= '0';
    
    -- Read/Write --
    if apbi.psel(pindex) = '1' then
      
      -- Write
      if apbi.pwrite = '1' and apbi.penable = '1' then
        
        -- Only conf area writeable
        if apbi.paddr(15) = '0' then
          
          -- pattern/mask
          if apbi.paddr(14 downto 13) = "11" then
            
            tl                              := conv_integer(apbi.paddr(11 downto 6));
            pattern(dbits-1 downto 0)       := v.trig_conf(tl).pattern;
            mask(dbits-1 downto 0)          := v.trig_conf(tl).mask;
            
            case apbi.paddr(5 downto 2) is
              
              when "0000" => pattern(31 downto 0)     := apbi.pwdata;
              when "0001" => pattern(63 downto 32)    := apbi.pwdata;
              when "0010" => pattern(95 downto 64)    := apbi.pwdata;
              when "0011" => pattern(127 downto 96)   := apbi.pwdata;
              when "0100" => pattern(159 downto 128)  := apbi.pwdata;
              when "0101" => pattern(191 downto 160)  := apbi.pwdata;
              when "0110" => pattern(223 downto 192)  := apbi.pwdata;
              when "0111" => pattern(255 downto 224)  := apbi.pwdata;

              when "1000" => mask(31 downto 0)        := apbi.pwdata;
              when "1001" => mask(63 downto 32)       := apbi.pwdata;
              when "1010" => mask(95 downto 64)       := apbi.pwdata;
              when "1011" => mask(127 downto 96)      := apbi.pwdata;
              when "1100" => mask(159 downto 128)     := apbi.pwdata;
              when "1101" => mask(191 downto 160)     := apbi.pwdata;
              when "1110" => mask(223 downto 192)     := apbi.pwdata;
              when "1111" => mask(255 downto 224)     := apbi.pwdata;
                             
              when others => null;

            end case;

            -- write back updated pattern/mask
            v.trig_conf(tl).pattern := pattern(dbits-1 downto 0);
            v.trig_conf(tl).mask    := mask(dbits-1 downto 0);
            
            -- count/eq 
          elsif apbi.paddr(14 downto 13) = "01" then
            tl                              := conv_integer(apbi.paddr(7 downto 2));
            v.trig_conf(tl).count           := apbi.pwdata(6 downto 1);
            v.trig_conf(tl).eq              := apbi.pwdata(0);

            -- arm/reset
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00000" then
            v.armed := apbi.pwdata(0);

            -- Page reg
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00010" then
            v.page := apbi.pwdata(3 downto 0);

            -- Trigger counter
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00011" then
            v.counter := apbi.pwdata(abits-1 downto 0);
          
            -- div count
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00100" then
            v.divcount := apbi.pwdata(15 downto 0);

           -- qualifier bit
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00101" then
            v.qualifier := apbi.pwdata(7 downto 0);
            v.qual_val  := apbi.pwdata(8);
          end if;
        end if;
        
        -- end write
        
        
        -- Read
      else

        -- Read config/status area
        if apbi.paddr(15) = '0' then

          -- pattern/mask 
          if apbi.paddr(14 downto 13) = "11" then

            tl                              := conv_integer(apbi.paddr(11 downto 6));
            pattern(dbits-1 downto 0)       := v.trig_conf(tl).pattern;
            mask(dbits-1 downto 0)          := v.trig_conf(tl).mask;

            case apbi.paddr(5 downto 2) is
              when "0000" => rdata   := pattern(31 downto 0);
              when "0001" => rdata   := pattern(63 downto 32);
              when "0010" => rdata   := pattern(95 downto 64);
              when "0011" => rdata   := pattern(127 downto 96);
              when "0100" => rdata   := pattern(159 downto 128);
              when "0101" => rdata   := pattern(191 downto 160);
              when "0110" => rdata   := pattern(223 downto 192);
              when "0111" => rdata   := pattern(255 downto 224);
                             
              when "1000" => rdata   := mask(31 downto 0);
              when "1001" => rdata   := mask(63 downto 32);
              when "1010" => rdata   := mask(95 downto 64);
              when "1011" => rdata   := mask(127 downto 96);
              when "1100" => rdata   := mask(159 downto 128);
              when "1101" => rdata   := mask(191 downto 160);
              when "1110" => rdata   := mask(223 downto 192);
              when "1111" => rdata   := mask(255 downto 224);

              when others => rdata  := (others => '0');
            end case;
            
            -- count/eq
          elsif apbi.paddr(14 downto 13) = "01" then
            tl                     := conv_integer(apbi.paddr(7 downto 2));
            rdata(6 downto 1)      := v.trig_conf(tl).count;
            rdata(0)               := v.trig_conf(tl).eq;
            
            -- status
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00000" then
            rdata := conv_std_logic_vector(usereg,1) & conv_std_logic_vector(usequal,1) &
                     r.armed & r.trigged &
                     conv_std_logic_vector(dbits,8)&
                     conv_std_logic_vector(depth-1,14)&
                     conv_std_logic_vector(trigl,6);

            -- trace buffer index
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00001" then
            rdata(abits-1 downto 0) := tr.w_addr(abits-1 downto 0);

            -- page reg
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00010" then
            rdata(3 downto 0) := r.page;
            
            -- trigger counter
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00011" then
            rdata(abits-1 downto 0) := r.counter;

            -- divcount
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00100" then
            rdata(15 downto 0) := r.divcount;

            -- qualifier
          elsif apbi.paddr(14 downto 13)&apbi.paddr(4 downto 2) = "00101" then
            rdata(7 downto 0) := r.qualifier;
            rdata(8) := r.qual_val;
          end if;
          
          
          -- Read from trace buffer
        else

          -- address always r.page & apbi.paddr(14 downto 5)

          r_en        <= '1';
          
          -- Select word from pattern
          case apbi.paddr(4 downto 2) is
          when "000" => rdata   := bufout(31 downto 0);
          when "001" => rdata   := bufout(63 downto 32);
          when "010" => rdata   := bufout(95 downto 64);
          when "011" => rdata   := bufout(127 downto 96);
          when "100" => rdata   := bufout(159 downto 128);
          when "101" => rdata   := bufout(191 downto 160);
          when "110" => rdata   := bufout(223 downto 192);
          when "111" => rdata   := bufout(255 downto 224);
          when others => rdata := (others => '0');
          end case;
          
        end if;
        
      end if; -- end read

    end if;

    if rstn = '0' then
      v.armed := '0'; v.trigged := '0'; v.finished := '0'; v.trig_demet := '0'; v.fin_demet := '0';
      v.counter := (others => '0');
      v.divcount := X"0001";
      v.qualifier := (others => '0');
      v.qual_val := '0';
      v.page := (others => '0');
    end if;
    
    apbo.prdata <= rdata;
    rin <= v;
  end process;


  -- Combinatorial process for trace clock domain
  comb2 : process (rstn, tr, r, sigreg)

    variable v  : trace_reg_type;

  begin
    v := tr;
    
    v.sample := '0';
    if tr.armed = '0' then 
      v.trigged := '0'; v.counter := (others => '0'); v.curr_tl := 0;
    end if;

    -- Synch arm signal
    v.arm_demet := r.armed;
    v.armed := tr.arm_demet;

    if tr.finished = '1' then
      v.finished := tr.armed;
    end if;
  
    -- Trigger --
    if tr.armed = '1' and tr.finished = '0' then

      if usediv = 1 then
        if tr.divcounter = X"0000" then
          v.divcounter := r.divcount-1;
          if usequal = 0 or sigreg(conv_integer(r.qualifier)) = r.qual_val then
            v.sample := '1';
          end if;
        else
          v.divcounter := v.divcounter - 1;
        end if;
      else
        v.sample := '1';
      end if;

      if tr.sample = '1' then v.w_addr := tr.w_addr + 1; end if;
      
      if tr.trigged = '1' and tr.sample = '1' then

        if tr.counter = r.counter then
          v.trigged := '0';
          v.sample := '0';
          v.finished := '1';
          v.counter := (others => '0');
        else v.counter := tr.counter + 1; end if;

      else
    
        -- match?
        if ((sigreg xor r.trig_conf(tr.curr_tl).pattern) and r.trig_conf(tr.curr_tl).mask) = dz then

          -- trig on equal
          if r.trig_conf(tr.curr_tl).eq = '1' then
            
            if tr.match_count /= r.trig_conf(tr.curr_tl).count then
              v.match_count := tr.match_count + 1;
            else
              
              -- final match?
              if tr.curr_tl = trigl-1 then
                v.trigged := '1';
              else
                v.curr_tl := tr.curr_tl + 1;
              end if;
              
            end if;
            
          end if;

        else -- not a match

          -- trig on inequal
          if r.trig_conf(tr.curr_tl).eq = '0' then

            if tr.match_count /= r.trig_conf(tr.curr_tl).count then
              v.match_count := tr.match_count + 1;
            else
              
              -- final match?
              if tr.curr_tl = trigl-1 then
                v.trigged := '1';
              else
                v.curr_tl := tr.curr_tl + 1;
              end if;
              
            end if;
          end if;
        end if; 
      end if; 
    end if;
    
    -- end trigger

    if rstn = '0' then
      v.armed := '0'; v.trigged := '0'; v.sample := '0'; v.finished := '0'; v.arm_demet := '0';
      v.curr_tl := 0;
      v.counter := (others => '0');
      v.divcounter := (others => '0');
      v.match_count := (others => '0');
      v.w_addr := (others => '0');
    end if;

    trin <= v;

  end process;

  -- clk traced signals through register to minimize fan out
  inreg: if usereg = 1 generate
    process (tclk)
    begin  
      if rising_edge(tclk) then 
        sigold <= sigreg;
        sigreg <= signals;     
      end if;
    end process;
  end generate;    

  noinreg: if usereg = 0 generate
    sigreg <= signals;
    sigold <= signals;
  end generate;    

  -- Update registers
  reg: process(clk)
  begin
    if rising_edge(clk) then r <= rin; end if;
  end process;
  
  treg: process(tclk)
  begin
    if rising_edge(tclk) then tr <= trin; end if;
  end process;

  r_addr    <= r.page & apbi.paddr(14 downto 5);
  
  trace_buf : syncram_2p
    generic map (tech => memtech, abits => abits, dbits => dbits)
    port map (clk, r_en, r_addr(abits-1 downto 0), bufout(dbits-1 downto 0),  -- read
              tclk, tr.sample, tr.w_addr, sigold);                            -- write

  apbo.pconfig <= pconfig;
  apbo.pindex  <= pindex;
  apbo.pirq    <= (others => '0');
  
end architecture;
