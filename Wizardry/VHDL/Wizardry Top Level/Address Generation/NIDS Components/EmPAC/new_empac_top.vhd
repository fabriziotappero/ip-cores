----------------------------------------------------------------------------------
--
--  This file is a part of Technica Corporation Wizardry Project
--
--  Copyright (C) 2004-2009, Technica Corporation  
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Design Name: Marlon Winder
-- Module Name: new_empac_top - Behavioral 
-- Project Name: Wizardry
-- Target Devices: Virtex 4 ML401
-- Tool versions: 
-- Description: Top-level structural description for EmPAC Component.
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.port_block_constants.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity new_empac_top is
port(
		sys_clock : in std_logic; 					-- 100 Mhz clock
		clock : in std_logic; 						-- 12.5 Mhz clock
		reset_100 : in std_logic; 					-- 100 Mhz reset
		reset : in std_logic; 						-- 12. 5 Mhz reset
		EmPAC_leds : out std_logic_vector(8 downto 0);  -- These LED's are used for debugging and are connected
		phy_data : in std_logic_vector(7 downto 0);  -- 8 bit phy data comming in at 12.5 Mhz
		phy_data_valid : in std_logic;               -- When asserted, indicates that the "phy_data" is valid
		field_data : out std_logic_vector(31 downto 0);		--  This is the parsed frame data.  Each 32 bit vector
		field_type : out std_logic_vector(7 downto 0);		--  corresponds to the "field_type" indicated.  
																			--  Each field type vector corresponds to a specific portion of the packet
		data_ready : out std_logic;								--  When "data_ready" is asserted, the data on "field_data"
																			--  is valid.  The parsed frame data is the "primary" output
																			--  of this component.  EmPAC's output connects directly to 
																			--  eRCP's input (actually, there is a FIFO sitting between them :) )
		
		-- Wishbone compliant memory interface
		-- These signals connect to RDIC and provide a method for EmPAC to access the DDR SDRAM
		ack_i : in  STD_LOGIC;										--  Wishbone acknowledge
      dat_i : in  STD_LOGIC_vector(31 downto 0);			--  Incoming data from Wishbone interface
      dat_o : out  STD_LOGIC_VECTOR (31 downto 0);			--  etc...
      adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
      we_o : out  STD_LOGIC;
      cyc_o : out  STD_LOGIC;
      stb_o : out  STD_LOGIC;
		lock_o : out std_logic;
		priority_o : out std_logic_vector(7 downto 0);		--  Indicates the access priority for this component.
		id_o : out std_logic_Vector(4 downto 0);  			--  This signal allows other components to refer to EmPAC's shared memory space,
																			--  thereby eliminating the need for other components to know which port EmPAC is connected to.
		
		
		fifo_empty_out : out std_logic;  						--  Debug output from the PPT below
		fifo_full_out : out std_logic;   						--  Debug output from the PPT below
		fifo_push_count : out std_logic_vector(11 downto 0);  --  Debug output from PPT below
		end_of_frame : out std_logic 								--  Signals to eRCP (or any other components that is processing the parsed frames)
																			--  that the frame is finished (i.e. the preamble inbetween packets was recieved by EmPAC).
																			
		);
end new_empac_top;

architecture Behavioral of new_empac_top is


-- Signals that connect components of EmPAC
signal data_ready_s : std_logic;
signal valid : std_logic;
signal field_data_early : std_logic_Vector(31 downto 0);
signal length1 : std_logic_vector(17 downto 0);--integer;
signal port_ind : std_logic;
signal length_ind : std_logic;
signal protocol_ind : std_logic;
signal src_port_found_s : std_Logic;
signal dst_port_found_s : std_Logic;
signal opt : std_logic;
signal field_type_s : std_logic_Vector(7 downto 0);
signal TCP_type : std_logic;
signal UDP_type : std_logic;
signal ICMP_type : std_logic;
signal field_data_s : std_logic_Vector(31 downto 0);
signal field_type_late : std_logic_vector(7 downto 0);
signal frame_counters : frame_counters_type;
signal field_type_0 : std_logic_vector(7 downto 0);
signal field_type_early : std_logic_vector(7 downto 0);

--  The assembler (new_assembler) accepts 8-bit phy data input, and assembles them into 32-bit vectors.
--  This output vector, "field_data_early", is accompannied by a "valid" signsl
--  that indicates the the 32 bit vector is ready to be processed by the next component,
--  the "protocol_fsm".  Notice that this field data is not the actual field data that 
--  is connected to field data.

--  Yeah...I know that some of the component names are a bit odd.  They are just what we used when we coded 
--  and never went back to change them ;)

component new_assembler is
    Port ( clock : in  STD_LOGIC;
           phy_data : in  STD_LOGIC_VECTOR (7 downto 0);
           phy_data_valid : in  STD_LOGIC;
           field_data_early : out  STD_LOGIC_VECTOR (31 downto 0);
			  valid : out std_logic
			  );
end component;


--  The protocol FSM (protocol_fsm) is a state machine that has states that correspond to each portion of the packet.
--  With a 32-bit field data input from new_assembler, this components classifies each of the 32 bit vectors according 
--  to which part of the packet is is.  This component also has inputs from the the "length_saver" component.

component protocol_fsm is
port(clock : in std_logic;
	  reset : in std_logic;
	  EmPAC_leds : out std_logic_Vector(8 downto 0);
	  phy_data_valid : in std_logic;
	  field_data_early : in std_logic_vector(31 downto 0);
	  opt : in std_logic;
	  length1 : in std_logic_vector(17 downto 0);
	  TCP_type : in std_Logic;
	  UDP_type : in std_logic;
	  icmp_type : in std_logic;
	  protocol_ind : out std_logic;
	  length_ind : out std_logic;
	  port_ind : out std_logic;
	  field_type_early : out std_logic_Vector(7 downto 0);
	  data_ready : out std_logic;
	  field_type_out : out std_logic_vector(7 downto 0);
	  field_data : out std_logic_vector(31 downto 0);
	  end_of_frame : out std_logic
	  );
