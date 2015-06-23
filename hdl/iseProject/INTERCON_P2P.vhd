--! @file
--! @brief Point to point wishbone interconnection (Sample Master with uart_wishbone_slave)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity INTERCON_P2P is
port (
            -- External (non-WISHBONE) inputs
            EXTCLK: in std_logic;
            EXTRST: in std_logic;
            -- External signals for simulation purposes
            byte_out: out std_logic_vector(7 downto 0);
				data_avaible : out std_logic;
            tx: out std_logic;
			   rx : in std_logic
        );
end INTERCON_P2P;

--! @brief Declaring the components (SYC0001a, SERIALMASTER, uart_wishbone_slave)  
--! @details Just instantiate and connect the various components
architecture Behavioral of INTERCON_P2P is
component SYC0001a
    port(
            -- WISHBONE Interface
            CLK_O:  out std_logic;	--! Clock output
            RST_O:  out std_logic;	--! Reset output
            -- NON-WISHBONE Signals
            EXTCLK: in  std_logic;	--! Clock input
            EXTRST: in  std_logic	--! Reset input
         );
end component SYC0001a;

component SERIALMASTER is
	port(
            -- WISHBONE Signals
            ACK_I:  in  std_logic;								--! Ack input
            ADR_O:  out std_logic_vector( 1 downto 0 );	--! Address output
            CLK_I:  in  std_logic;								--! Clock input
            CYC_O:  out std_logic;								--! Cycle output
            DAT_I:  in  std_logic_vector( 31 downto 0 );	--! Data input
            DAT_O:  out std_logic_vector( 31 downto 0 );	--! Data output
            RST_I:  in  std_logic;								--! Reset input
            SEL_O:  out std_logic;								--! Select output
            STB_O:  out std_logic;								--! Strobe output (Works like a chip select)
            WE_O:   out std_logic;								--! Write enable
				
				-- NON-WISHBONE Signals
				byte_rec : out std_logic_vector(7 downto 0)	--! Signal byte received (Used to debug on the out leds)			
         );
end component;

component uart_wishbone_slave is
    Port ( RST_I : in  STD_LOGIC;								--! Reset Input
           CLK_I : in  STD_LOGIC;								--! Clock Input
           ADR_I0 : in  STD_LOGIC_VECTOR (1 downto 0);	--! Address input
           DAT_I0 : in  STD_LOGIC_VECTOR (31 downto 0);	--! Data Input 0
           DAT_O0 : out  STD_LOGIC_VECTOR (31 downto 0);	--! Data Output 0
           WE_I : in  STD_LOGIC;									--! Write enable input
           STB_I : in  STD_LOGIC;								--! Strobe input (Works like a chip select)
           ACK_O : out  STD_LOGIC;								--! Ack output
			  
			  -- NON-WISHBONE Signals
			  serial_in : in std_logic;							--! Uart serial input
			  data_Avaible : out std_logic;						--! Flag to indicate data avaible					
			  serial_out : out std_logic							--! Uart serial output
			  );
end component;
signal CLK : std_logic;
signal RST : std_logic;
signal ACK : std_logic;
signal WE  : std_logic;
signal STB  : std_logic;
signal ADR : std_logic_vector(  1 downto 0 ); 
signal dataI : std_logic_vector (31 downto 0);
signal dataO : std_logic_vector (31 downto 0);
begin
	--! Instantiate SYC0001a
	uSysCon: component SYC0001a
    port map(
		 CLK_O   =>  CLK,
		 RST_O   =>  RST,
		 EXTCLK  =>  EXTCLK,
		 EXTRST  =>  EXTRST
    );
	
	--! Instantiate SERIALMASTER
	uMasterSerial : component SERIALMASTER
	port map(
		ACK_I => ACK,
		ADR_O => ADR,
		CLK_I => CLK,
		CYC_O => open,
		DAT_I => dataI,
		DAT_O => dataO,
		RST_I => RST,
		SEL_O => open,
		STB_O => STB,
		byte_rec => byte_out,
		WE_O => WE
	);
	
	--! Instantiate uart_wishbone_slave
	uUartWishboneSlave: component uart_wishbone_slave 
	port map(
		RST_I => RST,
		CLK_I => CLK,
		ADR_I0 => ADR,
		DAT_I0 => dataO,
		DAT_O0 => dataI,
		WE_I => WE,
		STB_I => STB,
		ACK_O => ACK,
		serial_in => rx,
		data_Avaible => open,
		serial_out => tx
   );

end Behavioral;

