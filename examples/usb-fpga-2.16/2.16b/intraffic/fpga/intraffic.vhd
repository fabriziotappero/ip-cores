library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
Library UNISIM;
use UNISIM.vcomponents.all;

entity intraffic is
    port(
        RESET         : in std_logic;
        CONT          : in std_logic;
        IFCLK_IN      : in std_logic;

        FD            : out std_logic_vector(15 downto 0); 

        SLOE          : out std_logic;
        SLRD          : out std_logic;
        SLWR          : out std_logic;
        FIFOADR0      : out std_logic;
        FIFOADR1      : out std_logic;
        PKTEND        : out std_logic;

        FLAGB         : in std_logic
    );
end intraffic;

architecture RTL of intraffic is

----------------------------
-- test pattern generator --
----------------------------
-- 30 bit counter
signal GEN_CNT : std_logic_vector(29 downto 0);
signal INT_CNT : std_logic_vector(6 downto 0);

signal FIFO_WORD : std_logic;

signal ifclk,ifclk_fbin,ifclk_fbout,ifclk_out : std_logic;

begin
    SLOE <= '1';
    SLRD <= '1';
    FIFOADR0 <= '0';
    FIFOADR1 <= '0';
    PKTEND <= '1';		-- no data alignment

-- ifclk filter + deskew
    ifclk_fb_buf : BUFG
    port map (
        I => ifclk_fbout,
        O => ifclk_fbin
     ); 

    ifclk_out_buf : BUFG
    port map (
        I => ifclk_out,
        O => ifclk
     ); 

    ifclk_mmcm : MMCME2_BASE
    generic map (
       BANDWIDTH => "OPTIMIZED",  -- OPTIMIZED, HIGH, LOW
       CLKFBOUT_MULT_F => 20.0,     -- Multiply value for all CLKOUT, (2-64)
       CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB, (-360.000-360.000).
       CLKIN1_PERIOD => 0.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
       -- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)
       CLKOUT0_DIVIDE_F => 20.0, 
       CLKOUT1_DIVIDE => 1,
       CLKOUT2_DIVIDE => 1,
       CLKOUT3_DIVIDE => 1,
       CLKOUT4_DIVIDE => 1,
       CLKOUT5_DIVIDE => 1,
       -- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
       CLKOUT0_DUTY_CYCLE => 0.5,
       CLKOUT1_DUTY_CYCLE => 0.5,
       CLKOUT2_DUTY_CYCLE => 0.5,
       CLKOUT3_DUTY_CYCLE => 0.5,
       CLKOUT4_DUTY_CYCLE => 0.5,
       CLKOUT5_DUTY_CYCLE => 0.5,
       -- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
       CLKOUT0_PHASE => 0.0,
       CLKOUT1_PHASE => 0.0,
       CLKOUT2_PHASE => 0.0,
       CLKOUT3_PHASE => 0.0,
       CLKOUT4_PHASE => 0.0,
       CLKOUT5_PHASE => 0.0,
       CLKOUT4_CASCADE => FALSE,  -- Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
       DIVCLK_DIVIDE => 1,        -- Master division value, (1-56)
       REF_JITTER1 => 0.0,        -- Reference input jitter in UI, (0.000-0.999).
       STARTUP_WAIT => FALSE      -- Delay DONE until MMCM Locks, (TRUE / FALSE)
    )
    port map (
       -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
       CLKOUT0 => ifclk_out,       -- 1-bit output: CLKOUT0
       -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
       CLKFBOUT => ifclk_fbout,    -- 1-bit output: Feedback clock
       CLKIN1 => ifclk_in,         -- 1-bit input: Input clock
       -- Control Ports: 1-bit (each) input: PLL control ports
       PWRDWN => '0',              -- 1-bit input: Power-down
       RST => RESET,               -- 1-bit input: Reset
       -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
       CLKFBIN => ifclk_fbin       -- 1-bit input: Feedback clock
    );

    dpIFCLK: process (IFCLK, RESET)
    begin
-- reset
        if RESET = '1' 
	then
	    GEN_CNT <= ( others => '0' );
	    INT_CNT <= ( others => '0' );
	    FIFO_WORD <= '0';
	    SLWR <= '1';
-- IFCLK
        elsif IFCLK'event and IFCLK = '1' 
	then

	    if CONT = '1' or FLAGB = '1'
	    then
		if FIFO_WORD = '0'
		then
		    FD(14 downto 0) <= GEN_CNT(14 downto 0);
		else
		    FD(14 downto 0) <= GEN_CNT(29 downto 15);
		end if;
		FD(15) <= FIFO_WORD;

		if FIFO_WORD = '1'
		then
		    GEN_CNT <= GEN_CNT + '1';
		    if INT_CNT = conv_std_logic_vector(99,7)
		    then 
			INT_CNT <= ( others => '0' );
		    else		    
			INT_CNT <= INT_CNT + '1';
		    end if;
		end if;
		FIFO_WORD <= not FIFO_WORD;
	    end if;
	    
    	    if ( INT_CNT >= conv_std_logic_vector(90,7) ) and ( CONT = '0' )
	    then
	        SLWR <= '1';
	    else
	        SLWR <= '0';
	    end if;
	    
	end if;
    end process dpIFCLK;

end RTL;
