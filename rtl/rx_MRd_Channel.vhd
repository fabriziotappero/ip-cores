----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    rx_MRd_Transact - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  14.12.2006
-- 
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.abb64Package.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx_MRd_Transact is
    port (
      -- Transaction receive interface
      trn_rsof_n         : IN  std_logic;
      trn_reof_n         : IN  std_logic;
      trn_rd             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n         : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n      : IN  std_logic;
      trn_rsrc_rdy_n     : IN  std_logic;
--      trn_rdst_rdy_n     : OUT std_logic;
      trn_rnp_ok_n       : OUT std_logic;
      trn_rsrc_dsc_n     : IN std_logic;
      trn_rbar_hit_n     : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
--      trn_rfc_ph_av      : IN  std_logic_vector(7 downto 0);
--      trn_rfc_pd_av      : IN  std_logic_vector(11 downto 0);
--      trn_rfc_nph_av     : IN  std_logic_vector(7 downto 0);
--      trn_rfc_npd_av     : IN  std_logic_vector(11 downto 0);
--      trn_rfc_cplh_av    : IN  std_logic_vector(7 downto 0);
--      trn_rfc_cpld_av    : IN  std_logic_vector(11 downto 0);

      IORd_Type          : IN  std_logic;
      MRd_Type           : IN  std_logic_vector(3 downto 0);
      Tlp_straddles_4KB  : IN  std_logic;

      -- MRd Channel
      pioCplD_Req        : OUT std_logic;
      pioCplD_RE         : IN  std_logic;
      pioCplD_Qout       : OUT std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
--      FIFO_Data_Count    : IN  std_logic_vector(C_FIFO_DC_WIDTH-1 downto 0);
      FIFO_Empty         : IN  std_logic;
      FIFO_Reading       : IN  std_logic;
      pio_FC_stop        : IN  std_logic;
      pio_reading_status : OUT std_logic; 

      -- Channel reset (from MWr channel)
      Channel_Rst        : IN  std_logic;

      -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic;
      trn_lnk_up_n       : IN  std_logic
    );

end entity rx_MRd_Transact;


architecture Behavioral of rx_MRd_Transact is

  type RxMRdTrnStates is         ( ST_MRd_RESET
                                 , ST_MRd_IDLE
                                 , ST_MRd_HEAD2
                                 , ST_MRd_Tail
                                 );

  -- State variables
  signal RxMRdTrn_NextState      : RxMRdTrnStates;
  signal RxMRdTrn_State          : RxMRdTrnStates;

  -- trn_rx stubs            
  signal  trn_rsof_n_i           : std_logic;
  signal  trn_reof_n_i           : std_logic;
  signal  trn_rd_i               : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  trn_rrem_n_i           : std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
  signal  trn_rbar_hit_n_i       : std_logic_vector(C_BAR_NUMBER-1 downto 0);
  signal  trn_rerrfwd_n_i        : std_logic;

  -- delays
  signal  trn_rd_r1              : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  trn_rbar_hit_n_r1      : std_logic_vector(C_BAR_NUMBER-1 downto 0);

  -- BAR encoded
  signal  Encoded_BAR_Index      : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);

  -- Reset
  signal  local_Reset            : std_logic;

  -- Output signals
