---====================== Start Copyright Notice ========================---
--==                                                                    ==--
--== Filename ..... switch_tb.vhd                                       ==--
--== Download ..... http://www.ida.ing.tu-bs.de                         ==--
--== Company ...... IDA TU Braunschweig, Prof. Dr.-Ing. Harald Michalik ==--
--== Authors ...... Björn Osterloh                                      ==--
--== Contact ...... Björn Osterloh (b.osterloh@tu-bs.de)                ==--
--== Copyright .... Copyright (c) 2008 IDA                              ==--
--== Project ...... SoCWire Switch Testbench                            ==--
--== Version ...... 1.00                                                ==--
--== Conception ... 22 April 2009                                       ==--
--== Modified ..... holgerm : minor bug fix marked with holgerm         ==--
--==                                                                    ==--
---======================= End Copyright Notice =========================---

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;

USE WORK.ALL;


ENTITY switch_tb IS
  GENERIC(
          --== Number Of Ports ==--
          nports     : NATURAL RANGE 2 TO 32 := 4; 
          --== Set Codec Speed to system clock in nanoseconds! ==--
		    --== DO NOT CHANGE THE GENERICS IN THE SUB MODULES!! ==--          
         datawidth            : NATURAL RANGE 8 TO 8192:=8;
         speed		            : NATURAL RANGE 1 TO 100:=10;		-- Set CODEC speed to system clock in nanoseconds !
         after64              : NATURAL RANGE 1 TO 6400:=64;   -- Spacewire Standard 6400 = 6.4 us
         after128             : NATURAL RANGE 1 TO 12800:=128; -- Spacewire Standard 12800 = 12.8 us                              
	      disconnect_detection : NATURAL RANGE 1 TO 850:=85     -- Spacewire Standard 850 = 850 ns
         );
END switch_tb;

ARCHITECTURE behavior OF switch_tb IS 

COMPONENT socwire_switch IS
  GENERIC(
          datawidth : NATURAL RANGE 8 TO 8192;
          nports     : NATURAL RANGE 2 TO 32;
          speed : NATURAL RANGE  1 TO 100;
          -- holgerm
	       after64              : NATURAL RANGE 1 TO 6400:=6400;   -- Spacewire Standard 6400 = 6.4 us
          after128             : NATURAL RANGE 1 TO 12800:=12800; -- Spacewire Standard 12800 = 12.8 us
          disconnect_detection : NATURAL RANGE 1 TO 850:=850     -- Spacewire Standard 850 = 850 ns
          -- holgerm
         );
  PORT(
       --==  General Interface (Sync Rst, 50MHz Clock) ==--

       rst        : IN  STD_LOGIC;
       clk        : IN  STD_LOGIC;

       --== Serial Receive Interface ==--

       rx         : IN  STD_LOGIC_VECTOR((datawidth+2)*nports-1 DOWNTO 0);
       rx_valid   : IN  STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

       --== Serial Transmit Interface ==--

       tx         : OUT STD_LOGIC_VECTOR((datawidth+2)*nports-1 DOWNTO 0);
       tx_valid   : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

       --== Active Interface ==--

       active     : OUT STD_LOGIC_VECTOR(nports-1 DOWNTO 0)
      );
END COMPONENT;


COMPONENT socwire_codec
  GENERIC(
         datawidth            : NATURAL RANGE 8 TO 8192;
         speed		            : NATURAL RANGE 1 TO 100;
         after64              : NATURAL RANGE 1 TO 6400;
         after128             : NATURAL RANGE 1 TO 12800;
	      disconnect_detection : NATURAL RANGE 1 TO 850
         );
	
	PORT(
		rst : IN std_logic;
		clk : IN std_logic;
		socw_en : IN std_logic;
		socw_dis : IN std_logic;
		rx : IN std_logic_vector(datawidth+1 downto 0);
		rx_valid : IN std_logic;
		dat_nwrite : IN std_logic;
		dat_din : IN std_logic_vector(datawidth downto 0);
		dat_nread : IN std_logic;          
		tx : OUT std_logic_vector(datawidth+1 downto 0);
		tx_valid : OUT std_logic;
		dat_full : OUT std_logic;
		dat_empty : OUT std_logic;
		dat_dout : OUT std_logic_vector(datawidth downto 0);
		active : OUT std_logic
		);
	END COMPONENT;
	
	
	

