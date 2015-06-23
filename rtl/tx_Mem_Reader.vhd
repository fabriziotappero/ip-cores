----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    tx_Mem_Reader - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
--
-- Revision 1.00 - first release.  20.03.2008
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

entity tx_Mem_Reader is
    port (

      -- DDR Read Interface
      DDR_rdc_sof        : OUT   std_logic;
      DDR_rdc_eof        : OUT   std_logic;
      DDR_rdc_v          : OUT   std_logic;
      DDR_rdc_FA         : OUT   std_logic;
      DDR_rdc_Shift      : OUT   std_logic;
      DDR_rdc_din        : OUT   std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DDR_rdc_full       : IN    std_logic;

      -- DDR payload FIFO Read Port
      DDR_FIFO_RdEn      : OUT   std_logic;
      DDR_FIFO_Empty     : IN    std_logic;
      DDR_FIFO_RdQout    : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);


      -- Event Buffer read port
      eb_FIFO_re         : OUT   std_logic; 
      eb_FIFO_empty      : IN    std_logic; 
      eb_FIFO_qout       : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Register Read interface
      Regs_RdAddr        : OUT   std_logic_vector(C_EP_AWIDTH-1 downto 0);
      Regs_RdQout        : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Read Command interface
      RdNumber           : IN    std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1 downto 0);
      RdNumber_eq_One    : IN    std_logic;
      RdNumber_eq_Two    : IN    std_logic;
      StartAddr          : IN    std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      Shift_1st_QWord    : IN    std_logic;
      FixedAddr          : IN    std_logic;
      is_CplD            : IN    std_logic;
      BAR_value          : IN    std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);
      RdCmd_Req          : IN    std_logic;
      RdCmd_Ack          : OUT   std_logic;

      -- Output port of the memory buffer
      mbuf_Din           : OUT   std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
      mbuf_WE            : OUT   std_logic;
      mbuf_Full          : IN    std_logic;
      mbuf_aFull         : IN    std_logic;
      mbuf_UserFull      : IN    std_logic;   -- Test pin, intended for DDR flow interrupted

      -- Common ports
      Tx_TimeOut         : OUT   std_logic;
      Tx_eb_TimeOut      : OUT   std_logic;
      mReader_Rst_n      : IN    std_logic;
      trn_clk            : IN    std_logic
    );

end tx_Mem_Reader;


architecture Behavioral of tx_Mem_Reader is


  type mReaderStates is           ( St_mR_Idle          -- Memory reader Idle

                                  , St_mR_CmdLatch      -- Capture the read command
                                  , St_mR_Transfer      -- Acknowlege the command request

                                  , St_mR_DDR_A         -- DDR access state A
--                                  , St_mR_DDR_B         -- DDR access state B
                                  , St_mR_DDR_C         -- DDR access state C

                                  , St_mR_Last          -- Last word is reached
                                  );

  -- State variables
  signal   TxMReader_State        : mReaderStates;


  -- DDR Read Interface
  signal   DDR_rdc_sof_i          : std_logic;
  signal   DDR_rdc_eof_i          : std_logic;
  signal   DDR_rdc_v_i            : std_logic;
  signal   DDR_rdc_Shift_i        : std_logic;
  signal   DDR_rdc_din_i          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   DDR_rdc_full_i         : std_logic;


  -- Register read address
  signal   Regs_RdAddr_i          : std_logic_vector(C_EP_AWIDTH-1   downto 0);
  signal   Regs_RdEn              : std_logic;
  signal   Regs_Hit               : std_logic;
  signal   Regs_Write_mbuf_r1     : std_logic;
  signal   Regs_Write_mbuf_r2     : std_logic;
  signal   Regs_Write_mbuf_r3     : std_logic;

  -- DDR FIFO read enable
  signal   DDR_FIFO_RdEn_i        : std_logic;
  signal   DDR_FIFO_RdEn_Mask     : std_logic;
  signal   DDR_FIFO_Hit           : std_logic;
  signal   DDR_FIFO_Write_mbuf_r1 : std_logic;
  signal   DDR_FIFO_Write_mbuf_r2 : std_logic;
  signal   DDR_FIFO_Write_mbuf_r3 : std_logic;

  -- Event Buffer
  signal   eb_FIFO_Hit            : std_logic;
  signal   eb_FIFO_Write_mbuf     : std_logic;
  signal   eb_FIFO_Write_mbuf_r1  : std_logic;
  signal   eb_FIFO_Write_mbuf_r2  : std_logic;
  signal   eb_FIFO_re_i           : std_logic;
  signal   eb_FIFO_RdEn_Mask_rise : std_logic;
  signal   eb_FIFO_RdEn_Mask_rise_r1 : std_logic;
  signal   eb_FIFO_RdEn_Mask_rise_r2 : std_logic;
  signal   eb_FIFO_RdEn_Mask_rise_r3 : std_logic;
  signal   eb_FIFO_RdEn_Mask      : std_logic;
  signal   eb_FIFO_RdEn_Mask_r1   : std_logic;
  signal   eb_FIFO_RdEn_Mask_r2   : std_logic;
  signal   ebFIFO_Rd_1DW          : std_logic;
  signal   ebFIFO_Rd_1DW_r1       : std_logic;
  signal   eb_FIFO_qout_r1        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   eb_FIFO_qout_shift     : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   eb_FIFO_qout_swapped   : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Memory data outputs
  signal   eb_FIFO_Dout_wire      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   DDR_Dout_wire          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   Regs_RdQout_wire       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal   mbuf_Din_wire_OR       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Output port of the memory buffer
  signal   mbuf_Din_i             : std_logic_vector(C_DBUS_WIDTH*9/8-1 downto 0);
  signal   mbuf_WE_i              : std_logic;
  signal   mbuf_Full_i            : std_logic;
  signal   mbuf_aFull_i           : std_logic;
  signal   mbuf_UserFull_i        : std_logic;
  signal   mbuf_aFull_r1          : std_logic;


  -- Read command request and acknowledge
  signal   RdCmd_Req_i            : std_logic;
  signal   RdCmd_Ack_i            : std_logic;

  signal   Shift_1st_QWord_k      : std_logic;
  signal   is_CplD_k              : std_logic;
  signal   may_be_MWr_k           : std_logic;
  signal   TRem_n_last_QWord      : std_logic;

  signal   regs_Rd_Counter        : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1   downto 0);
  signal   regs_Rd_Cntr_eq_One    : std_logic;
  signal   regs_Rd_Cntr_eq_Two    : std_logic;
  signal   DDR_Rd_Counter         : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1   downto 0);
  signal   DDR_Rd_Cntr_eq_One     : std_logic;

  signal   ebFIFO_Rd_Counter      : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG-1   downto 0);
  signal   ebFIFO_Rd_Cntr_eq_Two  : std_logic;

  signal   Address_var            : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal   Address_step           : std_logic_vector(4-1   downto 0);
  signal   TxTLP_eof_n            : std_logic;

  signal   TxTLP_eof_n_r1         : std_logic;
