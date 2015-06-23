----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    RxIn_Delay - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  20.02.2007
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

entity RxIn_Delay is
    port (
      -- Common ports
      trn_clk            : IN  std_logic;
      trn_reset_n        : IN  std_logic;
      trn_lnk_up_n       : IN  std_logic;

      -- Transaction receive interface
      trn_rsof_n         : IN  std_logic;
      trn_reof_n         : IN  std_logic;
      trn_rd             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n         : IN  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n      : IN  std_logic;
      trn_rsrc_rdy_n     : IN  std_logic;
      trn_rsrc_dsc_n     : IN  std_logic;
      trn_rbar_hit_n     : IN  std_logic_vector(C_BAR_NUMBER-1 downto 0);
      trn_rdst_rdy_n     : OUT std_logic;
      Pool_wrBuf_full    : IN  std_logic;
      Link_Buf_full      : IN  std_logic;

      -- Delay for one clock
      trn_rsof_n_dly     : OUT std_logic;
      trn_reof_n_dly     : OUT std_logic;
      trn_rd_dly         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      trn_rrem_n_dly     : OUT std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
      trn_rerrfwd_n_dly  : OUT std_logic;
      trn_rsrc_rdy_n_dly : OUT std_logic;
      trn_rdst_rdy_n_dly : OUT std_logic;
      trn_rsrc_dsc_n_dly : OUT std_logic;
      trn_rbar_hit_n_dly : OUT std_logic_vector(C_BAR_NUMBER-1 downto 0);


      -- TLP resolution
      IORd_Type          : OUT std_logic;
      IOWr_Type          : OUT std_logic;
      MRd_Type           : OUT std_logic_vector(3 downto 0);
      MWr_Type           : OUT std_logic_vector(1 downto 0);
      CplD_Type          : OUT std_logic_vector(3 downto 0);

      -- From Cpl/D channel
      usDMA_dex_Tag      : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);
      dsDMA_dex_Tag      : IN  std_logic_vector(C_TAG_WIDTH-1 downto 0);

      -- To Memory request process modules
      Tlp_straddles_4KB  : OUT std_logic;

      -- To Cpl/D channel
      Tlp_has_4KB        : OUT std_logic;
      Tlp_has_1DW        : OUT std_logic;
      CplD_is_the_Last   : OUT std_logic;
      CplD_on_Pool       : OUT std_logic;
      CplD_on_EB         : OUT std_logic;
      Req_ID_Match       : OUT std_logic;
      usDex_Tag_Matched  : OUT std_logic;
      dsDex_Tag_Matched  : OUT std_logic;
      CplD_Tag           : OUT std_logic_vector(C_TAG_WIDTH-1 downto  0);


      -- Additional
      cfg_dcommand       : IN  std_logic_vector(C_CFG_COMMAND_DWIDTH-1 downto 0);
      localID            : IN  std_logic_vector(C_ID_WIDTH-1 downto 0)
    );

end entity RxIn_Delay;



architecture Behavioral of RxIn_Delay is


-- Max Length Checking
   signal   Tlp_has_0_Length       :  std_logic;
   signal   Tlp_has_1DW_Length_i   :  std_logic;
   signal   MaxReadReqSize_Exceeded:  std_logic;
   signal   MaxPayloadSize_Exceeded:  std_logic;

   signal   Tlp_straddles_4KB_i    :  std_logic;
   signal   CarryIn_ALC            :  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG downto 0);
   signal   Tlp_has_4KB_i          :  std_logic;
   signal   cfg_MRS                :  std_logic_vector(C_CFG_MRS_BIT_TOP-C_CFG_MRS_BIT_BOT downto 0);
   signal   cfg_MPS                :  std_logic_vector(C_CFG_MPS_BIT_TOP-C_CFG_MPS_BIT_BOT downto 0);

   signal   cfg_MRS_decoded        :  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
   signal   cfg_MPS_decoded        :  std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);

   TYPE     CfgThreshold is ARRAY (C_TLP_FLD_WIDTH_OF_LENG-CBIT_SENSE_OF_MAXSIZE downto 0) 
                                   of std_logic_vector (C_TLP_FLD_WIDTH_OF_LENG downto 0);

   signal   MaxSize_Thresholds     : CfgThreshold;

-- As one clock of delay
   signal   trn_rsof_n_r1          :  std_logic;
   signal   trn_reof_n_r1          :  std_logic;
   signal   trn_rrem_n_r1          :  std_logic_vector(C_DBUS_WIDTH/8-1 downto 0);
   signal   trn_rd_r1              :  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
   signal   trn_rerrfwd_n_r1       :  std_logic;
   signal   trn_rsrc_rdy_n_r1      :  std_logic;
   signal   trn_rdst_rdy_n_i       :  std_logic;
   signal   trn_rdst_rdy_n_r1      :  std_logic;
   signal   trn_rsrc_dsc_n_r1      :  std_logic;
   signal   trn_rbar_hit_n_r1      :  std_logic_vector(C_BAR_NUMBER-1 downto 0);

