library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;



entity AI is
	port(
	iAI_start:in std_logic;
	iAI_DATA: in std_logic_vector(63 downto 0);
	iCOLOR:in std_logic_vector(7 downto 0);
	imovecount:in std_logic_vector(16 downto 0);
	oAI_Done: out std_logic;
	oAI_DATA: out std_logic_vector(63 downto 0);
	iCLK: in std_logic;
	iRST_n:in std_logic
	
	);
end entity AI;


architecture c_to_g of AI is
component bram_based_stream_buffer is
--#(.width(48), .depth(`CONNECT6AI_SYNTH_ILS_FIFO_QUEUE_DISMANTLE_LENGTH))  
		port(
                      clk:in std_logic;
                      reset:in std_logic;
                      store_ready:in std_logic;
                      flush:in std_logic;
                      store_req:out std_logic;
                      load_req:out std_logic;
                      load_ready:in std_logic;
                      indata:in std_logic_vector(47 downto 0);
                      outdata:out std_logic_vector(47 downto 0)
);
end component bram_based_stream_buffer;

component connect6ai_synth_tcab is
	port(
        clk: in std_logic;
        reset:in std_logic;
        stallbar_out:out std_logic;
        rawdataout_pico_ret_connect6ai_synth_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_0_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_1_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_2_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_3_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_4_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_5_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_6_0_outenable:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_7_0_outenable:out std_logic;
        start:in std_logic;
        rawdatain_pico_connect6ai_synth_firstmove_in_0_0:in std_logic_vector(16 downto 0);
        rawdatain_pico_connect6ai_synth_movein_0_in_1_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_1_in_2_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_2_in_3_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_3_in_4_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_4_in_5_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_5_in_6_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_6_in_7_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_movein_7_in_8_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_colour_in_9_0:in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_0_in_10_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_1_in_11_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_2_in_12_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_3_in_13_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_4_in_14_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_5_in_15_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_6_in_16_0: in std_logic_vector(7 downto 0);
        rawdatain_pico_connect6ai_synth_moveout_7_in_17_0: in std_logic_vector(7 downto 0);
        rawdataout_pico_ret_connect6ai_synth_0:out std_logic;
        rawdataout_pico_connect6ai_synth_moveout_out_0_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_1_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_2_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_3_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_4_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_5_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_6_0: out std_logic_vector(7 downto 0);
        rawdataout_pico_connect6ai_synth_moveout_out_7_0: out std_logic_vector(7 downto 0);
        instream_queue_di_0:in std_logic_vector(47 downto 0);
        instream_queue_req_0:out std_logic;
        instream_queue_ready_0:in std_logic;
        outstream_queue_do_1:out std_logic_vector(47 downto 0);
        outstream_queue_req_1:out std_logic;
        outstream_queue_ready_1:in std_logic

	);
