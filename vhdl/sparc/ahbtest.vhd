



----------------------------------------------------------------------------
--  This file is a part of the LEON VHDL model
--  Copyright (C) 1999  European Space Agency (ESA)
--
--  This library is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2 of the License, or (at your option) any later version.
--
--  See the file COPYING.LGPL for the full details of the license.



library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

use work.amba.all;
use work.leon_iface.all;


entity ahbtest is
   port (
      rst             : in  std_logic;
      clk             : in  clk_type;

      -- peripheral bus
--      pbi             : in  APB_Slv_In_Type;   -- peripheral bus in
--      pbo             : out APB_Slv_Out_Type;  -- peripheral bus out
--      irq             : out std_logic;         -- interrupt request

--      ahbi1  : in  ahb_mst_in_type;   -- dma port in
--      ahbo1 : out ahb_mst_out_type;  -- dma port out
--      ahbi2  : in  ahb_mst_in_type;   -- dma port in
--      ahbo2 : out ahb_mst_out_type;  -- dma port out
      ahbi : in  ahb_slv_in_type;
      ahbo : out ahb_slv_out_type

       
      );
end;      

architecture struct of ahbtest is
type slavestate is (idle, error, split, retry, ws1);
type reg_type is record
  haddr   : std_logic_vector(31 downto 0);   -- address bus
  hsel    : std_logic;
  htrans  : std_logic_vector(1 downto 0);    -- transfer type 
  hresp   : std_logic_vector(1 downto 0);    -- response type 
  hmaster : std_logic_vector(3 downto 0);    -- master
  smaster : std_logic_vector(3 downto 0);    -- split master
  hwrite  : std_logic;  		     -- read/write
  hready  : std_logic;  		     -- ready
  splitcnt : natural;
  ss : slavestate;
end record;

signal r, rin : reg_type;

begin

  comb : process(rst, ahbi, r)
  variable v : reg_type;
  variable prdata : std_logic_vector(31 downto 0);
  variable vsplit : std_logic_vector(15 downto 0);
  begin

    v := r; v.hready := '0'; vsplit := (others => '0');

    if r.splitcnt > 0 then 
      v.splitcnt := r.splitcnt -1;
      if v.splitcnt = 0 then 
	vsplit(conv_integer(unsigned(r.smaster))) := '1';
      end if;
    end if;

    if (ahbi.hready = '1') then
      v.hready := '0'; v.haddr  := ahbi.haddr; v.hwrite := ahbi.hwrite;
      v.hsel := ahbi.hsel; v.hwrite := ahbi.hwrite;
      v.hmaster := ahbi.hmaster; 
    end if;

    if (ahbi.hsel and ahbi.hready) = '1' then
      if ((ahbi.htrans = HTRANS_NONSEQ) or (ahbi.htrans = HTRANS_SEQ))
	  and (r.hresp = HRESP_OKAY)
      then
	  if (ahbi.haddr(5 downto 4) = "01") and ((ahbi.haddr(3) xor ahbi.haddr(2)) = '1') 
	  then v.hresp := HRESP_RETRY; v.ss := retry;
	  elsif (ahbi.haddr(5 downto 4) = "10") and ((ahbi.haddr(3) xor ahbi.haddr(2)) = '1') 
	  then v.hresp := HRESP_SPLIT; v.ss := split;
	  elsif (ahbi.haddr(5 downto 4) = "11") and ((ahbi.haddr(3) xor ahbi.haddr(2)) = '1') 
	  then v.hresp := HRESP_ERROR; v.ss := error;
	  else 
	    v.hresp := HRESP_OKAY;
	    if (ahbi.haddr(3 downto 2) = "00") then v.ss := ws1;
	    else v.hready := '1'; end if;
	  end if;
      else
	  if (r.hresp = HRESP_SPLIT) and (r.splitcnt > 2) then
	    v.ss := split; v.hresp := HRESP_SPLIT;
	  else
	    v.hresp := HRESP_OKAY; v.ss := idle; v.hready := '1';
	  end if;
      end if;
    end if;
    case r.ss is
    when idle =>
    when retry =>
	  v.hresp := HRESP_RETRY; v.ss := idle; v.hready := '1';
    when split =>
	  v.hresp := HRESP_SPLIT; v.ss := idle; v.hready := '1';
	  v.smaster := r.hmaster; 
	  if r.splitcnt = 0 then v.splitcnt := 15; end if;
    when error =>
	  v.hresp := HRESP_ERROR; v.ss := idle; v.hready := '1';
    when ws1 =>
	  v.hresp := HRESP_OKAY; v.ss := idle; v.hready := '1';
    end case;

    ahbo.hresp  <= r.hresp;
    ahbo.hready <= r.hready;
    ahbo.hrdata <= r.haddr;
    ahbo.hsplit <= vsplit;

    if rst = '0' then
      v.hready := '1'; v.hsel := '0'; v.hresp := HRESP_OKAY;
      v.haddr := (others => '0');
    end if;

    rin <= v;
  end process;

--    ahbo1.haddr   <= (others => '0') ;
--    ahbo1.htrans  <= HTRANS_IDLE;
--    ahbo1.hbusreq <= '0';
--    ahbo1.hwdata  <= (others => '0');
--    ahbo1.hlock   <= '0';
--    ahbo1.hwrite  <= '0';
--    ahbo1.hsize   <= HSIZE_WORD;
--    ahbo1.hburst  <= HBURST_SINGLE;
--    ahbo1.hprot   <= (others => '0');      


  regs : process(clk)
  begin if rising_edge(clk) then r <= rin; end if; end process;

end;