-- TLP type decision
   signal   TLP_is_MRd_BAR0_H3DW   :  std_logic;
   signal   TLP_is_MRd_BAR1_H3DW   :  std_logic;
   signal   TLP_is_MRd_BAR2_H3DW   :  std_logic;
   signal   TLP_is_MRd_BAR3_H3DW   :  std_logic;

   signal   TLP_is_MRd_BAR0_H4DW   :  std_logic;
   signal   TLP_is_MRd_BAR1_H4DW   :  std_logic;
   signal   TLP_is_MRd_BAR2_H4DW   :  std_logic;
   signal   TLP_is_MRd_BAR3_H4DW   :  std_logic;

   signal   TLP_is_MRdLk_BAR0_H3DW :  std_logic;
   signal   TLP_is_MRdLk_BAR1_H3DW :  std_logic;
   signal   TLP_is_MRdLk_BAR2_H3DW :  std_logic;
   signal   TLP_is_MRdLk_BAR3_H3DW :  std_logic;

   signal   TLP_is_MRdLk_BAR0_H4DW :  std_logic;
   signal   TLP_is_MRdLk_BAR1_H4DW :  std_logic;
   signal   TLP_is_MRdLk_BAR2_H4DW :  std_logic;
   signal   TLP_is_MRdLk_BAR3_H4DW :  std_logic;

   signal   TLP_is_MWr_BAR0_H3DW   :  std_logic;
   signal   TLP_is_MWr_BAR1_H3DW   :  std_logic;
   signal   TLP_is_MWr_BAR2_H3DW   :  std_logic;
   signal   TLP_is_MWr_BAR3_H3DW   :  std_logic;

   signal   TLP_is_MWr_BAR0_H4DW   :  std_logic;
   signal   TLP_is_MWr_BAR1_H4DW   :  std_logic;
   signal   TLP_is_MWr_BAR2_H4DW   :  std_logic;
   signal   TLP_is_MWr_BAR3_H4DW   :  std_logic;

   signal   TLP_is_IORd_BAR0       :  std_logic;
   signal   TLP_is_IORd_BAR1       :  std_logic;
   signal   TLP_is_IORd_BAR2       :  std_logic;
   signal   TLP_is_IORd_BAR3       :  std_logic;

   signal   TLP_is_IOWr_BAR0       :  std_logic;
   signal   TLP_is_IOWr_BAR1       :  std_logic;
   signal   TLP_is_IOWr_BAR2       :  std_logic;
   signal   TLP_is_IOWr_BAR3       :  std_logic;

   signal   TLP_is_IORd            :  std_logic;
   signal   TLP_is_IOWr            :  std_logic;

   signal   TLP_is_CplD            :  std_logic;
   signal   TLP_is_Cpl             :  std_logic;
   signal   TLP_is_CplDLk          :  std_logic;
   signal   TLP_is_CplLk           :  std_logic;


   signal   TLP_is_MRd_H3DW        :  std_logic;
   signal   TLP_is_MRd_H4DW        :  std_logic;
   signal   TLP_is_MRdLk_H3DW      :  std_logic;
   signal   TLP_is_MRdLk_H4DW      :  std_logic;

   signal   TLP_is_MWr_H3DW        :  std_logic;
   signal   TLP_is_MWr_H4DW        :  std_logic;


   signal   IORd_Type_i            :  std_logic;
   signal   IOWr_Type_i            :  std_logic;
   signal   MRd_Type_i             :  std_logic_vector(3 downto 0);
   signal   MWr_Type_i             :  std_logic_vector(1 downto 0);
   signal   CplD_Type_i            :  std_logic_vector(3 downto 0);

   signal   Req_ID_Match_i         :  std_logic;

   signal   usDex_Tag_Matched_i    :  std_logic;
   signal   dsDex_Tag_Matched_i    :  std_logic;


   -----------------------------------------------------------------
   -- Inbound DW counter
   signal   TLP_Payload_Address_i  : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
   signal   TLP_DW_Length_i        : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
   signal   TLP_Address_sig        : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG   downto 0);
   signal   MWr_on_Pool            :  std_logic;
   signal   MWr_on_EB              :  std_logic;
   signal   CplD_on_Pool_i         : std_logic;
   signal   CplD_on_EB_i           : std_logic;
   signal   CplD_is_the_Last_i     : std_logic;
   signal   CplD_Tag_i             : std_logic_vector(C_TAG_WIDTH-1 downto  0);

   --   Counter inside a TLP
   type TLPCntStates is            ( TK_RST
                                   , TK_Idle
--                                   , TK_MWr_3Hdr_B
                                   , TK_MWr_3Hdr_C
--                                   , TK_MWr_4Hdr_B
                                   , TK_MWr_4Hdr_C
--                                   , TK_MWr_4Hdr_D
--                                   , TK_CplD_Hdr_B
                                   , TK_CplD_Hdr_C
                                   , TK_Body
                                   );

   signal FSM_TLP_Cnt              : TLPCntStates;

   signal FSM_TLP_Cnt_r1           : TLPCntStates;

   --   CplD tag capture FSM (Address at tRAM)
   type AddrOnRAM_States is        ( AOtSt_RST
                                   , AOtSt_Idle
                                   , AOtSt_HdrA
                                   , AOtSt_HdrB
                                   , AOtSt_Body
                                   );

   signal FSM_AOtRAM               : AddrOnRAM_States;