--  signal   TxTLP_eof_n_r2         : std_logic;

  signal   TimeOut_Counter        : std_logic_vector(C_DBUS_WIDTH-1   downto 0);
  signal   TimeOut_Indic_TX       : std_logic;
  signal   TimeOut_Indic_eb_CplD  : std_logic;
  signal   TimeOut_Indic_eb_MWr   : std_logic;
  signal   TO_Cnt_Rst             : std_logic;
  signal   Tx_TimeOut_i           : std_logic;
  signal   Tx_eb_TimeOut_i        : std_logic;


begin

   -- read command REQ + ACK
   RdCmd_Req_i           <= RdCmd_Req;
   RdCmd_Ack             <= RdCmd_Ack_i;

   -- Time out signal out
   Tx_TimeOut            <= Tx_TimeOut_i;
   Tx_eb_TimeOut         <= Tx_eb_TimeOut_i;

------------------------------------------------------------
---             Memory read control
------------------------------------------------------------

   -- Event Buffer read
   eb_FIFO_re            <= eb_FIFO_re_i   ;

   -- DDR FIFO Read
   DDR_rdc_sof           <= DDR_rdc_sof_i  ;
   DDR_rdc_eof           <= DDR_rdc_eof_i  ;
   DDR_rdc_v             <= DDR_rdc_v_i    ;
   DDR_rdc_FA            <= '0'            ;  -- DDR_rdc_FA_i   ;
   DDR_rdc_Shift         <= DDR_rdc_Shift_i;
   DDR_rdc_din           <= DDR_rdc_din_i  ;
   DDR_rdc_full_i        <= DDR_rdc_full   ;

   DDR_FIFO_RdEn         <= DDR_FIFO_RdEn_i;


   -- Register address for read
   Regs_RdAddr           <= Regs_RdAddr_i;

   -- Memory buffer write port
   mbuf_Din              <= mbuf_Din_i;
   mbuf_WE               <= mbuf_WE_i;
   mbuf_Full_i           <= mbuf_Full;
   mbuf_aFull_i          <= mbuf_aFull;
   mbuf_UserFull_i       <= mbuf_UserFull;


   -- 
   Regs_RdAddr_i         <=  Address_var(C_EP_AWIDTH-1   downto 0);

-----------------------------------------------------
-- Synchronous Delay: mbuf_aFull
-- 
   Synchron_Delay_mbuf_aFull:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
         mbuf_aFull_r1      <= mbuf_aFull_i or mbuf_Full_i
                            or mbuf_UserFull_i;
      end if;
   end process;


