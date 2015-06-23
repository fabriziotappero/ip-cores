-----------------------------------------------------------------------------
--	Filename:	gh_uart_Rx_8bit.vhd
--
--	Description:
--		an 8 bit UART Rx Module
--
--	Copyright (c) 2006 by H LeFevre 
--		A VHDL 16550 UART core
--		an OpenCores.org Project
--		free to use, but see documentation for conditions 
--
--	Revision 	History:
--	Revision 	Date       	Author    	Comment
--	-------- 	---------- 	---------	-----------
--	1.0      	02/18/06  	H LeFevre  	Initial revision
--	1.1      	02/25/06  	H LeFevre  	mod to SM, goes to idle faster
--	        	          	         	   if no break error  
--	2.0     	06/18/07  	P.Azkarate  Define "range" in R_WCOUNT and R_brdCOUNT signals
-----------------------------------------------------------------------------
library ieee ;
use ieee.std_logic_1164.all ;

entity gh_uart_Rx_8bit is 
	port(
		clk       : in std_logic; -- clock
		rst       : in std_logic;
		BRCx16    : in std_logic; -- 16x clock enable
		sRX       : in std_logic; 
		num_bits  : in integer;
		Parity_EN : in std_logic;
		Parity_EV : in std_logic;
		Parity_ER : out std_logic;
		Frame_ER  : out std_logic;
		Break_ITR : out std_logic;
		D_RDY     : out std_logic;
		D         : out std_logic_vector(7 downto 0)
		);
end entity;
	
architecture a of gh_uart_Rx_8bit is

COMPONENT gh_shift_reg_se_sl is
	GENERIC (size: INTEGER := 16); 
	PORT(
		clk      : IN STD_logic;
		rst      : IN STD_logic;
		srst     : IN STD_logic:='0';
		SE       : IN STD_logic; -- shift enable
		D        : IN STD_LOGIC;
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

COMPONENT gh_jkff is
	PORT(	
		clk  : IN STD_logic;
		rst  : IN STD_logic;
		J,K  : IN STD_logic;
		Q    : OUT STD_LOGIC
		);
END COMPONENT;

	type R_StateType is (idle,R_start_bit,shift_data,R_parity,
	                     R_stop_bit,break_err);
	signal R_state, R_nstate : R_StateType; 

	signal parity      : std_logic;
	signal parity_Grst : std_logic;
	signal RWC_LD      : std_logic;
	signal R_WCOUNT : integer range 0 to 15;
	signal s_DATA_LD : std_logic;
	signal chk_par : std_logic;
	signal chk_frm : std_logic;
	signal clr_brk : std_logic;
	signal clr_D : std_logic;
	signal s_chk_par : std_logic;
	signal s_chk_frm : std_logic;
	signal R_shift_reg : std_logic_vector(7 downto 0);
	signal iRX : std_logic;
	signal BRC : std_logic;
	signal dCLK_LD : std_logic;
	signal R_brdCOUNT : integer range 0 to 15;
	signal iParity_ER : std_logic;
	signal iFrame_ER : std_logic;
	signal iBreak_ITR : std_logic;
	signal iD_RDY : std_logic;
	
begin

----------------------------------------------
---- outputs----------------------------------
----------------------------------------------
process(CLK,rst)
begin
	if (rst = '1') then	
		Parity_ER <= '0';
		Frame_ER <= '0';
		Break_ITR <= '0';
		D_RDY <= '0';
	elsif (rising_edge(CLK)) then
		if (BRCx16 = '1') then
			D_RDY <= iD_RDY;
			if (iD_RDY = '1') then
				Parity_ER <= iParity_ER;
				Frame_ER <= iFrame_ER;
				Break_ITR <= iBreak_ITR;
			end if;
		end if;
	end if;
end process;

	D <= R_shift_reg when (num_bits = 8) else
	    ('0' & R_shift_reg(7 downto 1)) when (num_bits = 7) else
	    ("00" & R_shift_reg(7 downto 2)) when (num_bits = 6) else
	    ("000" & R_shift_reg(7 downto 3)); -- when (bits_word = 5) else


----------------------------------------------

	dCLK_LD <= '1' when (R_state = idle) else
	           '0';
			   
	BRC <= '0' when (BRCx16 = '0') else
	       '1' when (R_brdCOUNT = 0) else
	       '0';
		   
u1 : gh_counter_integer_down -- baud rate divider
	generic map (15)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => dCLK_LD,
		CE => BRCx16,
		D => 14,
		Q => R_brdCOUNT);
		
----------------------------------------------------------

U2 : gh_shift_reg_se_sl 
	Generic Map(8)
	PORT MAP (
		clk => clk,
		rst => rst,
		srst => clr_D,
		SE => s_DATA_LD,
		D => sRX,
		Q => R_shift_reg);

-----------------------------------------------------------

	chk_par <= s_chk_par and (((parity xor iRX) and Parity_EV) 
	                 or (((not parity) xor iRX) and (not Parity_EV)));

U2c : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => chk_par,
		k => dCLK_LD,
		Q => iParity_ER);

	chk_frm <= s_chk_frm and (not iRX);
		
U2d : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => chk_frm,
		k => dCLK_LD,
		Q => iFrame_ER);

U2e : gh_jkff 
	PORT MAP (
		clk => clk,
		rst => rst,
		j => clr_d,
		k => clr_brk,
		Q => iBreak_ITR);
		
--------------------------------------------------------------
--------------------------------------------------------------


