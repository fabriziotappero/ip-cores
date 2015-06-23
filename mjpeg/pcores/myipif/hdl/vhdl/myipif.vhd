library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;


entity myipif is
  generic
    (
      C_BASEADDR   : std_logic_vector := X"50000000";
      C_HIGHADDR   : std_logic_vector := X"5000FFFF";
      C_OPB_AWIDTH : integer          := 32;
      C_OPB_DWIDTH : integer          := 32;
      C_FAMILY     : string           := "virtex2p";
      C_SDRAM_ADDR : std_logic_vector := X"00000000"
    );
  port
    (
      OPB_Clk      : in  std_logic;
      OPB_Rst      : in  std_logic;
      -- slave
      Sl_DBus      : out std_logic_vector(0 to C_OPB_DWIDTH-1);
      Sl_errAck    : out std_logic;
      Sl_retry     : out std_logic;
      Sl_toutSup   : out std_logic;
      Sl_xferAck   : out std_logic;
      OPB_ABus     : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
      OPB_BE       : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      OPB_DBus     : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
      OPB_RNW      : in  std_logic;
      OPB_select   : in  std_logic;
      OPB_seqAddr  : in  std_logic;
      -- master
      M_ABus       : out std_logic_vector(0 to C_OPB_AWIDTH-1);
      M_BE         : out std_logic_vector(0 to C_OPB_DWIDTH/8-1);
      M_busLock    : out std_logic;
      M_request    : out std_logic;
      M_RNW        : out std_logic;
      M_select     : out std_logic;
      M_seqAddr    : out std_logic;
      OPB_errAck   : in  std_logic;
      OPB_MGrant   : in  std_logic;
      OPB_retry    : in  std_logic;
      OPB_timeout  : in  std_logic;
      OPB_xferAck  : in  std_logic;
		
      LEDs         : out std_logic_vector(3 downto 0);
		BUTTONs      : in std_logic_vector(4 downto 0); -- 0:left, 1:right, 2:up, 3:down, 4:center
		SWITCHEs     : in std_logic_vector(3 downto 0);

		VGA_OUT_PIXEL_CLOCK: 	out STD_LOGIC;
		VGA_COMP_SYNCH: 			out STD_LOGIC;
		VGA_OUT_BLANK_Z: 			out STD_LOGIC;
		VGA_HSYNCH: 				out STD_LOGIC;
		VGA_VSYNCH: 				out STD_LOGIC;
		VGA_OUT_RED: 				out STD_LOGIC_VECTOR (7 downto 0);
		VGA_OUT_GREEN: 			out STD_LOGIC_VECTOR (7 downto 0);
		VGA_OUT_BLUE: 				out STD_LOGIC_VECTOR (7 downto 0)
    );
end entity myipif;



architecture IMP of myipif is


-- **********************************************************************************************
-- * Components
-- **********************************************************************************************

--------------------------------------------------------------
---- Chipscope Stuff
--------------------------------------------------------------
--	component icon
--	port (
--		control0    :   out std_logic_vector(35 downto 0));
--	end component;
--	
--	component ila
--	port(
--		control     : in    std_logic_vector(35 downto 0);
--		clk         : in    std_logic;
--		trig0       : in    std_logic_vector(127 downto 0));
--	end component;
--  
--	signal control0	: std_logic_vector(35 downto 0);
--	signal trig0		: std_logic_vector(127 downto 0);
------------------------------------------------------------



--------------------------------------------------------------
-- JPEG - Decoder
--------------------------------------------------------------
component jpeg is
  port(
    	Clk			:  in std_logic;
		data_i		:  in std_logic_vector(31 downto 0);
		reset_i		:  in std_logic;

		eoi_o			: out std_logic;	
		error_o		: out std_logic;
		
		context_o	: out std_logic_vector (3 downto 0);	
		red_o			: out STD_LOGIC_VECTOR (7 downto 0);
		green_o		: out STD_LOGIC_VECTOR (7 downto 0);
		blue_o		: out STD_LOGIC_VECTOR (7 downto 0);
		width_o		: out std_logic_vector(15 downto 0);
		height_o		: out std_logic_vector(15 downto 0);	
		sampling_o	: out std_logic_vector( 1 downto 0);
	
--		-- debug
--      LEDs			: out std_logic_vector(3 downto 0);
--		BUTTONs		:  in std_logic_vector(4 downto 0); -- 0:left, 1:right, 2:up, 3:down, 4:center
--		SWITCHEs		:  in std_logic_vector(3 downto 0);
--		-- chipscope-debugging
--		chipscope_o	: out std_logic_vector(127 downto 0);
--
		-- flow controll
		datavalid_i :  in std_logic;
		datavalid_o : out std_logic;
		ready_i		:  in std_logic;
		ready_o		: out std_logic
    );