end component;


--  The protocol saver (protocol_saver) accepts the field data as input from the new_assembler.  This component identifies
--  each packet as either TCP, UDP, or ICMP, which in turn enables the protocol fsm to properly parse the packets.
component protocol_saver is
    Port ( clock : in std_logic;
			  reset : in std_logic;
			  Protocol_indicator : in  STD_LOGIC;
           Field_data : in  STD_LOGIC_VECTOR (31 downto 0);
			  Field_type : in std_logic_vector(7 downto 0);
			  TCP_type_out : out std_logic;
			  UDP_type_out : out std_logic;
			  ICMP_type_out : out std_logic);

end component;


--  The length saver informs the protocol_fsm on how big each packet is supposed to be.
component lengthsaver IS 
PORT( 
	clock	: IN	std_logic;
	field_data	: IN       std_logic_vector (31 DOWNTO 0);
	length_indicator	: IN       std_logic;
	field_type : IN       std_logic_vector (7 DOWNTO 0);
	reset	: IN       std_logic;
	optional	:	OUT     std_logic;
	length1	: OUT	std_logic_vector (17 DOWNTO 0)
);
END component;


--  Counts the total number of packets of each type (TCP, IPV6, etc)
component frame_counting is
    Port ( clock : in  STD_LOGIC;
			  sys_clock : in std_logic;
           reset : in  STD_LOGIC;
--			  icmp_type : in std_logic;
           field_type : in  STD_LOGIC_VECTOR (7 downto 0);
			  field_data : in std_logic_Vector(7 downto 0);
           data_ready : in  STD_LOGIC;
			  frame_counters : out frame_counters_type);
end component;


--  This components tracks the ports that have been encountered.  Each time a new port type comes in,
--  
component port_block is
    Port ( sys_clock : in std_logic;
			  clock : in  STD_LOGIC;
			  reset_100 : in std_logic;
           reset : in  STD_LOGIC;
			  fifo_empty_out : out std_logic;
			  fifo_full_out : out std_logic;
			  field_data : in std_logic_vector(31 downto 0);
			  field_type : in std_logic_vector(7 downto 0);
			  data_ready : in std_logic;
			  frame_counters : in frame_counters_type;
           ack_i : in  STD_LOGIC;
           dat_i : in  STD_LOGIC_vector(31 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           we_o : out  STD_LOGIC;
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
			  fifo_push_count : out std_logic_vector(11 downto 0));
end component;

begin
-- Register the field data, field type and data ready signals
process(clock)
begin
	if rising_edge(clock) then
		data_ready <= data_ready_s;
		field_data <= field_data_s;
		field_type <= field_type_s;
	end if;
end process;

lock_o <= '0';
priority_o <= "00000001";  -- Highest priority
id_o <= "00001";  --  Device ID,  make sure that all components have a defferent id !!!
process(clock)
begin
	if rising_edge(clock) then
		field_type_late <= field_type_s;
	end if;
end process;


assemble: new_assembler 
Port map ( clock => clock,
           phy_data => phy_data,
           phy_data_valid => phy_data_valid,
           field_data_early => field_data_early,
			  valid => valid
			  );

fsm: protocol_fsm 
port map(clock => clock,
	  reset => reset,
	  EmPAC_leds => EmPAC_leds,
	  phy_data_valid => valid,
	  field_data_early => field_data_early,
	  opt => opt,
	  length1 => length1,
	  TCP_type => TCP_type,
	  UDP_type => UDP_type,
	  icmp_type => icmp_type,
	  protocol_ind => protocol_ind,
	  length_ind => length_ind,
	  port_ind => port_ind,
	  field_type_early => field_type_early,
	  data_ready => data_ready_s,
	  field_data => field_data_s,
	  field_type_out => field_type_s,
	  end_of_frame => end_of_frame
	  );


prot_type : protocol_saver
Port map( clock => clock,
			  reset => reset,
			  Protocol_indicator => protocol_ind,
           Field_data => field_data_early,
			  Field_type => field_type_early,
			  TCP_type_out => TCP_type,
			  UDP_type_out => UDP_type,
			  ICMP_type_out => ICMP_type);

length_save : lengthsaver
PORT map( 
	clock	=> clock,
	field_data	=> field_data_early,
	length_indicator	=> length_ind,
	field_type => field_type_early,
	reset	=> reset,
	optional	=> opt,
	length1	=> length1
);

counts: frame_counting
    Port map( clock => clock,
			  sys_clock => sys_clock,
           reset => reset,
           field_type => field_type_s,
			  field_data => field_data_s(7 downto 0),
           data_ready => data_ready_s,
			  frame_counters => frame_counters);

ppt: port_block
    Port map( sys_clock => sys_clock,
			  clock => clock,
           reset => reset,
			  reset_100 => reset_100,
			  fifo_empty_out => fifo_empty_out,
			  fifo_full_out => fifo_full_out,
			  field_data => field_data_s,
			  field_type => field_type_s,
			  data_ready => data_ready_s,
			  frame_counters => frame_counters,
           ack_i => ack_i,
           dat_i => dat_i,
           dat_o => dat_o,
           adr_o => adr_o,
           we_o => we_o,
           cyc_o => cyc_o,
           stb_o => stb_o,
			  fifo_push_count => fifo_push_count);

end Behavioral;