process(R_state,BRCx16,BRC,iRX,R_WCOUNT,Parity_EN,R_brdCOUNT,iBreak_ITR)
begin
	case R_state is
		when idle => -- idle  
			iD_RDY <= '0'; s_DATA_LD <= '0'; RWC_LD <= '1'; 
			s_chk_par <= '0'; s_chk_frm <= '0'; clr_brk <= '0';
			clr_D <= '0';
			if (iRX = '0') then	
				R_nstate <= R_start_bit;
			else 
				R_nstate <= idle;
			end if;
		when R_start_bit => -- 
			iD_RDY <= '0'; s_DATA_LD <= '0'; RWC_LD <= '1'; 
			s_chk_par <= '0'; s_chk_frm <= '0'; clr_brk <= '0';
			if (BRC = '1') then
				clr_D <= '1';
				R_nstate <= shift_data;
			elsif ((R_brdCOUNT = 8) and (iRX = '1')) then -- false start bit detection
				clr_D <= '0';
				R_nstate <= idle;
			else
				clr_D <= '0';
				R_nstate <= R_start_bit;
			end if;
		when shift_data => -- send data bit	
			iD_RDY <= '0'; RWC_LD <= '0';
			s_chk_par <= '0'; s_chk_frm <= '0';
			clr_D <= '0';
			if (BRCx16 = '0') then
				s_DATA_LD <= '0'; clr_brk <= '0';
				R_nstate <= shift_data;	
			elsif (R_brdCOUNT = 8) then
				s_DATA_LD <= '1'; clr_brk <= iRX; 
				R_nstate <= shift_data;	
			elsif ((R_WCOUNT = 1) and (R_brdCOUNT = 0) and (Parity_EN = '1')) then
				s_DATA_LD <= '0'; clr_brk <= '0';
				R_nstate <= R_parity;	
			elsif ((R_WCOUNT = 1) and (R_brdCOUNT = 0)) then
				s_DATA_LD <= '0'; clr_brk <= '0';
				R_nstate <= R_stop_bit;
			else
				s_DATA_LD <= '0'; clr_brk <= '0'; 
				R_nstate <= shift_data;
			end if;
		when R_parity => -- check parity bit
			iD_RDY <= '0'; s_DATA_LD <= '0'; 
			RWC_LD <= '0'; s_chk_frm <= '0';
			clr_D <= '0';
			if (BRCx16 = '0') then
				s_chk_par <= '0';  clr_brk <= '0';
				R_nstate <= R_parity;
			elsif (R_brdCOUNT = 8) then
				s_chk_par <= '1'; clr_brk <= iRX; 
				R_nstate <= R_parity;
			elsif (BRC = '1') then
				s_chk_par <= '0'; clr_brk <= '0';
				R_nstate <= R_stop_bit;
			else 
				s_chk_par <= '0'; clr_brk <= '0';
				R_nstate <= R_parity;
			end if;	 
		when R_stop_bit => -- check stop bit
			s_DATA_LD <= '0'; RWC_LD <= '0'; 
			s_chk_par <= '0'; clr_brk <= iRX;
			clr_D <= '0';
			if ((BRC = '1') and (iBreak_ITR = '1')) then
				iD_RDY <= '1'; s_chk_frm <= '0';
				R_nstate <= break_err; 
			elsif (BRC = '1') then
				iD_RDY <= '1'; s_chk_frm <= '0';
				R_nstate <=	idle;
			elsif (R_brdCOUNT = 8) then
				iD_RDY <= '0'; s_chk_frm <= '1';
				R_nstate <= R_stop_bit;	
			elsif ((R_brdCOUNT = 7) and (iBreak_ITR = '0')) then -- added 02/20/06
				iD_RDY <= '1'; s_chk_frm <= '0';
				R_nstate <=	idle;
			else 
				iD_RDY <= '0'; s_chk_frm <= '0';
				R_nstate <= R_stop_bit;
			end if;	
		when break_err => 
			iD_RDY <= '0'; s_DATA_LD <= '0'; RWC_LD <= '0'; 
			s_chk_par <= '0'; s_chk_frm <= '0'; clr_brk <= '0';
			clr_D <= '0';
			if (iRX = '1') then
				R_nstate <= idle;
			else
				R_nstate <= break_err;
			end if;
		when others => 
			iD_RDY <= '0'; s_DATA_LD <= '0'; RWC_LD <= '0'; 
			s_chk_par <= '0'; s_chk_frm <= '0'; clr_brk <= '0';
			clr_D <= '0';
			R_nstate <= idle;
	end case;
end process;

--
-- registers for SM
process(CLK,rst)
begin
	if (rst = '1') then	
		iRX <= '1';
		R_state <= idle;
	elsif (rising_edge(CLK)) then
		if (BRCx16 = '1') then
			iRX <= sRX;
			R_state <= R_nstate;
		else 
			iRX <= iRX;
			R_state <= R_state;
		end if;
	end if;
end process;

u3 : gh_counter_integer_down -- word counter
	generic map (8)
	port map(
		clk => clk,  
		rst  => rst, 
		LOAD => RWC_LD,
		CE => BRC,
		D => num_bits,
		Q => R_WCOUNT
		);

--------------------------------------------------------
--------------------------------------------------------
			   
	parity_Grst <= '1' when (R_state = R_start_bit) else
	               '0';
	
U4 : gh_parity_gen_Serial 
	PORT MAP (
		clk => clk,
		rst => rst,
		srst => parity_Grst,
		SD => BRC,
		D => R_shift_reg(7),
		Q => parity);

		
end a;