begin

   trn_rdst_rdy_n        <=  trn_rdst_rdy_n_i     ;   -- and trn_rsof_n and trn_rsof_n_r1  ;

   -- Delay
   trn_rsof_n_dly        <=  trn_rsof_n_r1        ;
   trn_reof_n_dly        <=  trn_reof_n_r1        ;
   trn_rrem_n_dly        <=  trn_rrem_n_r1        ;
   trn_rd_dly            <=  trn_rd_r1            ;
   trn_rerrfwd_n_dly     <=  trn_rerrfwd_n_r1     ;
   trn_rsrc_rdy_n_dly    <=  trn_rsrc_rdy_n_r1    ;
   trn_rdst_rdy_n_dly    <=  trn_rdst_rdy_n_r1    ;   -- trn_rdst_rdy_n_r1    ;
   trn_rsrc_dsc_n_dly    <=  trn_rsrc_dsc_n_r1    ;
   trn_rbar_hit_n_dly    <=  trn_rbar_hit_n_r1    ;


   -- TLP resolution
   IORd_Type             <=  '0' ;                 -- IORd_Type_i          ;
   IOWr_Type             <=  '0' ;                 -- IOWr_Type_i          ;
   MRd_Type              <=  MRd_Type_i           ;
   MWr_Type              <=  MWr_Type_i           ;
   CplD_Type             <=  CplD_Type_i          ;

   -- To Cpl/D channel
   Req_ID_Match          <=  Req_ID_Match_i       ;

   usDex_Tag_Matched     <=  usDex_Tag_Matched_i  ;
   dsDex_Tag_Matched     <=  dsDex_Tag_Matched_i  ;

   CplD_Tag              <=  CplD_Tag_i           ;
   CplD_is_the_Last      <=  CplD_is_the_Last_i   ;
   CplD_on_Pool          <=  CplD_on_Pool_i       ;
   CplD_on_EB            <=  CplD_on_EB_i         ;


   Tlp_has_4KB           <=  Tlp_has_4KB_i        ;
   Tlp_has_1DW           <=  Tlp_has_1DW_Length_i ;

   Tlp_straddles_4KB     <=  '0';                  --Tlp_straddles_4KB_i  ;


   --  !! !! 
   MaxReadReqSize_Exceeded  <=  '0';
   MaxPayloadSize_Exceeded  <=  '0';

 

----------------------------------------------
--
-- Synchronous Registered: TLP_DW_Length
--                         Tlp_has_4KB
--                         Tlp_has_1DW_Length
--                         Tlp_has_0_Length
--
   FSM_TLP_1ST_DW_Info:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         TLP_DW_Length_i        <= (OTHERS => '0');
         Tlp_has_4KB_i          <= '0';
         Tlp_has_1DW_Length_i   <= '0';
         Tlp_has_0_Length       <= '0';

      elsif trn_clk'event and trn_clk = '1' then
         if trn_rsof_n='0' then
            TLP_DW_Length_i        <= trn_rd(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT);
         else
            TLP_DW_Length_i        <= TLP_DW_Length_i;
         end if;

         if trn_rsof_n ='0' then
            if trn_rd(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)=C_ALL_ZEROS(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) then
               Tlp_has_4KB_i <= '1' ;
            else
               Tlp_has_4KB_i <= '0' ;
            end if;
         else
            Tlp_has_4KB_i <= Tlp_has_4KB_i ;
         end if;

         if trn_rsof_n ='0' then
            if trn_rd(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)
               = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
               Tlp_has_1DW_Length_i  <= '1';
            else
               Tlp_has_1DW_Length_i  <= '0';
            end if;
         else
            Tlp_has_1DW_Length_i  <= Tlp_has_1DW_Length_i;
         end if;

         if trn_rsof_n ='0' then
            if trn_rd(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)
               = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) 
               and trn_rd(2)='0' then
               Tlp_has_0_Length  <= '1';
            else
               Tlp_has_0_Length  <= '0';
            end if;
         else
            Tlp_has_0_Length  <= Tlp_has_0_Length;
         end if;

      end if;
   end process;



