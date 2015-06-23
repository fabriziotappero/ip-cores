-----------------------------------------------------------------------------
--	Filename:	gh_uart_Tx_8bit.vhd
--
--	Description:
--		an 8 bit UART Tx Module
--
--	Copyright (c) 2006, 2007 by H LeFevre
--		A VHDL 16550 UART core
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	02/18/06  	H LeFevre	Initial revision
--	1.1      	02/25/06  	H LeFevre	add BUSYn output
--	2.0     	06/18/07  	P.Azkarate  Define "range" in T_WCOUNT and x_dCOUNT signals
--	2.1     	07/12/07  	H LeFevre	fix a problem with 5 bit data and 1.5 stop bits
--       		          	         	   as pointed out by Matthias Klemm
--	2.2     	08/17/07  	H LeFevre	add stopB to sensitivity list line 164
--       		          	         	   as suggested by Guillaume Zin 
-----------------------------------------------------------------------------
library ieee ;
use ieee.std_logic_1164.all ;

entity gh_uart_Tx_8bit is 
	port(
		clk       : in std_logic; --  clock
		rst       : in std_logic;
		xBRC      : in std_logic; -- x clock enable
		D_RYn     : in std_logic; -- data ready 
		D         : in std_logic_vector(7 downto 0);
		num_bits  : in integer:= 8; -- number of bits in transfer
		Break_CB  : in std_logic;
		stopB     : in std_logic;
		Parity_EN : in std_logic;
		Parity_EV : in std_logic;
		sTX       : out std_logic;
		BUSYn     : out std_logic;
		read      : out std_logic -- data read
		);
end entity;
	
architecture a of gh_uart_Tx_8bit is

COMPONENT gh_shift_reg_PL_sl is
	GENERIC (size: INTEGER := 16);
	PORT(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		LOAD     : IN STD_LOGIC;  -- load data
		SE       : IN STD_LOGIC;  -- shift enable
		D        : IN STD_LOGIC_VECTOR(size-1 DOWNTO 0);
		Q        : OUT STD_LOGIC_VECTOR(size-1 DOWNTO 0)
		);
END COMPONENT;

COMPONENT gh_parity_gen_Serial is
	PORT(	
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		srst     : in STD_LOGIC;
		SD       : in STD_LOGIC; -- sample data pulse
		D        : in STD_LOGIC; -- data
		Q        : out STD_LOGIC
		);
END COMPONENT;

COMPONENT gh_counter_integer_down IS	
	generic(max_count : integer := 8);
	PORT(	
		clk      : IN STD_LOGIC;
		rst      : IN STD_LOGIC; 
		LOAD     : in STD_LOGIC; -- load D
		CE       : IN STD_LOGIC; -- count enable
		D        : in integer RANGE 0 TO max_count;
		Q        : out integer RANGE 0 TO max_count
		);
END COMPONENT;

	type T_StateType is (idle,s_start_bit,shift_data,s_parity,
	                     s_stop_bit,s_stop_bit2);
	signal T_state, T_nstate : T_StateType; 

	signal parity      : std_logic;
	signal parity_Grst : std_logic;
	signal TWC_LD      : std_logic;
	signal TWC_CE      : std_logic;
	signal T_WCOUNT : integer range 0 to 15;
	signal D_LD_v : integer range 1 to 15;
	signal D_LD : std_logic;
	signal Trans_sr_SE : std_logic;
	signal Trans_shift_reg : std_logic_vector(7 downto 0);
	signal iTX : std_logic;
	signal BRC : std_logic;
	signal dCLK_LD : std_logic;
	signal x_dCOUNT : integer range 0 to 15;
	
begin

----------------------------------------------
---- outputs----------------------------------
----------------------------------------------

	BUSYn <= '1' when (T_state = idle) else
	         '0';

	read <= D_LD; -- read a data word

----------------------------------------------

	dCLK_LD <= '1' when ((num_bits = 5) and (stopB = '1') 
	               and (T_state = s_stop_bit2) and (x_dCOUNT = 7)) else
	           '0' when (D_RYn = '0') else
	           '0' when (T_state /= idle) else
	           '1';

	D_LD_v <= 15 when (T_state = s_stop_bit2) else
	           1;
			   
	BRC <= '0' when (xBRC = '0') else
	       '1' when (x_dCOUNT = 0) else
	       '0';

   
u1 : gh_counter_integer_down -- baud rate divider
	generic map (15)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => dCLK_LD,
		CE => xBRC,
		D => D_LD_v,
		Q => x_dCOUNT);