end component jpeg;
------------------------------------------------------------



------------------------------------------------------------
-- VGA-handling
------------------------------------------------------------
component vga is
	port(
		Clk			: in std_logic;
		reset_i		: in std_logic;	
		eoi_i			: in std_logic;	
		
		red_i 		: in STD_LOGIC_VECTOR (7 downto 0);
		green_i		: in  STD_LOGIC_VECTOR (7 downto 0);
		blue_i		: in  STD_LOGIC_VECTOR (7 downto 0);
		width_i		: in  std_logic_vector(15 downto 0);
		height_i		: in  std_logic_vector(15 downto 0);	
		sampling_i	: in  std_logic_vector( 1 downto 0);

		VGA_OUT_PIXEL_CLOCK: 	out STD_LOGIC;
		VGA_COMP_SYNCH: 			out STD_LOGIC;
		VGA_OUT_BLANK_Z: 			out STD_LOGIC;
		VGA_HSYNCH: 				out STD_LOGIC;
		VGA_VSYNCH: 				out STD_LOGIC;
		VGA_OUT_RED: 				out STD_LOGIC_VECTOR (7 downto 0);
		VGA_OUT_GREEN: 			out STD_LOGIC_VECTOR (7 downto 0);
		VGA_OUT_BLUE: 				out STD_LOGIC_VECTOR (7 downto 0);

--		-- chipscope-debugging
--		chipscope_o	: out std_logic_vector(127 downto 0);

		-- flow controll
		datavalid_i :  in std_logic;
		ready_o		: out std_logic
	);
end component vga;
------------------------------------------------------------


-- **********************************************************************************************
-- * Signals
-- ********************************************************************************************** 
  type OPB_states is (idle, MasterRead1, MasterRead2);
  signal OPB_state, OPB_next_state: OPB_states := idle;

  signal Sl_DBus_D      : std_logic_vector(0 to C_OPB_DWIDTH-1);
  signal Sl_toutSup_D   : std_logic;
  signal Sl_xferAck_D   : std_logic;
  signal Sl_retry_D     : std_logic;
  signal Sl_errAck_D    : std_logic;
  signal M_ABus_D       : std_logic_vector(0 to C_OPB_AWIDTH-1);
  signal M_BE_D         : std_logic_vector(0 to C_OPB_DWIDTH/8-1);
  signal M_busLock_D    : std_logic;
  signal M_request_D    : std_logic;
  signal M_RNW_D        : std_logic;
  signal M_select_D     : std_logic;
  signal M_seqAddr_D    : std_logic;
    
  signal SLAVE_MEM : std_logic_vector (0 to 31);
  signal MASTER_MEM : std_logic_vector (0 to 31);
  signal MASTER_MEM_SET : std_logic;
  
  signal ddr_address: std_logic_vector(31 downto 0) :=X"00000000";
  signal we: std_logic :='0';
  signal go, go_D : std_logic :='0';
  signal burst, burst_D : std_logic :='1';
  signal reset, reset_D, last_reset : std_logic :='1';
  
	-- jpeg
	signal jpeg_OPB_datavalid : std_logic :='0';
	signal jpeg_width, jpeg_height : std_logic_vector(15 downto 0) :=(others=>'0');
	signal jpeg_sampling : std_logic_vector(1 downto 0) :=(others=>'0');
	signal jpeg_red, jpeg_green, jpeg_blue : std_logic_vector(7 downto 0) :=(others=>'0');
	signal jpeg_error, jpeg_eoi, jpeg_datavalid, jpeg_ready : std_logic :='0';
	signal jpeg_context : std_logic_vector(3 downto 0) :=(others=>'0');

	-- vga
	signal vga_ready : std_logic :='0';

