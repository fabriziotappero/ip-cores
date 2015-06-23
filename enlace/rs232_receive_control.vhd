--  C:\USER\XILINX_2006\UART_RS232\RX_CTRL.vhd
--  VHDL code created by Xilinx's StateCAD 7.1i
--  Thu Oct 19 16:59:23 2006

--  This VHDL code (for use with Xilinx XST) was generated using: 
--  enumerated state assignment with structured code format.
--  Minimization is enabled,  implied else is disabled, 
--  and outputs are area optimized.

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RX_CTRL IS
	PORT (CLK,ctr_bits_eq_9,fd_rxd,last_sample,RESET,sampled_bit: IN std_logic;
		incr_ctr_bits,ld_parity_error,load_data,load_discrepancy,new_data,
			reset_busy,reset_capture,reset_ctr_bits,reset_ctr_clock,rst_ce_ctr_clock,
			rst_discrepancy,set_busy,set_capture,set_ce_ctr_clock,shift_enable,
			start_error,stop_error : OUT std_logic);
END;

ARCHITECTURE BEHAVIOR OF RX_CTRL IS
	TYPE type_sreg IS (IDLE,CHECK_9_BITS,CHECK_START_BIT,CHECK_STOP_BIT,END_RECEIVING,
		SHIFT_BIT,START_BIT_ERROR,START_RECEIVING,STOP_BIT_ERROR,STORE_DATA,
		WAIT_NEXT_BIT,WAIT_STOP_BIT);
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

	PROCESS (sreg,ctr_bits_eq_9,fd_rxd,last_sample,sampled_bit)
	BEGIN
		incr_ctr_bits <= '0'; ld_parity_error <= '0'; load_data <= '0'; 
			load_discrepancy <= '0'; new_data <= '0'; reset_busy <= '0'; reset_capture <=
			 '0'; reset_ctr_bits <= '0'; reset_ctr_clock <= '0'; rst_ce_ctr_clock <= '0';
			 rst_discrepancy <= '0'; set_busy <= '0'; set_capture <= '0'; 
			set_ce_ctr_clock <= '0'; shift_enable <= '0'; start_error <= '0'; stop_error 
			<= '0'; 

		next_sreg<=IDLE;

		IF NOT ( (sreg=CHECK_9_BITS) OR (sreg=CHECK_START_BIT) OR (
			sreg=CHECK_STOP_BIT) OR (sreg=END_RECEIVING) OR (sreg=IDLE) OR (
			sreg=SHIFT_BIT) OR (sreg=START_BIT_ERROR) OR (sreg=START_RECEIVING) OR (
			sreg=STOP_BIT_ERROR) OR (sreg=STORE_DATA) OR (sreg=WAIT_NEXT_BIT) OR (
			sreg=WAIT_STOP_BIT)) THEN next_sreg<=IDLE;
			incr_ctr_bits<='0';
			ld_parity_error<='0';
			load_data<='0';
			load_discrepancy<='0';
			new_data<='0';
			reset_busy<='0';
			reset_capture<='0';
			reset_ctr_bits<='0';
			reset_ctr_clock<='0';
			rst_ce_ctr_clock<='0';
			rst_discrepancy<='0';
			set_busy<='0';
			set_capture<='0';
			set_ce_ctr_clock<='0';
			shift_enable<='0';
			start_error<='0';
			stop_error<='0';
		ELSE
			CASE sreg IS
				WHEN CHECK_9_BITS =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					rst_discrepancy<='1';
					IF ( ctr_bits_eq_9='1' ) THEN
						next_sreg<=STORE_DATA;
					 ELSE
						next_sreg<=WAIT_NEXT_BIT;
					END IF;
				WHEN CHECK_START_BIT =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					IF ( sampled_bit='0' ) THEN
						next_sreg<=WAIT_NEXT_BIT;
					 ELSE
						next_sreg<=START_BIT_ERROR;
					END IF;
				WHEN CHECK_STOP_BIT =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					IF ( sampled_bit='1' ) THEN
						next_sreg<=END_RECEIVING;
					 ELSE
						next_sreg<=STOP_BIT_ERROR;
					END IF;
				WHEN END_RECEIVING =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					reset_capture<='1';
					rst_ce_ctr_clock<='1';
					reset_ctr_clock<='1';
					reset_ctr_bits<='1';
					new_data<='1';
					reset_busy<='1';
					next_sreg<=IDLE;
				WHEN IDLE =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					IF ( fd_rxd='1' ) THEN
						next_sreg<=START_RECEIVING;
					 ELSE
						next_sreg<=IDLE;
					END IF;
				WHEN SHIFT_BIT =>
					ld_parity_error<='0';
					load_data<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					start_error<='0';
					stop_error<='0';
					shift_enable<='1';
					incr_ctr_bits<='1';
					load_discrepancy<='1';
					next_sreg<=CHECK_9_BITS;
				WHEN START_BIT_ERROR =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_ctr_bits<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					stop_error<='0';
					reset_capture<='1';
					rst_ce_ctr_clock<='1';
					reset_ctr_clock<='1';
					start_error<='1';
					reset_busy<='1';
					next_sreg<=IDLE;
				WHEN START_RECEIVING =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					set_capture<='1';
					set_ce_ctr_clock<='1';
					set_busy<='1';
					IF ( last_sample='1' ) THEN
						next_sreg<=CHECK_START_BIT;
					 ELSE
						next_sreg<=START_RECEIVING;
					END IF;
				WHEN STOP_BIT_ERROR =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='1';
					next_sreg<=END_RECEIVING;
				WHEN STORE_DATA =>
					incr_ctr_bits<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					ld_parity_error<='1';
					load_data<='1';
					next_sreg<=WAIT_STOP_BIT;
				WHEN WAIT_NEXT_BIT =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					IF ( last_sample='1' ) THEN
						next_sreg<=SHIFT_BIT;
					 ELSE
						next_sreg<=WAIT_NEXT_BIT;
					END IF;
				WHEN WAIT_STOP_BIT =>
					incr_ctr_bits<='0';
					ld_parity_error<='0';
					load_data<='0';
					load_discrepancy<='0';
					new_data<='0';
					reset_busy<='0';
					reset_capture<='0';
					reset_ctr_bits<='0';
					reset_ctr_clock<='0';
					rst_ce_ctr_clock<='0';
					rst_discrepancy<='0';
					set_busy<='0';
					set_capture<='0';
					set_ce_ctr_clock<='0';
					shift_enable<='0';
					start_error<='0';
					stop_error<='0';
					IF ( last_sample='1' ) THEN
						next_sreg<=CHECK_STOP_BIT;
					 ELSE
						next_sreg<=WAIT_STOP_BIT;
					END IF;
				WHEN OTHERS =>
			END CASE;
		END IF;
	END PROCESS;
END BEHAVIOR;