-- ---------------------------------------------------
-- State Machine: Tx Memory read control
--
   mR_FSM_Control:
   process ( trn_clk, mReader_Rst_n)
   begin
      if mReader_Rst_n = '0' then
         DDR_rdc_sof_i        <= '0';
         DDR_rdc_eof_i        <= '0';
         DDR_rdc_v_i          <= '0';
         DDR_rdc_Shift_i      <= '0';
         DDR_rdc_din_i        <= (OTHERS=>'0');

         eb_FIFO_Hit          <= '0';
         eb_FIFO_re_i         <= '0';
         eb_FIFO_RdEn_Mask    <= '0';

         DDR_FIFO_Hit         <= '0';
         DDR_FIFO_RdEn_i      <= '0';
         DDR_FIFO_RdEn_Mask   <= '0';
         Regs_Hit             <= '0';
         Regs_RdEn            <= '0';
         regs_Rd_Counter      <= (Others=>'0');
         DDR_Rd_Counter       <= (Others=>'0');
         DDR_Rd_Cntr_eq_One   <= '0';

         ebFIFO_Rd_Counter    <= (Others=>'0');
         ebFIFO_Rd_Cntr_eq_Two<= '0';

         regs_Rd_Cntr_eq_One  <= '0';
         regs_Rd_Cntr_eq_Two  <= '0';

         Shift_1st_QWord_k    <= '0';
         is_CplD_k            <= '0';
         may_be_MWr_k         <= '0';
         TRem_n_last_QWord    <= '0';

         Address_var          <= (Others=>'1');
         TxTLP_eof_n          <= '1';

         TO_Cnt_Rst           <= '0';

         RdCmd_Ack_i          <= '0';
         TxMReader_State      <= St_mR_Idle;

      elsif trn_clk'event and trn_clk = '1' then

         case TxMReader_State is

            when St_mR_Idle    =>
              if RdCmd_Req_i='0' then
                TxMReader_State      <= St_mR_Idle;
                eb_FIFO_Hit          <= '0';
                Regs_Hit             <= '0';
                Regs_RdEn            <= '0';
                TxTLP_eof_n          <= '1';
                Address_var          <= (Others=>'1');
                RdCmd_Ack_i          <= '0';
                is_CplD_k            <= '0';
                may_be_MWr_k         <= '0';
              else
                RdCmd_Ack_i          <= '1';
                Shift_1st_QWord_k    <= Shift_1st_QWord;
                TRem_n_last_QWord    <= Shift_1st_QWord xor RdNumber(0);
                is_CplD_k            <= is_CplD;
                may_be_MWr_k         <= not is_CplD;
                TxTLP_eof_n          <= '1';
                if BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0) 
                   = CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER-1) 
                   then
                   eb_FIFO_Hit      <= '0';
                   DDR_FIFO_Hit     <= '1';
                   Regs_Hit         <= '0';
                   Regs_RdEn        <= '0';
                   Address_var      <= Address_var;
                   TxMReader_State  <= St_mR_DDR_A;
                elsif BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0) 
                      = CONV_STD_LOGIC_VECTOR(CINT_REGS_SPACE_BAR, C_ENCODE_BAR_NUMBER-1) 
                   then
                   eb_FIFO_Hit      <= '0';
                   DDR_FIFO_Hit     <= '0';
                   Regs_Hit         <= '1';
                   Regs_RdEn        <= '1';
                   if Shift_1st_QWord='1' then
                     Address_var(C_EP_AWIDTH-1 downto 0)  <= StartAddr(C_EP_AWIDTH-1 downto 0) - "100";
                   else
                     Address_var(C_EP_AWIDTH-1 downto 0)  <= StartAddr(C_EP_AWIDTH-1 downto 0);
                   end if;
                   TxMReader_State  <= St_mR_CmdLatch;
                elsif BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0) 
                      = CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER-1) 
                   then
                   eb_FIFO_Hit      <= '1';
                   DDR_FIFO_Hit     <= '0';
                   Regs_Hit         <= '0';
                   Regs_RdEn        <= '0';
                   Address_var      <= Address_var;
                   TxMReader_State  <= St_mR_DDR_C;
                else
                   eb_FIFO_Hit      <= '0';
                   DDR_FIFO_Hit     <= '0';
                   Regs_Hit         <= '0';
                   Regs_RdEn        <= '0';
                   Address_var      <= Address_var;
                   TxMReader_State  <= St_mR_CmdLatch;
                end if;

              end if;


            when St_mR_DDR_A    =>
               DDR_rdc_sof_i        <= '1';
               DDR_rdc_eof_i        <= '0';
               DDR_rdc_v_i          <= '1';
               DDR_rdc_Shift_i      <= Shift_1st_QWord_k;
               DDR_rdc_din_i        <= C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_TLP_FLD_WIDTH_OF_LENG+2+32) 
                                     & RdNumber & "00" 
                                     & StartAddr(C_DBUS_WIDTH-1-32 downto 0);
               Regs_RdEn            <= '0';
               DDR_FIFO_RdEn_i      <= '0';
               TxTLP_eof_n          <= '1';
               RdCmd_Ack_i          <= '1';
               TxMReader_State      <= St_mR_DDR_C;  -- St_mR_DDR_B;


            when St_mR_DDR_C    =>
               DDR_rdc_sof_i        <= '0';
               DDR_rdc_eof_i        <= '0';
               DDR_rdc_v_i          <= '0';
               DDR_rdc_din_i        <= DDR_rdc_din_i;
               RdCmd_Ack_i          <= '0';
               TxTLP_eof_n          <= '1';
