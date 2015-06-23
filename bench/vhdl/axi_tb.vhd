----------------------------------------------------------------------  
----  axi_tb                                                      ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    testbench for the AXI-Lite interface, functions are       ----
----    provided to read and write data                           ----
----    writes bus transfers to out/axi_output                    ----
----                                                              ----
----  Dependencies:                                               ----
----    - mod_sim_exp_core                                        ----
----                                                              ----
----  Authors:                                                    ----
----      - Geoffrey Ottoy, DraMCo research group                 ----
----      - Jonas De Craene, JonasDC@opencores.org                ---- 
----                                                              ---- 
---------------------------------------------------------------------- 
----                                                              ---- 
---- Copyright (C) 2011 DraMCo research group and OPENCORES.ORG   ---- 
----                                                              ---- 
---- This source file may be used and distributed without         ---- 
---- restriction provided that this copyright statement is not    ---- 
---- removed from the file and that any derivative work contains  ---- 
---- the original copyright notice and the associated disclaimer. ---- 
----                                                              ---- 
---- This source file is free software; you can redistribute it   ---- 
---- and/or modify it under the terms of the GNU Lesser General   ---- 
---- Public License as published by the Free Software Foundation; ---- 
---- either version 2.1 of the License, or (at your option) any   ---- 
---- later version.                                               ---- 
----                                                              ---- 
---- This source is distributed in the hope that it will be       ---- 
---- useful, but WITHOUT ANY WARRANTY; without even the implied   ---- 
---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ---- 
---- PURPOSE.  See the GNU Lesser General Public License for more ---- 
---- details.                                                     ---- 
----                                                              ---- 
---- You should have received a copy of the GNU Lesser General    ---- 
---- Public License along with this source; if not, download it   ---- 
---- from http://www.opencores.org/lgpl.shtml                     ---- 
----                                                              ---- 
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

entity axi_tb is
end axi_tb;

architecture arch of axi_tb is
  -- constants
  constant CLK_PERIOD : time := 10 ns;
  constant CORE_CLK_PERIOD : time := 4 ns;
  constant C_S_AXI_DATA_WIDTH : integer := 32;
  constant C_S_AXI_ADDR_WIDTH : integer := 32;
  
  file output : text open write_mode is "out/axi_output.txt";
  
  ------------------------------------------------------------------
  -- Core parameters
  ------------------------------------------------------------------
  constant C_NR_BITS_TOTAL   : integer := 1536;
  constant C_NR_STAGES_TOTAL : integer := 96;
  constant C_NR_STAGES_LOW   : integer := 32;
  constant C_SPLIT_PIPELINE  : boolean := true; 
  constant C_FIFO_AW         : integer := 7; -- set to log2( (maximum exponent width)/16 )
  constant C_MEM_STYLE       : string  := "generic"; -- xil_prim, generic, asym are valid options
  constant C_FPGA_MAN        : string  := "xilinx";  -- xilinx, altera are valid options
  constant C_BASEADDR        : std_logic_vector(0 to 31) := x"A0000000";
  constant C_HIGHADDR        : std_logic_vector(0 to 31) := x"A0007FFF";
  
  
  signal core_clk     : std_logic := '0';
  -------------------------
  -- AXI4lite interface
  -------------------------
  --- Global signals
  signal S_AXI_ACLK    : std_logic;
  signal S_AXI_ARESETN : std_logic;
  --- Write address channel
  signal S_AXI_AWADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_AWVALID : std_logic;
  signal S_AXI_AWREADY : std_logic;
  --- Write data channel
  signal S_AXI_WDATA  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_WVALID : std_logic;
  signal S_AXI_WREADY : std_logic;
  signal S_AXI_WSTRB  : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
  --- Write response channel
  signal S_AXI_BVALID : std_logic;
  signal S_AXI_BREADY : std_logic;
  signal S_AXI_BRESP  : std_logic_vector(1 downto 0);
  --- Read address channel
  signal S_AXI_ARADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
  signal S_AXI_ARVALID : std_logic;
  signal S_AXI_ARREADY : std_logic;
  --- Read data channel
  signal S_AXI_RDATA  : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
  signal S_AXI_RVALID : std_logic;
  signal S_AXI_RREADY : std_logic;
  signal S_AXI_RRESP  : std_logic_vector(1 downto 0);

