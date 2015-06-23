--
-- FIFO (using Altera scfifo for Cyclone II)
--
-- Author:   Sebastian Witt
-- Date:     07.03.2008
-- Version:  1.0
--

LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

entity slib_fifo is
    generic (
        WIDTH       : integer := 8;                             -- FIFO width
        SIZE_E      : integer := 6                              -- FIFO size (2^SIZE_E)
    );
    port (
        CLK         : in std_logic;                             -- Clock
        RST         : in std_logic;                             -- Reset
        CLEAR       : in std_logic;                             -- Clear FIFO
        WRITE       : in std_logic;                             -- Write to FIFO
        READ        : in std_logic;                             -- Read from FIFO
        D           : in std_logic_vector(WIDTH-1 downto 0);    -- FIFO input
        Q           : out std_logic_vector(WIDTH-1 downto 0);   -- FIFO output
        EMPTY       : out std_logic;                            -- FIFO is empty
        FULL        : out std_logic;                            -- FIFO is full
        USAGE       : out std_logic_vector(SIZE_E-1 downto 0)   -- FIFO usage
    );
end slib_fifo;

architecture altera of slib_fifo is
    COMPONENT scfifo
	GENERIC (
		add_ram_output_register		: STRING;
		intended_device_family		: STRING;
		lpm_numwords                : NATURAL;
		lpm_showahead		        : STRING;
		lpm_type		            : STRING;
		lpm_width		            : NATURAL;
		lpm_widthu		            : NATURAL;
		overflow_checking		    : STRING;
		underflow_checking		    : STRING;
		use_eab		                : STRING
	);
	PORT (
			usedw	: OUT STD_LOGIC_VECTOR (SIZE_E-1 DOWNTO 0);
			rdreq	: IN STD_LOGIC ;
			sclr	: IN STD_LOGIC ;
			empty	: OUT STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			q	    : OUT STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
			wrreq	: IN STD_LOGIC ;
			data	: IN STD_LOGIC_VECTOR (WIDTH-1 DOWNTO 0);
			full	: OUT STD_LOGIC
	);
	END COMPONENT;

begin
    scfifo_component : scfifo
	GENERIC MAP (
		add_ram_output_register => "OFF",
		intended_device_family => "Cyclone II",
		lpm_numwords => 2**SIZE_E,
		lpm_showahead => "ON",
		lpm_type => "scfifo",
		lpm_width => WIDTH,
		lpm_widthu => SIZE_E,
		overflow_checking => "ON",
		underflow_checking => "ON",
		use_eab => "ON"
	)
	PORT MAP (
		rdreq => READ,
		sclr  => CLEAR,
		clock => CLK,
		wrreq => WRITE,
		data  => D,
		usedw => USAGE,
		empty => EMPTY,
		q     => Q,
		full  => FULL
	);
end altera;