--               if DDR_FIFO_Hit='1' and DDR_FIFO_Empty='1' then
               if DDR_FIFO_Hit='1' and DDR_FIFO_Empty='1' and Tx_TimeOut_i='0' then
                  TxMReader_State      <= St_mR_DDR_C;
--               elsif eb_FIFO_Hit='1' and eb_FIFO_empty='1' then
               elsif eb_FIFO_Hit='1' and eb_FIFO_empty='1' and Tx_eb_TimeOut_i='0' then
                  TxMReader_State      <= St_mR_DDR_C;
               else
                  TxMReader_State      <= St_mR_CmdLatch;
               end if;


            when St_mR_CmdLatch    =>
                  RdCmd_Ack_i          <= '0';
                  if regs_Rd_Cntr_eq_One = '1' then
                     Regs_RdEn            <= '0';
                     Address_var          <= Address_var;
                     TxTLP_eof_n          <= '0';
                     TxMReader_State      <= St_mR_Last;
                  elsif regs_Rd_Cntr_eq_Two = '1' then
                     if Shift_1st_QWord_k='1' then
                       TxMReader_State      <= St_mR_Transfer;
                       Regs_RdEn            <= Regs_RdEn;  -- '1';
                       TxTLP_eof_n          <= '1';
                       Address_var(C_EP_AWIDTH-1 downto 0)  <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
                     else
                       TxMReader_State      <= St_mR_Last;
                       Regs_RdEn            <= '0';
                       TxTLP_eof_n          <= '0';
                       Address_var(C_EP_AWIDTH-1 downto 0)  <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
                     end if;
                  else
                     Regs_RdEn            <= Regs_RdEn;
                     Address_var(C_EP_AWIDTH-1 downto 0)  <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
                     TxTLP_eof_n          <= '1';
                     TxMReader_State      <= St_mR_Transfer;
                  end if;


            when St_mR_Transfer    =>
                  RdCmd_Ack_i          <= '0';
                  if DDR_FIFO_Hit='1' and DDR_FIFO_RdEn_Mask='1' then
                     Address_var          <= Address_var;
                     Regs_RdEn            <= '0';
                     TxTLP_eof_n          <= '0';
                     TxMReader_State      <= St_mR_Last;
                  elsif eb_FIFO_Hit='1' and eb_FIFO_RdEn_Mask='1' then
                     Address_var          <= Address_var;
                     Regs_RdEn            <= '0';
                     TxTLP_eof_n          <= '0';
                     TxMReader_State      <= St_mR_Last;
                  elsif eb_FIFO_Hit='0' and regs_Rd_Cntr_eq_One = '1' then
                     Address_var          <= Address_var;
                     Regs_RdEn            <= '0';
                     TxTLP_eof_n          <= '0';
                     TxMReader_State      <= St_mR_Last;
                  elsif eb_FIFO_Hit='0' and regs_Rd_Cntr_eq_Two = '1' then
                     Address_var          <= Address_var;
                     Regs_RdEn            <= '0';
                     TxTLP_eof_n          <= '0';
                     TxMReader_State      <= St_mR_Last;
                  elsif mbuf_aFull_r1 = '1' then
                     Address_var          <= Address_var;
                     Regs_RdEn            <= '0';
                     TxTLP_eof_n          <= TxTLP_eof_n;
                     TxMReader_State      <= St_mR_Transfer;
                  else
                     Address_var(C_EP_AWIDTH-1 downto 0)    <= Address_var(C_EP_AWIDTH-1 downto 0) + "1000";
                     Regs_RdEn            <= Regs_Hit;
                     TxTLP_eof_n          <= TxTLP_eof_n;
                     TxMReader_State      <= St_mR_Transfer;
                  end if;


            when St_mR_Last    =>
               Regs_RdEn            <= '0';
               DDR_FIFO_RdEn_i      <= '0';
               TxTLP_eof_n          <= (not DDR_FIFO_Hit) and (not eb_FIFO_Hit);
               RdCmd_Ack_i          <= '0';
               TxMReader_State      <= St_mR_Idle;


            when Others    =>
               Address_var          <= Address_var;
               eb_FIFO_Hit          <= '0';
               Regs_RdEn            <= '0';
               DDR_FIFO_RdEn_i      <= '0';
               TxTLP_eof_n          <= '1';
               RdCmd_Ack_i          <= '0';
               TxMReader_State      <= St_mR_Idle;

         end case;


         case TxMReader_State is
            when St_mR_Idle    =>
              TO_Cnt_Rst   <= '1';

            when Others    =>
              TO_Cnt_Rst   <= '0';

         end case;


         case TxMReader_State is

            when St_mR_Idle    =>
              DDR_FIFO_RdEn_i  <= '0';
              DDR_FIFO_RdEn_Mask   <= '0';

            when Others    =>
              if DDR_Rd_Cntr_eq_One = '1' 
                 and (DDR_FIFO_Empty='0' or Tx_TimeOut_i='1')
                 and DDR_FIFO_RdEn_i='1'
                 then
                 DDR_FIFO_RdEn_Mask   <= '1';
                 DDR_FIFO_RdEn_i      <= '0';
              else
                 DDR_FIFO_RdEn_Mask   <= DDR_FIFO_RdEn_Mask;
                 DDR_FIFO_RdEn_i      <=  DDR_FIFO_Hit 
                                      and not mbuf_aFull_r1 
                                      and not DDR_FIFO_RdEn_Mask;
              end if;
         end case;


         case TxMReader_State is

            when St_mR_Idle    =>
              eb_FIFO_re_i        <= '0';
              eb_FIFO_RdEn_Mask   <= '0';

            when Others    =>
              if ebFIFO_Rd_Cntr_eq_Two = '1' 
                 and (eb_FIFO_empty='0' or Tx_eb_TimeOut_i='1')
                 and eb_FIFO_re_i='1'
                 then
                 eb_FIFO_RdEn_Mask   <= '1';
                 eb_FIFO_re_i        <= '0';
              else
                 eb_FIFO_RdEn_Mask   <= eb_FIFO_RdEn_Mask;
                 eb_FIFO_re_i        <= eb_FIFO_Hit 
                                      and not mbuf_aFull_r1 
                                      and not eb_FIFO_RdEn_Mask;
              end if;
         end case;


         case TxMReader_State is

            when St_mR_Idle    =>
              if RdCmd_Req_i='1' and 
                 BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0) 
                 /= CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER-1)
                 then
                 regs_Rd_Counter       <= RdNumber;
                 regs_Rd_Cntr_eq_One   <= RdNumber_eq_One;
                 regs_Rd_Cntr_eq_Two   <= RdNumber_eq_Two;
              else
                 regs_Rd_Counter       <= (Others=>'0');
                 regs_Rd_Cntr_eq_One   <= '0';
                 regs_Rd_Cntr_eq_Two   <= '0';
              end if;

            when St_mR_CmdLatch    =>
              if DDR_FIFO_Hit='0' then
                 if Shift_1st_QWord_k='1' then
                   regs_Rd_Counter          <= regs_Rd_Counter - '1';
                   if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG) then
                      regs_Rd_Cntr_eq_One   <= '1';
                   else
                      regs_Rd_Cntr_eq_One   <= '0';
                   end if;
                   if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(3, C_TLP_FLD_WIDTH_OF_LENG) then
                      regs_Rd_Cntr_eq_Two   <= '1';
                   else
                      regs_Rd_Cntr_eq_Two   <= '0';
                   end if;
                 else
                   regs_Rd_Counter          <= regs_Rd_Counter - "10";  -- '1';
                   if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(3, C_TLP_FLD_WIDTH_OF_LENG) then
                      regs_Rd_Cntr_eq_One   <= '1';
                   else
                      regs_Rd_Cntr_eq_One   <= '0';
                   end if;
                   if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                      regs_Rd_Cntr_eq_Two   <= '1';
                   else
                      regs_Rd_Cntr_eq_Two   <= '0';
                   end if;
                 end if;
              else
                 regs_Rd_Counter       <= regs_Rd_Counter;
                 regs_Rd_Cntr_eq_One   <= regs_Rd_Cntr_eq_One;
                 regs_Rd_Cntr_eq_Two   <= regs_Rd_Cntr_eq_Two;
              end if;

            when St_mR_Transfer    =>
              if DDR_FIFO_Hit='0' 
                 and mbuf_aFull_r1 = '0' 
                 then
                 regs_Rd_Counter           <= regs_Rd_Counter - "10";  -- '1';
                 if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(1, C_TLP_FLD_WIDTH_OF_LENG) then
                    regs_Rd_Cntr_eq_One   <= '1';
                 elsif regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(2, C_TLP_FLD_WIDTH_OF_LENG) then
                    regs_Rd_Cntr_eq_One   <= '1';
                 elsif regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(3, C_TLP_FLD_WIDTH_OF_LENG) then
                    regs_Rd_Cntr_eq_One   <= '1';
                 else
                    regs_Rd_Cntr_eq_One   <= '0';
                 end if;
                 if regs_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                    regs_Rd_Cntr_eq_Two   <= '1';
                 else
                    regs_Rd_Cntr_eq_Two   <= '0';
                 end if;
              else
                 regs_Rd_Counter       <= regs_Rd_Counter;
                 regs_Rd_Cntr_eq_One   <= regs_Rd_Cntr_eq_One;
                 regs_Rd_Cntr_eq_Two   <= regs_Rd_Cntr_eq_Two;
              end if;

            when Others    =>
              regs_Rd_Counter       <= regs_Rd_Counter;
              regs_Rd_Cntr_eq_One   <= regs_Rd_Cntr_eq_One;
              regs_Rd_Cntr_eq_Two   <= regs_Rd_Cntr_eq_Two;

         end case;


         case TxMReader_State is
            when St_mR_Idle    =>
              if RdCmd_Req_i='1' and 
                 BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0) 
                 = CONV_STD_LOGIC_VECTOR(CINT_DDR_SPACE_BAR, C_ENCODE_BAR_NUMBER-1)
                 then
                 if RdNumber(0)='1' then
                   DDR_Rd_Counter       <= RdNumber + '1';
                   DDR_Rd_Cntr_eq_One   <= RdNumber_eq_One;
                 elsif Shift_1st_QWord='1' then
                   DDR_Rd_Counter       <= RdNumber + "10";
                   DDR_Rd_Cntr_eq_One   <= RdNumber_eq_One;
                 else
                   DDR_Rd_Counter       <= RdNumber;
                   DDR_Rd_Cntr_eq_One   <= RdNumber_eq_One or RdNumber_eq_Two;
                 end if;
              else
                 DDR_Rd_Counter       <= (Others=>'0');
                 DDR_Rd_Cntr_eq_One   <= '0';
              end if;

            when Others    =>
              if ((DDR_FIFO_Empty='0' or Tx_TimeOut_i='1') and DDR_FIFO_RdEn_i='1')
                 then
                 DDR_Rd_Counter       <= DDR_Rd_Counter - "10";  -- '1';
                 if DDR_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                    DDR_Rd_Cntr_eq_One   <= '1';
                 else
                    DDR_Rd_Cntr_eq_One   <= '0';
                 end if;
              else
                 DDR_Rd_Counter       <= DDR_Rd_Counter;
                 DDR_Rd_Cntr_eq_One   <= DDR_Rd_Cntr_eq_One;
              end if;

         end case;


         case TxMReader_State is
            when St_mR_Idle    =>
              if RdCmd_Req_i='1' and 
                 BAR_value(C_ENCODE_BAR_NUMBER-2 downto 0) 
                 = CONV_STD_LOGIC_VECTOR(CINT_FIFO_SPACE_BAR, C_ENCODE_BAR_NUMBER-1)
                 then
                 if RdNumber_eq_One='1' then
                   ebFIFO_Rd_Counter       <= RdNumber + '1';
                   ebFIFO_Rd_Cntr_eq_Two   <= '1';
                   ebFIFO_Rd_1DW           <= '1';
                 else
                   ebFIFO_Rd_Counter       <= RdNumber;
                   ebFIFO_Rd_Cntr_eq_Two   <= RdNumber_eq_Two;  -- or RdNumber_eq_One;
                   ebFIFO_Rd_1DW           <= '0';
                 end if;
              else
                 ebFIFO_Rd_Counter       <= (Others=>'0');
                 ebFIFO_Rd_Cntr_eq_Two   <= '0';
                 ebFIFO_Rd_1DW           <= '0';
              end if;

            when Others    =>
              ebFIFO_Rd_1DW           <= ebFIFO_Rd_1DW;
              if (eb_FIFO_empty='0' or Tx_eb_TimeOut_i='1') and eb_FIFO_re_i='1'
                 then
                 ebFIFO_Rd_Counter       <= ebFIFO_Rd_Counter - "10";  -- '1';
                 if ebFIFO_Rd_Counter = CONV_STD_LOGIC_VECTOR(4, C_TLP_FLD_WIDTH_OF_LENG) then
                    ebFIFO_Rd_Cntr_eq_Two   <= '1';
                 else
                    ebFIFO_Rd_Cntr_eq_Two   <= '0';
                 end if;
              else
                 ebFIFO_Rd_Counter       <= ebFIFO_Rd_Counter;
                 ebFIFO_Rd_Cntr_eq_Two   <= ebFIFO_Rd_Cntr_eq_Two;
              end if;

         end case;

      end if;
   end process;