--  signal  trn_rdst_rdy_n_i       : std_logic;
  signal  trn_rnp_ok_n_i         : std_logic;
  signal  trn_rsrc_dsc_n_i       : std_logic;

  -- Throttle
  signal  trn_rx_throttle        : std_logic;

  signal  pio_reading_status_i   : std_logic; 
  signal  pio_read_fading_cnt    : std_logic_vector(8-1 downto 0); 
  signal  MRd_Has_3DW_Header     : std_logic;
  signal  MRd_Has_4DW_Header     : std_logic;
  signal  Tlp_is_Zero_Length     : std_logic;
  signal  Illegal_Leng_on_FIFO   : std_logic;

  -- Built-in single-port fifo as MRd channel buffer
  component v5sfifo_15x128
    port (
          clk                  : IN  std_logic;
          rst                  : IN  std_logic;
          prog_full            : OUT std_logic;
--          wr_clk               : IN  std_logic;
          wr_en                : IN  std_logic;
          din                  : IN  std_logic_VECTOR(C_CHANNEL_BUF_WIDTH-1 downto 0);
          full                 : OUT std_logic;
--          rd_clk               : IN  std_logic;
          rd_en                : IN  std_logic;
          dout                 : OUT std_logic_VECTOR(C_CHANNEL_BUF_WIDTH-1 downto 0);
          prog_empty           : OUT std_logic;
          empty                : OUT std_logic
    );
  end component;


  -- Signal with MRd channel FIFO
  signal  pioCplD_din            : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  pioCplD_Qout_wire      : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  pioCplD_RE_i           : std_logic;
  signal  pioCplD_we             : std_logic;
  signal  pioCplD_empty_i        : std_logic;
  signal  pioCplD_full           : std_logic;
  signal  pioCplD_prog_Full      : std_logic;
  signal  pioCplD_empty_r1       : std_logic;
  signal  pioCplD_prog_full_r1   : std_logic;

  signal  pioCplD_Qout_i         : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);
  signal  pioCplD_Qout_reg       : std_logic_vector(C_CHANNEL_BUF_WIDTH-1 downto 0);

  -- Request for output arbitration
  signal  pioCplD_Req_i        : std_logic;
  signal  pioCplD_Leng         : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);

  -- Busy/Done state bits generation
  type FSM_Request is         (
                                 REQST_Idle
                               , REQST_1Read
                               , REQST_Decision
                               , REQST_nFIFO_Req
--                               , REQST_Quantity
--                               , REQST_FIFO_Req
                               );

  signal FSM_REQ_pio          : FSM_Request;

begin

   -- positive reset and local
   local_Reset       <= not trn_reset_n or Channel_Rst;


   -- MRd channel buffer control
--   pioCplD_RE_i      <= pioCplD_RE;

   pioCplD_Qout      <= pioCplD_Qout_i;
   pioCplD_Req       <= pioCplD_Req_i;  -- and not FIFO_Reading;

   pio_reading_status  <= pio_reading_status_i;


   -- Output to the core as handshaking
   trn_rsof_n_i      <= trn_rsof_n;
   trn_reof_n_i      <= trn_reof_n;
   trn_rd_i          <= trn_rd;
   trn_rrem_n_i      <= trn_rrem_n;
   trn_rerrfwd_n_i   <= trn_rerrfwd_n;
   trn_rsrc_dsc_n_i  <= trn_rsrc_dsc_n;
   trn_rbar_hit_n_i  <= trn_rbar_hit_n;

   -- Output to the core as handshaking
   trn_rnp_ok_n      <= trn_rnp_ok_n_i;
   trn_rnp_ok_n_i    <= pioCplD_prog_full_r1;

   -- ( trn_rsrc_rdy_n seems never deasserted during packet)
   trn_rx_throttle   <= trn_rsrc_rdy_n;    --  or trn_rdst_rdy_n_i;


-- ------------------------------------------------
-- Synchronous Delay: trn_rd + trn_rbar_hit_n
-- 
   Synch_Delay_trn_rd:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         trn_rd_r1          <= trn_rd_i;
         trn_rbar_hit_n_r1  <= trn_rbar_hit_n_i;
      end if;

   end process;


-- ------------------------------------------------
-- States synchronous
--
   Syn_RxTrn_States:
   process ( trn_clk, local_Reset)
   begin
      if local_Reset = '1' then
         RxMRdTrn_State   <= ST_MRd_RESET;
      elsif trn_clk'event and trn_clk = '1' then
         RxMRdTrn_State   <= RxMRdTrn_NextState;
      end if;

   end process;


-- Next States
   Comb_RxTrn_NextStates:
   process ( 
             RxMRdTrn_State
           , MRd_Type
--           , IORd_Type
           , trn_rx_throttle
           , trn_rnp_ok_n_i
           , trn_rsrc_dsc_n_i
           , trn_rerrfwd_n_i
           )
   begin
     case RxMRdTrn_State  is

        when ST_MRd_RESET =>
              RxMRdTrn_NextState <= ST_MRd_IDLE;

        when ST_MRd_IDLE =>

           if trn_rnp_ok_n_i='0' then

            case MRd_Type is

             when C_TLP_TYPE_IS_MRD_H3 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when C_TLP_TYPE_IS_MRD_H4 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when C_TLP_TYPE_IS_MRDLK_H3 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when C_TLP_TYPE_IS_MRDLK_H4 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when OTHERS =>