end component connect6ai_synth_tcab;
signal out_enables:std_logic_vector(7 downto 0);
signal out_enables_reg:std_logic_vector(7 downto 0);
signal AI_DATA,mAI_DATA: std_logic_vector(63 downto 0);
signal ils_fifo_queue_dismantle_outdata:std_logic_vector(47 downto 0);
signal tcab_instream_queue_req_0:std_logic;
signal ils_fifo_queue_dismantle_store_req: std_logic;
signal tcab_outstream_queue_do_1:std_logic_vector(47 downto 0);
signal tcab_outstream_queue_req_1:std_logic;
signal ils_fifo_queue_dismantle_load_req: std_logic;
begin
oAI_DATA<=AI_DATA;
inst_ai:connect6ai_synth_tcab
	port map(

        clk=>iCLK,
        reset=>not(iRST_n),
        stallbar_out=>open,
        rawdataout_pico_ret_connect6ai_synth_0_outenable=>open,
        rawdataout_pico_connect6ai_synth_moveout_out_0_0_outenable=>out_enables(0),
        rawdataout_pico_connect6ai_synth_moveout_out_1_0_outenable=>out_enables(1),
        rawdataout_pico_connect6ai_synth_moveout_out_2_0_outenable=>out_enables(2),
        rawdataout_pico_connect6ai_synth_moveout_out_3_0_outenable=>out_enables(3),
        rawdataout_pico_connect6ai_synth_moveout_out_4_0_outenable=>out_enables(4),
        rawdataout_pico_connect6ai_synth_moveout_out_5_0_outenable=>out_enables(5),
        rawdataout_pico_connect6ai_synth_moveout_out_6_0_outenable=>out_enables(6),
        rawdataout_pico_connect6ai_synth_moveout_out_7_0_outenable=>out_enables(7),
        start=>iAI_start,
        rawdatain_pico_connect6ai_synth_firstmove_in_0_0=>imovecount,
        rawdatain_pico_connect6ai_synth_movein_0_in_1_0=>iAI_DATA(31 downto 24),
        rawdatain_pico_connect6ai_synth_movein_1_in_2_0=>iAI_DATA(23 downto 16),
        rawdatain_pico_connect6ai_synth_movein_2_in_3_0=>iAI_DATA(15 downto 8),
        rawdatain_pico_connect6ai_synth_movein_3_in_4_0=>iAI_DATA(7 downto 0),
        rawdatain_pico_connect6ai_synth_movein_4_in_5_0=>iAI_DATA(63 downto 56),
        rawdatain_pico_connect6ai_synth_movein_5_in_6_0=>iAI_DATA(55 downto 48),
        rawdatain_pico_connect6ai_synth_movein_6_in_7_0=>iAI_DATA(47 downto 40),
        rawdatain_pico_connect6ai_synth_movein_7_in_8_0=>iAI_DATA(39 downto 32),
        rawdatain_pico_connect6ai_synth_colour_in_9_0=>icolor,
        rawdatain_pico_connect6ai_synth_moveout_0_in_10_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_1_in_11_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_2_in_12_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_3_in_13_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_4_in_14_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_5_in_15_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_6_in_16_0=> to_stdlogicvector(x"00"),
        rawdatain_pico_connect6ai_synth_moveout_7_in_17_0=> to_stdlogicvector(x"00"),
        rawdataout_pico_ret_connect6ai_synth_0=>open,
        rawdataout_pico_connect6ai_synth_moveout_out_0_0=> mAI_DATA(63 downto 56),    
        rawdataout_pico_connect6ai_synth_moveout_out_1_0=> mAI_DATA(55 downto 48),
        rawdataout_pico_connect6ai_synth_moveout_out_2_0=> mAI_DATA(47 downto 40),
        rawdataout_pico_connect6ai_synth_moveout_out_3_0=> mAI_DATA(39 downto 32),
        rawdataout_pico_connect6ai_synth_moveout_out_4_0=> mAI_DATA(31 downto 24),
        rawdataout_pico_connect6ai_synth_moveout_out_5_0=> mAI_DATA(23 downto 16),
        rawdataout_pico_connect6ai_synth_moveout_out_6_0=> mAI_DATA(15 downto 8),
        rawdataout_pico_connect6ai_synth_moveout_out_7_0=> mAI_DATA(7 downto 0),
        instream_queue_di_0=>ils_fifo_queue_dismantle_outdata(47 downto 0),
        instream_queue_req_0=>tcab_instream_queue_req_0,
        instream_queue_ready_0=>ils_fifo_queue_dismantle_store_req,
        outstream_queue_do_1=>tcab_outstream_queue_do_1(47 downto 0),
        outstream_queue_req_1=>tcab_outstream_queue_req_1,
        outstream_queue_ready_1=>ils_fifo_queue_dismantle_load_req
	);
  ils_fifo_queue_dismantle:bram_based_stream_buffer 
--#(.width(48), .depth(`CONNECT6AI_SYNTH_ILS_FIFO_QUEUE_DISMANTLE_LENGTH))  
		port map(
                      clk=>iCLK,
                      reset=>not(iRST_n),
                      store_ready=>tcab_instream_queue_req_0,
                      flush=>'0',
                      store_req=>ils_fifo_queue_dismantle_store_req,
                      load_req=>ils_fifo_queue_dismantle_load_req,
                      load_ready=>tcab_outstream_queue_req_1,
                      indata=>tcab_outstream_queue_do_1(47 downto 0),
                      outdata=>ils_fifo_queue_dismantle_outdata(47 downto 0));

process(iCLK)
begin
		if rising_edge(iCLK) then
			if(iAI_start='1') then
				out_enables_reg<="00000000";
				for i in 0 to 7 loop
				AI_DATA( 63-8*i downto 56-8*i)<="00000000";
				end loop;
			else
				for i in 0 to 7 loop
				if(out_enables(i)='1') then
				out_enables_reg(i)<=out_enables(i);
				AI_DATA( 63-8*i downto 56-8*i)<=mAI_DATA(63-8*i downto 56-8*i);
				else
				out_enables_reg(i)<=out_enables_reg(i);
				AI_DATA( 63-8*i downto 56-8*i)<=AI_DATA(63-8*i downto 56-8*i);
				end if;
				end loop;
			end if;
		end if;
end process;
			oAI_Done<= out_enables_reg(0) and out_enables_reg(1) and out_enables_reg(2) and out_enables_reg(3) and 
				out_enables_reg(4) and out_enables_reg(5) and out_enables_reg(6) and out_enables_reg(7);

			--oAI_Done<= out_enables(0) and out_enables(1) and out_enables(2) and out_enables(3);
end architecture c_to_g;
