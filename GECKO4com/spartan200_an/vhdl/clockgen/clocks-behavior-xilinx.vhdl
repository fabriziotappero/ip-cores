--------------------------------------------------------------------------------
--            _   _            __   ____                                      --
--           / / | |          / _| |  __|                                     --
--           | |_| |  _   _  / /   | |_                                       --
--           |  _  | | | | | | |   |  _|                                      --
--           | | | | | |_| | \ \_  | |__                                      --
--           |_| |_| \_____|  \__| |____| microLab                            --
--                                                                            --
--           Bern University of Applied Sciences (BFH)                        --
--           Quellgasse 21                                                    --
--           Room HG 4.33                                                     --
--           2501 Biel/Bienne                                                 --
--           Switzerland                                                      --
--                                                                            --
--           http://www.microlab.ch                                           --
--------------------------------------------------------------------------------
--   GECKO4com
--  
--   2010/2011 Dr. Theo Kluter
--  
--   This VHDL code is free code: you can redistribute it and/or modify
--   it under the terms of the GNU General Public License as published by
--   the Free Software Foundation, either version 3 of the License, or
--   (at your option) any later version.
--  
--   This VHDL code is distributed in the hope that it will be useful,
--   but WITHOUT ANY WARRANTY; without even the implied warranty of
--   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--   GNU General Public License for more details. 
--   You should have received a copy of the GNU General Public License
--   along with these sources.  If not, see <http://www.gnu.org/licenses/>.
--

LIBRARY unisim;
USE unisim.all;

ARCHITECTURE xilinx OF clocks IS

   COMPONENT DCM
	generic
	(
		CLKDV_DIVIDE : real := 2.0;
		CLKFX_DIVIDE : integer := 1;
		CLKFX_MULTIPLY : integer := 4;
		CLKIN_DIVIDE_BY_2 : boolean := false;
		CLKIN_PERIOD : real := 10.0;
		CLKOUT_PHASE_SHIFT : string := "NONE";
		CLK_FEEDBACK : string := "1X";
		DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
		DFS_FREQUENCY_MODE : string := "LOW";
		DLL_FREQUENCY_MODE : string := "LOW";
		DSS_MODE : string := "NONE";
		DUTY_CYCLE_CORRECTION : boolean := true;
		FACTORY_JF : bit_vector := X"C080";
		PHASE_SHIFT : integer := 0;
		STARTUP_WAIT : boolean := false                     --non-simulatable
	);
	port
	(
		CLK0 : out std_ulogic := '0';
		CLK180 : out std_ulogic := '0';
		CLK270 : out std_ulogic := '0';
		CLK2X : out std_ulogic := '0';
		CLK2X180 : out std_ulogic := '0';
		CLK90 : out std_ulogic := '0';
		CLKDV : out std_ulogic := '0';
		CLKFX : out std_ulogic := '0';
		CLKFX180 : out std_ulogic := '0';
		LOCKED : out std_ulogic := '0';
		PSDONE : out std_ulogic := '0';
		STATUS : out std_logic_vector(7 downto 0) := "00000000";
		CLKFB : in std_ulogic := '0';
		CLKIN : in std_ulogic := '0';
		DSSEN : in std_ulogic := '0';
		PSCLK : in std_ulogic := '0';
		PSEN : in std_ulogic := '0';
		PSINCDEC : in std_ulogic := '0';
		RST : in std_ulogic := '0'
	);
   END COMPONENT;
   
   COMPONENT BUFG
      PORT ( I  : IN  std_logic;
             O  : OUT std_logic );
   END COMPONENT;
   
   COMPONENT FD
      GENERIC ( INIT : bit );
      PORT( C : IN  std_logic;
            D : IN  std_logic;
            Q : OUT std_logic );
   END COMPONENT;
   
   SIGNAL s_user_clock_1_reset_reg : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_user_clock_1_reset     : std_logic;
   SIGNAL s_user_clock_1_out_ub    : std_logic;
   SIGNAL s_user_clock_2_reset_reg : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_user_clock_2_reset     : std_logic;
   SIGNAL s_user_clock_2_out_ub    : std_logic;
   SIGNAL s_lock_48_mul            : std_logic;
   SIGNAL s_48MHz_mul              : std_logic;
   SIGNAL s_mul_reset_count_reg    : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_clk_48_ubuf            : std_logic;
   SIGNAL s_clk_96_ubuf            : std_logic;
   SIGNAL s_clk_75_ubuf            : std_logic;
   SIGNAL s_clk_48MHz              : std_logic;
   SIGNAL s_clk_96MHz              : std_logic;
   SIGNAL s_lock_48                : std_logic;
   SIGNAL s_reset_count_reg        : std_logic_vector( 7 DOWNTO 0 );
   SIGNAL s_clock_div_reg          : std_logic;
   SIGNAL s_msec_counter_reg       : std_logic_vector(16 DOWNTO 0 );
   