--               if IORd_Type='1' then   -- Temp taking IORd as MRd3
--                 RxMRdTrn_NextState <= ST_MRd3_HEAD1;
--               else
                 RxMRdTrn_NextState <= ST_MRd_IDLE;
--               end if;

            end case;  -- MRd_Type

           else
             RxMRdTrn_NextState <= ST_MRd_IDLE;
           end if;


        when ST_MRd_HEAD2 =>
           if trn_rx_throttle = '1' then
              RxMRdTrn_NextState <= ST_MRd_HEAD2;
           else
              RxMRdTrn_NextState <= ST_MRd_Tail;
           end if;


        when ST_MRd_Tail =>      -- support back-to-back transactions

           if trn_rnp_ok_n_i='0' then

            case MRd_Type is

             when C_TLP_TYPE_IS_MRD_H3 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when C_TLP_TYPE_IS_MRD_H4 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when C_TLP_TYPE_IS_MRDLK_H3 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when C_TLP_TYPE_IS_MRDLK_H4 =>
               RxMRdTrn_NextState <= ST_MRd_HEAD2;
             when OTHERS =>
--               if IORd_Type='1' then   -- Temp taking IORd as MRd3
--                 RxMRdTrn_NextState <= ST_MRd3_HEAD1;
--               else
                 RxMRdTrn_NextState <= ST_MRd_IDLE;
--               end if;

            end case;  -- MRd_Type

           else
             RxMRdTrn_NextState <= ST_MRd_IDLE;
           end if;

        when OTHERS =>
           RxMRdTrn_NextState <= ST_MRd_RESET;

     end case;

   end process;



-- ------------------------------------------------
-- Synchronous calculation: Encoded_BAR_Index
-- 
   Syn_Calc_Encoded_BAR_Index:
   process ( trn_clk, local_Reset)
   begin
      if local_Reset = '1' then
         Encoded_BAR_Index <= (OTHERS=>'1');

      elsif trn_clk'event and trn_clk = '1' then

         if    trn_rbar_hit_n(0)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(0, C_ENCODE_BAR_NUMBER);
         elsif trn_rbar_hit_n(1)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(1, C_ENCODE_BAR_NUMBER);
         elsif trn_rbar_hit_n(2)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(2, C_ENCODE_BAR_NUMBER);
         elsif trn_rbar_hit_n(3)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(3, C_ENCODE_BAR_NUMBER);
         elsif trn_rbar_hit_n(4)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(4, C_ENCODE_BAR_NUMBER);
         elsif trn_rbar_hit_n(5)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(5, C_ENCODE_BAR_NUMBER);
         elsif trn_rbar_hit_n(6)='0' then
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(6, C_ENCODE_BAR_NUMBER);
         else
            Encoded_BAR_Index <= CONV_STD_LOGIC_VECTOR(7, C_ENCODE_BAR_NUMBER);
         end if;

      end if;
   end process;


