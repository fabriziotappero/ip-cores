----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:05:52 11/22/2009 
-- Design Name: 
-- Module Name:    top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity vga is
    Port ( VGA_R : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_G : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_B : out  STD_LOGIC_VECTOR (3 downto 0);
           VGA_HSYNC : out  STD_LOGIC := '0';
           VGA_VSYNC : out  STD_LOGIC := '0';
           CLK_50M : in STD_LOGIC;
			  CLK_133M33 : in STD_LOGIC);
end vga;

architecture Behavioral of vga is
  signal VGA_CLK : std_logic;

	-- displayed stuff
  signal cell : std_logic := '1';
  signal fbwa, fbra : integer range 0 to 2048-1;
  signal fbwe : boolean := false;
  signal fbwd, fbrd : std_logic;
  type linebuffer is array (0 to 2048-1) of std_logic;
  signal pixels : linebuffer;

  type modeline is record
    pixelclock : real;     -- calculations for the DCM need to be done by hand
    hdisp      : positive;
	 hsyncstart : positive;
	 hsyncend   : positive;
	 htotal     : positive;
	 vdisp      : positive;
	 vsyncstart : positive;
	 vsyncend   : positive;
	 vtotal     : positive;
	 hpulse     : std_logic;  -- pulse level (i.e. '0' for -hsync, or '1' for +hsync)
	 vpulse     : std_logic;
  end record modeline;

  -- Modelines taken from http://www.mythtv.org/wiki/Modeline_Database

  -- 640x480 VGA -- all -vsync -hsync
  constant VGA60: modeline := (25.18, 640, 656, 752, 800, 480, 490, 492, 525, '0', '0');  -- pitifully, 25 is as close as I get.
  constant VGA75: modeline := (31.50, 640, 656, 720, 840, 480, 481, 484, 500, '0', '0');  -- 50/27*17 ~ 31.48
  -- from VESA modepool
  constant SXGA60: modeline := (108.00, 1280, 1328, 1440, 1688, 1024, 1025, 1028, 1066, '1', '1'); -- 108 ~ 50/6*13 ~ 133.33/21*17
  -- 1920x1200@60Hz nvidia mode pool
  constant WUXGA60: modeline := (193.16, 1920, 2048, 2256, 2592, 1200, 1201, 1204, 1242, '1', '1'); -- 193.16 ~ 50/7*27 ~ 133.33/11*16

  constant mode: modeline := SXGA60;
  alias pixclksrc is CLK_133M33;
  constant pixclkperiod: real := 7.5;
  constant pixclkdiv: positive := 21;
  constant pixclkmul: positive := 17;

--  constant mode: modeline := VGA60;
--  alias pixclksrc is CLK_50M;
--  constant pixclkperiod: real := 20.0;
--  constant pixclkdiv: positive := 4;
--  constant pixclkmul: positive := 2;

  signal column: integer range 0 to mode.htotal-1 := 0;
  signal row: integer range 0 to mode.vtotal-1 := 0;
  
  signal vblank, hblank, linestart, framestart : boolean := false;