BEGIN
--------------------------------------------------------------------------------
--- Here some outputs are defined                                            ---
--------------------------------------------------------------------------------
   clk_48MHz       <= s_clk_48MHz;
   clk_96MHz       <= s_clk_96MHz;
   reset_out       <= s_reset_count_reg(7);
   msec_tick       <= s_msec_counter_reg(16);
   
   make_clock_div_reg : PROCESS( s_reset_count_reg , s_clk_96MHz )
   BEGIN
      IF (s_reset_count_reg(7) = '1') THEN s_clock_div_reg <= '0';
      ELSIF (s_clk_96MHz'event AND (s_clk_96MHz = '1')) THEN
         s_clock_div_reg <= NOT(s_clock_div_reg);
      END IF;
   END PROCESS make_clock_div_reg;
   
   clk48_ff : FD
              GENERIC MAP ( INIT => '0' )
              PORT MAP ( C => s_clk_96MHz,
                         D => s_clock_div_reg,
                         Q => clock_48MHz_out );
   
   make_msec_counter : PROCESS( s_clk_48MHz , s_reset_count_reg , 
                                s_msec_counter_reg )
   BEGIN
      IF (s_reset_count_reg(7) = '1') THEN
         s_msec_counter_reg <= (OTHERS => '0');
      ELSIF (s_clk_48MHz'event AND (s_clk_48MHz = '1')) THEN
         IF (s_msec_counter_reg(16) = '1') THEN
            s_msec_counter_reg <= "0"&X"BB7E";
                                           ELSE
            s_msec_counter_reg <= unsigned(s_msec_counter_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_msec_counter;
   
--------------------------------------------------------------------------------
--- Here all internal FPGA signals are generated                             ---
--------------------------------------------------------------------------------
   dcm3 : DCM
          GENERIC MAP (  CLKDV_DIVIDE          => 2.0,
                         CLKFX_DIVIDE          => 1,
                         CLKFX_MULTIPLY        => 3,
                         CLKIN_DIVIDE_BY_2     => false,
                         CLKIN_PERIOD          => 62.5,
                         CLKOUT_PHASE_SHIFT    => "NONE",
                         CLK_FEEDBACK          => "NONE",
                         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
                         DFS_FREQUENCY_MODE    => "LOW",
                         DLL_FREQUENCY_MODE    => "LOW",
                         DSS_MODE              => "NONE",
                         DUTY_CYCLE_CORRECTION => true,
                         FACTORY_JF            => X"C080",
                         PHASE_SHIFT           => 0,
                         STARTUP_WAIT          => false )
	       PORT MAP ( CLK0     => OPEN,
                     CLK180   => OPEN,
                     CLK270   => OPEN,
                     CLK2X    => OPEN,
                     CLK2X180 => OPEN,
                     CLK90    => OPEN,
                     CLKDV    => OPEN,
                     CLKFX    => s_48MHz_mul,
                     CLKFX180 => OPEN,
                     LOCKED   => s_lock_48_mul,
                     PSDONE   => OPEN,
                     STATUS   => OPEN,
                     CLKFB    => '0',
                     CLKIN    => clock_16MHz,
                     DSSEN    => '1',
                     PSCLK    => '0',
                     PSEN     => '0',
                     PSINCDEC => '0',
                     RST	   => '0');
   make_mul_reset_counter : PROCESS( s_48MHz_mul , s_lock_48_mul )
   BEGIN
      IF (s_lock_48_mul = '0') THEN s_mul_reset_count_reg <= (OTHERS => '1');
      ELSIF (s_48MHz_mul'event AND (s_48MHz_mul = '1')) THEN
         IF (s_mul_reset_count_reg(7) = '1') THEN
            s_mul_reset_count_reg <= unsigned(s_mul_reset_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_mul_reset_counter;
   
   dcm4 : DCM
          GENERIC MAP (  CLKDV_DIVIDE          => 2.0,
                         CLKFX_DIVIDE          => 16,
                         CLKFX_MULTIPLY        => 25,
                         CLKIN_DIVIDE_BY_2     => false,
                         CLKIN_PERIOD          => 20.83,
                         CLKOUT_PHASE_SHIFT    => "NONE",
                         CLK_FEEDBACK          => "1X",
                         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
                         DFS_FREQUENCY_MODE    => "LOW",
                         DLL_FREQUENCY_MODE    => "LOW",
                         DSS_MODE              => "NONE",
                         DUTY_CYCLE_CORRECTION => true,
                         FACTORY_JF            => X"C080",
                         PHASE_SHIFT           => 0,
                         STARTUP_WAIT          => false )
	       PORT MAP ( CLK0     => s_clk_48_ubuf,
                     CLK180   => OPEN,
                     CLK270   => OPEN,
                     CLK2X    => s_clk_96_ubuf,
                     CLK2X180 => OPEN,
                     CLK90    => OPEN,
                     CLKDV    => OPEN,
                     CLKFX    => s_clk_75_ubuf,
                     CLKFX180 => OPEN,
                     LOCKED   => s_lock_48,
                     PSDONE   => OPEN,
                     STATUS   => OPEN,
                     CLKFB    => s_clk_48MHz,
                     CLKIN    => s_48MHz_mul,
                     DSSEN    => '1',
                     PSCLK    => '0',
                     PSEN     => '0',
                     PSINCDEC => '0',
                     RST	   => s_mul_reset_count_reg(7));
   buf3 : BUFG
          PORT MAP ( I => s_clk_48_ubuf,
                     O => s_clk_48MHz );
   buf4 : BUFG
          PORT MAP ( I => s_clk_96_ubuf,
                     O => s_clk_96MHz );
   buf5 : BUFG
          PORT MAP ( I => s_clk_75_ubuf,
                     O => clk_75MHz );

   make_reset_count_reg : PROCESS( s_clk_48MHz , s_lock_48 )
   BEGIN
      IF (s_lock_48 = '0') THEN s_reset_count_reg <= (OTHERS => '1');
      ELSIF (s_clk_48MHz'event AND (s_clk_48MHz = '1')) THEN
         IF (s_reset_count_reg(7) = '1') THEN
            s_reset_count_reg <= unsigned(s_reset_count_reg) - 1;
         END IF;
      END IF;
   END PROCESS make_reset_count_reg;

--------------------------------------------------------------------------------
--- Here the 25MHz is defined                                                ---
--------------------------------------------------------------------------------
   clock_25MHz_out <= NOT(clock_25MHz);

--------------------------------------------------------------------------------
--- Here the user clocks are defined                                         ---
--------------------------------------------------------------------------------
   make_user_clock_1_reset_reg : PROCESS( user_clock_1 , system_n_reset )
   BEGIN
      IF (system_n_reset = '0') THEN s_user_clock_1_reset_reg <= (OTHERS => '0');
      ELSIF (user_clock_1'event AND (user_clock_1 = '1')) THEN
         IF (s_user_clock_1_reset_reg(7) = '0') THEN
            s_user_clock_1_reset_reg <= unsigned(s_user_clock_1_reset_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_user_clock_1_reset_reg;
   
   s_user_clock_1_reset <= NOT(s_user_clock_1_reset_reg(7));
   
   dcm1 : DCM
          GENERIC MAP (  CLKDV_DIVIDE          => 2.0,
                         CLKFX_DIVIDE          => 1,
                         CLKFX_MULTIPLY        => 3,
                         CLKIN_DIVIDE_BY_2     => false,
                         CLKIN_PERIOD          => 10.0,
                         CLKOUT_PHASE_SHIFT    => "NONE",
                         CLK_FEEDBACK          => "1X",
                         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
                         DFS_FREQUENCY_MODE    => "LOW",
                         DLL_FREQUENCY_MODE    => "LOW",
                         DSS_MODE              => "NONE",
                         DUTY_CYCLE_CORRECTION => true,
                         FACTORY_JF            => X"C080",
                         PHASE_SHIFT           => 0,
                         STARTUP_WAIT          => false )
	       PORT MAP ( CLK0     => s_user_clock_1_out_ub,
                     CLK180   => OPEN,
                     CLK270   => OPEN,
                     CLK2X    => OPEN,
                     CLK2X180 => OPEN,
                     CLK90    => OPEN,
                     CLKDV    => OPEN,
                     CLKFX    => OPEN,
                     CLKFX180 => OPEN,
                     LOCKED   => user_clock_1_lock,
                     PSDONE   => OPEN,
                     STATUS   => OPEN,
                     CLKFB    => user_clock_1_fb,
                     CLKIN    => user_clock_1,
                     DSSEN    => '1',
                     PSCLK    => '0',
                     PSEN     => '0',
                     PSINCDEC => '0',
                     RST	   => s_user_clock_1_reset);
   buf1 : BUFG
          PORT MAP ( I  => s_user_clock_1_out_ub,
                     O  => user_clock_1_out );

   make_user_clock_2_reset_reg : PROCESS( user_clock_2 , system_n_reset )
   BEGIN
      IF (system_n_reset = '0') THEN s_user_clock_2_reset_reg <= (OTHERS => '0');
      ELSIF (user_clock_2'event AND (user_clock_2 = '1')) THEN
         IF (s_user_clock_2_reset_reg(7) = '0') THEN
            s_user_clock_2_reset_reg <= unsigned(s_user_clock_2_reset_reg) + 1;
         END IF;
      END IF;
   END PROCESS make_user_clock_2_reset_reg;
   
   s_user_clock_2_reset <= NOT(s_user_clock_2_reset_reg(7));
   
   dcm2 : DCM
          GENERIC MAP (  CLKDV_DIVIDE          => 2.0,
                         CLKFX_DIVIDE          => 1,
                         CLKFX_MULTIPLY        => 3,
                         CLKIN_DIVIDE_BY_2     => false,
                         CLKIN_PERIOD          => 10.0,
                         CLKOUT_PHASE_SHIFT    => "NONE",
                         CLK_FEEDBACK          => "1X",
                         DESKEW_ADJUST         => "SYSTEM_SYNCHRONOUS",
                         DFS_FREQUENCY_MODE    => "LOW",
                         DLL_FREQUENCY_MODE    => "LOW",
                         DSS_MODE              => "NONE",
                         DUTY_CYCLE_CORRECTION => true,
                         FACTORY_JF            => X"C080",
                         PHASE_SHIFT           => 0,
                         STARTUP_WAIT          => false )
	       PORT MAP ( CLK0     => s_user_clock_2_out_ub,
                     CLK180   => OPEN,
                     CLK270   => OPEN,
                     CLK2X    => OPEN,
                     CLK2X180 => OPEN,
                     CLK90    => OPEN,
                     CLKDV    => OPEN,
                     CLKFX    => OPEN,
                     CLKFX180 => OPEN,
                     LOCKED   => user_clock_2_lock,
                     PSDONE   => OPEN,
                     STATUS   => OPEN,
                     CLKFB    => user_clock_2_fb,
                     CLKIN    => user_clock_2,
                     DSSEN    => '1',
                     PSCLK    => '0',
                     PSEN     => '0',
                     PSINCDEC => '0',
                     RST	   => s_user_clock_2_reset);
   buf2 : BUFG
          PORT MAP ( I  => s_user_clock_2_out_ub,
                     O  => user_clock_2_out );
END xilinx;
