--------------------------------------------------------------------------------
--This file is part of fpga_gpib_controller.
--
-- Fpga_gpib_controller is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- Fpga_gpib_controller is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with Fpga_gpib_controller.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------
-- Author: Andrzej Paluch
-- 
-- Create Date:    22:17:28 01/24/2012 
-- Design Name: 
-- Module Name:    main - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.communication.ALL;
use work.wrapperComponents.ALL;
use work.helperComponents.ALL;


entity main is
	port(
		--reset : in std_logic;
		clk : in std_logic;
		
		------ UART ---------
		RX : in std_logic;
		TX : out std_logic;
		
		------ GPIB ---------
		DI : in std_logic_vector (7 downto 0);
		DO : out std_logic_vector (7 downto 0);
		ATN_in : in std_logic;
		ATN_out : out std_logic;
		DAV_in : in std_logic;
		DAV_out : out std_logic;
		NRFD_in : in std_logic;
		NRFD_out : out std_logic;
		NDAC_in : in std_logic;
		NDAC_out : out std_logic;
		EOI_in : in std_logic;
		EOI_out : out std_logic;
		SRQ_in : in std_logic;
		SRQ_out : out std_logic;
		IFC_in : in std_logic;
		IFC_out : out std_logic;
		REN_in : in std_logic;
		REN_out : out std_logic;
		
		------ LEDS ---------
		led1 : out std_logic;
		led2 : out std_logic
		------ DEBUG --------
		;debug1 : out std_logic
		;debug2 : out std_logic
	);
end main;

architecture Behavioral of main is

	constant BUF_LEN_MAX_BIT_NUM : integer := 11;

	type UART_REC_STATES is (
		ST_UART_REC_READ_ADDR,
		ST_UART_REC_READ_B1,
		ST_UART_REC_READ_B2,
		
		ST_UART_REC_READ_BURST_W_LEN_B1,
		ST_UART_REC_READ_BURST_W_LEN_B2,
		
		ST_UART_REC_BURST_READ
	);

	type UART_TR_STATES is (
		ST_UART_TR_IDLE,
		ST_UART_TR_WAIT_NOT_READY_TO_SEND_1,
		ST_UART_TR_WRITE_B1,
		ST_UART_TR_WAIT_NOT_READY_TO_SEND_2,
		ST_UART_TR_WRITE_B2,
		
		ST_UART_TR_WRITE_BURST,
		ST_UART_TR_WAIT_BURST_NOT_READY_TO_SEND,
		ST_UART_TR_WAIT_BURST_READY_TO_SEND
	);

	---------- global -------------
	signal reset : std_logic;
	signal reset_timer : integer range 0 to 50000000;

	---------- UART ---------------
	signal uart_reset, uart_clk, uart_RX, uart_TX, uart_data_out_ready,
		uart_data_in_ready, uart_ready_to_send : std_logic;
	signal uart_data_out, uart_data_in : std_logic_vector(7 downto 0);

	---------- GPIB ------------------------
	signal gpib_reset, gpib_clk : std_logic;
	---------- GPIB interface signals ------
	signal gpib_DI, gpib_DO : std_logic_vector (7 downto 0);
	signal gpib_output_valid : std_logic;
	signal gpib_ATN_in, gpib_ATN_out, gpib_DAV_in, gpib_DAV_out, gpib_NRFD_in,
		gpib_NRFD_out, gpib_NDAC_in, gpib_NDAC_out, gpib_EOI_in, gpib_EOI_out,
		gpib_SRQ_in, gpib_SRQ_out, gpib_IFC_in, gpib_IFC_out, gpib_REN_in,
		gpib_REN_out : std_logic;
	---------- registers access -------------
	signal gpib_data_in, gpib_data_out : std_logic_vector(15 downto 0);
	signal gpib_reg_addr : std_logic_vector(14 downto 0);
	signal gpib_strobe_read, gpib_strobe_write : std_logic;
	
	----------- writer strobe pulse generator
	signal t_in_strobe_write, t_out_strobe_write : std_logic;
	----------- reader strobe pulse generator
	signal t_in_strobe_read, t_out_strobe_read : std_logic;
	
	---------- interrupt line ---------------
	signal gpib_interrupt_line : std_logic;
	
	---------- UART transceiver -------------
	signal uart_rec_state : UART_REC_STATES;
	signal uart_strobe_write_s1, uart_strobe_write_s2 : std_logic;
	signal uart_tr_state : UART_TR_STATES;

	signal burstLen : std_logic_vector (BUF_LEN_MAX_BIT_NUM downto 0);
	signal isBurstRead : std_logic;
	signal subscribeBurstRead_1, subscribeBurstRead_2 : std_logic;
	signal currentBurstReadLen : integer range 0 to 2**BUF_LEN_MAX_BIT_NUM;

	-- GPIB synchronizer
	signal gSync_clk : std_logic;
	signal gSync_DI : std_logic_vector(7 downto 0);
	signal gSync_DO : std_logic_vector(7 downto 0);
	signal gSync_ATN_in : std_logic;
	signal gSync_ATN_Out : std_logic;
	signal gSync_DAV_in : std_logic;
	signal gSync_DAV_out : std_logic;
	signal gSync_NRFD_in : std_logic;
	signal gSync_NRFD_out : std_logic;
	signal gSync_NDAC_in : std_logic;
	signal gSync_NDAC_out : std_logic;
	signal gSync_EOI_in : std_logic;
	signal gSync_EOI_out : std_logic;
	signal gSync_SRQ_in : std_logic;
	signal gSync_SRQ_out : std_logic;
	signal gSync_IFC_in : std_logic;
	signal gSync_IFC_out : std_logic;
	signal gSync_REN_in : std_logic;
	signal gSync_REN_out : std_logic;
	