---- --------------------------------------------------------------------------
--   -- Max Payload Size bits
--   cfg_MPS               <= cfg_dcommand(C_CFG_MPS_BIT_TOP downto C_CFG_MPS_BIT_BOT);
--
--   -- Max Read Request Size bits
--   cfg_MRS               <= cfg_dcommand(C_CFG_MRS_BIT_TOP downto C_CFG_MRS_BIT_BOT);
--
--
--
--   -- --------------------------------
--   -- Decoding MPS
--   --
--   Trn_Rx_Decoding_MPS:
--   process ( trn_clk )
--   begin
--      if trn_clk'event and trn_clk = '1' then
--
--         case cfg_MPS is
--           when CONV_STD_LOGIC_VECTOR(0, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(1, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(2, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(3, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(4, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(5, 3) =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when Others =>
--              cfg_MPS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--         end case;
--
--      end if;
--   end process;
--
--
--   -- --------------------------------
--   -- Decoding MRS
--   --
--   Trn_Rx_Decoding_MRS:
--   process ( trn_clk )
--   begin
--      if trn_clk'event and trn_clk = '1' then
--
--         case cfg_MRS is
--           when CONV_STD_LOGIC_VECTOR(0, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(1, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(2, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(3, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(4, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when CONV_STD_LOGIC_VECTOR(5, 3) =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--           when Others =>
--              cfg_MRS_decoded   <= MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE);
--
--         end case;
--
--      end if;
--   end process;
--
--
--   -------------------------------------------------------------
--   MaxSize_Thresholds(0) <= (CBIT_SENSE_OF_MAXSIZE=>'1', Others=>'0');
--   Gen_MaxSizes:
--   FOR i IN 1 TO C_TLP_FLD_WIDTH_OF_LENG-CBIT_SENSE_OF_MAXSIZE GENERATE
--     MaxSize_Thresholds(i) <= MaxSize_Thresholds(i-1)(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0)&'0';
--   END GENERATE;
--
--   -- --------------------------------
--   -- Calculation of MPS exceed
--   --
--   Trn_Rx_MaxPayloadSize_Exceeded:
--   process ( trn_clk )
--   begin
--      if trn_clk'event and trn_clk = '1' then
--
--         case cfg_MPS_decoded is
--
----           when CONV_STD_LOGIC_VECTOR(1, 6)  =>   -- MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
----             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
----                MaxPayloadSize_Exceeded <= '1';
----             else
----                MaxPayloadSize_Exceeded <= '0';
----             end if;
--
--           when CONV_STD_LOGIC_VECTOR(2, 6)  =>   -- MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(1) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(4, 6)  =>   -- MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(2) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(8, 6)  =>   -- MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(3) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(16, 6)  =>   -- MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(4) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(32, 6)  =>   -- MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--                MaxPayloadSize_Exceeded <= '0';            -- !!
--
--           when OTHERS  =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
--                MaxPayloadSize_Exceeded <= '1';
--             else
--                MaxPayloadSize_Exceeded <= '0';
--             end if;
--
--        end case;
--
--      end if;
--   end process;
--
--
--   -- --------------------------------
--   -- Calculation of MRS exceed
--   --
--   Trn_Rx_MaxReadReqSize_Exceeded:
--   process ( trn_clk )
--   begin
--      if trn_clk'event and trn_clk = '1' then
--
--         case cfg_MRS_decoded is
--
----           when CONV_STD_LOGIC_VECTOR(1, 6)  =>   -- MaxSize_Thresholds(0)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
----             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
----                MaxReadReqSize_Exceeded <= '1';
----             else
----                MaxReadReqSize_Exceeded <= '0';
----             end if;
--
--           when CONV_STD_LOGIC_VECTOR(2, 6)  =>   -- MaxSize_Thresholds(1)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(1) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(4, 6)  =>   -- MaxSize_Thresholds(2)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(2) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(8, 6)  =>   -- MaxSize_Thresholds(3)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(3) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(16, 6)  =>   -- MaxSize_Thresholds(4)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(4) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--           when CONV_STD_LOGIC_VECTOR(32, 6)  =>   -- MaxSize_Thresholds(5)(C_TLP_FLD_WIDTH_OF_LENG downto CBIT_SENSE_OF_MAXSIZE) =>
--                MaxReadReqSize_Exceeded <= '0';            -- !!
--
--           when OTHERS  =>
--             if trn_rd(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0) > MaxSize_Thresholds(0) then
--                MaxReadReqSize_Exceeded <= '1';
--             else
--                MaxReadReqSize_Exceeded <= '0';
--             end if;
--
--        end case;
--
--      end if;
--   end process;




   --    ---------------------------------------------------------
   ----  Pipelining all trn_rx input signals for one clock
   ----    to get better timing
   ---- 
   Trn_Rx_Inputs_Delayed:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         trn_rsof_n_r1      <= trn_rsof_n;
         trn_reof_n_r1      <= trn_reof_n;
         trn_rrem_n_r1      <= trn_rrem_n;
         trn_rd_r1          <= trn_rd;
         trn_rerrfwd_n_r1   <= trn_rerrfwd_n;
         trn_rsrc_rdy_n_r1  <= trn_rsrc_rdy_n;
         trn_rdst_rdy_n_r1  <= trn_rdst_rdy_n_i;
         trn_rsrc_dsc_n_r1  <= trn_rsrc_dsc_n;
         trn_rbar_hit_n_r1  <= trn_rbar_hit_n;
      end if;
   end process;


   -- -----------------------------------------
   -- TLP Types
   --
   TLP_Decision_Registered:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         TLP_is_MRd_H3DW   <= '0';

         TLP_is_MRdLk_H3DW <= '0';

         TLP_is_MRd_H4DW   <= '0';

         TLP_is_MRdLk_H4DW <= '0';

         TLP_is_MWr_H3DW   <= '0';

         TLP_is_MWr_H4DW   <= '0';

         TLP_is_IORd       <= '0';

         TLP_is_IOWr       <= '0';

         TLP_is_CplD       <= '0';
         TLP_is_CplDLk     <= '0';
         TLP_is_Cpl        <= '0';
         TLP_is_CplLk      <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         -- IORd
         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_IO_REQ
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_IORd   <= '1';
         else
                TLP_is_IORd   <= '0';
         end if;


         -- IOWr
         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_WITH_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_IO_REQ
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_IOWr   <= '1';
         else
                TLP_is_IOWr   <= '0';
         end if;


         -- MRd
         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_MRd_H3DW   <= '1';
         else
                TLP_is_MRd_H3DW   <= '0';
         end if;



         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT4_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_MRd_H4DW   <= '1';
         else
                TLP_is_MRd_H4DW   <= '0';
         end if;


         -- MRdLk
         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ_LK
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_MRdLk_H3DW   <= '1';
         else
                TLP_is_MRdLk_H3DW   <= '0';
         end if;


         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT4_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ_LK
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_MRdLk_H4DW   <= '1';
         else
                TLP_is_MRdLk_H4DW   <= '0';
         end if;



         -- MWr
         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_WITH_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_MWr_H3DW   <= '1';
         else
                TLP_is_MWr_H3DW   <= '0';
         end if;


         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT4_WITH_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_MEM_REQ
            and trn_rd(C_TLP_EP_BIT) ='0'
--            and trn_rbar_hit_n(CINT_REGS_SPACE_BAR) ='0'
            and trn_rbar_hit_n(CINT_BAR_SPACES-1 downto 0) /= C_ALL_ONES(CINT_BAR_SPACES-1 downto 0)
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_MWr_H4DW   <= '1';
         else
                TLP_is_MWr_H4DW   <= '0';
         end if;



         -- CplD, Cpl/CplDLk, CplLk
         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_WITH_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION
            and trn_rd(C_TLP_EP_BIT) ='0'
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_CplD     <= '1';
         else
                TLP_is_CplD     <= '0';
         end if;

         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_WITH_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION_LK
            and trn_rd(C_TLP_EP_BIT) ='0'
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_CplDLk   <= '1';
         else
                TLP_is_CplDLk   <= '0';
         end if;


         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION
            and trn_rd(C_TLP_EP_BIT) ='0'
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_Cpl      <= '1';
         else
                TLP_is_Cpl      <= '0';
         end if;

         if     trn_rd(C_TLP_FMT_BIT_TOP  downto C_TLP_FMT_BIT_BOT)  = C_FMT3_NO_DATA
            and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_BOT) = C_TYPE_COMPLETION_LK
            and trn_rd(C_TLP_EP_BIT) ='0'
            and trn_rsrc_rdy_n ='0'
            and trn_rsof_n ='0'
            then
                TLP_is_CplLk    <= '1';
         else
                TLP_is_CplLk    <= '0';
         end if;

      end if;
   end process;


-- --------------------------------------------------------------------------
--   TLP_is_IORd        <=  TLP_is_IORd_BAR0       or TLP_is_IORd_BAR1;
--   TLP_is_IOWr        <=  TLP_is_IOWr_BAR0       or TLP_is_IOWr_BAR1;

--   TLP_is_MRd_H3DW    <=  TLP_is_MRd_BAR0_H3DW   or TLP_is_MRd_BAR1_H3DW;
--   TLP_is_MRdLk_H3DW  <=  TLP_is_MRdLk_BAR0_H3DW or TLP_is_MRdLk_BAR1_H3DW;

--   TLP_is_MRd_H4DW    <=  TLP_is_MRd_BAR0_H4DW   or TLP_is_MRd_BAR1_H4DW;
--   TLP_is_MRdLk_H4DW  <=  TLP_is_MRdLk_BAR0_H4DW or TLP_is_MRdLk_BAR1_H4DW;

--   TLP_is_MWr_H3DW    <=  TLP_is_MWr_BAR0_H3DW   or TLP_is_MWr_BAR1_H3DW;

--   TLP_is_MWr_H4DW    <=  TLP_is_MWr_BAR0_H4DW   or TLP_is_MWr_BAR1_H4DW;

-- --------------------------------------------------------------------------

   IORd_Type_i    <= TLP_is_IORd and Tlp_has_1DW_Length_i;
   IOWr_Type_i    <= TLP_is_IOWr and Tlp_has_1DW_Length_i;


   MRd_Type_i     <= (TLP_is_MRd_H3DW   and not MaxReadReqSize_Exceeded)
                   & (TLP_is_MRdLk_H3DW and not MaxReadReqSize_Exceeded)
                   & (TLP_is_MRd_H4DW   and not MaxReadReqSize_Exceeded)
                   & (TLP_is_MRdLk_H4DW and not MaxReadReqSize_Exceeded)
                   ;

   MWr_Type_i     <= (TLP_is_MWr_H3DW   and not MaxPayloadSize_Exceeded)
                   & (TLP_is_MWr_H4DW   and not MaxPayloadSize_Exceeded)
                   ;

   CplD_Type_i    <= (TLP_is_CplD       and not MaxPayloadSize_Exceeded)
                   & (TLP_is_Cpl        and not MaxPayloadSize_Exceeded)
                   & (TLP_is_CplDLk     and not MaxPayloadSize_Exceeded)
                   & (TLP_is_CplLk      and not MaxPayloadSize_Exceeded)
                   ;


   ---------------------------------------------------
   --
   -- Synchronous Registered: TLP_Header_Resolution
   --
   FSM_TLP_Header_Resolution:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         FSM_TLP_Cnt           <= TK_RST;
         TLP_Payload_Address_i <= (OTHERS => '1');
         MWr_on_Pool           <= '0';
         CplD_on_Pool_i        <= '0';
         CplD_on_EB_i          <= '0';
         trn_rdst_rdy_n_i      <= '1';

      elsif trn_clk'event and trn_clk = '1' then

        -- States transition
        case FSM_TLP_Cnt is

          when TK_RST =>
              FSM_TLP_Cnt           <= TK_Idle;
              trn_rdst_rdy_n_i      <= '1';

          when TK_Idle =>
            trn_rdst_rdy_n_i      <= '0';
            if trn_rsof_n='0' and trn_rsrc_rdy_n='0' 
               and trn_rd(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) ="10" 
               and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="00" 
               then
              FSM_TLP_Cnt    <= TK_MWr_3Hdr_C;
            elsif trn_rsof_n='0' and trn_rsrc_rdy_n='0' 
               and trn_rd(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) ="11" 
               and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="00" 
               then
              FSM_TLP_Cnt    <= TK_MWr_4Hdr_C;
            elsif trn_rsof_n='0' and trn_rsrc_rdy_n='0' 
               and trn_rd(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) ="10" 
               and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="01" 
               then
              FSM_TLP_Cnt    <= TK_CplD_Hdr_C;
            else
              FSM_TLP_Cnt    <= TK_Idle;
            end if;


          when TK_MWr_3Hdr_C =>
            trn_rdst_rdy_n_i      <= '0';
            if trn_reof_n='0' and trn_reof_n_r1='1' then  -- falling edge
              FSM_TLP_Cnt    <= TK_Idle;
            elsif trn_rsrc_rdy_n='1' then
              FSM_TLP_Cnt    <= TK_MWr_3Hdr_C;
            else
              FSM_TLP_Cnt    <= TK_Body;
            end if;

          when TK_MWr_4Hdr_C =>
            trn_rdst_rdy_n_i      <= '0';
            if trn_reof_n='0' and trn_reof_n_r1='1' then  -- falling edge
              FSM_TLP_Cnt    <= TK_Idle;
            elsif trn_rsrc_rdy_n='1' then
              FSM_TLP_Cnt    <= TK_MWr_4Hdr_C;
            else
              FSM_TLP_Cnt    <= TK_Body;      -- TK_MWr_4Hdr_D;
            end if;


          when TK_Cpld_Hdr_C =>
            trn_rdst_rdy_n_i      <= '0';
            if trn_reof_n='0' and trn_reof_n_r1='1' then  -- falling edge
              FSM_TLP_Cnt    <= TK_Idle;
            elsif trn_rsrc_rdy_n='1' then
              FSM_TLP_Cnt    <= TK_Cpld_Hdr_C;
            else
              FSM_TLP_Cnt    <= TK_Body;
            end if;


          when TK_Body =>
            if trn_reof_n='0' and trn_reof_n_r1='1' then  -- falling edge
              FSM_TLP_Cnt    <= TK_Idle;
              trn_rdst_rdy_n_i      <= '0';
            else
              FSM_TLP_Cnt    <= TK_Body;
              trn_rdst_rdy_n_i      <= ((MWr_on_Pool or CplD_on_Pool_i) and Pool_wrBuf_full)
                                    or ((MWr_on_EB or CplD_on_EB_i) and Link_Buf_full)
                                    ;
            end if;


          when OTHERS  =>
              trn_rdst_rdy_n_i    <= trn_rdst_rdy_n_i;
              FSM_TLP_Cnt    <= TK_RST;

        end case;


        -- MWr_on_Pool
        case FSM_TLP_Cnt is

          when TK_RST =>
              MWr_on_Pool   <= '0';
              MWr_on_EB     <= '0';

          when TK_Idle =>
            if trn_rsof_n='0' and trn_rsrc_rdy_n='0' 
               and trn_rd(C_TLP_FMT_BIT_TOP) = '1' 
               and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="00" 
               then
              MWr_on_Pool   <= not trn_rbar_hit_n(CINT_DDR_SPACE_BAR);
              MWr_on_EB     <= not trn_rbar_hit_n(CINT_FIFO_SPACE_BAR);
            else
              MWr_on_Pool   <= MWr_on_Pool;
              MWr_on_EB     <= MWr_on_EB;
            end if;


          when OTHERS  =>
              MWr_on_Pool   <= MWr_on_Pool;
              if trn_reof_n='0' and trn_reof_n_r1='1' then  -- falling edge
                MWr_on_EB     <= '0';
              else
                MWr_on_EB     <= MWr_on_EB;
              end if;

        end case;


        -- CplD_on_Pool
        case FSM_TLP_Cnt is

          when TK_RST =>
              CplD_on_Pool_i  <= '0';
              CplD_on_EB_i    <= '0';

          when TK_Idle =>
              CplD_on_Pool_i  <= '0';
              CplD_on_EB_i    <= '0';

          when TK_CplD_Hdr_C =>
--            if trn_rsof_n='0' and trn_rsrc_rdy_n='0' 
--               and trn_rd(C_TLP_FMT_BIT_TOP downto C_TLP_FMT_BIT_BOT) ="10" 
--               and trn_rd(C_TLP_TYPE_BIT_TOP downto C_TLP_TYPE_BIT_TOP-1) ="01" 
--               then
              CplD_on_Pool_i  <= not trn_rd(C_CPLD_TAG_BIT_TOP) and not trn_rd(C_CPLD_TAG_BIT_TOP-1);
              CplD_on_EB_i    <= not trn_rd(C_CPLD_TAG_BIT_TOP) and trn_rd(C_CPLD_TAG_BIT_TOP-1);
--            else
--              CplD_on_Pool_i  <= CplD_on_Pool_i;
--              CplD_on_EB_i    <= CplD_on_EB_i;
--            end if;


          when OTHERS  =>
              CplD_on_Pool_i  <= CplD_on_Pool_i;
              CplD_on_EB_i    <= CplD_on_EB_i;

        end case;


        -- CplD_Tag
        case FSM_TLP_Cnt is

          when TK_RST =>
              CplD_Tag_i    <= (OTHERS => '1');

--          when TK_Idle =>
--              CplD_Tag_i    <= CplD_Tag_i;

          when TK_CplD_Hdr_C =>
--            if trn_reof_n='0' then
--              CplD_Tag_i    <= (OTHERS => '1');
--            els
            if trn_rsrc_rdy_n='0' -- and trn_rdst_rdy_n='0' 
               then
              CplD_Tag_i    <= trn_rd(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT);
            else
              CplD_Tag_i    <= CplD_Tag_i;
            end if;

          when OTHERS  =>
              CplD_Tag_i    <= CplD_Tag_i;

        end case;


      end if;
   end process;


   ---------------------------------------------------
   --
   -- Synchronous Registered: CplD_is_the_Last
   --
   Syn_Calc_CplD_is_the_Last:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
         CplD_is_the_Last_i    <= '0';

      elsif trn_clk'event and trn_clk = '1' then

         if trn_rsof_n='0' and trn_rsrc_rdy_n='0' then
            if trn_rd(C_TLP_TYPE_BIT_TOP-1)= '1' 
               and (trn_rd(C_TLP_FLD_WIDTH_OF_LENG+1 downto 2)=trn_rd(C_TLP_LENG_BIT_TOP downto C_TLP_LENG_BIT_BOT)
               or trn_rd(1 downto 0)=CONV_STD_LOGIC_VECTOR(1, 2))  -- Zero-length
               then
               CplD_is_the_Last_i <= '1';
            else
               CplD_is_the_Last_i <= '0';
            end if;
         else
           CplD_is_the_Last_i  <= CplD_is_the_Last_i;
         end if;
 
      end if;
   end process;

   ---------------------------------------------------
   --
   -- Synchronous Delay: FSM_TLP_Cnt
   --
   SynDelay_FSM_TLP_Cnt:
   process ( trn_clk )
   begin
      if trn_clk'event and trn_clk = '1' then
         FSM_TLP_Cnt_r1   <=  FSM_TLP_Cnt;
      end if;
   end process;


---- --------------------------------------------------------------------------
--
--   TLP_Address_sig      <=  '0' & trn_rd(C_TLP_FLD_WIDTH_OF_LENG+1 downto 2);
--
---------------------------------------------------------------------------------------
---- Calculates the Address-Length combination carry-in
--   TLP_Calc_CarryIn_ALC:
--   process ( trn_clk, trn_reset_n)
--   begin
--      if trn_reset_n = '0' then
--         CarryIn_ALC    <= (OTHERS =>'0');
--      elsif trn_clk'event and trn_clk = '1' then
--         CarryIn_ALC    <= ('0'& TLP_DW_Length_i) + TLP_Address_sig;
--      end if;
--   end process;
--
--
--   ---------------------------------------------------
--   --
--   -- Synchronous Registered: Tlp_straddles_4KB
--   --
--   FSM_Output_Tlp_straddles_4KB:
--   process ( trn_clk, trn_reset_n)
--   begin
--      if trn_reset_n = '0' then
--         Tlp_straddles_4KB_i   <= '0';
--
--      elsif trn_clk'event and trn_clk = '1' then
--
--        case FSM_TLP_Cnt_r1 is
--
--          when TK_RST =>
--              Tlp_straddles_4KB_i   <= '0';
--
--          when TK_MWr_3Hdr_C =>
--            if Tlp_has_4KB_i='1'
--               and trn_rd(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0) 
--                   /=C_ALL_ZEROS(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0)
--               then
--               Tlp_straddles_4KB_i <= '1';
--            else
--               Tlp_straddles_4KB_i <= CarryIn_ALC(C_TLP_FLD_WIDTH_OF_LENG);
--            end if;
--
--          when TK_MWr_4Hdr_D =>
--            if Tlp_has_4KB_i='1'
--               and trn_rd(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0) 
--                   /=C_ALL_ZEROS(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0)
--               then
--               Tlp_straddles_4KB_i <= '1';
--            else
--               Tlp_straddles_4KB_i <= CarryIn_ALC(C_TLP_FLD_WIDTH_OF_LENG);
--            end if;
--
--
--          when OTHERS  =>
--              Tlp_straddles_4KB_i <= Tlp_straddles_4KB_i;
--
--        end case;
--
--      end if;
--   end process;
--



   --  ---------------------------------------------------------
   --  To Cpl/D channel as indicator when ReqID matched
   --  
   TLP_ReqID_Matched:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
          Req_ID_Match_i      <= '0';
      elsif trn_clk'event and trn_clk = '1' then
        if trn_rd(C_CPLD_REQID_BIT_TOP downto C_CPLD_REQID_BIT_BOT)=localID then
          Req_ID_Match_i      <= '1';
        else
          Req_ID_Match_i      <= '0';
        end if;
      end if;
   end process;


   --  ------------------------------------------------------------
   --  To Cpl/D channel as indicator when us Tag_Descriptor matched
   --  
   TLP_usDexTag_Matched:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
          usDex_Tag_Matched_i      <= '0';
      elsif trn_clk'event and trn_clk = '1' then
        if trn_rd(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT)=usDMA_dex_Tag then
          usDex_Tag_Matched_i      <= '1';
        else
          usDex_Tag_Matched_i      <= '0';
        end if;
      end if;
   end process;


   --  ------------------------------------------------------------
   --  To Cpl/D channel as indicator when ds Tag_Descriptor matched
   --  
   TLP_dsDexTag_Matched:
   process ( trn_clk, trn_reset_n)
   begin
      if trn_reset_n = '0' then
          dsDex_Tag_Matched_i      <= '0';
      elsif trn_clk'event and trn_clk = '1' then
        if trn_rd(C_CPLD_TAG_BIT_TOP downto C_CPLD_TAG_BIT_BOT)=dsDMA_dex_Tag then
          dsDex_Tag_Matched_i      <= '1';
        else
          dsDex_Tag_Matched_i      <= '0';
        end if;
      end if;
   end process;


end architecture Behavioral;