-- ----------------------------------------------------------------------------------
-- 
-- Synchronous output: MRd FIFO write port
-- 
-- PIO Channel Buffer (128-bit) definition:
--     Note: Type not shows in this buffer
--
--  127 ~ xxx : Peripheral address
--  xxy ~  97 : reserved
--         96 : Zero-length
--         95 : reserved
--         94 : Valid
--   93 ~  68 : reserved
--   67 ~  65 : BAR number
--   64 ~  49 : Requester ID
--   48 ~  41 : Tag
--   40 ~  34 : Lower Address
--   33 ~  31 : Completion Status
--   30 ~  19 : Byte count
--
--   18 ~  17 : Format
--   16 ~  14 : TC
--         13 : TD
--         12 : EP
--   11 ~  10 : Attribute
--    9 ~   0 : Length
-- 
   RxFSM_Output_pioCplD_WR:
   process ( trn_clk, local_Reset)
   begin
      if local_Reset = '1' then
         pioCplD_we  <= '0';
         pioCplD_din <= (OTHERS=>'0');

      elsif trn_clk'event and trn_clk = '1' then

         case RxMRdTrn_State is


            when ST_MRd_HEAD2 =>
               pioCplD_we  <= '0';

               if Illegal_Leng_on_FIFO='1' then          -- Cpl : unsupported request
                 pioCplD_din(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT)
                             <= C_FMT3_NO_DATA;
                 pioCplD_din(C_CHBUF_CPLD_CS_BIT_TOP downto C_CHBUF_CPLD_CS_BIT_BOT)
                             <= "001";      --------------- ############
               else
                 pioCplD_din(C_CHBUF_FMT_BIT_TOP downto C_CHBUF_FMT_BIT_BOT)
                             <= C_FMT3_WITH_DATA;
                 pioCplD_din(C_CHBUF_CPLD_CS_BIT_TOP downto C_CHBUF_CPLD_CS_BIT_BOT)
                             <= "000";      --------------- ############
               end if;


               pioCplD_din(C_CHBUF_TC_BIT_TOP downto C_CHBUF_TC_BIT_BOT)
                           <= trn_rd_r1(C_TLP_TC_BIT_TOP downto C_TLP_TC_BIT_BOT);

               pioCplD_din(C_CHBUF_TD_BIT)  <= '0';

               pioCplD_din(C_CHBUF_EP_BIT)  <= '0';

               pioCplD_din(C_CHBUF_ATTR_BIT_TOP downto C_CHBUF_ATTR_BIT_BOT)
--                           <= trn_rd_r1(C_TLP_ATTR_BIT_TOP) & C_NO_SNOOP;  -- downto C_TLP_ATTR_BIT_BOT);
                           <= trn_rd_r1(C_TLP_ATTR_BIT_TOP downto C_TLP_ATTR_BIT_BOT);

               pioCplD_din(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT)
                             <= trn_rd_r1(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);

               pioCplD_din(C_CHBUF_QVALID_BIT)  <= '1';

               pioCplD_din(C_CHBUF_CPLD_REQID_BIT_TOP downto C_CHBUF_CPLD_REQID_BIT_BOT)
                           <= trn_rd_r1(C_TLP_REQID_BIT_TOP downto C_TLP_REQID_BIT_BOT);

               pioCplD_din(C_CHBUF_CPLD_TAG_BIT_TOP downto C_CHBUF_CPLD_TAG_BIT_BOT)
                           <= trn_rd_r1(C_TLP_TAG_BIT_TOP downto C_TLP_TAG_BIT_BOT);

               pioCplD_din(C_CHBUF_0LENG_BIT) <= Tlp_is_Zero_Length;

               if Tlp_is_Zero_Length='1' then
                 pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
                           <= CONV_STD_LOGIC_VECTOR(0, C_ENCODE_BAR_NUMBER);
