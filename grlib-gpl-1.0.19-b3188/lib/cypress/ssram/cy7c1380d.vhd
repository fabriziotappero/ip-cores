--***************************************************************************************
--
--    File Name:  CY7C1380_PL_SCD.vhd
--      Version:  1.0
--         Date:  December 22nd, 2004
--        Model:  BUS Functional
--    Simulator:  Modelsim 
--
--
--       Queries:  MPD Applications
--       Website:  www.cypress.com/support
--      Company:  Cypress Semiconductor
--       Part #:  CY7C1380D (512K x 36)
--
--  Description:  Cypress 18Mb Synburst SRAM (Pipelined SCD)
--
--
--   Disclaimer:  THESE DESIGNS ARE PROVIDED "AS IS" WITH NO WARRANTY 
--                WHATSOEVER AND CYPRESS SPECIFICALLY DISCLAIMS ANY 
--                IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR
--                A PARTICULAR PURPOSE, OR AGAINST INFRINGEMENT.
--
--	Copyright(c) Cypress Semiconductor, 2004
--	All rights reserved
--
-- Rev       Date        Changes
-- ---    ----------  ---------------------------------------
-- 1.0      12/22/2004  - New Model
--                      - New Test Bench
--                      - New Test Vectors
--
--***************************************************************************************

-- Timings for Different Speed Bins (sb):	250MHz, 225MHz, 200MHz, 167MHz, 133MHz

LIBRARY ieee, grlib, gaisler, work;
	USE ieee.std_logic_1164.all;
--	USE ieee.std_logic_unsigned.all;
--	Use IEEE.Std_Logic_Arith.all;
        USE work.package_utility.all;   
	use grlib.stdlib.all;
	use ieee.std_logic_1164.all;
	use std.textio.all;
	use gaisler.sim.all;


