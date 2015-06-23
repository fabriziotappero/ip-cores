----------------------------------------------------------------------  
----  msec_axi_tb                                                 ---- 
----                                                              ---- 
----  This file is part of the                                    ----
----    Modular Simultaneous Exponentiation Core project          ---- 
----    http://www.opencores.org/cores/mod_sim_exp/               ---- 
----                                                              ---- 
----  Description                                                 ---- 
----    testbench for the AXI-Lite interface of the modular       ----
----    simultaneous exponentiation core. Performs some           ----
----    exponentiations to verify the design                      ----
----    Takes input parameters from in/sim_input.txt en writes    ----
----    result and output to out/axi_sim_output.txt. The AXI bus  ----
----    transfers ar written to out/axi_bus_output                ----
----                                                              ----
----  Dependencies:                                               ----
----    - msec_ipcore_axilite                                     ----
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
use ieee.std_logic_arith.all;

library std;
use std.textio.all;

library ieee;
use ieee.std_logic_textio.all;

entity msec_axi_tb is
end msec_axi_tb;

architecture arch of msec_axi_tb is
  -- constants
  constant CLK_PERIOD : time := 10 ns;
  constant CORE_CLK_PERIOD : time := 4 ns;
  constant C_S_AXI_DATA_WIDTH : integer := 32;
  constant C_S_AXI_ADDR_WIDTH : integer := 32;
  
  file output : text open write_mode is "out/axi_sim_output.txt";
  file axi_dbg : text open write_mode is "out/axi_bus_output.txt";
  file input  : text open read_mode is "src/sim_input.txt";

  ------------------------------------------------------------------
  -- Core parameters
  ------------------------------------------------------------------
  constant C_NR_BITS_TOTAL   : integer := 1536;
  constant C_NR_STAGES_TOTAL : integer := 96;
  constant C_NR_STAGES_LOW   : integer := 32;
  constant C_SPLIT_PIPELINE  : boolean := true; 
  constant C_FIFO_AW         : integer := 7; -- set to log2( (maximum exponent width)/16 )
  constant C_MEM_STYLE       : string  := "xil_prim"; -- xil_prim, generic, asym are valid options
  constant C_FPGA_MAN        : string  := "xilinx";  -- xilinx, altera are valid options
  constant C_BASEADDR        : std_logic_vector(0 to 31) := x"A0000000";
  constant C_HIGHADDR        : std_logic_vector(0 to 31) := x"A0007FFF";
  
  -- extra calculated constants
  constant NR_BITS_LOW : integer := (C_NR_BITS_TOTAL/C_NR_STAGES_TOTAL)*C_NR_STAGES_LOW;
  constant NR_BITS_HIGH : integer := C_NR_BITS_TOTAL-NR_BITS_LOW;

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
  
  -- CORE control reg bits
  signal core_control_reg    : std_logic_vector(31 downto 0) := (others=>'0');
  signal core_start          : std_logic;
  signal core_exp_m          : std_logic;
  signal core_p_sel          : std_logic_vector(1 downto 0);
  signal core_dest_op_single : std_logic_vector(1 downto 0);
  signal core_x_sel_single   : std_logic_vector(1 downto 0);
  signal core_y_sel_single   : std_logic_vector(1 downto 0);
  signal core_modulus_sel    : std_logic;
  signal calc_time           : std_logic;
  signal IntrEvent           : std_logic;
  