---- ** begin: avoid PIO read blocking
--               elsif trn_rbar_hit_n_r1(CINT_FIFO_SPACE_BAR)='0' and FIFO_Empty='1' then
--                 pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                           <= CONV_STD_LOGIC_VECTOR(0, C_ENCODE_BAR_NUMBER);
---- ** end
               else
                 pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
                           <= Encoded_BAR_Index;
               end if;


            when ST_MRd_Tail =>

              if MRd_Has_4DW_Header='1' then
                pioCplD_din(C_CHBUF_CPLD_LA_BIT_TOP downto C_CHBUF_CPLD_LA_BIT_BOT)
                             <= trn_rd_r1(C_CHBUF_CPLD_LA_BIT_TOP-C_CHBUF_CPLD_LA_BIT_BOT downto 0);

                if trn_rbar_hit_n_r1(CINT_REGS_SPACE_BAR)='0' then
                   pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                               <= trn_rd_r1(C_CHBUF_PA_BIT_TOP-C_CHBUF_PA_BIT_BOT downto 0);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= CONV_STD_LOGIC_VECTOR(CINT_REGS_SPACE_BAR, C_ENCODE_BAR_NUMBER);   --- "000";
                elsif trn_rbar_hit_n_r1(CINT_BRAM_SPACE_BAR)='0' then
                   pioCplD_din(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)
                               <= trn_rd_r1(C_CHBUF_MA_BIT_TOP-C_CHBUF_MA_BIT_BOT downto 0);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= CONV_STD_LOGIC_VECTOR(CINT_BRAM_SPACE_BAR, C_ENCODE_BAR_NUMBER);   --- "001";
                elsif trn_rbar_hit_n_r1(CINT_DDR_SPACE_BAR)='0' then
                   pioCplD_din(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT)
                               <= trn_rd_r1(C_CHBUF_DDA_BIT_TOP-C_CHBUF_DDA_BIT_BOT downto 0);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER);   --- "001";
                else
                   pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                               <= C_ALL_ZEROS(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= C_ALL_ONES(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT);    --- "111" !!!
                end if;

              else 
                pioCplD_din(C_CHBUF_CPLD_LA_BIT_TOP downto C_CHBUF_CPLD_LA_BIT_BOT)
                             <= trn_rd_r1(C_CHBUF_CPLD_LA_BIT_TOP-C_CHBUF_CPLD_LA_BIT_BOT+32 downto 32);

                if trn_rbar_hit_n_r1(CINT_REGS_SPACE_BAR)='0' then
                   pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                               <= trn_rd_r1(C_CHBUF_PA_BIT_TOP-C_CHBUF_PA_BIT_BOT+32 downto 32);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= CONV_STD_LOGIC_VECTOR(CINT_REGS_SPACE_BAR, C_ENCODE_BAR_NUMBER);   --- "000";
                elsif trn_rbar_hit_n_r1(CINT_BRAM_SPACE_BAR)='0' then
                   pioCplD_din(C_CHBUF_MA_BIT_TOP downto C_CHBUF_MA_BIT_BOT)
                               <= trn_rd_r1(C_CHBUF_MA_BIT_TOP-C_CHBUF_MA_BIT_BOT+32 downto 32);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= CONV_STD_LOGIC_VECTOR(CINT_BRAM_SPACE_BAR, C_ENCODE_BAR_NUMBER);   --- "001";
                elsif trn_rbar_hit_n_r1(CINT_DDR_SPACE_BAR)='0' then
                   pioCplD_din(C_CHBUF_DDA_BIT_TOP downto C_CHBUF_DDA_BIT_BOT)
                               <= trn_rd_r1(C_CHBUF_DDA_BIT_TOP-C_CHBUF_DDA_BIT_BOT+32 downto 32);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER);   --- "001";
                else
                   pioCplD_din(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT)
                               <= C_ALL_ZEROS(C_CHBUF_PA_BIT_TOP downto C_CHBUF_PA_BIT_BOT);
--                   pioCplD_din(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                               <= C_ALL_ONES(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT);    --- "111" !!!
                end if;
              end if;


              if pioCplD_din(C_CHBUF_0LENG_BIT) ='1' then   --  Zero-length
                 pioCplD_din(C_CHBUF_CPLD_BC_BIT_TOP downto C_CHBUF_CPLD_BC_BIT_BOT)
                          <= CONV_STD_LOGIC_VECTOR(1, C_CHBUF_CPLD_BC_BIT_TOP-C_CHBUF_CPLD_BC_BIT_BOT+1);
              else
                 pioCplD_din(C_CHBUF_CPLD_BC_BIT_TOP downto C_CHBUF_CPLD_BC_BIT_BOT)
                          <= pioCplD_din(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT) &"00";
              end if;

--              if trn_rbar_hit_n_r1(CINT_REGS_SPACE_BAR)='0'
--                 or trn_rbar_hit_n_r1(CINT_BRAM_SPACE_BAR)='0' 
--                 then
              if trn_rbar_hit_n_r1(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0) then
                 pioCplD_we  <= not Tlp_straddles_4KB;                    --'1';
              else
                 pioCplD_we  <= '0';
              end if;


            when OTHERS =>
               pioCplD_we  <= '0';
               pioCplD_din <= pioCplD_din;

         end case;

      end if;
   end process;


-- -----------------------------------------------------------------------
-- Capture: MRd_Has_4DW_Header
--        : Tlp_is_Zero_Length
-- 
   Syn_Capture_MRd_Has_4DW_Header:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         MRd_Has_3DW_Header   <= '0';
         MRd_Has_4DW_Header   <= '0';
         Tlp_is_Zero_Length   <= '0';
         Illegal_Leng_on_FIFO <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if trn_rsof_n_i='0' then
            MRd_Has_3DW_Header   <= not trn_rd_i(C_TLP_FMT_BIT_BOT) and not trn_rd_i(C_TLP_FMT_BIT_BOT+1);
            MRd_Has_4DW_Header   <= trn_rd_i(C_TLP_FMT_BIT_BOT) and not trn_rd_i(C_TLP_FMT_BIT_BOT+1);
            Tlp_is_Zero_Length   <= not (trn_rd_i(3) or trn_rd_i(2) or trn_rd_i(1) or trn_rd_i(0));
            if     trn_rd_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)/=CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG)
               and trn_rd_i(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)/=CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG)
               and trn_rbar_hit_n(CINT_FIFO_SPACE_BAR)='0'
               then
              Illegal_Leng_on_FIFO  <= '1';
            else
              Illegal_Leng_on_FIFO  <= '0';
            end if;
         else
            MRd_Has_3DW_Header    <= MRd_Has_3DW_Header;
            MRd_Has_4DW_Header    <= MRd_Has_4DW_Header;
            Tlp_is_Zero_Length    <= Tlp_is_Zero_Length;
            Illegal_Leng_on_FIFO  <= Illegal_Leng_on_FIFO;
         end if;
      end if;
   end process;