entity CY7C1380D is

     GENERIC (
	fname	: string := "prom.srec"; -- File to read from
        -- Constant Parameters
        addr_bits : INTEGER :=      19;         -- This is external address
        data_bits : INTEGER :=      36; 

--Clock timings for 250Mhz
        Cyp_tCO   : TIME := 	2.6 ns;	-- Data Output Valid After CLK Rise

        Cyp_tCYC  : TIME := 	4.0 ns;  -- Clock cycle time
        Cyp_tCH   : TIME :=	        1.7 ns;	-- Clock HIGH time
        Cyp_tCL   : TIME :=	        1.7 ns;	-- Clock LOW time

        Cyp_tCHZ  : TIME := 	2.6 ns;	-- Clock to High-Z
        Cyp_tCLZ  : TIME := 	1.0 ns;	-- Clock to Low-Z
        Cyp_tOEHZ : TIME :=         2.6 ns;	-- OE# HIGH to Output High-Z
        Cyp_tOELZ : TIME :=         0.0 ns;	-- OE# LOW to Output Low-Z 
        Cyp_tOEV  : TIME :=         2.6 ns;	-- OE# LOW to Output Valid 

        Cyp_tAS   : TIME := 	1.2 ns;	-- Address Set-up Before CLK Rise
        Cyp_tADS  : TIME := 	1.2 ns;	-- ADSC#, ADSP# Set-up Before CLK Rise
        Cyp_tADVS : TIME :=         1.2 ns;	-- ADV# Set-up Before CLK Rise
        Cyp_tWES  : TIME :=	        1.2 ns;	-- BWx#, GW#, BWE# Set-up Before CLK Rise
        Cyp_tDS   : TIME :=	        1.2 ns;	-- Data Input Set-up Before CLK Rise
        Cyp_tCES  : TIME :=	        1.2 ns;	-- Chip Enable Set-up 

        Cyp_tAH   : TIME := 	0.3 ns;	-- Address Hold After CLK Rise
        Cyp_tADH  : TIME := 	0.3 ns;	-- ADSC#, ADSP# Hold After CLK Rise
        Cyp_tADVH : TIME :=         0.3 ns;	-- ADV# Hold After CLK Rise
        Cyp_tWEH  : TIME :=	        0.3 ns;	-- BWx#, GW#, BWE# Hold After CLK Rise
        Cyp_tDH   : TIME := 	0.3 ns;	-- Data Input Hold After CLK Rise
        Cyp_tCEH  : TIME := 	0.3 ns	-- Chip Enable Hold After CLK Rise

--Clock timings for 225Mhz
--         Cyp_tCO  : TIME := 	2.8 ns;	-- Data Output Valid After CLK Rise
                    
--         Cyp_tCYC : TIME := 	4.4 ns;  -- Clock cycle time
--         Cyp_tCH  : TIME :=	2.0 ns;	-- Clock HIGH time
--         Cyp_tCL  : TIME :=	2.0 ns;	-- Clock LOW time
                    
--         Cyp_tCHZ : TIME := 	2.8 ns;	-- Clock to High-Z
--         Cyp_tCLZ : TIME := 	1.0 ns;	-- Clock to Low-Z
--         Cyp_tOEHZ: TIME :=       2.8 ns;	-- OE# HIGH to Output High-Z
--         Cyp_tOELZ: TIME :=       0.0 ns;	-- OE# LOW to Output Low-Z 
--         Cyp_tOEV : TIME :=       2.8 ns;	-- OE# LOW to Output Valid 
                    
--         Cyp_tAS  : TIME := 	1.4 ns;	-- Address Set-up Before CLK Rise
--         Cyp_tADS : TIME := 	1.4 ns;	-- ADSC#, ADSP# Set-up Before CLK Rise
--         Cyp_tADVS: TIME :=       1.4 ns;	-- ADV# Set-up Before CLK Rise
--         Cyp_tWES : TIME :=	1.4 ns;	-- BWx#, GW#, BWE# Set-up Before CLK Rise
--         Cyp_tDS  : TIME :=	1.4 ns;	-- Data Input Set-up Before CLK Rise
--         Cyp_tCES : TIME :=	1.4 ns;	-- Chip Enable Set-up 
                    
--         Cyp_tAH  : TIME := 	0.4 ns;	-- Address Hold After CLK Rise
--         Cyp_tADH : TIME := 	0.4 ns;	-- ADSC#, ADSP# Hold After CLK Rise
--         Cyp_tADVH: TIME :=       0.4 ns;	-- ADV# Hold After CLK Rise
--         Cyp_tWEH : TIME :=	0.4 ns;	-- BWx#, GW#, BWE# Hold After CLK Rise
--         Cyp_tDH  : TIME := 	0.4 ns;	-- Data Input Hold After CLK Rise
--         Cyp_tCEH : TIME := 	0.4 ns	-- Chip Enable Hold After CLK Rise

--Clock timings for 200Mhz
--         Cyp_tCO  : TIME := 	3.0 ns;	-- Data Output Valid After CLK Rise
                    
--         Cyp_tCYC : TIME := 	5.0 ns;  -- Clock cycle time
--         Cyp_tCH  : TIME :=	2.0 ns;	-- Clock HIGH time
--         Cyp_tCL  : TIME :=	2.0 ns;	-- Clock LOW time
                    
--         Cyp_tCHZ : TIME := 	3.0 ns;	-- Clock to High-Z
--         Cyp_tCLZ : TIME := 	1.3 ns;	-- Clock to Low-Z
--         Cyp_tOEHZ: TIME :=       3.0 ns;	-- OE# HIGH to Output High-Z
--         Cyp_tOELZ: TIME :=       0.0 ns;	-- OE# LOW to Output Low-Z 
--         Cyp_tOEV : TIME :=       3.0 ns;	-- OE# LOW to Output Valid 
                    
--         Cyp_tAS  : TIME := 	1.4 ns;	-- Address Set-up Before CLK Rise
--         Cyp_tADS : TIME := 	1.4 ns;	-- ADSC#, ADSP# Set-up Before CLK Rise
--         Cyp_tADVS: TIME :=       1.4 ns;	-- ADV# Set-up Before CLK Rise
--         Cyp_tWES : TIME :=	1.4 ns;	-- BWx#, GW#, BWE# Set-up Before CLK Rise
--         Cyp_tDS  : TIME :=	1.4 ns;	-- Data Input Set-up Before CLK Rise
--         Cyp_tCES : TIME :=	1.4 ns;	-- Chip Enable Set-up 
                    
--         Cyp_tAH  : TIME := 	0.4 ns;	-- Address Hold After CLK Rise
--         Cyp_tADH : TIME := 	0.4 ns;	-- ADSC#, ADSP# Hold After CLK Rise
--         Cyp_tADVH: TIME :=       0.4 ns;	-- ADV# Hold After CLK Rise
--         Cyp_tWEH : TIME :=	0.4 ns;	-- BWx#, GW#, BWE# Hold After CLK Rise
--         Cyp_tDH  : TIME := 	0.4 ns;	-- Data Input Hold After CLK Rise
--         Cyp_tCEH : TIME := 	0.4 ns	-- Chip Enable Hold After CLK Rise

--Clock timings for 167Mhz
--         Cyp_tCO  : TIME := 	3.4 ns;	-- Data Output Valid After CLK Rise
                    
--         Cyp_tCYC : TIME := 	6.0 ns;  -- Clock cycle time
--         Cyp_tCH  : TIME :=	2.2 ns;	-- Clock HIGH time
--         Cyp_tCL  : TIME :=	2.2 ns;	-- Clock LOW time
                    
--         Cyp_tCHZ : TIME := 	3.4 ns;	-- Clock to High-Z
--         Cyp_tCLZ : TIME := 	1.3 ns;	-- Clock to Low-Z
--         Cyp_tOEHZ: TIME :=       3.4 ns;	-- OE# HIGH to Output High-Z
--         Cyp_tOELZ: TIME :=       0.0 ns;	-- OE# LOW to Output Low-Z 
--         Cyp_tOEV : TIME :=       3.4 ns;	-- OE# LOW to Output Valid 
                    
--         Cyp_tAS  : TIME := 	1.5 ns;	-- Address Set-up Before CLK Rise
--         Cyp_tADS : TIME := 	1.5 ns;	-- ADSC#, ADSP# Set-up Before CLK Rise
--         Cyp_tADVS: TIME :=       1.5 ns;	-- ADV# Set-up Before CLK Rise
--         Cyp_tWES : TIME :=	1.5 ns;	-- BWx#, GW#, BWE# Set-up Before CLK Rise
--         Cyp_tDS  : TIME :=	1.5 ns;	-- Data Input Set-up Before CLK Rise
--         Cyp_tCES : TIME :=	1.5 ns;	-- Chip Enable Set-up 
                    
--         Cyp_tAH  : TIME := 	0.5 ns;	-- Address Hold After CLK Rise
--         Cyp_tADH : TIME := 	0.5 ns;	-- ADSC#, ADSP# Hold After CLK Rise
--         Cyp_tADVH: TIME :=       0.5 ns;	-- ADV# Hold After CLK Rise
--         Cyp_tWEH : TIME :=	0.5 ns;	-- BWx#, GW#, BWE# Hold After CLK Rise
--         Cyp_tDH  : TIME := 	0.5 ns;	-- Data Input Hold After CLK Rise
--         Cyp_tCEH : TIME := 	0.5 ns	-- Chip Enable Hold After CLK Rise

--Clock timings for 133Mhz
--         Cyp_tCO  : TIME := 	4.2 ns;	-- Data Output Valid After CLK Rise
                    
--         Cyp_tCYC : TIME := 	7.5 ns;  -- Clock cycle time
--         Cyp_tCH  : TIME :=	2.5 ns;	-- Clock HIGH time
--         Cyp_tCL  : TIME :=	2.5 ns;	-- Clock LOW time
                    
--         Cyp_tCHZ : TIME := 	3.4 ns;	-- Clock to High-Z
--         Cyp_tCLZ : TIME := 	1.3 ns;	-- Clock to Low-Z
--         Cyp_tOEHZ: TIME :=       4.0 ns;	-- OE# HIGH to Output High-Z
--         Cyp_tOELZ: TIME :=       0.0 ns;	-- OE# LOW to Output Low-Z 
--         Cyp_tOEV : TIME :=       4.2 ns;	-- OE# LOW to Output Valid 
                    
--         Cyp_tAS  : TIME := 	1.5 ns;	-- Address Set-up Before CLK Rise
--         Cyp_tADS : TIME := 	1.5 ns;	-- ADSC#, ADSP# Set-up Before CLK Rise
--         Cyp_tADVS: TIME :=       1.5 ns;	-- ADV# Set-up Before CLK Rise
--         Cyp_tWES : TIME :=	1.5 ns;	-- BWx#, GW#, BWE# Set-up Before CLK Rise
--         Cyp_tDS  : TIME :=	1.5 ns;	-- Data Input Set-up Before CLK Rise
--         Cyp_tCES : TIME :=	1.5 ns;	-- Chip Enable Set-up 
                    
--         Cyp_tAH  : TIME := 	0.5 ns;	-- Address Hold After CLK Rise
--         Cyp_tADH : TIME := 	0.5 ns;	-- ADSC#, ADSP# Hold After CLK Rise
--         Cyp_tADVH: TIME :=       0.5 ns;	-- ADV# Hold After CLK Rise
--         Cyp_tWEH : TIME :=	0.5 ns;	-- BWx#, GW#, BWE# Hold After CLK Rise
--         Cyp_tDH  : TIME := 	0.5 ns;	-- Data Input Hold After CLK Rise
--         Cyp_tCEH : TIME := 	0.5 ns	-- Chip Enable Hold After CLK Rise
        );
        PORT (iZZ : IN STD_LOGIC;
              iMode : IN STD_LOGIC;
              iADDR : IN STD_LOGIC_VECTOR ((addr_bits -1) downto 0);
              inGW : IN STD_LOGIC;
              inBWE : IN STD_LOGIC;
              inBWd : IN STD_LOGIC;
              inBWc : IN STD_LOGIC;
              inBWb : IN STD_LOGIC;
              inBWa : IN STD_LOGIC;
              inCE1 : IN STD_LOGIC;
              iCE2 : IN STD_LOGIC;
              inCE3 : IN STD_LOGIC;
              inADSP : IN STD_LOGIC;
              inADSC : IN STD_LOGIC;
              inADV : IN STD_LOGIC;
              inOE : IN STD_LOGIC;
              ioDQ : INOUT STD_LOGIC_VECTOR ((data_bits-1) downto 0);
              iCLK : IN STD_LOGIC);

