LIBRARY ieee;
USE ieee.std_logic_1164.all;

LIBRARY altera_mf;
USE altera_mf.all;

ENTITY apll IS
  generic (
    freq    : integer := 200;
    mult    : integer := 8;
    div     : integer := 5;
    rskew   : integer := 0
  );
	PORT
	(
    areset      : IN STD_LOGIC  := '0';
    inclk0      : IN STD_LOGIC  := '0';
    phasestep   : IN STD_LOGIC  := '0';
    phaseupdown : IN STD_LOGIC  := '0';
    scanclk     : IN STD_LOGIC  := '1';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		c2		: OUT STD_LOGIC ;
		c3		: OUT STD_LOGIC ;
		c4		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC;
		phasedone		: OUT STD_LOGIC 
	);
END apll;


ARCHITECTURE SYN OF apll IS

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC ;
	SIGNAL sub_wire2	: STD_LOGIC ;
	SIGNAL sub_wire3	: STD_LOGIC ;
	SIGNAL sub_wire4	: STD_LOGIC ;
	SIGNAL sub_wire5	: STD_LOGIC ;
	SIGNAL sub_wire6	: STD_LOGIC ;
	SIGNAL sub_wire7	: STD_LOGIC ;
	SIGNAL sub_wire8	: STD_LOGIC_VECTOR (1 DOWNTO 0);
	SIGNAL sub_wire9_bv	: BIT_VECTOR (0 DOWNTO 0);
	SIGNAL sub_wire9	: STD_LOGIC_VECTOR (0 DOWNTO 0);

  signal phasecounter_reg : std_logic_vector(3 downto 0);
  attribute syn_keep : boolean;
  attribute syn_keep of phasecounter_reg : signal is true;
  attribute syn_preserve : boolean;
  attribute syn_preserve of phasecounter_reg : signal is true;

  constant period : integer := 1000000/freq;

  function set_phase(freq : in integer) return string is
    variable s : string(1 to 4) := "0000";
    variable f,r : integer;
  begin
    f := freq;
    while f /= 0 loop
      r := f mod 10;
      case r is
        when 0 => s := "0" & s(1 to 3);
        when 1 => s := "1" & s(1 to 3);
        when 2 => s := "2" & s(1 to 3);
        when 3 => s := "3" & s(1 to 3);
        when 4 => s := "4" & s(1 to 3);
        when 5 => s := "5" & s(1 to 3);
        when 6 => s := "6" & s(1 to 3);
        when 7 => s := "7" & s(1 to 3);
        when 8 => s := "8" & s(1 to 3);
        when 9 => s := "9" & s(1 to 3);
        when others =>
      end case;
      f := f / 10;
    end loop;
    return s;
  end function;

  type phasevec is array (1 to 3) of string(1 to 4);
  type phasevecarr is array (10 to 21) of phasevec;

  constant phasearr : phasevecarr := (
	  ("2500", "5000", "7500"), ("2273", "4545", "6818"),   -- 100 & 110 MHz
	  ("2083", "4167", "6250"), ("1923", "3846", "5769"),   -- 120 & 130 MHz
	  ("1786", "3571", "5357"), ("1667", "3333", "5000"),   -- 140 & 150 MHz
	  ("1563", "3125", "4688"), ("1471", "2941", "4412"),   -- 160 & 170 MHz
	  ("1389", "2778", "4167"), ("1316", "2632", "3947"),   -- 180 & 190 MHz
	  ("1250", "2500", "3750"), ("1190", "2381", "3571"));  -- 200 & 210 MHz

  --constant pshift_90  : string := phasearr((freq*mult)/(10*div))(1);
  constant pshift_90  : string := set_phase(100000/((4*freq*mult)/(10*div)));
  --constant pshift_180 : string := phasearr((freq*mult)/(10*div))(2);
  constant pshift_180 : string := set_phase(100000/((2*freq*mult)/(10*div)));
  --constant pshift_270 : string := phasearr((freq*mult)/(10*div))(3);
  constant pshift_270 : string := set_phase(300000/((4*freq*mult)/(10*div)));
  
  constant pshift_rclk : string := set_phase(rskew);

	COMPONENT altpll
	GENERIC (
		bandwidth_type		: STRING;
		clk0_divide_by		: NATURAL;
		clk0_duty_cycle		: NATURAL;
		clk0_multiply_by		: NATURAL;
		clk0_phase_shift		: STRING;
		clk1_divide_by		: NATURAL;
		clk1_duty_cycle		: NATURAL;
		clk1_multiply_by		: NATURAL;
		clk1_phase_shift		: STRING;
		clk2_divide_by		: NATURAL;
		clk2_duty_cycle		: NATURAL;
		clk2_multiply_by		: NATURAL;
		clk2_phase_shift		: STRING;
		clk3_divide_by		: NATURAL;
		clk3_duty_cycle		: NATURAL;
		clk3_multiply_by		: NATURAL;
		clk3_phase_shift		: STRING;
		clk4_divide_by		: NATURAL;
		clk4_duty_cycle		: NATURAL;
		clk4_multiply_by		: NATURAL;
		clk4_phase_shift		: STRING;
		compensate_clock		: STRING;
		inclk0_input_frequency		: NATURAL;
		intended_device_family		: STRING;
		lpm_hint		: STRING;
		lpm_type		: STRING;
		operation_mode		: STRING;
		pll_type		: STRING;
		port_activeclock		: STRING;
		port_areset		: STRING;
		port_clkbad0		: STRING;
		port_clkbad1		: STRING;
		port_clkloss		: STRING;
		port_clkswitch		: STRING;
		port_configupdate		: STRING;
		port_fbin		: STRING;
		port_fbout		: STRING;
		port_inclk0		: STRING;
		port_inclk1		: STRING;
		port_locked		: STRING;
		port_pfdena		: STRING;
		port_phasecounterselect		: STRING;
		port_phasedone		: STRING;
		port_phasestep		: STRING;
		port_phaseupdown		: STRING;
		port_pllena		: STRING;
		port_scanaclr		: STRING;
		port_scanclk		: STRING;
		port_scanclkena		: STRING;
		port_scandata		: STRING;
		port_scandataout		: STRING;
		port_scandone		: STRING;
		port_scanread		: STRING;
		port_scanwrite		: STRING;
		port_clk0		: STRING;
		port_clk1		: STRING;
		port_clk2		: STRING;
		port_clk3		: STRING;
		port_clk4		: STRING;
		port_clk5		: STRING;
		port_clk6		: STRING;
		port_clk7		: STRING;
		port_clk8		: STRING;
		port_clk9		: STRING;
		port_clkena0		: STRING;
		port_clkena1		: STRING;
		port_clkena2		: STRING;
		port_clkena3		: STRING;
		port_clkena4		: STRING;
		port_clkena5		: STRING;
		self_reset_on_loss_lock		: STRING;
		using_fbmimicbidir_port		: STRING;
		width_clock		: NATURAL
	);
	PORT (
			phasestep	: IN STD_LOGIC ;
			phaseupdown	: IN STD_LOGIC ;
			inclk	: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			phasecounterselect	: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			locked	: OUT STD_LOGIC ;
			phasedone	: OUT STD_LOGIC ;
			areset	: IN STD_LOGIC ;
			clk	: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			scanclk	: IN STD_LOGIC 
	);
	END COMPONENT;