begin

	-- UART
	uart_reset <= reset;
	uart_clk <= clk;
	uart_RX <= RX;
	TX <= uart_TX;

	-- GPIB sync
	gSync_clk <= clk;
	gSync_DI <= DI;
	gSync_ATN_in <= ATN_in;
	gSync_DAV_in <= DAV_in;
	gSync_NRFD_in <= NRFD_in;
	gSync_NDAC_in <= NDAC_in;
	gSync_EOI_in <= EOI_in;
	gSync_SRQ_in <= SRQ_in;
	gSync_IFC_in <= IFC_in;
	gSync_REN_in <= REN_in;
	

	-- GPIB
	gpib_reset <= reset;
	gpib_clk <= clk;
	gpib_DI <= not gSync_DO;
	DO <= gpib_DO when gpib_output_valid = '1' else "00000000";
	gpib_ATN_in <= not gSync_ATN_Out;
	ATN_out <= gpib_ATN_out;
	gpib_DAV_in <= not gSync_DAV_out;
	DAV_out <= gpib_DAV_out;
	gpib_NRFD_in <= not gSync_NRFD_out;
	NRFD_out <= gpib_NRFD_out;
	gpib_NDAC_in <= not gSync_NDAC_out;
	NDAC_out <= gpib_NDAC_out;
	gpib_EOI_in <= not gSync_EOI_out;
	EOI_out <= gpib_EOI_out;
	gpib_SRQ_in <= not gSync_SRQ_out;
	SRQ_out <= gpib_SRQ_out;
	gpib_IFC_in <= not gSync_IFC_out;
	IFC_out <= gpib_IFC_out;
	gpib_REN_in <= not gSync_REN_out;
	REN_out <= gpib_REN_out;

	-- DEBUG
	--led1 <= reset;
	led2 <= uart_data_out_ready;
	--debug1 <= gpib_output_valid;

	---------- receive from UART -----------
	process (reset, uart_data_out_ready, uart_strobe_write_s2) begin
		if reset = '1' then
			uart_strobe_write_s1 <= uart_strobe_write_s2;
			t_in_strobe_write <= '0';
			
			subscribeBurstRead_1 <= '0';
			
			uart_rec_state <= ST_UART_REC_READ_ADDR;
		elsif rising_edge(uart_data_out_ready) then
			case uart_rec_state is
				when ST_UART_REC_READ_ADDR =>
					gpib_reg_addr(14 downto 6) <= "000000000";
					gpib_reg_addr(5 downto 0) <= uart_data_out(5 downto 0);
					
					if uart_data_out(7) = '1' then
						if uart_data_out(6) = '1' then
							isBurstRead <= '1';
							uart_rec_state <= ST_UART_REC_READ_BURST_W_LEN_B1;
						else
							uart_strobe_write_s1 <= not uart_strobe_write_s2;
							uart_rec_state <= ST_UART_REC_READ_ADDR;
						end if;
					else
						if uart_data_out(6) = '1' then
							isBurstRead <= '0';
							uart_rec_state <= ST_UART_REC_READ_BURST_W_LEN_B1;
						else
							uart_rec_state <= ST_UART_REC_READ_B1;
						end if;
					end if;
				
				when ST_UART_REC_READ_B1 =>
					gpib_data_in(7 downto 0) <= uart_data_out;
					uart_rec_state <= ST_UART_REC_READ_B2;
				
				when ST_UART_REC_READ_B2 =>
					gpib_data_in(15 downto 8) <= uart_data_out;
					t_in_strobe_write <= not t_out_strobe_write;
					uart_rec_state <= ST_UART_REC_READ_ADDR;
				
				-- burst length
				when ST_UART_REC_READ_BURST_W_LEN_B1 =>
					burstLen(7 downto 0) <= uart_data_out;
					uart_rec_state <= ST_UART_REC_READ_BURST_W_LEN_B2;
					
				when ST_UART_REC_READ_BURST_W_LEN_B2 =>
					burstLen(11 downto 8) <= uart_data_out(3 downto 0);
					if isBurstRead = '1' then
						subscribeBurstRead_1 <= not subscribeBurstRead_2;
						uart_rec_state <= ST_UART_REC_READ_ADDR;
					else
						uart_rec_state <= ST_UART_REC_BURST_READ;
					end if;
				
				when ST_UART_REC_BURST_READ =>
					gpib_data_in(7 downto 0) <= uart_data_out;
					t_in_strobe_write <= not t_out_strobe_write;
					burstLen <= burstLen - 1;
					
					if burstLen = "000000000001" then
						uart_rec_state <= ST_UART_REC_READ_ADDR;
					end if;
				
				when others =>
					uart_rec_state <= ST_UART_REC_READ_ADDR;
			end case;
		end if;
	end process;

	---------- write to UART ---------------------
	process (reset, clk, uart_strobe_write_s1) begin
		if reset = '1' then
			uart_strobe_write_s2 <= uart_strobe_write_s1;
			uart_data_in_ready <= '0';
			t_in_strobe_read <= '0';
			
			subscribeBurstRead_2 <= '0';
			
			led1 <= '0';
			
			uart_tr_state <= ST_UART_TR_IDLE;
		elsif rising_edge(clk) then
			case uart_tr_state is
				when ST_UART_TR_IDLE =>
					if uart_strobe_write_s2 /= uart_strobe_write_s1 and
							uart_ready_to_send = '1' then
						uart_strobe_write_s2 <= uart_strobe_write_s1;
						uart_data_in <= gpib_data_out(7 downto 0);
						uart_data_in_ready <= '1';
						uart_tr_state <= ST_UART_TR_WAIT_NOT_READY_TO_SEND_1;
					elsif subscribeBurstRead_1 /= subscribeBurstRead_2 and
							uart_ready_to_send = '1' then
						subscribeBurstRead_2 <= subscribeBurstRead_1;
						currentBurstReadLen <= conv_integer(UNSIGNED(burstLen));
						
						uart_tr_state <= ST_UART_TR_WRITE_BURST;
					end if;
				
				when ST_UART_TR_WAIT_NOT_READY_TO_SEND_1 =>
					if uart_ready_to_send = '0' then
						uart_data_in_ready <= '0';
						uart_tr_state <= ST_UART_TR_WRITE_B1;
					end if;
				
				when ST_UART_TR_WRITE_B1 =>
					if uart_ready_to_send = '1' then
						uart_data_in <= gpib_data_out(15 downto 8);
						uart_data_in_ready <= '1';
						uart_tr_state <= ST_UART_TR_WAIT_NOT_READY_TO_SEND_2;
					end if;
				
				when ST_UART_TR_WAIT_NOT_READY_TO_SEND_2 =>
					if uart_ready_to_send = '0' then
						uart_data_in_ready <= '0';
						uart_tr_state <= ST_UART_TR_WRITE_B2;
					end if;
				
				when ST_UART_TR_WRITE_B2 =>
					if uart_ready_to_send = '1' then
						t_in_strobe_read <= not t_out_strobe_read;
					
						uart_tr_state <= ST_UART_TR_IDLE;
					end if;
				
				-- burst read
				when ST_UART_TR_WRITE_BURST =>
					if uart_ready_to_send = '1' then
						uart_data_in <= gpib_data_out(7 downto 0);
						uart_data_in_ready <= '1';
						currentBurstReadLen <= currentBurstReadLen - 1;
						
						led1 <= '1';
						
						uart_tr_state <= ST_UART_TR_WAIT_BURST_NOT_READY_TO_SEND;
					end if;
				
				when ST_UART_TR_WAIT_BURST_NOT_READY_TO_SEND =>
					if uart_ready_to_send = '0' then
						uart_data_in_ready <= '0';
						t_in_strobe_read <= not t_out_strobe_read;
						
						uart_tr_state <= ST_UART_TR_WAIT_BURST_READY_TO_SEND;
					end if;
				
				when ST_UART_TR_WAIT_BURST_READY_TO_SEND =>
					if uart_ready_to_send = '1' then
						
						if currentBurstReadLen > 0 then
							uart_tr_state <= ST_UART_TR_WRITE_BURST;
						else
							led1 <= '0';
							uart_tr_state <= ST_UART_TR_IDLE;
						end if;
					end if;
				
				
				when others =>
					uart_tr_state <= ST_UART_TR_IDLE;
			end case;
		end if;
	end process;

	process (clk) begin
		if rising_edge(clk) then
			if reset_timer < 50000000 then
				reset_timer <= reset_timer + 1;
				reset <= '1';
			else
				reset <= '0';
			end if;
		end if;
	end process;

	uart0: Uart port map(
		reset => uart_reset, clk => uart_clk, RX => uart_RX, TX => uart_TX,
		data_out => uart_data_out, data_out_ready => uart_data_out_ready,
		data_in => uart_data_in, data_in_ready => uart_data_in_ready,
		ready_to_send => uart_ready_to_send
	);
	
	spg_strobe_write: SinglePulseGenerator generic map (WIDTH => 1) port map(
		reset => reset, clk => clk,
		t_in => t_in_strobe_write, t_out => t_out_strobe_write,
		pulse => gpib_strobe_write
	);
	
	spg_strobe_read: SinglePulseGenerator generic map (WIDTH => 1) port map(
		reset => reset, clk => clk,
		t_in => t_in_strobe_read, t_out => t_out_strobe_read,
		pulse => gpib_strobe_read
	);
	
	gpibSync: GpibSynchronizer port map (
		clk => gSync_clk,
		DI => gSync_DI,
		DO => gSync_DO,
		ATN_in => gSync_ATN_in,
		ATN_out => gSync_ATN_Out,
		DAV_in => gSync_DAV_in,
		DAV_out => gSync_DAV_out,
		NRFD_in => gSync_NRFD_in,
		NRFD_out => gSync_NRFD_out,
		NDAC_in => gSync_NDAC_in,
		NDAC_out => gSync_NDAC_out,
		EOI_in => gSync_EOI_in,
		EOI_out => gSync_EOI_out,
		SRQ_in => gSync_SRQ_in,
		SRQ_out => gSync_SRQ_out,
		IFC_in => gSync_IFC_in,
		IFC_out => gSync_IFC_out,
		REN_in => gSync_REN_in,
		REN_out => gSync_REN_out
	);
	
	gpib0: RegsGpibFasade port map(
		reset => gpib_reset, clk => gpib_clk,
		DI => gpib_DI, DO => gpib_DO, output_valid => gpib_output_valid,
		ATN_in => gpib_ATN_in, ATN_out => gpib_ATN_out,
		DAV_in => gpib_DAV_in, DAV_out => gpib_DAV_out,
		NRFD_in => gpib_NRFD_in, NRFD_out => gpib_NRFD_out,
		NDAC_in => gpib_NDAC_in, NDAC_out => gpib_NDAC_out,
		EOI_in => gpib_EOI_in, EOI_out => gpib_EOI_out,
		SRQ_in => gpib_SRQ_in, SRQ_out => gpib_SRQ_out,
		IFC_in => gpib_IFC_in, IFC_out => gpib_IFC_out,
		REN_in => gpib_REN_in, REN_out => gpib_REN_out,
		data_in => gpib_data_in, data_out => gpib_data_out,
		reg_addr => gpib_reg_addr,
		strobe_read => gpib_strobe_read,
		strobe_write => gpib_strobe_write,
		interrupt_line => gpib_interrupt_line,
		debug1 => debug1, debug2 => debug2
	);

end Behavioral;