--	-- debug
--	signal jpeg_chipscope : std_logic_vector(127 downto 0) :=(others=>'0');
--	signal vga_chipscope : std_logic_vector(127 downto 0) :=(others=>'0');
--	signal BUTTONs_deb : std_logic_vector(4 downto 0) :=(others=>'1'); 
--	signal SWITCHEs_deb, SWITCHEs_deb_D : std_logic_vector(3 downto 0) :=(others=>'1'); 
--	signal LEDs_intern : std_logic_vector(3 downto 0) := "1111";

	-- quick n dirty
	type address_states is (repeat_frame, continue);
	signal address_state, address_state_D : address_states := repeat_frame;

	signal eoi_counter, eoi_counter_D : std_logic_vector(3 downto 0) :=(others=>'0');
	signal eoi_counter_threshold, eoi_counter_threshold_D : std_logic_vector(3 downto 0) :="0001";
	signal old_ddr_address, old_ddr_address_D : std_logic_vector(31 downto 0) :=X"00000000";
	signal soi, soi_D, eoi, eoi_D, eoi_hold, eoi_hold_D : std_logic :='0'; 
	signal received_ff, received_ff_D : std_logic :='0';

	signal pause, pause_D : std_logic :='1';
	signal slower, slower_D, last_slower : std_logic :='1';
	signal faster, faster_D, last_faster : std_logic :='1';
	signal next_frame, next_frame_D : std_logic :='0';



begin 

-- **********************************************************************************************
-- * Debugging
-- **********************************************************************************************

--------------------------------------------------------------
---- Chipscope Stuff
--------------------------------------------------------------
--i_icon : icon
--port map( 
--	control0    => control0 
--);
--
--i_ila : ila
--port map(
--	control   => control0,
--	clk       => OPB_Clk,
--	trig0     => trig0 
--);
	

--process(SWITCHES_deb)
--begin
--	case SWITCHES_deb is
--		when "1111" =>
--			trig0 <= ddr_address & 
----						jpeg_width & jpeg_height &
--						old_ddr_address &
----						jpeg_red & jpeg_green & jpeg_blue & jpeg_error & jpeg_eoi & jpeg_datavalid & jpeg_ready & jpeg_context &
--						OPB_DBus &
--						vga_ready & go & burst & reset & "000" & address_state_cs_flag  & we & jpeg_ready & jpeg_context & jpeg_error & received_ff & jpeg_eoi & pause & next_frame & slower & faster & eoi_hold & eoi & soi & eoi_counter_threshold & eoi_counter;
--		when "1110" =>
--			trig0 <= vga_chipscope;
--		when "1101" =>	
--			trig0 <= jpeg_chipscope;
------		when "0011" =>
----		when "0100" =>
----		when "0101" =>
----		when "0110" =>
----		when "0111" =>
----		when "1000" =>
----		when "1001" =>
----		when "1010" =>
----		when "1011" =>
----		when "1100" =>
----		when "1101" =>
----		when "1110" =>
--		when others =>
--	end case;
--end process;
--------------------------------------------------------------


------------------------------------------------------------------
---- LEDs debugging
------------------------------------------------------------------
--process(LEDs_intern, SWITCHEs_deb)
--begin
--	case SWITCHEs_deb is
--	when "1111" => 
--		LEDs <= LEDs_intern;
--	when "1110" => 
--		LEDs <= not jpeg_sampling & not jpeg_error & not go;
--	when "1101" =>
--		LEDs <= eoi_counter_threshold;
--	when "1100" =>
--		LEDs <= not OPB_retry & not OPB_xferAck & not OPB_timeout & not jpeg_error;
--	when "1001" =>
--		LEDs <= not OPB_retry_hold & not OPB_xferAck_hold & not OPB_timeout_hold & not jpeg_error;
--	when others =>
--		LEDs <= go & burst & burst & go;
--	end case;
--end process;
------------------------------------------------------------------

-- **********************************************************************************************
-- * debounce buttons and switches 
-- **********************************************************************************************
--process(OPB_Clk)
--begin
--	if rising_edge(OPB_Clk) then
--		counter <= counter + 1;
--		last_counter <= counter(8);
--
--		if counter(8)='1' and last_counter='0' then
--			BUTTONs_deb <= BUTTONs;
----			SWITCHEs_deb <= SWITCHEs;
--		end if;
--
--	end if;	
--end process;



-- **********************************************************************************************
-- * Port Maps
-- **********************************************************************************************