BEGIN
	sub_wire9_bv(0 DOWNTO 0) <= "0";
	sub_wire9    <= To_stdlogicvector(sub_wire9_bv);
	sub_wire5    <= sub_wire0(4);
	sub_wire4    <= sub_wire0(3);
	sub_wire3    <= sub_wire0(2);
	sub_wire2    <= sub_wire0(1);
	sub_wire1    <= sub_wire0(0);
	c0    <= sub_wire1;
	c1    <= sub_wire2;
	c2    <= sub_wire3;
	c3    <= sub_wire4;
	c4    <= sub_wire5;
	locked    <= sub_wire6;
	sub_wire7    <= inclk0;
	sub_wire8    <= sub_wire9(0 DOWNTO 0) & sub_wire7;

  -- quartus bug, cant be constant
  process(scanclk)
  begin
    if rising_edge(scanclk) then
      phasecounter_reg <= "0110"; --phasecounter;
    end if;
  end process;

	altpll_component : altpll
	GENERIC MAP (
		bandwidth_type => "AUTO",
		clk0_divide_by => div,--5,
		clk0_duty_cycle => 50,
		clk0_multiply_by => mult,--8,
		clk0_phase_shift => "0",
		clk1_divide_by => div,--5,
		clk1_duty_cycle => 50,
		clk1_multiply_by => mult,--8,
		clk1_phase_shift => pshift_90,--"1250",
		clk2_divide_by => div,--5,
		clk2_duty_cycle => 50,
		clk2_multiply_by => mult,--8,
		clk2_phase_shift => pshift_180,--"2500",
		clk3_divide_by => div,--5,
		clk3_duty_cycle => 50,
		clk3_multiply_by => mult,--8,
		clk3_phase_shift => pshift_270,--"3750",
		clk4_divide_by => div,
		clk4_duty_cycle => 50,
		clk4_multiply_by => mult,
		clk4_phase_shift => pshift_rclk,--"0",
		compensate_clock => "CLK0",
		inclk0_input_frequency => period,--8000,
		intended_device_family => "Stratix III",
		lpm_hint => "CBX_MODULE_PREFIX=apll",
		lpm_type => "altpll",
		operation_mode => "NORMAL",
		pll_type => "AUTO",
		port_activeclock => "PORT_UNUSED",
		port_areset => "PORT_USED",
		port_clkbad0 => "PORT_UNUSED",
		port_clkbad1 => "PORT_UNUSED",
		port_clkloss => "PORT_UNUSED",
		port_clkswitch => "PORT_UNUSED",
		port_configupdate => "PORT_UNUSED",
		port_fbin => "PORT_UNUSED",
		port_fbout => "PORT_UNUSED",
		port_inclk0 => "PORT_USED",
		port_inclk1 => "PORT_UNUSED",
		port_locked => "PORT_USED",
		port_pfdena => "PORT_UNUSED",
		port_phasecounterselect => "PORT_USED",
		port_phasedone => "PORT_USED",
		port_phasestep => "PORT_USED",
		port_phaseupdown => "PORT_USED",
		port_pllena => "PORT_UNUSED",
		port_scanaclr => "PORT_UNUSED",
		port_scanclk => "PORT_USED",
		port_scanclkena => "PORT_UNUSED",
		port_scandata => "PORT_UNUSED",
		port_scandataout => "PORT_UNUSED",
		port_scandone => "PORT_UNUSED",
		port_scanread => "PORT_UNUSED",
		port_scanwrite => "PORT_UNUSED",
		port_clk0 => "PORT_USED",
		port_clk1 => "PORT_USED",
		port_clk2 => "PORT_USED",
		port_clk3 => "PORT_USED",
		port_clk4 => "PORT_USED",
		port_clk5 => "PORT_UNUSED",
		port_clk6 => "PORT_UNUSED",
		port_clk7 => "PORT_UNUSED",
		port_clk8 => "PORT_UNUSED",
		port_clk9 => "PORT_UNUSED",
		port_clkena0 => "PORT_UNUSED",
		port_clkena1 => "PORT_UNUSED",
		port_clkena2 => "PORT_UNUSED",
		port_clkena3 => "PORT_UNUSED",
		port_clkena4 => "PORT_UNUSED",
		port_clkena5 => "PORT_UNUSED",
		self_reset_on_loss_lock => "ON",
		using_fbmimicbidir_port => "OFF",
		width_clock => 10
	)
	PORT MAP (
		phasestep => phasestep,
		phaseupdown => phaseupdown,
		inclk => sub_wire8,
		phasecounterselect => phasecounter_reg,
		areset => areset,
		scanclk => scanclk,
		clk => sub_wire0,
		locked => sub_wire6,
    phasedone => phasedone 
	);

END SYN;