end CY7C1380D;
ARCHITECTURE CY7C1380D_arch OF CY7C1380D IS



    signal    Read_reg_o1, Read_reg1 : STD_LOGIC;
    signal    WrN_reg1 : STD_LOGIC;
    signal    ADSP_N_o : STD_LOGIC;
    signal    pipe_reg1, ce_reg1,pcsr_write1, ctlr_write1 : STD_LOGIC;
    signal    Sys_clk : STD_LOGIC := '0';
    signal    test : STD_LOGIC;
    signal    dout, din1 : STD_LOGIC_VECTOR (data_bits-1 downto 0);
    signal    ce : STD_LOGIC;
    signal    Write_n : STD_LOGIC;
    signal    Read : STD_LOGIC;

    signal    bwa_n1 : STD_LOGIC;
    signal    bwb_n1 : STD_LOGIC;
    signal    bwc_n1 : STD_LOGIC;
    signal    bwd_n1 : STD_LOGIC;

    signal    latch_addr : STD_LOGIC;
    signal    addr_reg_read1,addr_reg_write1,addr_reg_in1 : STD_LOGIC_VECTOR (addr_bits-1 downto 0);  

    signal    OeN_HZ : STD_LOGIC;
    signal    OeN_DataValid : STD_LOGIC;
    signal    OeN_efct : STD_LOGIC;

    signal    WR_HZ : STD_LOGIC;
    signal    WR_LZ : STD_LOGIC;
    signal    WR_efct : STD_LOGIC;

    signal    CE_HZ : STD_LOGIC;
    signal    CE_LZ : STD_LOGIC;
    signal    Pipe_efct : STD_LOGIC;

    signal    RD_HZ : STD_LOGIC;
    signal    RD_LZ : STD_LOGIC;
    signal    RD_efct : STD_LOGIC;