U2 : gh_shift_reg_PL_sl 
	Generic Map(8)
	PORT MAP (
		clk => clk,
		rst => rst,
		LOAD => D_LD,
		SE => Trans_sr_SE,
		D => D,
		Q => Trans_shift_reg);
		
--------------------------------------------------------------
--------------------------------------------------------------
	
process (clk,rst)
begin
	if (rst = '1') then
		sTX <= '1';
	elsif (rising_edge(clk)) then
		sTX <= iTX and (not Break_CB);
	end if;
end process ;

	iTX <= '0' when (T_state = s_start_bit) else -- send start bit
	        Trans_shift_reg(0) when (T_state = shift_data) else -- send data
	        parity when ((Parity_EV = '1') and (T_state = s_parity)) else
	        (not parity) when (T_state = s_parity) else
	        '1'; -- idle, stop bit

process(T_state,D_RYn,BRC,T_WCOUNT,Parity_EN,num_bits,x_dCOUNT,stopB)
begin
	case T_state is
		when idle => -- idle  
			TWC_CE <= '0';
			if ((D_RYn = '0') and (BRC = '1')) then
				D_LD <= '1'; Trans_sr_SE <= '0'; 
				TWC_LD <= '0'; 
				T_nstate <= s_start_bit;
			else 
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= idle;
			end if;
		when s_start_bit => -- fifo is read, send start bit
			TWC_CE <= '0';
			if (BRC = '1') then
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '1';
				T_nstate <= shift_data;
			else
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_start_bit;
			end if;
		when shift_data => -- send data bit
			if (BRC = '0') then
				D_LD <= '0'; Trans_sr_SE <= '0'; 
				TWC_LD <= '0'; TWC_CE <= '0';
				T_nstate <= shift_data;
			elsif ((T_WCOUNT = 1) and (Parity_EN = '1')) then
				D_LD <= '0'; Trans_sr_SE <= '0'; 
				TWC_LD <= '0'; TWC_CE <= '1';
				T_nstate <= s_parity;
			elsif (T_WCOUNT = 1) then
				D_LD <= '0'; Trans_sr_SE <= '0'; 
				TWC_LD <= '0'; TWC_CE <= '1';
				T_nstate <= s_stop_bit;
			else
				D_LD <= '0'; Trans_sr_SE <= '1'; 
				TWC_LD <= '0'; TWC_CE <= '1';
				T_nstate <= shift_data;
			end if;
		when s_parity => -- send parity bit
			TWC_CE <= '0';
			if (BRC = '1') then
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_stop_bit;
			else 
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_parity;
			end if;	 
		when s_stop_bit => -- send stop bit
			TWC_CE <= '0';
			if (BRC = '0') then
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_stop_bit;
			elsif (stopB = '1') then
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_stop_bit2;
			elsif (D_RYn = '0') then
				D_LD <= '1'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_start_bit;
			else 
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= idle;
			end if;
		when s_stop_bit2 => -- send stop bit 
			TWC_CE <= '0';
			if ((D_RYn = '0') and (BRC = '1')) then
				D_LD <= '1'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_start_bit; 
			elsif (BRC = '1') then
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= idle;
			elsif ((num_bits = 5) and (x_dCOUNT = 7) and (D_RYn = '0')) then
				D_LD <= '1'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_start_bit;
			elsif ((num_bits = 5) and (x_dCOUNT = 7)) then
				D_LD <= '1'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= idle;
			else 
				D_LD <= '0'; Trans_sr_SE <= '0'; TWC_LD <= '0';
				T_nstate <= s_stop_bit2;
			end if;
		when others => 
			D_LD <= '0'; Trans_sr_SE <= '0'; 
			TWC_LD <= '0'; TWC_CE <= '0';
			T_nstate <= idle;
	end case;
end process;

--
-- registers for SM
process(CLK,rst)
begin
	if (rst = '1') then
		T_state <= idle;
	elsif (rising_edge(CLK)) then
		T_state <= T_nstate;
	end if;
end process;

u3 : gh_counter_integer_down -- word counter
	generic map (8)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => TWC_LD,
		CE => TWC_CE,
		D => num_bits,
		Q => T_WCOUNT
		);

--------------------------------------------------------
--------------------------------------------------------

	parity_Grst <= '1' when (T_state = s_start_bit) else
	               '0';
	
U4 : gh_parity_gen_Serial 
	PORT MAP (
		clk => clk,
		rst => rst,
		srst => parity_Grst,
		SD => BRC,
		D => Trans_shift_reg(0),
		Q => parity);

		
end a;