-----------------------------------------------------
-- Synchronous Delay: mbuf_writes
-- 
   Synchron_Delay_mbuf_writes:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
         Regs_Write_mbuf_r1      <= Regs_RdEn;
         Regs_Write_mbuf_r2      <= Regs_Write_mbuf_r1;
         Regs_Write_mbuf_r3      <= Regs_Write_mbuf_r2;

         DDR_FIFO_Write_mbuf_r1  <= DDR_FIFO_RdEn_i and (not DDR_FIFO_Empty or Tx_TimeOut_i);
         DDR_FIFO_Write_mbuf_r2  <= DDR_FIFO_Write_mbuf_r1;
         DDR_FIFO_Write_mbuf_r3  <= DDR_FIFO_Write_mbuf_r2;

         eb_FIFO_Write_mbuf      <= eb_FIFO_re_i and (not eb_FIFO_empty or Tx_eb_TimeOut_i);
         eb_FIFO_Write_mbuf_r1   <= eb_FIFO_Write_mbuf;
         eb_FIFO_Write_mbuf_r2   <= eb_FIFO_Write_mbuf_r1;

         eb_FIFO_RdEn_Mask_r1    <= eb_FIFO_RdEn_Mask;
         eb_FIFO_RdEn_Mask_r2    <= eb_FIFO_RdEn_Mask_r1;

      end if;
   end process;