-- -----------------------------------------------------------------------
-- syn
--        : pio_reading_status
-- 
   Syn_PIO_Reading_EB_Status:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         pio_reading_status_i <= '0';
         pio_read_fading_cnt  <= (OTHERS=>'0');
      elsif trn_clk'event and trn_clk = '1' then
         if trn_reof_n_i='0' then
            if  MRd_Has_4DW_Header='1' 
            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR)='0'
            and trn_rd_i(8-1 downto 0)=X"90" then
                pio_reading_status_i <= '1';
                pio_read_fading_cnt  <= X"E0";
            elsif MRd_Has_3DW_Header='1'
            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR)='0'
            and trn_rd_i(32+8-1 downto 32)=X"90" then
                pio_reading_status_i <= '1';
                pio_read_fading_cnt  <= X"E0";
            elsif pio_read_fading_cnt(7)='1' then
                pio_reading_status_i <= '1';
                pio_read_fading_cnt  <= pio_read_fading_cnt + '1';
            else
                pio_reading_status_i <= '0';
                pio_read_fading_cnt  <= (OTHERS=>'0');
            end if;
         elsif pio_read_fading_cnt=X"00" then
                pio_reading_status_i <= '0';
                pio_read_fading_cnt  <= (OTHERS=>'0');
         else
                pio_reading_status_i <= pio_reading_status_i;
                pio_read_fading_cnt  <= pio_read_fading_cnt + '1';
         end if;

      end if;
   end process;


   -- -------------------------------------------------
   -- MRd TLP Buffer
   -- -------------------------------------------------
   pioCplD_Buffer:
   v5sfifo_15x128
      port map (
         clk           => trn_clk,
         rst           => local_Reset,
         prog_full     => pioCplD_prog_Full,
--         wr_clk        => trn_clk,
         wr_en         => pioCplD_we,
         din           => pioCplD_din,
         full          => pioCplD_full,
--         rd_clk        => trn_clk,
         rd_en         => pioCplD_RE_i,
         dout          => pioCplD_Qout_wire,
         prog_empty    => open,
         empty         => pioCplD_empty_i
       );


-- ---------------------------------------------
--  Request for arbitration
-- 
   Synch_Req_Proc:
   process (local_Reset, trn_clk )
   begin
      if local_Reset = '1' then
         pioCplD_RE_i     <= '0';
         pioCplD_Qout_i   <= (OTHERS=>'0');
         pioCplD_Qout_reg <= (OTHERS=>'0');
         pioCplD_Leng     <= (0=>'1', OTHERS=>'0');
         pioCplD_Req_i    <= '0';
         FSM_REQ_pio      <= REQST_IDLE;

      elsif trn_clk'event and trn_clk = '1' then

         case FSM_REQ_pio  is

           when REQST_IDLE  =>
             if pioCplD_empty_i = '0' then
               pioCplD_RE_i   <= '1';
               pioCplD_Req_i  <= '0';
               pioCplD_Qout_i <= pioCplD_Qout_i;
               FSM_REQ_pio    <= REQST_1Read;
             else
               pioCplD_RE_i   <= '0';
               pioCplD_Req_i  <= '0';
               pioCplD_Qout_i <= pioCplD_Qout_i;
               FSM_REQ_pio    <= REQST_IDLE;
             end if;

           when REQST_1Read  =>
             pioCplD_RE_i   <= '0';
             pioCplD_Req_i  <= '0';
             pioCplD_Qout_i <= pioCplD_Qout_i;
             FSM_REQ_pio    <= REQST_Decision;

           when REQST_Decision  =>
             pioCplD_Qout_reg  <= pioCplD_Qout_wire;
             pioCplD_Leng      <= pioCplD_Qout_wire(C_CHBUF_LENG_BIT_TOP downto C_CHBUF_LENG_BIT_BOT);
             pioCplD_Qout_i    <= pioCplD_Qout_i;