--------------------------------------------------------------
-- JPEG - Decoder
--------------------------------------------------------------
jpeg_decoder:jpeg
  port map(
    	Clk			=> OPB_Clk,
		data_i		=> OPB_DBus,
		reset_i		=> reset,
		
		eoi_o			=> jpeg_eoi,
		error_o		=> jpeg_error,
		
--		-- debug
--      LEDs			=> LEDs_intern,
--		BUTTONs		=> BUTTONs_deb,
--		SWITCHEs		=> SWITCHEs_deb,
--		chipscope_o	=> jpeg_chipscope,
--
		context_o	=> jpeg_context,
		red_o			=> jpeg_red,
		green_o		=> jpeg_green,
		blue_o		=> jpeg_blue,
		width_o		=> jpeg_width,
		height_o		=> jpeg_height,
		sampling_o 	=> jpeg_sampling,

		datavalid_i => jpeg_OPB_datavalid,
	   datavalid_o	=> jpeg_datavalid,
		ready_i		=> vga_ready,
		ready_o		=> jpeg_ready
    );
--------------------------------------------------------------
jpeg_OPB_datavalid <= we;
we		<= MASTER_MEM_SET and OPB_xferAck;



vga_core:vga
	port map(
		Clk			=> OPB_Clk,
		reset_i		=> reset,
		eoi_i			=> jpeg_context(3),
		
		red_i 		=> jpeg_red, 
		green_i		=> jpeg_green,
		blue_i		=> jpeg_blue,
		width_i		=> jpeg_width,
		height_i		=> jpeg_height,
		sampling_i	=> jpeg_sampling,

		VGA_OUT_PIXEL_CLOCK	=> VGA_OUT_PIXEL_CLOCK,
		VGA_COMP_SYNCH			=> VGA_COMP_SYNCH,
		VGA_OUT_BLANK_Z		=> VGA_OUT_BLANK_Z,
		VGA_HSYNCH				=> VGA_HSYNCH,	
		VGA_VSYNCH				=> VGA_VSYNCH,
		VGA_OUT_RED				=> VGA_OUT_RED,
		VGA_OUT_GREEN			=> VGA_OUT_GREEN,	
		VGA_OUT_BLUE			=> VGA_OUT_BLUE,

--		-- chipscope-debugging
--		chipscope_o	=> vga_chipscope,	

		-- flow controll
		datavalid_i => jpeg_datavalid,
		ready_o		=> vga_ready
	);






-- **********************************************************************************************
-- * Processes
-- **********************************************************************************************


------------------------------------------------------------
-- eoi and soi detection 
------------------------------------------------------------
process(OPB_DBus, received_ff)
begin

	soi_D				<= '0';
	eoi_D				<= '0';
	received_ff_D	<= '0';

	if(OPB_DBus(0  to 15)=X"FFD9" or
		OPB_DBus(8  to 23)=X"FFD9" or
		OPB_DBus(16 to 31)=X"FFD9" or
		(OPB_Dbus(0 to 7) =X"D9" and received_ff='1') ) then
		eoi_D <='1';
	end if;

	if(OPB_DBus(0  to 15)=X"FFD8" or
		OPB_DBus(8  to 23)=X"FFD8" or
		OPB_DBus(16 to 31)=X"FFD8" or
		(OPB_Dbus(0 to 7) =X"D8" and received_ff='1') ) then
		soi_D <='1';
	end if;

	if (OPB_DBus(24 to 31)=X"FF") then
		received_ff_D <= '1';
	end if;
end process;

process(OPB_Clk)
begin
	if rising_edge(OPB_Clk) then
		if reset='1' then
			soi			<= '0';
			eoi			<= '0';
			received_ff	<= '0';
		elsif(we='1') then
			soi			<= soi_D;
			eoi			<= eoi_D;
			received_ff	<= received_ff_D;
		end if;	
	end if;
end process;
------------------------------------------------------------







------------------------------------------------------------
-- keep address in sync with data 
------------------------------------------------------------
process(OPB_Clk)
begin
	if rising_edge(OPB_Clk) then
		if reset='1' or OPB_DBus=X"454e4445" then		-- OPB_DBus=X"454e4445" ("ENDE" in ASCII) is a very ugly proof of concept hack
			ddr_address <= X"00000000"; 
		elsif (jpeg_eoi='1' and eoi_hold='0') then 
			ddr_address <= old_ddr_address;
		elsif we ='1' and jpeg_ready='1' then
			ddr_address <= ddr_address+4;
		end if;
	end if;
end process;
------------------------------------------------------------





------------------------------------------------------------
-- decide whether this or following frame to be displayed
------------------------------------------------------------
process(	eoi_hold, old_ddr_address, eoi_counter, address_state, soi, ddr_address, jpeg_eoi,
			eoi_counter_threshold, pause, next_frame)