--------------------------------------------------------------------------
--  Wires to be OR'ed to build mbuf_Din
--------------------------------------------------------------------------

   eb_FIFO_Dout_wire     <= eb_FIFO_qout_r1 when (eb_FIFO_Hit='1' and Shift_1st_QWord_k='0')
                            else eb_FIFO_qout_shift when (eb_FIFO_Hit='1' and Shift_1st_QWord_k='1')
                            else (OTHERS=>'0');
   DDR_Dout_wire         <= DDR_FIFO_RdQout when DDR_FIFO_Hit='1'  else (OTHERS=>'0');
   Regs_RdQout_wire      <= Regs_RdQout     when Regs_Hit='1'      else (OTHERS=>'0');

   mbuf_Din_wire_OR      <= eb_FIFO_Dout_wire or DDR_Dout_wire   or Regs_RdQout_wire;

-----------------------------------------------------
-- Synchronous Delay: mbuf_WE
-- 
   Synchron_Delay_mbuf_WE:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
         mbuf_WE_i      <= DDR_FIFO_Write_mbuf_r1
                        or Regs_Write_mbuf_r2
                        or (eb_FIFO_Write_mbuf_r1 or (Shift_1st_QWord_k
                            and eb_FIFO_RdEn_Mask_rise_r1 and not ebFIFO_Rd_1DW_r1))
                        ;
      end if;
   end process;