SIGNAL rst :   STD_LOGIC;
SIGNAL clk :   STD_LOGIC:= '0';
	
SIGNAL rx         : STD_LOGIC_VECTOR((datawidth+2)*nports-1 DOWNTO 0);
SIGNAL rx_valid   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL tx         : STD_LOGIC_VECTOR((datawidth+2)*nports-1 DOWNTO 0);
SIGNAL tx_valid   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL active_i   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL active_ii  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);

SIGNAL socw_en     : STD_LOGIC;
SIGNAL socw_dis    : STD_LOGIC;

SIGNAL dat_full   : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_nwrite : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_din    : STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);
SIGNAL dat_nread  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_empty  : STD_LOGIC_VECTOR(nports-1 DOWNTO 0);
SIGNAL dat_dout   : STD_LOGIC_VECTOR((datawidth+1)*nports-1 DOWNTO 0);

SIGNAL dat_nwrite_P0 : STD_LOGIC;
SIGNAL dat_nwrite_P1 : STD_LOGIC;
SIGNAL dat_nwrite_P2 : STD_LOGIC;
SIGNAL dat_nwrite_P3 : STD_LOGIC;
SIGNAL dat_din_P0 : STD_LOGIC_VECTOR (datawidth downto 0);
SIGNAL dat_din_P1 : STD_LOGIC_VECTOR (datawidth downto 0);
SIGNAL dat_din_P2 : STD_LOGIC_VECTOR (datawidth downto 0);
SIGNAL dat_din_P3 : STD_LOGIC_VECTOR (datawidth downto 0);

-- holgerm
-- compile with "vsim -novopt switch_tb" otherwise optimization will delete these signals
SIGNAL dat_empty_P0 : STD_LOGIC;
SIGNAL dat_empty_P1 : STD_LOGIC;
SIGNAL dat_empty_P2 : STD_LOGIC;
SIGNAL dat_empty_P3 : STD_LOGIC;
SIGNAL dat_dout_P0 : STD_LOGIC_VECTOR (datawidth downto 0);
SIGNAL dat_dout_P1 : STD_LOGIC_VECTOR (datawidth downto 0);
SIGNAL dat_dout_P2 : STD_LOGIC_VECTOR (datawidth downto 0);
SIGNAL dat_dout_P3 : STD_LOGIC_VECTOR (datawidth downto 0);
-- holgerm

