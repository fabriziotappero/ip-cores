--  C:\USER\XILINX_2006\UART_RS232\TX_CTRL.vhd
--  VHDL code created by Xilinx's StateCAD 7.1i
--  Thu Oct 19 16:58:46 2006

--  This VHDL code (for use with Xilinx XST) was generated using: 
--  enumerated state assignment with structured code format.
--  Minimization is enabled,  implied else is disabled, 
--  and outputs are area optimized.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY TX_CTRL IS
	PORT (CLK,ctr_eq_9,fa_send_clk,RESET,send_data: IN std_logic;
		incr_ctr,load_parity_bit,load_txd,reset_busy,reset_ctr,reset_txd,send_done,
			set_busy,set_txd,shift_enable : OUT std_logic);
END;

ARCHITECTURE BEHAVIOR OF TX_CTRL IS
	TYPE type_sreg IS (IDLE,END_SENDING,LOAD_PARITY,SEND_BIT,SHIFT_BIT,START_BIT
		,STOP_BIT,WAIT_SEND_CLK);
	SIGNAL sreg, next_sreg : type_sreg;
BEGIN
	PROCESS (CLK, RESET, next_sreg)
	BEGIN
		IF ( RESET='1' ) THEN
			sreg <= IDLE;
		ELSIF CLK='1' AND CLK'event THEN
			sreg <= next_sreg;
		END IF;
	END PROCESS;

	PROCESS (sreg,ctr_eq_9,fa_send_clk,send_data)
	BEGIN
		incr_ctr <= '0'; load_parity_bit <= '0'; load_txd <= '0'; reset_busy <= 
			'0'; reset_ctr <= '0'; reset_txd <= '0'; send_done <= '0'; set_busy <= '0'; 
			set_txd <= '0'; shift_enable <= '0'; 

		next_sreg<=IDLE;

		IF NOT ( (sreg=END_SENDING) OR (sreg=IDLE) OR (sreg=LOAD_PARITY) OR (
			sreg=SEND_BIT) OR (sreg=SHIFT_BIT) OR (sreg=START_BIT) OR (sreg=STOP_BIT) OR 
			(sreg=WAIT_SEND_CLK)) THEN next_sreg<=IDLE;
			incr_ctr<='0';
			load_parity_bit<='0';
			load_txd<='0';
			reset_busy<='0';
			reset_ctr<='0';
			reset_txd<='0';
			send_done<='0';
			set_busy<='0';
			set_txd<='0';
			shift_enable<='0';
		ELSE
			CASE sreg IS
				WHEN END_SENDING =>
					incr_ctr<='0';
					load_parity_bit<='0';
					load_txd<='0';
					reset_txd<='0';
					set_busy<='0';
					set_txd<='0';
					shift_enable<='0';
					reset_ctr<='1';
					send_done<='1';
					reset_busy<='1';
					next_sreg<=IDLE;
				WHEN IDLE =>
					incr_ctr<='0';
					load_parity_bit<='0';
					load_txd<='0';
					reset_busy<='0';
					reset_ctr<='0';
					reset_txd<='0';
					send_done<='0';
					set_busy<='0';
					set_txd<='0';
					shift_enable<='0';
					IF ( send_data='1' ) THEN
						next_sreg<=LOAD_PARITY;
					 ELSE
						next_sreg<=IDLE;
					END IF;
				WHEN LOAD_PARITY =>
					incr_ctr<='0';
					load_txd<='0';
					reset_busy<='0';
					reset_ctr<='0';
					reset_txd<='0';
					send_done<='0';
					set_txd<='0';
					shift_enable<='0';
					load_parity_bit<='1';
					set_busy<='1';
					next_sreg<=WAIT_SEND_CLK;
				WHEN SEND_BIT =>
					incr_ctr<='0';
					load_parity_bit<='0';
					load_txd<='0';
					reset_busy<='0';
					reset_ctr<='0';
					reset_txd<='0';
					send_done<='0';
					set_busy<='0';
					set_txd<='0';
					shift_enable<='0';
					IF ( fa_send_clk='1' AND ctr_eq_9='0' ) THEN
						next_sreg<=SHIFT_BIT;
					END IF;
					IF ( fa_send_clk='1' AND ctr_eq_9='1' ) THEN
						next_sreg<=STOP_BIT;
					END IF;
					IF ( fa_send_clk='0' ) THEN
						next_sreg<=SEND_BIT;
					END IF;
				WHEN SHIFT_BIT =>
					load_parity_bit<='0';
					reset_busy<='0';
					reset_ctr<='0';
					reset_txd<='0';
					send_done<='0';
					set_busy<='0';
					set_txd<='0';
					load_txd<='1';
					shift_enable<='1';
					incr_ctr<='1';
					next_sreg<=SEND_BIT;
				WHEN START_BIT =>
					incr_ctr<='0';
					load_parity_bit<='0';
					load_txd<='0';
					reset_busy<='0';
					reset_ctr<='0';
					send_done<='0';
					set_busy<='0';
					set_txd<='0';
					shift_enable<='0';
					reset_txd<='1';
					IF ( fa_send_clk='1' ) THEN
						next_sreg<=SHIFT_BIT;
					 ELSE
						next_sreg<=START_BIT;
					END IF;
				WHEN STOP_BIT =>
					incr_ctr<='0';
					load_parity_bit<='0';
					load_txd<='0';
					reset_busy<='0';
					reset_ctr<='0';
					reset_txd<='0';
					send_done<='0';
					set_busy<='0';
					shift_enable<='0';
					set_txd<='1';
					IF ( fa_send_clk='1' ) THEN
						next_sreg<=END_SENDING;
					 ELSE
						next_sreg<=STOP_BIT;
					END IF;
				WHEN WAIT_SEND_CLK =>
					incr_ctr<='0';
					load_parity_bit<='0';
					load_txd<='0';
					reset_busy<='0';
					reset_ctr<='0';
					reset_txd<='0';
					send_done<='0';
					set_busy<='0';
					set_txd<='0';
					shift_enable<='0';
					IF ( fa_send_clk='1' ) THEN
						next_sreg<=START_BIT;
					 ELSE
						next_sreg<=WAIT_SEND_CLK;
					END IF;
				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;
END BEHAVIOR;