-----------------------------------------------------
-- Synchronous Delay: TxTLP_eof_n
-- 
   Synchron_Delay_TxTLP_eof_n:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
         TxTLP_eof_n_r1      <= TxTLP_eof_n;
--         TxTLP_eof_n_r2      <= TxTLP_eof_n_r1;
      end if;
   end process;

--   eb_FIFO_qout_swapped  <= eb_FIFO_qout(C_DBUS_WIDTH/2-1 downto 0) & eb_FIFO_qout(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2);
   eb_FIFO_qout_swapped  <= eb_FIFO_qout(C_DBUS_WIDTH/2+7  downto C_DBUS_WIDTH/2)
                          & eb_FIFO_qout(C_DBUS_WIDTH/2+15 downto C_DBUS_WIDTH/2+8)
                          & eb_FIFO_qout(C_DBUS_WIDTH/2+23 downto C_DBUS_WIDTH/2+16)
                          & eb_FIFO_qout(C_DBUS_WIDTH/2+31 downto C_DBUS_WIDTH/2+24)

                          & eb_FIFO_qout(7  downto 0)
                          & eb_FIFO_qout(15 downto 8)
                          & eb_FIFO_qout(23 downto 16)
                          & eb_FIFO_qout(31 downto 24)
                          ;

-----------------------------------------------------
-- Synchronous Delay: eb_FIFO_qout
-- 
   Synchron_Delay_eb_FIFO_qout:
   process ( trn_clk )
   begin
     if trn_clk'event and trn_clk = '1' then
        ebFIFO_Rd_1DW_r1          <= ebFIFO_Rd_1DW;
        eb_FIFO_RdEn_Mask_rise    <= eb_FIFO_RdEn_Mask and not eb_FIFO_RdEn_Mask_r1;
        eb_FIFO_RdEn_Mask_rise_r1 <= eb_FIFO_RdEn_Mask_rise;
        eb_FIFO_RdEn_Mask_rise_r2 <= eb_FIFO_RdEn_Mask_rise_r1;
        eb_FIFO_qout_r1           <= eb_FIFO_qout_swapped;
        eb_FIFO_qout_shift        <= eb_FIFO_qout_r1(C_DBUS_WIDTH/2-1 downto 0) 
                                   & eb_FIFO_qout_swapped(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2);
      end if;
   end process;