BEGIN

	-- Component Declaration for the Unit Under Test (UUT)

  U0 : socwire_switch
    GENERIC MAP
      (
       datawidth =>datawidth,
       nports    => nports,
       speed	  => speed,
       -- holgerm
       after64              =>after64,
       after128             =>after128,
       disconnect_detection =>disconnect_detection
       -- holgerm
      )
    PORT MAP
      (--==  General Interface (Sync Rst) ==--
       clk      => clk,
       rst      => rst,
       rx       => tx,
       rx_valid => tx_valid,
       tx       => rx,
       tx_valid => rx_valid,
       active   => active_i
      );
      
  G0 : FOR i IN 0 TO nports-1 GENERATE 
    U1 : socwire_codec
      GENERIC MAP
        (
         datawidth            =>datawidth,
         speed		            =>speed,
         after64              =>after64,
         after128             =>after128,
	      disconnect_detection =>disconnect_detection
        )
      PORT MAP
        (--==  General Interface (Sync Rst, 50MHz Clock) ==--
         rst        => rst,
         clk        => clk,
         --== Link Enable Interface ==--
         socw_en     => socw_en,
         socw_dis    => socw_dis,
         --== Serial Receive Interface ==--
         rx         => rx((i+1)*10-1 DOWNTO i*10),
         rx_valid   => rx_valid(i),
         --== Serial Transmit Interface ==--
         tx         => tx((i+1)*10-1 DOWNTO i*10),
		 tx_valid   => tx_valid(i),
         --== Data Input Interface ==--
         dat_full   => dat_full(i),
         dat_nwrite => dat_nwrite(i),
         dat_din    => dat_din((i+1)*9-1 DOWNTO i*9),
         --== Data Output Interface ==--
         dat_nread  => dat_nread(i),
         dat_empty  => dat_empty(i),
         dat_dout   => dat_dout((i+1)*9-1 DOWNTO i*9),
         --== Active Interface ==--
         active     => active_ii(i)
        );
  END GENERATE G0;     
  
    socw_en  <= '1';
    socw_dis <= '0'; 

	
	clk <= not clk after 5 ns;

	dat_nwrite(0)<=dat_nwrite_P0;
	dat_nwrite(1)<=dat_nwrite_P1;
	dat_nwrite(2)<=dat_nwrite_P2;
	dat_nwrite(3)<=dat_nwrite_P3;
	dat_din(8 downto 0)  <=dat_din_P0; 
	dat_din(17 downto 9) <=dat_din_P1; 
	dat_din(26 downto 18)<=dat_din_P2; 
	dat_din(35 downto 27)<=dat_din_P3; 
   
   -- holgerm
   -- compile with "vsim -novopt switch_tb" otherwise optimization will delete these signals
   dat_empty_P0 <= dat_empty(0);
   dat_empty_P1 <= dat_empty(1);
   dat_empty_P2 <= dat_empty(2);
   dat_empty_P3 <= dat_empty(3);
   dat_dout_P0 <= dat_dout(8  downto  0);
   dat_dout_P1 <= dat_dout(17 downto  9);
   dat_dout_P2 <= dat_dout(26 downto 18);
   dat_dout_P3 <= dat_dout(35 downto 27);
   -- holgerm
   
	
	
	tb : PROCESS
	
	BEGIN
		
		rst <= '1';
		dat_nwrite_P0<='1';
		dat_nwrite_P1<='1';
		dat_nwrite_P2<='1';
		dat_nwrite_P3<='1';
		dat_din_P0<=(others=>'0');
		dat_din_P1<=(others=>'0');
		dat_din_P2<=(others=>'0');
		dat_din_P3<=(others=>'0');
		dat_nread  <= (others => '1');		
		wait for 100 ns;
		rst <= '0';		
		wait for 1 us;
		dat_nread  <= (others => '0');
			
--	   Send Packet from Port 0 to Port 1			
      dat_nwrite_P0<='0';
		dat_din_P0<="000000001"; -- Port 1
		wait for 10 ns;
      dat_din_P0<="000001010"; -- Data 0		
		wait for 10 ns;
		dat_din_P0<="000001011"; -- Data 1			
		wait for 10 ns;
		dat_din_P0<="100000000"; -- EOP			
	   wait for 10 ns;
		dat_nwrite_P0<='1';
		
--	   Send Packet from Port 2 to Port 3			
      dat_nwrite_P2<='0';
		dat_din_P2<="000000011"; -- Port 3
		wait for 10 ns;
      dat_din_P2<="000001100"; -- Data 0		
		wait for 10 ns;
		dat_din_P2<="000001101"; -- Data 1			
		wait for 10 ns;
		dat_din_P2<="100000000"; -- EOP			
	   wait for 10 ns;
		dat_nwrite_P2<='1';
		
--	   Send Packet from Port 0 and Port 1 to Port 2 and Port 3			
      dat_nwrite_P0<='0';
		dat_din_P0<="000000010"; -- Port 2
		dat_nwrite_P1<='0';
		dat_din_P1<="000000011"; -- Port 3
		wait for 10 ns;
      dat_din_P0<="000001110"; -- Data 0		
		dat_din_P1<="000001010"; -- Data 0		
		wait for 10 ns;
		dat_din_P0<="000001111"; -- Data 1			
		dat_din_P1<="000001011"; -- Data 1		
		wait for 10 ns;
		dat_din_P0<="100000000"; -- EOP			
		dat_din_P1<="100000000"; -- EOP			
	   wait for 10 ns;
		dat_nwrite_P0<='1';
		dat_nwrite_P1<='1';


		
		

		
		
		
		
		
		
		wait for 1000 ms; --wait very long	

	END PROCESS;

END;