begin
	eoi_hold_D <= eoi_hold;
	old_ddr_address_D <= old_ddr_address;
	eoi_counter_D <= eoi_counter;
	address_state_D <= address_state;


	if jpeg_eoi='1' then 
		eoi_counter_D <= eoi_counter+1;
	end if;


	case address_state is
	when repeat_frame =>
		if (jpeg_eoi='1' and ((eoi_counter=eoi_counter_threshold and pause='0') or next_frame='1')) then
			eoi_counter_D <= (others=>'0');
			address_state_D <= continue;
		end if;
	when continue =>
		if eoi='1' then
			eoi_hold_D<='1';
		end if;
		if jpeg_eoi='1' and eoi_counter_threshold/="0000"  then
			address_state_D <= repeat_frame;
		end if;
	end case;


	-- independant from state because it is not certain whether jpeg_eoi or soi comes first	
	if eoi_hold='1' and soi='1' then
		old_ddr_address_D <= ddr_address-4;
		eoi_hold_D<='0';
	end if;

end process;



process(OPB_Clk)
begin
	if rising_edge(OPB_Clk) then
	if reset='1' then
		eoi_hold			<= '0';
		old_ddr_address<= X"00000000";
		eoi_counter		<= (others=>'0');
		address_state	<= repeat_frame;
	else
		eoi_hold 		<= eoi_hold_D;
		old_ddr_address<= old_ddr_address_D;
		eoi_counter		<= eoi_counter_D;
		address_state	<= address_state_D;
	end if;
	end if;
end process;

------------------------------------------------------------


--------------------------------------------------------------
-- adjust the framerate
--------------------------------------------------------------
process(faster, slower, eoi_counter_threshold)
begin
	eoi_counter_threshold_D <= eoi_counter_threshold;
	if faster='1' and last_faster='0' and eoi_counter_threshold/="0000" then
		eoi_counter_threshold_D <= eoi_counter_threshold-1;
	end if;
	if slower='1' and last_slower='0' and eoi_counter_threshold/="1111" then
		eoi_counter_threshold_D <= eoi_counter_threshold+1;
	end if;
end process;

process(OPB_Clk)
begin
	if rising_edge(OPB_Clk) then
	if reset='1' then
		eoi_counter_threshold<="0001";
	else
		eoi_counter_threshold<=eoi_counter_threshold_D;
	end if;
	end if;
end process;
--------------------------------------------------------------









--------------------------------------------------------------
---- configure bus transfer
--------------------------------------------------------------
process(OPB_CLK)
begin
  if rising_edge(OPB_CLK) then

	faster		<= faster_D;
	slower		<= slower_D;
	last_faster	<= faster;
	last_slower	<= slower;

	if reset='1' then	
		 go			<= '0';
		 burst		<= '1';
		 reset		<= '0';
--		 SWITCHEs_deb <= (others=>'1');
		 pause		<= '1';
		 next_frame <= '0';
	else 
		 go			<= go_D;
		 burst		<= burst_D;
		 reset		<= reset_D;
--		 SWITCHEs_deb <= SWITCHEs_deb_D;
		 pause <= pause_D;
		 next_frame <= next_frame_D;
	end if;

  end if;
end process;
------------------------------------------------------------




------------------------------------------------------------
-- Myipif: communicate over the OPB-Bus
------------------------------------------------------------
process (OPB_state, OPB_ABus, OPB_DBus, OPB_RNW, OPB_select, OPB_Rst, OPB_xferAck, OPB_MGrant, 
			ddr_address, go, burst, pause, next_frame, jpeg_eoi,   --SWITCHEs_deb,
			jpeg_ready, jpeg_error, reset)
begin
  Sl_toutSup_D	<= '0';
  Sl_xferAck_D	<= '0';
  Sl_errAck_D	<= '0';
  Sl_retry_D	<= '0';
  Sl_DBus_D		<= X"00000000";
  M_ABus_D		<= X"00000000";
  M_BE_D			<= (others => '1');
  M_busLock_D	<= '0';
  M_request_D	<= '0';
  M_RNW_D		<= '0';
  M_select_D	<= '0';
  M_seqAddr_D	<= '0';	

  go_D			<= go;
  burst_D 		<= burst; 
  reset_D		<= '0';