-----------------------------------------------------
-- Synchronous Delay: mbuf_Din
-- 
   Synchron_Delay_mbuf_Din:
   process ( trn_clk, mReader_Rst_n)
   begin
      if mReader_Rst_n = '0' then
         mbuf_Din_i           <= (C_DBUS_WIDTH=>'1', Others=>'0');

      elsif trn_clk'event and trn_clk = '1' then
         if Tx_TimeOut_i='1' and DDR_FIFO_Hit='1' then
           mbuf_Din_i(C_DBUS_WIDTH-1 downto 0)     <= (OTHERS=>'1');
         elsif Tx_eb_TimeOut_i='1' and eb_FIFO_Hit='1' and is_CplD_k='1' then
           mbuf_Din_i(C_DBUS_WIDTH-1 downto 0)     <= (OTHERS=>'1');
         elsif Tx_eb_TimeOut_i='1' and eb_FIFO_Hit='1' and may_be_MWr_k='1' then
           mbuf_Din_i(C_DBUS_WIDTH-1 downto 0)     <= (OTHERS=>'1');
         else
           mbuf_Din_i(C_DBUS_WIDTH-1 downto 0)     <= Endian_Invert_64(mbuf_Din_wire_OR);
         end if;

         if DDR_FIFO_Hit='1' then
           mbuf_Din_i(C_DBUS_WIDTH)                <= not DDR_FIFO_RdEn_Mask;
           mbuf_Din_i(70)                          <= TRem_n_last_QWord;
         elsif eb_FIFO_Hit='1' then
           if Shift_1st_QWord_k='1' and ebFIFO_Rd_1DW='0' then
              mbuf_Din_i(C_DBUS_WIDTH)                <= not eb_FIFO_RdEn_Mask_r2;
           else
              mbuf_Din_i(C_DBUS_WIDTH)                <= not eb_FIFO_RdEn_Mask_r1;
           end if;
           mbuf_Din_i(70)                          <= TRem_n_last_QWord;
         else
           mbuf_Din_i(C_DBUS_WIDTH)                <= TxTLP_eof_n_r1;
           mbuf_Din_i(70)                          <= TRem_n_last_QWord;
         end if;
      end if;
   end process;


-----------------------------------------------------
-- Synchronous: Time-out counter
-- 
   Synchron_TimeOut_Counter:
   process ( trn_clk, TO_Cnt_Rst )
   begin
      if TO_Cnt_Rst='1' then
         TimeOut_Counter        <= (OTHERS=>'0');
         TimeOut_Indic_TX       <= '0';
         TimeOut_Indic_eb_CplD  <= '0';
         TimeOut_Indic_eb_MWr   <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         TimeOut_Counter(21 downto 0)   <= TimeOut_Counter(21 downto 0) + '1';

         if TimeOut_Counter(21 downto 10)=X"FFF" then
--         if TimeOut_Counter(4 downto 1)=X"F" then
            TimeOut_Indic_TX       <= '1';
         else
            TimeOut_Indic_TX       <= '0';
         end if;

         if TimeOut_Counter(7 downto 4)=X"F" then
--         if TimeOut_Counter(3 downto 0)=X"F" then
            TimeOut_Indic_eb_CplD  <= '1';
         else
            TimeOut_Indic_eb_CplD  <= '0';
         end if;

         if TimeOut_Counter(10 downto 7)=X"F" then
--         if TimeOut_Counter(3 downto 0)=X"F" then
            TimeOut_Indic_eb_MWr   <= '1';
         else
            TimeOut_Indic_eb_MWr   <= '0';
         end if;

      end if;
   end process;

-----------------------------------------------------
-- Synchronous: Tx_TimeOut
-- 
   SynchOUT_Tx_TimeOut:
   process ( trn_clk, mReader_Rst_n )
   begin
      if mReader_Rst_n='0' then
         Tx_TimeOut_i      <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if TimeOut_Indic_TX='1' then
            Tx_TimeOut_i   <= '1';
         else
            Tx_TimeOut_i   <= Tx_TimeOut_i;
         end if;
      end if;
   end process;

-----------------------------------------------------
-- Synchronous: Tx_eb_TimeOut
-- 
   SynchOUT_Tx_eb_TimeOut:
   process ( trn_clk, mReader_Rst_n )
   begin
      if mReader_Rst_n='0' then
         Tx_eb_TimeOut_i      <= '0';
      elsif trn_clk'event and trn_clk = '1' then
         if TimeOut_Indic_eb_CplD='1' and is_CplD_k='1'
            then
            Tx_eb_TimeOut_i   <= '1';
         elsif TimeOut_Indic_eb_MWr='1' and may_be_MWr_k='1'
            then
            Tx_eb_TimeOut_i   <= '1';
         else
            Tx_eb_TimeOut_i   <= Tx_eb_TimeOut_i;
         end if;
      end if;
   end process;

end architecture Behavioral;
