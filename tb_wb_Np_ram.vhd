----------------------------------------------------------------------------------
-- Company:       VISENGI S.L. (www.visengi.com)
-- Engineer:      Victor Lopez Lorenzo (victor.lopez (at) visengi (dot) com)
-- 
-- Create Date:    23:44:13 22/August/2008 
-- Project Name:   Triple Port WISHBONE SPRAM Wrapper
-- Tool versions:  Xilinx ISE 9.2i
-- Description: 
--
-- Description: This is a wrapper for an inferred single port RAM, that converts it
--              into a Three-port RAM with one WISHBONE slave interface for each port. 
--
--
-- LICENSE TERMS: GNU LESSER GENERAL PUBLIC LICENSE Version 2.1
--     That is you may use it in ANY project (commercial or not) without paying a cent.
--     You are only required to include in the copyrights/about section of accompanying 
--     software and manuals of use that your system contains a "3P WB SPRAM Wrapper
--     (C) VISENGI S.L. under LGPL license"
--     This holds also in the case where you modify the core, as the resulting core
--     would be a derived work.
--     Also, we would like to know if you use this core in a project of yours, just an email will do.
--
--    Please take good note of the disclaimer section of the LPGL license, as we don't
--    take any responsability for anything that this core does.
----------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

ENTITY tb_wb_Np_ram_vhd IS
END tb_wb_Np_ram_vhd;