begin

  ------------------------------------------
  -- Generate clk
  ------------------------------------------
  clk_process : process
  begin
    while (true) loop
      S_AXI_ACLK <= '0';
      wait for CLK_PERIOD/2;
      S_AXI_ACLK <= '1';
      wait for CLK_PERIOD/2;
    end loop;
  end process;
  
  core_clk_process : process
  begin
    while (true) loop
      core_clk <= '0';
      wait for CORE_CLK_PERIOD/2;
      core_clk <= '1';
      wait for CORE_CLK_PERIOD/2;
    end loop;
  end process;
  

  stim_proc : process
  
    variable Lw : line;
  
    procedure waitclk(n : natural := 1) is
    begin
      for i in 1 to n loop
        wait until rising_edge(S_AXI_ACLK);
      end loop;
    end waitclk;
    
    procedure axi_write( address : std_logic_vector(31 downto 0);
                         data    : std_logic_vector(31 downto 0) ) is 
      variable counter : integer := 0;
    begin
      -- place address on the bus
      wait until rising_edge(S_AXI_ACLK);
      S_AXI_AWADDR <= address;
      S_AXI_AWVALID <= '1';
      S_AXI_WDATA <= data;
      S_AXI_WVALID <= '1';
      S_AXI_WSTRB <= "1111";
      while (counter /= 2) loop -- wait for slave response
        wait until rising_edge(S_AXI_ACLK); 
        if (S_AXI_AWREADY='1') then
          S_AXI_AWVALID <= '0';
          counter := counter+1;
        end if;
        if (S_AXI_WREADY='1') then
          S_AXI_WVALID <= '0';
          counter := counter+1;
        end if;
      end loop;
      S_AXI_BREADY <= '1';
      if S_AXI_BVALID/='1' then
        wait until S_AXI_BVALID='1';
      end if;
      
      write(Lw, string'("Wrote "));
      hwrite(Lw, data);
      write(Lw, string'(" to   "));
      hwrite(Lw, address);
      
      if (S_AXI_BRESP /= "00") then
        write(Lw, string'("   --> Error! Status: "));
        write(Lw, S_AXI_BRESP);
      end if;
      writeline(output, Lw);
      
      wait until rising_edge(S_AXI_ACLK);
      S_AXI_BREADY <= '0';
    end axi_write;
    
    procedure axi_read( address  : std_logic_vector(31 downto 0) ) is 
    begin
      -- place address on the bus
      wait until rising_edge(S_AXI_ACLK);
      S_AXI_ARADDR <= address;
      S_AXI_ARVALID <= '1';
      wait until S_AXI_ARREADY='1';
      wait until rising_edge(S_AXI_ACLK); 
      S_AXI_ARVALID <= '0';
      -- wait for read data
      S_AXI_RREADY <= '1';
      wait until S_AXI_RVALID='1';
      wait until rising_edge(S_AXI_ACLK);
      
      write(Lw, string'("Read  "));
      hwrite(Lw, S_AXI_RDATA);
      write(Lw, string'(" from "));
      hwrite(Lw, address);
      
      if (S_AXI_RRESP /= "00") then
        write(Lw, string'("   --> Error! Status: "));
        write(Lw, S_AXI_RRESP);
      end if;
      writeline(output, Lw); 
      S_AXI_RREADY <= '0';
  
      --assert false report "Wrote " & " to " & " Status=" & to_string(S_AXI_BRESP) severity note;
    end axi_read;
    
 
  begin
  
    write(Lw, string'("----------------------------------------------"));
    writeline(output, Lw);
    write(Lw, string'("--            AXI BUS SIMULATION            --"));
    writeline(output, Lw);
    write(Lw, string'("----------------------------------------------"));
    writeline(output, Lw);
    S_AXI_AWADDR <= (others=>'0');
    S_AXI_AWVALID <= '0';
    S_AXI_WDATA <= (others=>'0');
    S_AXI_WVALID <= '0';
    S_AXI_WSTRB <= (others=>'0');
    S_AXI_BREADY <= '0';
    S_AXI_ARADDR <= (others=>'0');
    S_AXI_ARVALID <= '0';
    S_AXI_RREADY <= '0';
    
    S_AXI_ARESETN <= '0';
    waitclk(10);
    S_AXI_ARESETN <= '1';
    waitclk(20);
    
    axi_write(x"A0000000", x"11111111");
    axi_read(x"A0000000");
    axi_write(x"A0001000", x"01234567");
    axi_read(x"A0001000");
    axi_write(x"A0002000", x"AAAAAAAA");
    axi_read(x"A0002000");
    axi_write(x"A0003000", x"BBBBBBBB");
    axi_read(x"A0003000");
    axi_write(x"A0004000", x"CCCCCCCC");
    axi_read(x"A0004000");
    axi_write(x"A0005000", x"DDDDDDDD");
    axi_read(x"A0005000");
    axi_write(x"A0006000", x"EEEEEEEE");
    axi_read(x"A0006000");
    axi_write(x"A0007000", x"FFFFFFFF");
    axi_read(x"A0007000");
    axi_write(x"A0008000", x"22222222");
    axi_read(x"A0008000");
    axi_write(x"A0009000", x"33333333");
    axi_read(x"A0009000");
    axi_write(x"A000A000", x"44444444");
    axi_read(x"A000A000");
    waitclk(100);
    
    assert false report "End of simulation" severity failure;
    
  end process;


  -------------------------
  -- Unit Under Test
  -------------------------
  uut : entity work.msec_ipcore_axilite
  generic map(
    C_NR_BITS_TOTAL   => C_NR_BITS_TOTAL,
    C_NR_STAGES_TOTAL => C_NR_STAGES_TOTAL,
    C_NR_STAGES_LOW   => C_NR_STAGES_LOW,
    C_SPLIT_PIPELINE  => C_SPLIT_PIPELINE,
    C_FIFO_AW         => C_FIFO_AW,
    C_MEM_STYLE       => C_MEM_STYLE, -- xil_prim, generic, asym are valid options
    C_FPGA_MAN        => C_FPGA_MAN,   -- xilinx, altera are valid options
    C_BASEADDR        => C_BASEADDR,
    C_HIGHADDR        => C_HIGHADDR
  )
  port map(
    --USER ports
    core_clk => core_clk,
    -------------------------
    -- AXI4lite interface
    -------------------------
    --- Global signals
    S_AXI_ACLK    => S_AXI_ACLK,
    S_AXI_ARESETN => S_AXI_ARESETN,
    --- Write address channel
    S_AXI_AWADDR  => S_AXI_AWADDR,
    S_AXI_AWVALID => S_AXI_AWVALID,
    S_AXI_AWREADY => S_AXI_AWREADY,
    --- Write data channel
    S_AXI_WDATA  => S_AXI_WDATA,
    S_AXI_WVALID => S_AXI_WVALID,
    S_AXI_WREADY => S_AXI_WREADY,
    S_AXI_WSTRB  => S_AXI_WSTRB,
    --- Write response channel
    S_AXI_BVALID => S_AXI_BVALID,
    S_AXI_BREADY => S_AXI_BREADY,
    S_AXI_BRESP  => S_AXI_BRESP,
    --- Read address channel
    S_AXI_ARADDR  => S_AXI_ARADDR,
    S_AXI_ARVALID => S_AXI_ARVALID,
    S_AXI_ARREADY => S_AXI_ARREADY,
    --- Read data channel
    S_AXI_RDATA  => S_AXI_RDATA,
    S_AXI_RVALID => S_AXI_RVALID,
    S_AXI_RREADY => S_AXI_RREADY,
    S_AXI_RRESP  => S_AXI_RRESP
  );

end arch;