--  SWITCHEs_deb_D <= SWITCHEs_deb;
  pause_D		<= pause;

  next_frame_D	<= next_frame;
  if jpeg_eoi='1' then
	next_frame_D <= '0';
  end if;
  
  faster_D <= '0';
  slower_D <= '0';


  MASTER_MEM_SET <= '0';
  
  case OPB_state is 
  
  when idle =>
		 OPB_next_state <= idle;

----
-- OPB-Bus configuration (via ppc and UART)
		 if (OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000001") then
			go_D <= '1';

		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000002") then
			go_D <= '0';
			
		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000003") then
			burst_D <= '1';
		 
		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000004") then
			burst_D <= '0';
		
		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000005") then
			reset_D <= '1';
		 
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000006") then
--			SWITCHEs_deb_D(0) <= '0';
--	
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000007") then
--			SWITCHEs_deb_D(0) <= '1';
--		 
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000008") then
--			SWITCHEs_deb_D(1) <= '0';
--		
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000009") then
--			SWITCHEs_deb_D(1) <= '1';
--		 
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"0000000A") then
--			SWITCHEs_deb_D(2) <= '0';
--	
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"0000000B") then
--			SWITCHEs_deb_D(2) <= '1';
--		 
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"0000000C") then
--			SWITCHEs_deb_D(3) <= '0';
--		
--		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"0000000D") then
--			SWITCHEs_deb_D(3) <= '1';
--
		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"0000000E") then
			pause_D <= '1';

		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"0000000F") then
			pause_D <= '0';

		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000010") then
			next_frame_D <= '1';

		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000011") then
			faster_D <= '1';

		 elsif(OPB_ABus(0 to 31)=X"50000004" and OPB_RNW='0' and OPB_DBus=X"00000012") then
			slower_D <= '1';

----------
-- get jpeg data from ram
		 elsif (jpeg_ready='1' and jpeg_error='0' and go='1' and OPB_DBus/=X"454e4445") then
      	OPB_next_state <= MasterRead1;
		end if;
----------



  when MasterRead1 =>
      M_request_D <= '1';
       if (OPB_MGrant = '1') then
          M_seqAddr_D		<= burst;
			 M_busLock_D		<= '1';
   		 OPB_next_state	<= MasterRead2;
       else
   	    OPB_next_state	<= MasterRead1;
       end if;
  
  
  when MasterRead2 =>
       M_seqAddr_D 		  <= burst;
       M_busLock_D        <= '1';
       M_select_D         <= '1';
       M_RNW_D            <= '1';
       M_ABus_D           <= "000" & ddr_address(28 downto 0);				-- begin with 3 zeroes to prevent writing to sonething different than DDR-RAM 
       MASTER_MEM_SET     <= '1';
       if(jpeg_ready='1' and jpeg_error='0' and burst='1' and OPB_DBus/=X"454e4445") then
          OPB_next_state <= MasterRead2;
       else 
          OPB_next_state <= idle;
       end if;

  end case;       
  
  -- Reset
  if (OPB_Rst = '1' or reset='1' or jpeg_eoi='1') then
     OPB_next_state <= idle;
     Sl_DBus_D      <= X"00000000";
     Sl_xferAck_D   <= '0';
     M_ABus_D       <= X"00000000";
  end if;
end process;  
------------------------------------------------------------


------------------------------------------------------------
-- OPB_state: Reset and Synchronization
------------------------------------------------------------
process (OPB_Clk, OPB_Rst)
begin
  if (OPB_Rst='1') then
     OPB_state <= idle;
  elsif (OPB_Clk'event and OPB_Clk='1') then
     OPB_state <= OPB_next_state;
  end if;   
end process;
------------------------------------------------------------

------------------------------------------------------------
-- Synchronize other signals
------------------------------------------------------------
process(OPB_CLK)
begin
  if rising_edge(OPB_CLK) then
    Sl_toutSup <= Sl_toutSup_D;
    Sl_xferAck <= Sl_xferAck_D;
    Sl_errAck  <= Sl_errAck_D;
    Sl_DBus    <= Sl_DBus_D;
    Sl_retry   <= Sl_retry_D;

    M_ABus     <= M_ABus_D;
    M_BE       <= M_BE_D;
    M_busLock  <= M_busLock_D;
    M_request  <= M_request_D;
    M_RNW      <= M_RNW_D;
    M_select   <= M_select_D;
    M_seqAddr  <= M_seqAddr_D;  
  end if;
end process;
------------------------------------------------------------

end IMP;