ARCHITECTURE behavior OF tb_wb_Np_ram_vhd IS 

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT wb_Np_ram
	PORT(
		wb_clk_i : IN std_logic;
		wb_rst_i : IN std_logic;
		wb1_cyc_i : IN std_logic;
		wb1_stb_i : IN std_logic;
		wb1_we_i : IN std_logic;
		wb1_adr_i : IN std_logic_vector(7 downto 0);
		wb1_dat_i : IN std_logic_vector(31 downto 0);
		wb2_cyc_i : IN std_logic;
		wb2_stb_i : IN std_logic;
		wb2_we_i : IN std_logic;
		wb2_adr_i : IN std_logic_vector(7 downto 0);
		wb2_dat_i : IN std_logic_vector(31 downto 0);
		wb3_cyc_i : IN std_logic;
		wb3_stb_i : IN std_logic;
		wb3_we_i : IN std_logic;
		wb3_adr_i : IN std_logic_vector(7 downto 0);
		wb3_dat_i : IN std_logic_vector(31 downto 0);          
		wb1_dat_o : OUT std_logic_vector(31 downto 0);
		wb1_ack_o : OUT std_logic;
		wb2_dat_o : OUT std_logic_vector(31 downto 0);
		wb2_ack_o : OUT std_logic;
		wb3_dat_o : OUT std_logic_vector(31 downto 0);
		wb3_ack_o : OUT std_logic
		);
	END COMPONENT;

	--Inputs
	SIGNAL wb_clk_i :  std_logic := '0';
	SIGNAL wb_rst_i :  std_logic := '0';
	SIGNAL wb1_cyc_i :  std_logic := '0';
	SIGNAL wb1_stb_i :  std_logic := '0';
	SIGNAL wb1_we_i :  std_logic := '0';
	SIGNAL wb2_cyc_i :  std_logic := '0';
	SIGNAL wb2_stb_i :  std_logic := '0';
	SIGNAL wb2_we_i :  std_logic := '0';
	SIGNAL wb3_cyc_i :  std_logic := '0';
	SIGNAL wb3_stb_i :  std_logic := '0';
	SIGNAL wb3_we_i :  std_logic := '0';
	SIGNAL wb1_adr_i :  std_logic_vector(7 downto 0) := (others=>'0');
	SIGNAL wb1_dat_i :  std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL wb2_adr_i :  std_logic_vector(7 downto 0) := (others=>'0');
	SIGNAL wb2_dat_i :  std_logic_vector(31 downto 0) := (others=>'0');
	SIGNAL wb3_adr_i :  std_logic_vector(7 downto 0) := (others=>'0');
	SIGNAL wb3_dat_i :  std_logic_vector(31 downto 0) := (others=>'0');

	--Outputs
	SIGNAL wb1_dat_o :  std_logic_vector(31 downto 0);
	SIGNAL wb1_ack_o :  std_logic;
	SIGNAL wb2_dat_o :  std_logic_vector(31 downto 0);
	SIGNAL wb2_ack_o :  std_logic;
	SIGNAL wb3_dat_o :  std_logic_vector(31 downto 0);
	SIGNAL wb3_ack_o :  std_logic;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
	uut: wb_Np_ram PORT MAP(
		wb_clk_i => wb_clk_i,
		wb_rst_i => wb_rst_i,
		wb1_cyc_i => wb1_cyc_i,
		wb1_stb_i => wb1_stb_i,
		wb1_we_i => wb1_we_i,
		wb1_adr_i => wb1_adr_i,
		wb1_dat_i => wb1_dat_i,
		wb1_dat_o => wb1_dat_o,
		wb1_ack_o => wb1_ack_o,
		wb2_cyc_i => wb2_cyc_i,
		wb2_stb_i => wb2_stb_i,
		wb2_we_i => wb2_we_i,
		wb2_adr_i => wb2_adr_i,
		wb2_dat_i => wb2_dat_i,
		wb2_dat_o => wb2_dat_o,
		wb2_ack_o => wb2_ack_o,
		wb3_cyc_i => wb3_cyc_i,
		wb3_stb_i => wb3_stb_i,
		wb3_we_i => wb3_we_i,
		wb3_adr_i => wb3_adr_i,
		wb3_dat_i => wb3_dat_i,
		wb3_dat_o => wb3_dat_o,
		wb3_ack_o => wb3_ack_o
	);





   
   wb1_control : process (wb_rst_i, wb_clk_i)
      variable WaitACKWB : std_logic;
      variable data : std_logic_vector(31 downto 0);
      variable State : integer;
   begin
      if (wb_rst_i = '1') then
         wb1_dat_i <= (others => '0');
         wb1_adr_i <= (others => '0');
         wb1_we_i <= '0';
         wb1_stb_i <= '0';
         wb1_cyc_i <= '0';
         
         data := (others => '0');
         WaitACKWB := '0';
         State := 0;
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         if (WaitACKWB = '1') then
            if (wb1_ack_o = '1') then
               WaitACKWB := '0';
               wb1_we_i <= '0';
               wb1_stb_i <= '0';
               wb1_cyc_i <= '0';
               data := wb1_dat_o;
            end if;
         end if;
         
         if (WaitACKWB = '0') then
            case State is
               when 0 => --init
						wb1_adr_i <= X"00";
						wb1_dat_i <= x"00000001";
						wb1_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 1 =>
						wb1_adr_i <= X"01";
						wb1_dat_i <= x"00000002";
						wb1_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 2 =>
                  wb1_adr_i <= X"02";
						wb1_dat_i <= x"00000003";
						wb1_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 3 =>
                  State := State + 1;
               when 4 =>
                  wb1_adr_i <= X"00";
						wb1_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 5 =>
                  State := State + 1;
               when 6 =>
                  State := State + 1;
               when 7 =>
                  wb1_adr_i <= X"01";
                  wb1_dat_i <= data;
						wb1_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 8 =>
                  wb1_adr_i <= X"05";
                  wb1_dat_i <= x"00500FA0";
						wb1_we_i <= '1';
                  WaitACKWB := '1';
                  State := 0;
               when 45 =>
                  report "-----------> Testbench Finished OK!" severity FAILURE; --everything went fine, it's just to stop the simulation
                  
               when others =>
                  null;
            end case;
            
            if (WaitACKWB = '1') then
               wb1_stb_i <= '1';
               wb1_cyc_i <= '1';
            end if;
         end if;         
      end if;
   end process wb1_control;





   wb2_control : process (wb_rst_i, wb_clk_i)
      variable WaitACKWB : std_logic;
      variable data : std_logic_vector(31 downto 0);
      variable State : integer;
   begin
      if (wb_rst_i = '1') then
         wb2_dat_i <= (others => '0');
         wb2_adr_i <= (others => '0');
         wb2_we_i <= '0';
         wb2_stb_i <= '0';
         wb2_cyc_i <= '0';
         
         data := (others => '0');
         WaitACKWB := '0';
         State := 0;
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         if (WaitACKWB = '1') then
            if (wb2_ack_o = '1') then
               WaitACKWB := '0';
               wb2_we_i <= '0';
               wb2_stb_i <= '0';
               wb2_cyc_i <= '0';
               data := wb2_dat_o;
            end if;
         end if;
         
         if (WaitACKWB = '0') then
            case State is
               when 0 => --init
						wb2_adr_i <= X"05";
						wb2_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 1 =>
                  State := State + 1;
               when 2 =>
                  State := State + 1;
               when 3 =>
                  State := State + 1;
               when 4 =>
						wb2_adr_i <= X"04";
						wb2_dat_i <= x"00000002";
						wb2_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 5 =>
                  State := State + 1;
               when 6 =>
                  State := State + 1;
               when 7 =>
                  State := State + 1;
               when 8 =>
                  wb2_adr_i <= X"03";
						wb2_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 9 =>
                  State := State + 1;
               when 10 =>
                  wb2_adr_i <= X"02";
						wb2_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 11 =>
                  State := State + 1;
               when 12 =>
                  State := State + 1;
               when 13 =>
                  State := State + 1;
               when 14 =>
                  wb2_adr_i <= X"01";
						wb2_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 15 =>
                  State := State + 1;
               when 16 =>
                  State := State + 1;
               when 17 =>
                  wb2_adr_i <= X"05";
                  wb2_dat_i <= data;
						wb2_we_i <= '1';
                  WaitACKWB := '1';
                  State := 0;
               when others =>
                  null;
            end case;
            
            if (WaitACKWB = '1') then
               wb2_stb_i <= '1';
               wb2_cyc_i <= '1';
            end if;
         end if;         
      end if;
   end process wb2_control;



   wb3_control : process (wb_rst_i, wb_clk_i)
      variable WaitACKWB : std_logic;
      variable data : std_logic_vector(31 downto 0);
      variable State : integer;
   begin
      if (wb_rst_i = '1') then
         wb3_dat_i <= (others => '0');
         wb3_adr_i <= (others => '0');
         wb3_we_i <= '0';
         wb3_stb_i <= '0';
         wb3_cyc_i <= '0';
         
         data := (others => '0');
         WaitACKWB := '0';
         State := 0;
      elsif (wb_clk_i = '1' and wb_clk_i'event) then
         if (WaitACKWB = '1') then
            if (wb3_ack_o = '1') then
               WaitACKWB := '0';
               wb3_we_i <= '0';
               wb3_stb_i <= '0';
               wb3_cyc_i <= '0';
               data := wb3_dat_o;
            end if;
         end if;
         
         if (WaitACKWB = '0') then
            case State is
               when 0 =>
                  State := State + 1;
               when 1 => --init
						wb3_adr_i <= X"05";
						wb3_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 2 =>
						wb3_adr_i <= X"02";
						wb3_dat_i <= x"00000002";
						wb3_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 3 =>
                  State := State + 1;
               when 4 =>
                  wb3_adr_i <= X"01";
						wb3_dat_i <= x"00000003";
						wb3_we_i <= '1';
                  WaitACKWB := '1';
                  State := State + 1;
               when 5 =>
                  wb3_adr_i <= X"05";
						wb3_we_i <= '0';
                  WaitACKWB := '1';
                  State := State + 1;
               when 6 =>
                  State := State + 1;
               when 7 =>
                  State := State + 1;
               when 8 =>
                  wb3_adr_i <= X"01";
                  wb3_dat_i <= data;
						wb3_we_i <= '1';
                  WaitACKWB := '1';
                  State := 0;
               when others =>
                  null;
            end case;
            
            if (WaitACKWB = '1') then
               wb3_stb_i <= '1';
               wb3_cyc_i <= '1';
            end if;
         end if;         
      end if;
   end process wb3_control;



   wb_rst_i <= '1', '0' after 60 ns; --active high
	
	Clocking : process --50 MHz -> T = 20 ns 
	begin
			wb_clk_i <= '1';
			wait for 10 ns;
			wb_clk_i <= '0';
			wait for 10 ns;
	end process;

END;