begin

  -- map the core control bits to the core control register
  core_control_reg(31 downto 30) <= core_p_sel;
  core_control_reg(29 downto 28) <= core_dest_op_single;
  core_control_reg(27 downto 26) <= core_x_sel_single;
  core_control_reg(25 downto 24) <= core_y_sel_single;
  core_control_reg(23) <= core_start;
  core_control_reg(22) <= core_exp_m;
  core_control_reg(21) <= core_modulus_sel;

  ------------------------------------------
  -- Generate S_AXI_ACLK
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
    -- variables to read file
    variable L : line;
    variable Lw : line;
    variable La : line;
    
    -- constants for memory space selection
    constant op_modulus : std_logic_vector(2 downto 0) := "000";
    constant op_0 : std_logic_vector(2 downto 0) := "001";
    constant op_1 : std_logic_vector(2 downto 0) := "010";
    constant op_2 : std_logic_vector(2 downto 0) := "011";
    constant op_3 : std_logic_vector(2 downto 0) := "100";
    constant fifo : std_logic_vector(2 downto 0) := "101";
    constant control_reg : std_logic_vector(2 downto 0) := "110";
    
    procedure waitclk(n : natural := 1) is
    begin
      for i in 1 to n loop
        wait until rising_edge(S_AXI_ACLK);
      end loop;
    end waitclk;
    
    procedure axi_write( variable address : std_logic_vector(31 downto 0);
                         variable data    : std_logic_vector(31 downto 0) ) is 
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
      
      write(La, string'("Wrote "));
      hwrite(La, data);
      write(La, string'(" to   "));
      hwrite(La, address);
      
      if (S_AXI_BRESP /= "00") then
        write(La, string'("   --> Error! Status: "));
        write(La, S_AXI_BRESP);
      end if;
      writeline(axi_dbg, La);
      
      wait until rising_edge(S_AXI_ACLK);
      S_AXI_BREADY <= '0';
    end axi_write;
    
    procedure axi_read( variable address  : std_logic_vector(31 downto 0);
                        variable data : out std_logic_vector(31 downto 0) ) is 
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
      
      data := S_AXI_RDATA;
      write(La, string'("Read  "));
      hwrite(La, S_AXI_RDATA);
      write(La, string'(" from "));
      hwrite(La, address);
      
      if (S_AXI_RRESP /= "00") then
        write(La, string'("   --> Error! Status: "));
        write(La, S_AXI_RRESP);
      end if;
      writeline(axi_dbg, La); 
      S_AXI_RREADY <= '0';
  
      --assert false report "Wrote " & " to " & " Status=" & to_string(S_AXI_BRESP) severity note;
    end axi_read;
    
    procedure axi_write_control_reg is 
      variable address : std_logic_vector(31 downto 0);
      variable data    : std_logic_vector(31 downto 0);
    begin
      wait until rising_edge(S_AXI_ACLK);
      address := C_BASEADDR+x"00006000";
      data := core_control_reg;
      axi_write(address, data); 
    end axi_write_control_reg;
    
    procedure loadOp(constant op_sel : std_logic_vector(2 downto 0);
                    variable op_data : std_logic_vector(2047 downto 0)) is
      variable address : std_logic_vector(31 downto 0);
      variable zero    : std_logic_vector(31 downto 0) := (others=>'0');
    begin
      -- set the start address
      address := C_BASEADDR(0 to 15) & '0' & op_sel & "0000" & "000000" & "00";
      -- write operand per 32 bits
      for i in 0 to (C_NR_BITS_TOTAL/32)-1 loop
        case (core_p_sel) is
          when "11" =>
            axi_write(address, op_data(((i+1)*32)-1 downto (i*32)));
          when "01" =>
            if (i < 16) then axi_write(address, op_data(((i+1)*32)-1 downto (i*32)));
            else axi_write(address, zero); end if;
          when "10" =>
            if (i >= 16) then axi_write(address, op_data(((i-15)*32)-1 downto ((i-16)*32)));
            else axi_write(address, zero); end if;
          when others =>
            axi_write(address, zero);
        end case;
        -- next address is 32 further
        address := address + "100";
      end loop;
    end loadOp;
    
    procedure readOp(constant op_sel : std_logic_vector(2 downto 0);
                    variable op_data  : out std_logic_vector(2047 downto 0);
                    variable op_width : integer) is
      variable address : std_logic_vector(31 downto 0);
      variable data    : std_logic_vector(31 downto 0);
    begin
      -- set destination operand, cause only can readfrom destination operand
      case op_sel is
        when "001" => core_dest_op_single <= "00";
        when "010" => core_dest_op_single <= "01";
        when "011" => core_dest_op_single <= "10";
        when "100" => core_dest_op_single <= "11";
        when others => core_dest_op_single <= "00";
      end case;
      axi_write_control_reg;
      
      -- set the start address
      if (core_p_sel = "10") then
        address := C_BASEADDR(0 to 15) & '0' & op_sel & "0000" & "010000" & "00";
      else
        address := C_BASEADDR(0 to 15) & '0' & op_sel & "0000" & "000000" & "00";
      end if;
      -- read the data
      for i in 0 to (op_width/32)-1 loop
        axi_read(address, data);
        op_data(((i+1)*32)-1 downto (i*32)) := data;
        -- next address is 32 further
        address := address + "100";
      end loop;
    end readOp;
  
    procedure loadFifo(variable data : std_logic_vector(31 downto 0)) is
      variable address : std_logic_vector(31 downto 0);
    begin
      -- set the start address
      address := C_BASEADDR(0 to 15) & '0' & fifo & "0000" & "000000" & "00";
      axi_write(address, data);
    end loadFifo;
    
    function ToString(constant Timeval : time) return string is
      variable StrPtr : line;
    begin
      write(StrPtr,Timeval);
      return StrPtr.all;
    end ToString;
    
    
    variable base_width : integer;
    variable exponent_width : integer;
    variable g0 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable g1 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable e0 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable e1 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable m : std_logic_vector(2047 downto 0) := (others=>'0');
    variable R2 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable R : std_logic_vector(2047 downto 0) := (others=>'0');
    variable gt0 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable gt1 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable gt01 : std_logic_vector(2047 downto 0) := (others=>'0');
    variable one : std_logic_vector(2047 downto 0) := std_logic_vector(conv_unsigned(1, 2048));
    variable result : std_logic_vector(2047 downto 0) := (others=>'0');
    variable data_read : std_logic_vector(2047 downto 0) := (others=>'0');
    variable good_value : boolean;
    variable param_count : integer := 0;
    variable temp_data : std_logic_vector(31 downto 0);
    
    variable timer : time;
  begin
  
    write(Lw, string'("----------------------------------------------"));
    writeline(output, Lw);
    write(Lw, string'("--            AXI BUS SIMULATION            --"));
    writeline(output, Lw);
    write(Lw, string'("----------------------------------------------"));
    writeline(output, Lw);
    -- axi bus initialisation
    S_AXI_AWADDR <= (others=>'0');
    S_AXI_AWVALID <= '0';
    S_AXI_WDATA <= (others=>'0');
    S_AXI_WVALID <= '0';
    S_AXI_WSTRB <= (others=>'0');
    S_AXI_BREADY <= '0';
    S_AXI_ARADDR <= (others=>'0');
    S_AXI_ARVALID <= '0';
    S_AXI_RREADY <= '0';
    -- control signals initialisation
    core_start <= '0';
    core_exp_m <= '0';
    core_x_sel_single <= "00";
    core_y_sel_single <= "01";
    core_dest_op_single <= "01";
    core_p_sel <= "11";
    core_modulus_sel <= '0';
    -- reset
    S_AXI_ARESETN <= '0';
    waitclk(10);
    S_AXI_ARESETN <= '1';
    waitclk(20);
    
    
    while not endfile(input) loop
      readline(input, L); -- read next line
      next when L(1)='-'; -- skip comment lines
      -- read input values
      case param_count is
        when 0 => -- base width
          read(L, base_width, good_value);
          assert good_value report "Can not read base width" severity failure;
          assert false report "Simulating exponentiation" severity note;
          write(Lw, string'("----------------------------------------------"));
          writeline(output, Lw);
          write(Lw, string'("--              EXPONENTIATION              --"));
          writeline(output, Lw);
          write(Lw, string'("----------------------------------------------"));
          writeline(output, Lw);
          write(Lw, string'("----- Variables used:"));
          writeline(output, Lw);
          write(Lw, string'("base width: "));
          write(Lw, base_width);
          writeline(output, Lw);
          case (base_width) is
            when C_NR_BITS_TOTAL => when NR_BITS_HIGH => when NR_BITS_LOW =>
            when others => 
              write(Lw, string'("=> incompatible base width!!!")); writeline(output, Lw);
              assert false report "incompatible base width!!!" severity failure;
          end case;
          
        when 1 => -- exponent width
          read(L, exponent_width, good_value);
          assert good_value report "Can not read exponent width" severity failure;
          write(Lw, string'("exponent width: "));
          write(Lw, exponent_width);
          writeline(output, Lw);
          
        when 2 => -- g0
          hread(L, g0(base_width-1 downto 0), good_value);
          assert good_value report "Can not read g0! (wrong lenght?)" severity failure;
          write(Lw, string'("g0: "));
          hwrite(Lw, g0(base_width-1 downto 0));
          writeline(output, Lw);
          
        when 3 => -- g1
          hread(L, g1(base_width-1 downto 0), good_value);
          assert good_value report "Can not read g1! (wrong lenght?)" severity failure;
          write(Lw, string'("g1: "));
          hwrite(Lw, g1(base_width-1 downto 0));
          writeline(output, Lw);
          
        when 4 => -- e0
          hread(L, e0(exponent_width-1 downto 0), good_value);
          assert good_value report "Can not read e0! (wrong lenght?)" severity failure;
          write(Lw, string'("e0: "));
          hwrite(Lw, e0(exponent_width-1 downto 0));
          writeline(output, Lw);
          
        when 5 => -- e1
          hread(L, e1(exponent_width-1 downto 0), good_value);
          assert good_value report "Can not read e1! (wrong lenght?)" severity failure;
          write(Lw, string'("e1: "));
          hwrite(Lw, e1(exponent_width-1 downto 0));
          writeline(output, Lw);
          
        when 6 => -- m
          hread(L, m(base_width-1 downto 0), good_value);
          assert good_value report "Can not read m! (wrong lenght?)" severity failure;
          write(Lw, string'("m:  "));
          hwrite(Lw, m(base_width-1 downto 0));
          writeline(output, Lw);
          
        when 7 => -- R^2
          hread(L, R2(base_width-1 downto 0), good_value);
          assert good_value report "Can not read R2! (wrong lenght?)" severity failure;
          write(Lw, string'("R2: "));
          hwrite(Lw, R2(base_width-1 downto 0));
          writeline(output, Lw);
          
        when 8 => -- R
          hread(L, R(base_width-1 downto 0), good_value);
          assert good_value report "Can not read R! (wrong lenght?)" severity failure;
        
        when 9 => -- gt0
          hread(L, gt0(base_width-1 downto 0), good_value);
          assert good_value report "Can not read gt0! (wrong lenght?)" severity failure;
        
        when 10 => -- gt1
          hread(L, gt1(base_width-1 downto 0), good_value);
          assert good_value report "Can not read gt1! (wrong lenght?)" severity failure;
        
        when 11 => -- gt01
          hread(L, gt01(base_width-1 downto 0), good_value);
          assert good_value report "Can not read gt01! (wrong lenght?)" severity failure;
          
          -- select pipeline for all computations
          ----------------------------------------
          writeline(output, Lw);
          write(Lw, string'("----- Selecting pipeline: "));
          writeline(output, Lw);
          case (base_width) is
            when C_NR_BITS_TOTAL =>  core_p_sel <= "11"; write(Lw, string'("  Full pipeline selected"));
            when NR_BITS_HIGH =>  core_p_sel <= "10"; write(Lw, string'("  Upper pipeline selected"));
            when NR_BITS_LOW  =>  core_p_sel <= "01"; write(Lw, string'("  Lower pipeline selected"));
            when others =>
              write(Lw, string'("  Invallid bitwidth for design"));
              assert false report "impossible basewidth!" severity failure;
          end case;
          axi_write_control_reg;
          writeline(output, Lw);
          
          writeline(output, Lw);
          write(Lw, string'("----- Writing operands:"));
          writeline(output, Lw);
          
          -- load the modulus
          --------------------
          loadOp(op_modulus, m); -- visual check needed
          write(Lw, string'("  m written"));
          writeline(output, Lw);
          
          -- load g0
          -----------
          loadOp(op_0, g0);
          -- verify
          readOp(op_0, data_read, base_width);
          if (g0(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  g0 written in operand_0")); writeline(output, Lw);
          else
            write(Lw, string'("  failed to write g0 to operand_0!")); writeline(output, Lw);
            assert false report "Load g0 to op0 data verify failed!!" severity failure;
          end if;
          
          -- load g1
          -----------
          loadOp(op_1, g1);
          -- verify
          readOp(op_1, data_read, base_width);
          if (g1(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  g1 written in operand_1")); writeline(output, Lw);
          else
            write(Lw, string'("  failed to write g1 to operand_1!")); writeline(output, Lw);
            assert false report "Load g1 to op1 data verify failed!!" severity failure;
          end if;
          
          -- load R2
          -----------
          loadOp(op_2, R2);
          -- verify
          readOp(op_2, data_read, base_width);
          if (R2(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  R^2 written in operand_2")); writeline(output, Lw);
          else
            write(Lw, string'("  failed to write R^2 to operand_2!")); writeline(output, Lw);
            assert false report "Load R2 to op2 data verify failed!!" severity failure;
          end if;
          
          -- load a=1
          ------------
          loadOp(op_3, one);
          -- verify
          readOp(op_3, data_read, base_width);
          if (one(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  1 written in operand_3")); writeline(output, Lw);
          else
            write(Lw, string'("  failed to write 1 to operand_3!")); writeline(output, Lw);
            assert false report "Load 1 to op3 data verify failed!!" severity failure;
          end if;
          
          writeline(output, Lw);
          write(Lw, string'("----- Pre-computations: "));
          writeline(output, Lw);
          
          -- compute gt0
          ---------------
          core_x_sel_single <= "00"; -- g0
          core_y_sel_single <= "10"; -- R^2
          core_dest_op_single <= "00"; -- op_0 = (g0 * R) mod m
          axi_write_control_reg;
          timer := NOW;
          core_start <= '1';
          axi_write_control_reg;
          core_start <= '0';
          axi_write_control_reg;
          wait until IntrEvent = '1';
          timer := NOW-timer;
          waitclk(10);
          readOp(op_0, data_read, base_width);
          write(Lw, string'("  Computed gt0: "));
          hwrite(Lw, data_read(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  Read gt0:     "));
          hwrite(Lw, gt0(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  => calc time is "));
          write(Lw, string'(ToString(timer)));
          writeline(output, Lw);
          write(Lw, string'("  => expected time is "));
          write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
          writeline(output, Lw);
          if (gt0(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  => gt0 is correct!")); writeline(output, Lw);
          else
            write(Lw, string'("  => Error: gt0 is incorrect!!!")); writeline(output, Lw);
            assert false report "gt0 is incorrect!!!" severity failure;
          end if;
          
          -- compute gt1
          ---------------
          core_x_sel_single <= "01"; -- g1
          core_y_sel_single <= "10"; -- R^2
          core_dest_op_single <= "01"; -- op_1 = (g1 * R) mod m
          timer := NOW;
          core_start <= '1';
          axi_write_control_reg;
          core_start <= '0';
          axi_write_control_reg;
          wait until IntrEvent = '1';
          timer := NOW-timer;
          waitclk(10);
          readOp(op_1, data_read, base_width);
          write(Lw, string'("  Computed gt1: "));
          hwrite(Lw, data_read(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  Read gt1:     "));
          hwrite(Lw, gt1(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  => calc time is "));
          write(Lw, string'(ToString(timer)));
          writeline(output, Lw);
          write(Lw, string'("  => expected time is "));
          write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
          writeline(output, Lw);
          if (gt1(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  => gt1 is correct!")); writeline(output, Lw);
          else
            write(Lw, string'("  => Error: gt1 is incorrect!!!")); writeline(output, Lw);
            assert false report "gt1 is incorrect!!!" severity failure;
          end if;
          
          -- compute a
          -------------
          core_x_sel_single <= "10"; -- R^2
          core_y_sel_single <= "11"; -- 1
          core_dest_op_single <= "11"; -- op_3 = (R) mod m
          core_start <= '1';
          axi_write_control_reg;
          timer := NOW;
          core_start <= '0';
          axi_write_control_reg;
          wait until IntrEvent = '1';
          timer := NOW-timer;
          waitclk(10);
          readOp(op_3, data_read, base_width);
          write(Lw, string'("  Computed a=(R)mod m: "));
          hwrite(Lw, data_read(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  Read (R)mod m:       "));
          hwrite(Lw, R(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  => calc time is "));
          write(Lw, string'(ToString(timer)));
          writeline(output, Lw);
          write(Lw, string'("  => expected time is "));
          write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
          writeline(output, Lw);
          if (R(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  => (R)mod m is correct!")); writeline(output, Lw);
          else
            write(Lw, string'("  => Error: (R)mod m is incorrect!!!")); writeline(output, Lw);
            assert false report "(R)mod m is incorrect!!!" severity failure;
          end if;
          
          -- compute gt01
          ---------------
          core_x_sel_single <= "00"; -- gt0
          core_y_sel_single <= "01"; -- gt1
          core_dest_op_single <= "10"; -- op_2 = (gt0 * gt1) mod m
          core_start <= '1';
          axi_write_control_reg;
          timer := NOW;
          core_start <= '0';
          axi_write_control_reg;
          wait until IntrEvent = '1';
          timer := NOW-timer;
          waitclk(10);
          readOp(op_2, data_read, base_width);
          write(Lw, string'("  Computed gt01: "));
          hwrite(Lw, data_read(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  Read gt01:     "));
          hwrite(Lw, gt01(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  => calc time is "));
          write(Lw, string'(ToString(timer)));
          writeline(output, Lw);
          write(Lw, string'("  => expected time is "));
          write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
          writeline(output, Lw);
          if (gt01(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  => gt01 is correct!")); writeline(output, Lw);
          else
            write(Lw, string'("  => Error: gt01 is incorrect!!!")); writeline(output, Lw);
            assert false report "gt01 is incorrect!!!" severity failure;
          end if;
          
          -- load exponent fifo
          ----------------------
          writeline(output, Lw);
          write(Lw, string'("----- Loading exponent fifo: "));
          writeline(output, Lw);
          for i in (exponent_width/16)-1 downto 0 loop
            temp_data := e1((i*16)+15 downto (i*16)) & e0((i*16)+15 downto (i*16));
            LoadFifo(temp_data);
          end loop;
          waitclk(10);
          write(Lw, string'("  => Done"));
          writeline(output, Lw);
          
          -- start exponentiation
          ------------------------
          writeline(output, Lw);
          write(Lw, string'("----- Starting exponentiation: "));
          writeline(output, Lw);
          core_exp_m <= '1';
          timer := NOW;
          core_start <= '1';
          axi_write_control_reg;
          core_start <= '0';
          axi_write_control_reg;
          wait until IntrEvent='1';
          timer := NOW-timer;
          waitclk(10);
          write(Lw, string'("  => calc time is "));
          write(Lw, string'(ToString(timer)));
          writeline(output, Lw);
          write(Lw, string'("  => expected time is "));
          write(Lw, ((C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD*7*exponent_width)/4);
          writeline(output, Lw);
          write(Lw, string'("  => Done"));
          core_exp_m <= '0';
          writeline(output, Lw);
          
          -- post-computations
          ---------------------
          writeline(output, Lw);
          write(Lw, string'("----- Post-computations: "));
          writeline(output, Lw);
          -- load in 1 to operand 2
          loadOp(op_2, one);
          -- verify
          readOp(op_2, data_read, base_width);
          if (one(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  1 written in operand_2")); writeline(output, Lw);
          else
            write(Lw, string'("  failed to write 1 to operand_2!")); writeline(output, Lw);
            assert false report "Load 1 to op2 data verify failed!!" severity failure;
          end if;
          -- compute result
          core_x_sel_single <= "11"; -- a
          core_y_sel_single <= "10"; -- 1
          core_dest_op_single <= "11"; -- op_3 = (a) mod m
          timer := NOW;
          core_start <= '1';
          axi_write_control_reg;
          core_start <= '0';
          axi_write_control_reg;
          wait until IntrEvent = '1';
          timer := NOW-timer;
          waitclk(10);
          readOp(op_3, data_read, base_width);
          write(Lw, string'("  Computed result: "));
          hwrite(Lw, data_read(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  => calc time is "));
          write(Lw, string'(ToString(timer)));
          writeline(output, Lw);
          write(Lw, string'("  => expected time is "));
          write(Lw, (C_NR_STAGES_TOTAL+(2*(base_width-1)))*CLK_PERIOD);
          writeline(output, Lw);
          
        when 12 => -- check with result
          hread(L, result(base_width-1 downto 0), good_value);
          assert good_value report "Can not read result! (wrong lenght?)" severity failure;
          writeline(output, Lw);
          write(Lw, string'("----- verifying result: "));
          writeline(output, Lw);
          write(Lw, string'("  Read result:     "));
          hwrite(Lw, result(base_width-1 downto 0));
          writeline(output, Lw);
          write(Lw, string'("  Computed result: "));
          hwrite(Lw, data_read(base_width-1 downto 0));
          writeline(output, Lw);
          if (result(base_width-1 downto 0) = data_read(base_width-1 downto 0)) then
            write(Lw, string'("  => Result is correct!")); writeline(output, Lw);
          else
            write(Lw, string'("  Error: result is incorrect!!!")); writeline(output, Lw);
            assert false report "result is incorrect!!!" severity failure;
          end if;
          writeline(output, Lw);
  
        when others => 
          assert false report "undefined state!" severity failure;
      end case;
      
      if (param_count = 12) then
        param_count := 0;
      else
        param_count := param_count+1;
      end if;
    end loop;
    
    wait for 1 us;
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
    calc_time => calc_time,
    IntrEvent => IntrEvent,
    core_clk  => core_clk,
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