begin

    ce <= ((not inCE1) and (iCE2) and  (not inCE3));
    Write_n <= not((((not inBWa) OR (not inBWb) OR (not inBWc) OR (not inBWd)) AND (not inBWE)) OR (not inGW));
    Read  <= (((inBWa AND inBWb AND inBWc AND inBWd) AND (not inBWE)) OR (inGW AND inBWE) OR (( not inADSP) AND ce));
    bwa_n1   <= not((not Write_n) AND ((not inGW) OR ((not inBWE) AND (not inBWa))));		
    bwb_n1   <= not((not Write_n) AND ((not inGW) OR ((not inBWE) AND (not inBWb))));		
    bwc_n1   <= not((not Write_n) AND ((not inGW) OR ((not inBWE) AND (not inBWc))));		
    bwd_n1   <= not((not Write_n) AND ((not inGW) OR ((not inBWE) AND (not inBWd))));
    latch_addr    <= ((not inADSC) OR ((not inADSP) AND (not inCE1)));
    OeN_efct     <= OeN_DataValid when (inOE = '0') else OeN_HZ;
    WR_efct  <=	WR_LZ when (WrN_reg1 = '0') else WR_HZ;
    Pipe_efct <= CE_LZ when ((ce_reg1 = '1') and (pipe_reg1 = '1')) else CE_HZ;
    RD_efct  <= CE_LZ when (Read_reg_o1 = '1') else  CE_HZ ;


    Process (Read_reg_o1)
      begin
        if (Read_reg_o1 = '0') then
            RD_HZ <= '0' after Cyp_tCHZ;
            RD_LZ <= '0' after Cyp_tCLZ;
        elsif (Read_reg_o1 = '1') then
            RD_HZ <= '1' after Cyp_tCHZ;
            RD_LZ <= '1' after Cyp_tCLZ;
        else
            RD_HZ <= 'X' after Cyp_tCHZ;
            RD_LZ <= 'X' after Cyp_tCLZ;
        end if;
    end process;



    Process (pipe_reg1)
      begin
        if (pipe_reg1 = '1') then
           CE_LZ <= '1' after Cyp_tCLZ;
        elsif (pipe_reg1 = '0') then
           CE_LZ <= '0' after Cyp_tCLZ;
        else
           CE_LZ <= 'X' after Cyp_tCLZ; 
        end if;
    end process;

    -- System Clock Decode
    Process (iclk)
      variable Sys_clk1 : std_logic := '0';   
      begin
        if (rising_edge (iclk)) then
            Sys_clk1 := not iZZ;
        end if;
        if (falling_edge (iCLK)) then
            Sys_clk1 := '0';
        end if;
    Sys_clk <= Sys_clk1;
      end process;


    
    Process (WrN_reg1)
      begin
        if (WrN_reg1 = '1') then
           WR_HZ   <= '1' after Cyp_tCHZ;
           WR_LZ <= '1' after Cyp_tCLZ;
        elsif (WrN_reg1 = '0') then
           WR_HZ <= '0' after Cyp_tCHZ;
           WR_LZ <= '0' after Cyp_tCLZ;
        else
           WR_HZ <= 'X' after Cyp_tCHZ;
           WR_LZ <= 'X' after Cyp_tCLZ; 
        end if;
    end process; 

    Process (inOE)
      begin
        if (inOE = '1') then
          OeN_HZ  <= '1' after Cyp_tOEHZ;
          OeN_DataValid <= '1' after Cyp_tOEV;
        elsif (inOE = '0') then
          OeN_HZ <= '0' after Cyp_tOEHZ;
          OeN_DataValid <= '0' after Cyp_tOEV;
        else
          OeN_HZ <= 'X' after Cyp_tOEHZ;
          OeN_DataValid <= 'X' after Cyp_tOEV;  
        end if;
    end process;
    
    process (ce_reg1, pipe_reg1)
      begin
         if ((ce_reg1 = '0') or (pipe_reg1 = '0')) then
           CE_HZ <= '0' after Cyp_tCHZ;
         elsif ((ce_reg1 = '1') and (pipe_reg1 = '1')) then
           CE_HZ <= '1' after Cyp_tCHZ; 
         else
           CE_HZ <= 'X' after Cyp_tCHZ;   
         end if;
    end process;

    Process (Sys_clk) 
      TYPE memory_array  IS ARRAY ((2**addr_bits -1) DOWNTO 0) OF STD_LOGIC_VECTOR ((data_bits/4) - 1 DOWNTO 0);
      variable Read_reg_o : std_logic;
      variable Read_reg : std_logic;
      variable pcsr_write, ctlr_write : std_logic;
      variable WrN_reg : std_logic;
      variable latch_addr_old, latch_addr_current : std_logic;
      variable addr_reg_in, addr_reg_read, addr_reg_write : std_logic_vector (addr_bits -1 downto 0) := (others => '0');
      variable bcount, first_addr : std_logic_vector (1 downto 0) := "00";
      variable bwa_reg,bwb_reg,bwc_reg,bwd_reg, pipe_reg, ce_reg : std_logic;
      variable din : std_logic_vector (data_bits-1 downto 0); 
      variable first_addr_int : integer;
      variable bank0 		: memory_array;
      variable bank1 		: memory_array;
      variable bank2 		: memory_array;
      variable bank3 		: memory_array;

	variable FIRST		: boolean := true;
	file TCF : text open read_mode is fname;
	variable rectype : std_logic_vector(3 downto 0);
  	variable recaddr : std_logic_vector(31 downto 0);
  	variable reclen  : std_logic_vector(7 downto 0);
  	variable recdata : std_logic_vector(0 to 16*8-1);
	variable CH : character;
	variable ai : integer := 0;
	variable L1 : line;

    begin
      if FIRST then

      L1:= new string'("");
      while not endfile(TCF) loop
        readline(TCF,L1);
        if (L1'length /= 0) then
          while (not (L1'length=0)) and (L1(L1'left) = ' ') loop
            std.textio.read(L1,CH);
          end loop;

          if L1'length > 0 then
            std.textio.read(L1, ch);
            if (ch = 'S') or (ch = 's') then
              hexread(L1, rectype);
              hexread(L1, reclen);
	      recaddr := (others => '0');
	      case rectype is 
		when "0001" =>
                  hexread(L1, recaddr(15 downto 0));
		when "0010" =>
                  hexread(L1, recaddr(23 downto 0));
		when "0011" =>
                  hexread(L1, recaddr);
		  recaddr(31 downto 24) := (others => '0');
		when others => next;
	      end case;
              hexread(L1, recdata);
              ai := conv_integer(recaddr)/4;
 	      for i in 0 to 3 loop
                bank3 (ai+i) := "0000" & recdata((i*32) to (i*32+4));
		bank2 (ai+i) := recdata((i*32+5) to (i*32+13));
		bank1 (ai+i) := recdata((i*32+14) to (i*32+22));
		bank0 (ai+i) := recdata((i*32+23) to (i*32+31));
	      end loop;
            end if;
          end if;
        end if;
      end loop;

      FIRST := false;
    end if;	

        if rising_edge (Sys_clk) then
 
            if (Write_n = '0') then 
                Read_reg_o := '0'; 
            else 
                Read_reg_o := Read_reg;
            end if;

            if (Write_n = '0') then
                Read_reg := '0'; 
            else 
                Read_reg := Read;
            end if;
            Read_reg1 <= Read_reg;
            Read_reg_o1 <= Read_reg_o;          

            if (Read_reg = '1') then
                pcsr_write     := '0';
                ctlr_write     := '0';
            end if;

	-- Write Register

            if (Read_reg_o = '1') then
                WrN_reg := '1'; 
            else 
                WrN_reg := Write_n;
            end if; 
            WrN_reg1 <= WrN_reg;
       
            latch_addr_old := latch_addr_current;
            latch_addr_current := latch_addr;

            if (latch_addr_old = '1' and (Write_n = '0') and ADSP_N_o = '0') then
                pcsr_write     := '1'; --Ctlr Write = 0; Pcsr Write = 1;
            
            elsif (latch_addr_current = '1' and  (Write_n = '0')  and inADSP = '1' and inADSC = '0') then
                ctlr_write     := '1'; --Ctlr Write = 0; Pcsr Write = 1;
            end if;
            -- ADDRess Register
            if (latch_addr = '1')  then
                addr_reg_in := iADDR;
                bcount := iADDR (1 downto 0); 
                first_addr := iADDR (1 downto 0); 
            end if;
            addr_reg_in1 <= addr_reg_in;
        -- ADSP_N Previous-Cycle Register
            ADSP_N_o <= inADSP;
            pcsr_write1 <= pcsr_write;
            ctlr_write1 <= ctlr_write;        
            first_addr_int := CONV_INTEGER1 (first_addr);
        -- Binary Counter and Logic

		if ((iMode = '0') and (inADV = '0') and (latch_addr = '0')) then 	-- Linear Burst
        		bcount := (bcount + '1');         	-- Advance Counter	

		elsif ((iMode = '1') and (inADV = '0') and (latch_addr = '0')) then -- Interleaved Burst
		        if ((first_addr_int REM 2) = 0) then
        			bcount := (bcount + '1');         -- Increment Counter
			    elsif ((first_addr_int REM 2) = 1) then
        			bcount := (bcount - '1');         -- Decrement Counter 
                end if;    
		end if;

        -- Read ADDRess
        addr_reg_read := addr_reg_write;
        addr_reg_read1 <= addr_reg_read;

        -- Write ADDRess
        addr_reg_write := addr_reg_in ((addr_bits - 1) downto 2) & bcount(1) & bcount(0);
        addr_reg_write1 <= addr_reg_write;
        -- Byte Write Register    
        bwa_reg :=  not bwa_n1;
        bwb_reg :=  not bwb_n1;
        bwc_reg :=  not bwc_n1;
        bwd_reg :=  not bwd_n1;

        -- Enable Register
        pipe_reg := ce_reg;
	
        -- Enable Register
        if (latch_addr = '1')  then 
          ce_reg := ce;
        end if; 
        
        pipe_reg1 <= pipe_reg;
        ce_reg1 <= ce_reg;        

        -- Input Register
        if ((ce_reg = '1') and ((bwa_n1 ='0') or (bwb_n1 = '0') or (bwc_n1 = '0') or (bwd_n1 = '0')) and
                ((pcsr_write = '1') or (ctlr_write = '1'))) then
            din := ioDQ;
        end if;
        din1 <= din;

        -- Byte Write Driver
        if ((ce_reg = '1') and (bwa_reg = '1')) then
            bank0 (CONV_INTEGER1 (addr_reg_write)) := din (8 downto  0);
        end if;
        if ((ce_reg = '1') and (bwb_reg = '1')) then
            bank1 (CONV_INTEGER1 (addr_reg_write)) := din (17 downto 9);
        end if;
        if ((ce_reg = '1') and (bwc_reg = '1')) then
            bank2 (CONV_INTEGER1 (addr_reg_write)) := din (26 downto 18);
        end if;
        if ((ce_reg = '1') and (bwd_reg = '1')) then
            bank3 (CONV_INTEGER1 (addr_reg_write)) := din (35 downto 27);
        end if;

        -- Output Registers

        if ((Write_n = '0') or (pipe_reg = '0')) then
            dout (35 downto 0) <= "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ" after Cyp_tCHZ;
        elsif (Read_reg_o = '1') then
            dout ( 8 downto 0) <= bank0 (CONV_INTEGER1 (addr_reg_read)) after Cyp_tCO;
            dout (17 downto 9) <= bank1 (CONV_INTEGER1 (addr_reg_read)) after Cyp_tCO;
            dout (26 downto 18) <= bank2 (CONV_INTEGER1 (addr_reg_read)) after Cyp_tCO;
            dout (35 downto 27) <= bank3 (CONV_INTEGER1 (addr_reg_read)) after Cyp_tCO;
        end if;

    end if;
    end process;

    -- Output Buffers
    ioDQ <= dout when ((inOE ='0') and (iZZ='0') and (Pipe_efct='1') and (RD_efct='1') and (WR_efct='1')) 
          else "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";


    clk_check : PROCESS
        VARIABLE clk_high, clk_low : TIME := 0 ns;
    BEGIN
        WAIT ON iClk;
            IF iClk = '1' AND NOW >= Cyp_tCYC THEN
                ASSERT (NOW - clk_low >= Cyp_tCH)
                    REPORT "Clk width low - tCH violation"
                    SEVERITY ERROR;
                ASSERT (NOW - clk_high >= Cyp_tCYC)
                    REPORT "Clk period high - tCYC violation"
                    SEVERITY ERROR;
                clk_high := NOW;
            ELSIF iClk = '0' AND NOW /= 0 ns THEN
                ASSERT (NOW - clk_high >= Cyp_tCL)
                    REPORT "Clk width high - tCL violation"
                    SEVERITY ERROR;
                ASSERT (NOW - clk_low >= Cyp_tCYC)
                    REPORT "Clk period low - tCYC violation"
                    SEVERITY ERROR;
                clk_low := NOW;
            END IF;
    END PROCESS;

    -- Check for Setup Timing Violation
    setup_check : PROCESS
    BEGIN
        WAIT ON iClk;
        IF iClk = '1' THEN
            ASSERT (iAddr'LAST_EVENT >= Cyp_tAS)
                REPORT "Addr - tAS violation"
                SEVERITY ERROR;
            ASSERT (inGW'LAST_EVENT >= Cyp_tWES)
                REPORT "GW# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inBWE'LAST_EVENT >= Cyp_tWES)
                REPORT "BWE# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inCe1'LAST_EVENT >= Cyp_tWES)
                REPORT "CE1# - tWES violation"
                SEVERITY ERROR;
            ASSERT (iCe2'LAST_EVENT >= Cyp_tWES)
                REPORT "CE2 - tWES violation"
                SEVERITY ERROR;
            ASSERT (inCe3'LAST_EVENT >= Cyp_tWES)
                REPORT "CE3# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inAdv'LAST_EVENT >= Cyp_tADVS)
                REPORT "ADV# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inAdsp'LAST_EVENT >= Cyp_tADVS)
                REPORT "ADSP# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inAdsc'LAST_EVENT >= Cyp_tADVS)
                REPORT "ADSC# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inBwa'LAST_EVENT >= Cyp_tWES)
                REPORT "BWa# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inBwb'LAST_EVENT >= Cyp_tWES)
                REPORT "BWb# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inBwc'LAST_EVENT >= Cyp_tWES)
                REPORT "BWc# - tWES violation"
                SEVERITY ERROR;
            ASSERT (inBwd'LAST_EVENT >= Cyp_tWES)
                REPORT "BWd# - tWES violation"
                SEVERITY ERROR;
            ASSERT (ioDq'LAST_EVENT >= Cyp_tDS)
                REPORT "Dq - tDS violation"
                SEVERITY ERROR;
        END IF;
    END PROCESS;

    -- Check for Hold Timing Violation
    hold_check : PROCESS
    BEGIN
        WAIT ON iClk'DELAYED(Cyp_tAH), iClk'DELAYED(Cyp_tWEH), iClk'DELAYED(Cyp_tDH);
        IF iClk'DELAYED(Cyp_tAH) = '1' THEN
            ASSERT (iAddr'LAST_EVENT > Cyp_tAH)
                REPORT "Addr - tAH violation"
                SEVERITY ERROR;
        END IF;
        IF iClk'DELAYED(Cyp_tDH) = '1' THEN
            ASSERT (ioDq'LAST_EVENT > Cyp_tDH)
                REPORT "Dq - tDH violation"
                SEVERITY ERROR;
        END IF;
        IF iClk'DELAYED(Cyp_tWEH) = '1' THEN
            ASSERT (inCe1'LAST_EVENT > Cyp_tWEH)
                REPORT "CE1# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (iCe2'LAST_EVENT > Cyp_tWEH)
                REPORT "CE2 - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inCe3'LAST_EVENT > Cyp_tWEH)
                REPORT "CE3 - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inAdv'LAST_EVENT > Cyp_tWEH)
                REPORT "ADV# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inADSP'LAST_EVENT > Cyp_tWEH)
                REPORT "ADSP# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inADSC'LAST_EVENT > Cyp_tWEH)
                REPORT "ADSC# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inBwa'LAST_EVENT > Cyp_tWEH)
                REPORT "BWa# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inBwb'LAST_EVENT > Cyp_tWEH)
                REPORT "BWb# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inBwc'LAST_EVENT > Cyp_tWEH)
                REPORT "BWc# - tWEH violation"
                SEVERITY ERROR;
            ASSERT (inBwd'LAST_EVENT > Cyp_tWEH)
                REPORT "BWd# - tWEH violation"
                SEVERITY ERROR;
        END IF;
        
    END PROCESS;
end CY7C1380D_arch;