--             if pioCplD_Qout_wire(C_CHBUF_FMT_BIT_TOP) = '1'  -- Has Payload
--               and pioCplD_Qout_wire(C_CHBUF_CPLD_BAR_BIT_TOP downto C_CHBUF_CPLD_BAR_BIT_BOT)
--                   =CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER) 
--               then
--               pioCplD_RE_i  <= '0';
--               pioCplD_Req_i <= '0';
--               FSM_REQ_pio   <= REQST_Quantity;
--             else
               pioCplD_RE_i  <= '0';
               pioCplD_Req_i <= '1';
               FSM_REQ_pio   <= REQST_nFIFO_Req;
--             end if;

           when REQST_nFIFO_Req  =>
             if pioCplD_RE = '1' then
               pioCplD_RE_i   <= '0';
               pioCplD_Qout_i <= pioCplD_Qout_reg;
               pioCplD_Req_i  <= '0';
               FSM_REQ_pio    <= REQST_IDLE;
             else
               pioCplD_RE_i   <= '0';
               pioCplD_Qout_i <= pioCplD_Qout_i;
               pioCplD_Req_i  <= '1';
               FSM_REQ_pio    <= REQST_nFIFO_Req;
             end if;

--           when REQST_Quantity  =>
--             if FIFO_Empty='1' then
--               pioCplD_RE_i   <= '0';
--               pioCplD_Req_i  <= '0';
--               pioCplD_Qout_i <= pioCplD_Qout_i;
--               FSM_REQ_pio    <= REQST_Quantity;
--             else
--               pioCplD_RE_i   <= '0';
--               pioCplD_Qout_i <= pioCplD_Qout_i;
--               pioCplD_Req_i  <= '1';
--               FSM_REQ_pio    <= REQST_FIFO_Req;
--             end if;
--
--           when REQST_FIFO_Req  =>
--             if FIFO_Empty='1' then
--               pioCplD_RE_i   <= '0';
--               pioCplD_Req_i  <= '0';
--               pioCplD_Qout_i <= pioCplD_Qout_i;
--               FSM_REQ_pio    <= REQST_Quantity;
--             elsif pioCplD_RE = '1' then
--               pioCplD_RE_i   <= '0';
--               pioCplD_Qout_i <= pioCplD_Qout_reg;
--               pioCplD_Req_i  <= '0';
--               FSM_REQ_pio    <= REQST_IDLE;
--             else
--               pioCplD_RE_i   <= '0';
--               pioCplD_Qout_i <= pioCplD_Qout_i;
--               pioCplD_Req_i  <= '1';
--               FSM_REQ_pio    <= REQST_FIFO_Req;
--             end if;

           when OTHERS  =>
             pioCplD_RE_i     <= '0';
             pioCplD_Qout_i   <= (OTHERS=>'0');
             pioCplD_Qout_reg <= (OTHERS=>'0');
             pioCplD_Leng     <= (OTHERS=>'1');
             pioCplD_Req_i    <= '0';
             FSM_REQ_pio      <= REQST_IDLE;

         end case;

      end if;
   end process;



-- ---------------------------------------------
--  Delay of Empty and prog_Full
-- 
   Synch_Delay_empty_and_full:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         pioCplD_empty_r1      <= pioCplD_empty_i;
         pioCplD_prog_full_r1  <= pioCplD_prog_Full;
      end if;
   end process;


end architecture Behavioral;