begin
   DCM_1 : DCM_SP
   generic map (                        -- synthesize 193.33MHz; we're a bit off.
      --CLKDV_DIVIDE => 2.0, --  Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5
                           --     7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
      CLKFX_DIVIDE => pixclkdiv,   --  Can be any interger from 1 to 32
      CLKFX_MULTIPLY => pixclkmul, --  Can be any integer from 1 to 32
      --CLKIN_DIVIDE_BY_2 => FALSE, --  TRUE/FALSE to enable CLKIN divide by two feature
      CLKIN_PERIOD => pixclkperiod,--20.0, --  Specify period of input clock
      --CLKOUT_PHASE_SHIFT => "NONE", --  Specify phase shift of "NONE", "FIXED" or "VARIABLE" 
      CLK_FEEDBACK => "NONE",         --  Specify clock feedback of "NONE", "1X" or "2X" 
      --DESKEW_ADJUST => "SYSTEM_SYNCHRONOUS", -- "SOURCE_SYNCHRONOUS", "SYSTEM_SYNCHRONOUS" or
                                             --     an integer from 0 to 15
      --DLL_FREQUENCY_MODE => "LOW",     -- "HIGH" or "LOW" frequency mode for DLL
      DUTY_CYCLE_CORRECTION => TRUE, --  Duty cycle correction, TRUE or FALSE
      PHASE_SHIFT => 0,        --  Amount of fixed phase shift from -255 to 255
      STARTUP_WAIT => TRUE) --  Delay configuration DONE until DCM_SP LOCK, TRUE/FALSE
   port map (
      --CLK0 => open,     -- 0 degree DCM CLK ouptput
      --CLK180 => open, -- 180 degree DCM CLK output
      --CLK270 => open, -- 270 degree DCM CLK output
      --CLK2X => open,   -- 2X DCM CLK output
      --CLK2X180 => open, -- 2X, 180 degree DCM CLK out
      --CLK90 => open,   -- 90 degree DCM CLK output
      --CLKDV => open,   -- Divided DCM CLK out (CLKDV_DIVIDE)
      CLKFX => VGA_CLK,   -- DCM CLK synthesis out (M/D)
      --CLKFX180 => open, -- 180 degree CLK synthesis out
      --LOCKED => AWAKE, -- DCM LOCK status output
      --PSDONE => open, -- Dynamic phase adjust done output
      --STATUS => open, -- 8-bit DCM status bits output
      --CLKFB => open,   -- DCM clock feedback
      CLKIN => pixclksrc,   -- Clock input (from IBUFG, BUFG or DCM)
      --PSCLK => open,   -- Dynamic phase adjust clock input
      --PSEN => open,     -- Dynamic phase adjust enable input
      --PSINCDEC => open, -- Dynamic phase adjust increment/decrement
      RST => '0'        -- DCM asynchronous reset input
   );

  sync: process (VGA_CLK)
  begin
    if rising_edge(VGA_CLK) then
	   linestart <= false;
	   if column=mode.htotal-1 then
		  column <= 0;
		else
		  column <= column+1;
		end if;
		case column is
		  when mode.hdisp-1 =>
		    hblank <= true;
		  when mode.hsyncstart =>
		    VGA_HSYNC <= mode.hpulse;
          framestart <= false;
		    case row is
		      when mode.vsyncstart =>
		        VGA_VSYNC <= mode.vpulse;
		      when mode.vsyncend =>
		        VGA_VSYNC <= not mode.vpulse;
			   when mode.vdisp-1 =>
			     vblank <= true;
			   when mode.vtotal-1 =>
			     vblank <= false;
				  framestart <= true;
				when others =>
				  null;
		    end case;
	       if row=mode.vtotal-1 then
		      row <= 0;
		    else
		      row <= row+1;
		    end if;
		  when mode.hsyncend =>
		    VGA_HSYNC <= not mode.hpulse;
		  when mode.htotal-1 =>
		    linestart <= true;
			 hblank <= false;
		  when others =>
		    null;
		end case;
	 end if;
  end process;
  
  memwr: process (VGA_CLK)
  begin  -- process memwr
    if VGA_CLK'event and VGA_CLK = '1' then  -- rising clock edge
      if fbwe then
        pixels(fbwa) <= fbwd;
      end if;
    end if;
  end process memwr;
  memrd: process (VGA_CLK)
  begin
    if rising_edge(VGA_CLK) then
      fbrd <= pixels(fbra);
    end if;
  end process memrd;

  -- purpose: calculates upcoming pixels
  -- type   : sequential
  -- inputs : VGA_CLK, vblank, newline
  -- outputs: cell
  wolfram: process (VGA_CLK)
    variable rule : unsigned(7 downto 0) := to_unsigned(30,8);
    variable x : integer range 0 to 2048-1 := 0;
    variable x0 : integer range 0 to 4 := 0;
    constant init : unsigned(0 to 4) := "00101";
    variable prev : unsigned(0 to 2) := "000";
  begin  -- process
    if rising_edge(VGA_CLK) then
      fbwe<=true;
      if linestart then
        x:=0;
        x0:=0;
      elsif x/=2048-1 then
        x:=x+1;
      end if;
      fbwa<=x;
		fbra<=x+4;
      if framestart then
        -- Wolfram rules:
        -- the three prior cells (left, self, right) are read as a binary number
        -- the rule number is converted to binary; each bit position corresponds
        -- to a configuration. thus, rule 34 is
        --  00100010 - only configuration 1 and 5 lead to state 1.
        -- that's 001 and 101, so the rule can only grow in one diagonal direction
		  cell <= '0';
		  fbwd <= '0';
		  -- initial conditions for different rules
		  case to_integer(rule) is
		    when 34 =>
            fbwd<=init(x0);
            cell <= init(x0);
          when others =>
			   if x=mode.hdisp/2 then
		          fbwd <= '1';
			       cell <= '1';
            end if;
		  end case;
        if x0=4 then
          x0:=0;
        else
          x0:=x0+1;
        end if;
        prev:="0"&init(0 to 1);         -- first two pixels will be strange :/
      else
		  fbwd<=rule(to_integer(prev));
		  cell<=rule(to_integer(prev));
        prev(0 to 1):=prev(1 to 2);
        if x<mode.hdisp-1 then
          prev(2):=fbrd;
        else
          prev(2):='1';
        end if;
      end if;
    end if;
  end process wolfram;
  
   -- purpose: output a signal to the VGA port
   -- type   : sequential
   -- inputs : VGA_CLK
   -- outputs: VGA_R, VGA_G, VGA_B, VGA_HSYNC, VGA_VSYNC
   vgaout: process (VGA_CLK)
	  variable vdisparea : boolean := false;
   begin  -- process vgaout
     if rising_edge(VGA_CLK) then
       -- pixel value output
       if not (hblank or vblank) then
         case column is
           when 0|mode.hdisp-1 =>
             VGA_R <= (others => '1');
             VGA_G <= (others => '1');
             VGA_B <= (others => '1');
           when others =>
             case row is
               when 0|mode.vdisp-1 =>
                 VGA_R <= (others => '1');
                 VGA_G <= (others => '1');
                 VGA_B <= (others => '1');
               when others =>
                 VGA_R <= (others => cell);
                 VGA_G <= (others => cell);
                 VGA_B <= (others => cell);
             end case;
         end case;
       else
         VGA_R <= (others => '0');
         VGA_G <= (others => '0');
         VGA_B <= (others => '0');
       end if;
     end if;
   end process vgaout;

end Behavioral;

