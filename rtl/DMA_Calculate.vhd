----------------------------------------------------------------------------------
-- Company:  ziti, Uni. HD
-- Engineer:  wgao
-- 
-- Design Name: 
-- Module Name:    DMA_Calculate - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision 1.00 - first release.  09.02.2007
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

entity DMA_Calculate is
    port (
      -- Downstream Registers from MWr Channel
      DMA_PA             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);  -- EP   (local)
      DMA_HA             : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);  -- Host (remote)
      DMA_BDA            : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_Length         : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_Control        : IN  std_logic_vector(C_DBUS_WIDTH-1 downto 0);

      -- Calculation in advance, for better timing
      HA_is_64b          : IN  std_logic;
      BDA_is_64b         : IN  std_logic;

      -- Calculation in advance, for better timing
      Leng_Hi19b_True    : IN  std_logic;
      Leng_Lo7b_True     : IN  std_logic;


      -- Parameters fed to DMA_FSM
      DMA_PA_Loaded      : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_PA_Var         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto  0);
      DMA_HA_Var         : OUT std_logic_vector(C_DBUS_WIDTH-1 downto  0);

      DMA_BDA_fsm        : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      BDA_is_64b_fsm     : OUT std_logic;
      DMA_0_Leng         : OUT std_logic;


      DMA_Snout_Length   : OUT std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto  0);
      DMA_Body_Length    : OUT std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
      DMA_Tail_Length    : OUT std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto  0);

      -- Only for downstream channel
      DMA_PA_Snout       : OUT std_logic_vector(C_DBUS_WIDTH-1 downto 0);
      DMA_BAR_Number     : OUT std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);

      -- Engine control signals
      DMA_Start          : IN  std_logic;
      DMA_Start2         : IN  std_logic;   -- out of consecutive dex

      -- Control signals to FSM
      No_More_Bodies     : OUT std_logic;   -- No more block(s) of Max_Size
      ThereIs_Snout      : OUT std_logic;   -- 1st packet before Body blocks
      ThereIs_Body       : OUT std_logic;   -- Block(s) of Max_Size
      ThereIs_Tail       : OUT std_logic;   -- Last packet with size less than Max_Size
      ThereIs_Dex        : OUT std_logic;   -- Not the last descriptor
      HA64bit            : OUT std_logic;   -- Host Address is 64-bit
      Addr_Inc           : OUT std_logic;   -- Peripheral Address increase token


      -- FSM indicators
      State_Is_LoadParam : IN  std_logic;
      State_Is_Snout     : IN  std_logic;
      State_Is_Body      : IN  std_logic;
--      State_Is_Tail      : IN  std_logic;


      -- Additional
      Param_Max_Cfg      : IN  std_logic_vector(2 downto 0);

      -- Common ports
      dma_clk            : IN  std_logic;
      dma_reset          : IN  std_logic
    );

end entity DMA_Calculate;



architecture Behavioral of DMA_Calculate is

  --  Significant bits from the MaXSiZe parameter
  signal  Max_TLP_Size         :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);

  signal  mxsz_left            :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT);
  signal  mxsz_mid             :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT);
  signal  mxsz_right           :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT);

  --  Signals masked by MaxSize
  signal  DMA_Leng_Left_Msk    :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT);
  signal  DMA_Leng_Mid_Msk     :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT);
  signal  DMA_Leng_Right_Msk   :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT);

  -- Alias
  signal  Lo_Leng_Left_Msk_is_True  :  std_logic;
  signal  Lo_Leng_Mid_Msk_is_True   :  std_logic;
  signal  Lo_Leng_Right_Msk_is_True :  std_logic;

  -- Masked values of HA and Length
  signal  DMA_HA_Msk           :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);
  signal  DMA_Length_Msk       :  std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto 0);


  -- Indicates whether the DMA_PA is already accepted
  signal  PA_is_taken          : std_logic;

  -- Calculation for the PA of the next DMA, if UPA bit = 0
  signal  DMA_PA_next          : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_PA_current       : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- eventual PA parameter for the current DMA transaction
  signal  DMA_PA_Loaded_i      : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  -- Calculation in advance, only for better timing
  signal  Carry_PA_plus_Leng   : std_logic_vector(CBIT_CARRY downto 0);
  signal  Carry_PAx_plus_Leng  : std_logic_vector(CBIT_CARRY downto 0);
  signal  Leng_Hi_plus_PA_Hi   : std_logic_vector(C_DBUS_WIDTH-1 downto CBIT_CARRY);
  signal  Leng_Hi_plus_PAx_Hi  : std_logic_vector(C_DBUS_WIDTH-1 downto CBIT_CARRY);

  -- DMA parameters from the register module
  signal  DMA_PA_i             : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_HA_i             : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_BDA_i            : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_Length_i         : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  DMA_Control_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);

  --  delay
  signal  State_Is_Snout_r1    : std_logic;
  signal  State_Is_Body_r1     : std_logic;

  -- from control word
  signal  Dex_is_Last          : std_logic;
  signal  Engine_Ends          : std_logic;

  -- Major FSM control signals
  signal  ThereIs_Snout_i      : std_logic;
  signal  ThereIs_Body_i       : std_logic;
  signal  ThereIs_Tail_i       : std_logic;
  signal  Snout_Only           : std_logic;

  signal  ThereIs_Dex_i        : std_logic;
  signal  No_More_Bodies_i     : std_logic;

  -- Address/Length combination
  signal  ALc                  : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto  0);
  -- Compressed ALc
      --  ALc_B bit means the ALc has carry in, making an extra Body block.
  signal  ALc_B                : std_logic;
  signal  ALc_B_wire           : std_logic;
      --  ALc_T bit means the ALc has trailer, making a final Tail block.
  signal  ALc_T                : std_logic;
  signal  ALc_T_wire           : std_logic;

  -- Compressed Length
      --  Leng_Two bit means Length >= 2 Max_Size.
  signal  Leng_Two             : std_logic;
      --  Leng_One bit means Length >= 1 Max_Size.
  signal  Leng_One             : std_logic;
      --  Leng_nint bit means Length is not integral of Max_Sizes.
  signal  Leng_nint            : std_logic;


  signal  Length_analysis      : std_logic_vector(2 downto  0);
  signal  Snout_Body_Tail      : std_logic_vector(2 downto  0);

  -- Byte counter
  signal  DMA_Byte_Counter     : std_logic_vector(C_DBUS_WIDTH-1 downto  0);  -- !!! Elastic
  signal  Length_minus         : std_logic_vector(C_DBUS_WIDTH-1 downto  0);
  signal  DMA_BC_Carry         : std_logic_vector(CBIT_CARRY downto  0);

  -- Remote & Local Address variable
  signal  DMA_HA_Var_i         : std_logic_vector(C_DBUS_WIDTH-1 downto  0);
  signal  DMA_HA_Carry32       : std_logic_vector(C_DBUS_WIDTH/2 downto  0);
  signal  DMA_PA_Var_i         : std_logic_vector(C_DBUS_WIDTH-1 downto  0);

  -- BDA parameter is buffered for FSM module
  signal  DMA_BDA_fsm_i        : std_logic_vector(C_DBUS_WIDTH-1 downto 0);
  signal  BDA_is_64b_fsm_i     : std_logic;

  -- Token bits out of Control word
  signal  HA64bit_i            : std_logic;
  signal  Addr_Inc_i           : std_logic;
  signal  use_PA               : std_logic;

  signal  DMA_Start_r1         : std_logic;
  signal  DMA_Start2_r1        : std_logic;
  signal  DMA_Leng_sub         : std_logic_vector(4-1 downto  0);
  signal  DMA_0_Leng_i         : std_logic;

  --      for better timing
  signal  HA_gap               : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto  0);

  --
  signal  DMA_Snout_Length_i   : std_logic_vector(C_MAXSIZE_FLD_BIT_TOP downto  0);
  signal  DMA_Tail_Length_i    : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto  0);
  --      for better timing
  signal  raw_Tail_Length      : std_logic_vector(C_TLP_FLD_WIDTH_OF_LENG+1 downto  0);

  signal  DMA_PA_Snout_Carry   : std_logic_vector(CBIT_CARRY downto  0);
  signal  DMA_PA_Body_Carry    : std_logic_vector(CBIT_CARRY downto  0);

  signal  DMA_BAR_Number_i     : std_logic_vector(C_ENCODE_BAR_NUMBER-1 downto 0);

begin

   --  Partition indicators
   No_More_Bodies     <= No_More_Bodies_i   ;
   ThereIs_Snout      <= ThereIs_Snout_i    ;
   ThereIs_Body       <= ThereIs_Body_i     ;
   ThereIs_Tail       <= ThereIs_Tail_i     ;
   ThereIs_Dex        <= ThereIs_Dex_i      ;
	HA64bit            <= HA64bit_i          ;
   Addr_Inc           <= Addr_Inc_i         ;
   DMA_0_Leng         <= DMA_0_Leng_i       ;

   --
   DMA_PA_Loaded      <= DMA_PA_Loaded_i ;
   DMA_PA_Var         <= DMA_PA_Var_i    ;
   DMA_HA_Var         <= DMA_HA_Var_i    ;
	DMA_BDA_fsm        <= DMA_BDA_fsm_i   ;
   BDA_is_64b_fsm     <= BDA_is_64b_fsm_i;

   -- Only for downstream channel
   DMA_PA_Snout       <= DMA_PA_current(C_DBUS_WIDTH-1 downto 0);
   DMA_BAR_Number     <= DMA_BAR_Number_i;

   -- different lengths
   DMA_Snout_Length   <= DMA_Snout_Length_i ;
   DMA_Body_Length    <= Max_TLP_Size       ;
   DMA_Tail_Length    <= DMA_Tail_Length_i  ;


   --  Register stubs
   DMA_PA_i           <=  DMA_PA;
   DMA_HA_i           <=  DMA_HA;
   DMA_BDA_i          <=  DMA_BDA;
   DMA_Length_i       <=  DMA_Length;
   DMA_Control_i      <=  DMA_Control;



-- ---------------------------------------------------------------
-- Parameters should be captured by the start/start2 and be kept 
--     in case Pause command comes.
--
   Syn_Param_Capture:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
			Addr_Inc_i         <= '0';
         use_PA             <= '0';
         Dex_is_Last        <= '0';
         Engine_Ends        <= '1';
         DMA_BAR_Number_i   <= (OTHERS=>'0');

			DMA_BDA_fsm_i      <= (OTHERS=>'0');
         BDA_is_64b_fsm_i   <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         if DMA_Start ='1' or DMA_Start2 ='1' then
           Addr_Inc_i         <= DMA_Control_i(CINT_BIT_DMA_CTRL_AINC);
           use_PA             <= DMA_Control_i(CINT_BIT_DMA_CTRL_UPA);
           Dex_is_Last        <= DMA_Control_i(CINT_BIT_DMA_CTRL_LAST);
           Engine_Ends        <= DMA_Control_i(CINT_BIT_DMA_CTRL_END);
           DMA_BAR_Number_i   <= DMA_Control_i(CINT_BIT_DMA_CTRL_BAR_TOP downto CINT_BIT_DMA_CTRL_BAR_BOT);

           DMA_BDA_fsm_i      <= DMA_BDA_i    ;
           BDA_is_64b_fsm_i   <= BDA_is_64b   ; 
         else
			  Addr_Inc_i         <= Addr_Inc_i   ;
           use_PA             <= use_PA       ;
           Dex_is_Last        <= Dex_is_Last  ;
           Engine_Ends        <= Engine_Ends  ;
           DMA_BAR_Number_i   <= DMA_BAR_Number_i;

			  DMA_BDA_fsm_i      <= DMA_BDA_fsm_i    ;
           BDA_is_64b_fsm_i   <= BDA_is_64b_fsm_i ;
         end if;

      end if;
   end process;

-- -----------------------------------------------------------------
--   DMA has zero length. 
--     for sake of timing convergence, divided calculating is used.
--
   Syn_DMA_0_Leng:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
			DMA_Start_r1       <= '0';
			DMA_Start2_r1      <= '0';
			DMA_Leng_sub       <= (OTHERS=>'0');
			DMA_0_Leng_i       <= '1';

      elsif dma_clk'event and dma_clk = '1' then

         DMA_Start_r1       <= DMA_Start;
         DMA_Start2_r1      <= DMA_Start2;
         if DMA_Length(C_DBUS_WIDTH/2-1 downto C_DBUS_WIDTH/2-8)
            =C_ALL_ZEROS(C_DBUS_WIDTH/2-1 downto C_DBUS_WIDTH/2-8) then
            DMA_Leng_sub(3)    <= '0';
         else
            DMA_Leng_sub(3)    <= '1';
         end if;
         if DMA_Length(C_DBUS_WIDTH/2-9 downto C_DBUS_WIDTH/2-16)
            =C_ALL_ZEROS(C_DBUS_WIDTH/2-9 downto C_DBUS_WIDTH/2-16) then
            DMA_Leng_sub(2)    <= '0';
         else
            DMA_Leng_sub(2)    <= '1';
         end if;
         if DMA_Length(C_DBUS_WIDTH/2-17 downto C_DBUS_WIDTH/2-24)
            =C_ALL_ZEROS(C_DBUS_WIDTH/2-17 downto C_DBUS_WIDTH/2-24) then
            DMA_Leng_sub(1)    <= '0';
         else
            DMA_Leng_sub(1)    <= '1';
         end if;
         if DMA_Length(C_DBUS_WIDTH/2-25 downto 2)
            =C_ALL_ZEROS(C_DBUS_WIDTH/2-25 downto 2) then
            DMA_Leng_sub(0)    <= '0';
         else
            DMA_Leng_sub(0)    <= '1';
         end if;

         if DMA_Start_r1 ='1' or DMA_Start2_r1 ='1' then
           if DMA_Leng_sub=C_ALL_ZEROS(4-1 downto 0) then
              DMA_0_Leng_i       <= '1';
           else
              DMA_0_Leng_i       <= '0';
           end if;
         else
           DMA_0_Leng_i       <= DMA_0_Leng_i;
         end if;

      end if;
   end process;


--   Addr_Inc_i         <= DMA_Control_i(CINT_BIT_DMA_CTRL_AINC);
--   use_PA             <= DMA_Control_i(CINT_BIT_DMA_CTRL_UPA);
--   Dex_is_Last        <= DMA_Control_i(CINT_BIT_DMA_CTRL_LAST);
--   Engine_Ends        <= DMA_Control_i(CINT_BIT_DMA_CTRL_END);
--   use_Irpt_Done      <= not DMA_Control_i(CINT_BIT_DMA_CTRL_EDI);


   -- Means there is consecutive descriptor(s)
   ThereIs_Dex_i      <= not Dex_is_Last and not Engine_Ends;


-- ---------------------------------------------------------------
--  PA_i selection
--
   Syn_Calc_DMA_PA:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_PA_current       <= (Others=>'0');
         PA_is_taken          <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         if DMA_Start = '1' and PA_is_taken='0' then
            DMA_PA_current   <= DMA_PA_i(C_DBUS_WIDTH-1 downto 2) &"00";
            PA_is_taken      <= '1';
         elsif DMA_Start2 = '1' and PA_is_taken='0' and DMA_Control_i(CINT_BIT_DMA_CTRL_UPA) = '1' then
            DMA_PA_current   <= DMA_PA_i(C_DBUS_WIDTH-1 downto 2) &"00";
            PA_is_taken      <= '1';
         elsif DMA_Start2 = '1' and PA_is_taken='0' and DMA_Control_i(CINT_BIT_DMA_CTRL_UPA) = '0' then
            DMA_PA_current(C_DBUS_WIDTH-1 downto 0) <= DMA_PA_next;
            PA_is_taken      <= '1';
         else
            DMA_PA_current   <= DMA_PA_current;
            if DMA_Start='0' and DMA_Start2='0' then
               PA_is_taken   <= '0';
            else
               PA_is_taken   <= PA_is_taken;
            end if;
         end if;

      end if;

   end process;


-- ---------------------------------------------------------------
-- PA_next Calculation
--
   Syn_Calc_DMA_PA_next:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_PA_next       <= (Others=>'0');

      elsif dma_clk'event and dma_clk = '1' then

         if DMA_Start = '1' and PA_is_taken='0' then
            if DMA_Control_i(CINT_BIT_DMA_CTRL_AINC) = '1' then
               DMA_PA_next(CBIT_CARRY-1 downto  0)           <= Carry_PA_plus_Leng(CBIT_CARRY-1 downto 0);
               DMA_PA_next(C_DBUS_WIDTH-1 downto CBIT_CARRY) <= Leng_Hi_plus_PA_Hi 
                                                              + Carry_PA_plus_Leng(CBIT_CARRY);
            else
               DMA_PA_next <= DMA_PA_i(C_DBUS_WIDTH-1 downto 2) &"00";
            end if;

         elsif DMA_Start2 = '1' and PA_is_taken='0' then
            if DMA_Control_i(CINT_BIT_DMA_CTRL_AINC) = '1' then
               DMA_PA_next(CBIT_CARRY-1 downto  0)           <= Carry_PAx_plus_Leng(CBIT_CARRY-1 downto 0);
               DMA_PA_next(C_DBUS_WIDTH-1 downto CBIT_CARRY) <= Leng_Hi_plus_PAx_Hi 
                                                              + Carry_PAx_plus_Leng(CBIT_CARRY);
            else
               DMA_PA_next <= DMA_PA_next;
            end if;
         else
            DMA_PA_next    <= DMA_PA_next;
         end if;

      end if;

   end process;


-- ---------------------------------------------------------------
-- Carry_PA_plus_Leng(16 downto 0)
--
   Syn_Calc_Carry_PA_plus_Leng:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         Carry_PA_plus_Leng    <= (Others=>'0');

      elsif dma_clk'event and dma_clk = '1' then
         Carry_PA_plus_Leng    <= ('0'& DMA_PA_i(CBIT_CARRY-1 downto 2) &"00")
                                + ('0'& DMA_Length_i(CBIT_CARRY-1 downto 2) &"00");
      end if;

   end process;


-- ---------------------------------------------------------------
-- Carry_PAx_plus_Leng(16 downto 0)
--
   Syn_Calc_Carry_PAx_plus_Leng:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         Carry_PAx_plus_Leng   <= (Others=>'0');

      elsif dma_clk'event and dma_clk = '1' then
         Carry_PAx_plus_Leng   <= ('0'& DMA_PA_next (CBIT_CARRY-1 downto 2) &"00")
                                + ('0'& DMA_Length_i(CBIT_CARRY-1 downto 2) &"00");
      end if;

   end process;


-- ---------------------------------------------------------------
-- Leng_Hi_plus_PA_Hi(31 downto 16)
--
   Syn_Calc_Leng_Hi_plus_PA_Hi:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         Leng_Hi_plus_PA_Hi           <= (Others=>'0');

      elsif dma_clk'event and dma_clk = '1' then
         Leng_Hi_plus_PA_Hi           <= DMA_Length_i(C_DBUS_WIDTH-1 downto CBIT_CARRY) 
                                       + DMA_PA_i(C_DBUS_WIDTH-1 downto CBIT_CARRY);

      end if;

   end process;


-- ---------------------------------------------------------------
-- Leng_Hi_plus_PAx_Hi(31 downto 16)
--
   Syn_Calc_Leng_Hi_plus_PAx_Hi:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         Leng_Hi_plus_PAx_Hi          <= (Others=>'0');

      elsif dma_clk'event and dma_clk = '1' then
         Leng_Hi_plus_PAx_Hi          <= DMA_Length_i(C_DBUS_WIDTH-1 downto CBIT_CARRY) 
                                       + DMA_PA_next(C_DBUS_WIDTH-1 downto CBIT_CARRY);

      end if;

   end process;


-- -----------------------------------------------------------------------------------------------------------------------------------
   DMA_Leng_Left_Msk        <= DMA_Length_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_left;
   DMA_Leng_Mid_Msk         <= DMA_Length_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_mid;
   DMA_Leng_Right_Msk       <= DMA_Length_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_right;

-- -----------------------------------------------------------------------------------------------------------------------------------
   DMA_HA_Msk               <= (DMA_HA_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_right)
                             &  DMA_HA_i(C_MAXSIZE_FLD_BIT_BOT-1 downto 2)
                             &  "00";
   DMA_Length_Msk           <= (DMA_Length_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_right)
                             &  DMA_Length_i(C_MAXSIZE_FLD_BIT_BOT-1 downto 2)
                             &  "00";

-- -----------------------------------------------------------------------------------------------------------------------------------
   Lo_Leng_Left_Msk_is_True   <= '0' when DMA_Leng_Left_Msk =C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) else '1';
   Lo_Leng_Mid_Msk_is_True    <= '0' when DMA_Leng_Mid_Msk  =C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) else '1';
   Lo_Leng_Right_Msk_is_True  <= '0' when DMA_Leng_Right_Msk=C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) else '1';


-- ----------------------------------------------------------
-- Synchronous Register: Leng_Info(Compressed Length Information)
---
   Syn_Calc_Parameter_Leng_Info:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         Leng_Two  <= '0';
         Leng_One  <= '0';
         Leng_nint <= '0';

      elsif dma_clk'event and dma_clk = '1' then
         Leng_Two  <= Leng_Hi19b_True or Lo_Leng_Left_Msk_is_True;
         Leng_One  <= Lo_Leng_Mid_Msk_is_True;
         Leng_nint <= Leng_Lo7b_True  or Lo_Leng_Right_Msk_is_True;

      end if;
   end process;


-- -----------------------------------------------------------------------------------------------------------------------------------
   ALc_B_wire  <= '0' when (ALc(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_mid)=C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT)
                      else '1';
   ALc_T_wire  <= '0' when (ALc(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_right)=C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT)
                           and ALc(C_MAXSIZE_FLD_BIT_BOT-1 downto 0)=C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_BOT-1 downto 0)
                      else '1';
-- -----------------------------------------------------------------------------------------------------------------------------------

-- -------------------------------------------------------
-- Synchronous Register: ALc (Address-Length combination)
---
   Syn_Calc_Parameter_ALc:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         ALc      <= (Others=>'0');
         ALc_B    <= '0';
         ALc_T    <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         ALc      <= DMA_Length_Msk + DMA_HA_Msk;
         ALc_B    <= ALc_B_wire;
         ALc_T    <= ALc_T_wire;

      end if;

   end process;


   -- concatenation of the Length information
   Length_analysis <= Leng_Two & Leng_One & Leng_nint;

   -- -------------------------------------------
   -- Analysis on the DMA division
   --     truth-table expressions
   -- 
   Comb_S_B_T:
   process ( 
             Length_analysis
           , ALc_B
           , ALc_T
           )
   begin
     case Length_analysis is

        --   Zero-length DMA, nothing to send
        when "000"  =>
          Snout_Body_Tail <= "000";

        --   Length < Max_Size. Always Snout and never Body, Tail depends on ALc.
        when "001"  =>
          Snout_Body_Tail <= '1' & '0' & (ALc_B and ALc_T);

        --   Length = Max_Size. Division depends only on ALc-Tail.
        when "010"  =>
          Snout_Body_Tail <= ALc_T & not ALc_T & ALc_T;
        --   Length = (k+1) Max_Size, k>=1. Always Body. Snout and Tail depend on ALc-Tail.
        --                                  Body = Leng_Two or not ALc_T
        when "100"  =>
          Snout_Body_Tail <= ALc_T & '1' & ALc_T;
        when "110"  =>
          Snout_Body_Tail <= ALc_T & '1' & ALc_T;

        --   Length = (1+d) Max_Size, 0<d<1. Always Snout. Body and Tail copy ALc.
        when "011"  =>
          Snout_Body_Tail <= '1' & ALc_B & ALc_T;
        --   Length = (k+1+d) Max_Size, k>=1, 0<d<1. Always Snout and Body. Tail copies ALc-Tail.
        --                                           Body = Leng_Two or ALc_B
        when "101"  =>
          Snout_Body_Tail <= '1' & '1' & ALc_T;
        when "111"  =>
          Snout_Body_Tail <= '1' & '1' & ALc_T;

        --   dealt as zero-length DMA
        when Others  =>
          Snout_Body_Tail <= "000";

     end case;

   end process;

-- -----------------------------------------------
-- Synchronous Register:
--                       ThereIs_Snout
--                       ThereIs_Body
--                       ThereIs_Tail
--
   Syn_Calc_Parameters_SBT:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         ThereIs_Snout_i   <= '0';
         ThereIs_Body_i    <= '0';
         ThereIs_Tail_i    <= '0';

         Snout_Only        <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         ThereIs_Snout_i   <= Snout_Body_Tail(2);
         ThereIs_Body_i    <= Snout_Body_Tail(1);
         ThereIs_Tail_i    <= Snout_Body_Tail(0);

         Snout_Only        <= ALc_T and not Snout_Body_Tail(0);

      end if;

   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  HA_gap
--
   Syn_Calc_HA_gap:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         HA_gap   <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then
         HA_gap   <= Max_TLP_Size - DMA_HA_Msk;
      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_PA_Snout_Carry
--
   FSM_Calc_DMA_PA_Snout_Carry:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_PA_Snout_Carry   <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then
         DMA_PA_Snout_Carry   <= ('0'& DMA_PA_current(CBIT_CARRY-1 downto 0)) + HA_gap;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_PA_Body_Carry
--
   FSM_Calc_DMA_PA_Body_Carry:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_PA_Body_Carry <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then
         DMA_PA_Body_Carry <= ('0'& DMA_PA_Var_i(CBIT_CARRY-1 downto 0)) + Max_TLP_Size;
      end if;
   end process;


-- ------------------------------------------------------------------
-- Synchronous Register: Length_minus
-- 
   Sync_Calc_Length_minus:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         Length_minus  <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then
         Length_minus  <= DMA_Length_i - Max_TLP_Size;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_BC_Carry
--
   FSM_Calc_DMA_BC_Carry:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_BC_Carry <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then
         DMA_BC_Carry <= ('0'& DMA_Byte_Counter(CBIT_CARRY-1 downto 0)) - Max_TLP_Size;

      end if;
   end process;


-- --------------------------------------------
-- Synchronous reg: DMA_Snout_Length
--                  DMA_Tail_Length
--
   FSM_Calc_DMA_Snout_Tail_Lengths:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_Snout_Length_i   <= (OTHERS =>'0');
         DMA_Tail_Length_i    <= (OTHERS =>'0');
         raw_Tail_Length      <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         DMA_Tail_Length_i(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0) <= (raw_Tail_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto C_MAXSIZE_FLD_BIT_BOT) 
                                                                   and mxsz_right(C_TLP_FLD_WIDTH_OF_LENG+1 downto C_MAXSIZE_FLD_BIT_BOT)
                                                                  ) &  raw_Tail_Length( C_MAXSIZE_FLD_BIT_BOT-1 downto 0);
         if State_Is_LoadParam ='1' then
            raw_Tail_Length(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0) <= DMA_Length_Msk(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0)
                                                                 + DMA_HA_Msk(C_TLP_FLD_WIDTH_OF_LENG+1 downto 0);
            if Snout_Only='1' then
              DMA_Snout_Length_i <= DMA_Length_i(C_MAXSIZE_FLD_BIT_TOP downto 2) &"00";
            else
              DMA_Snout_Length_i <= Max_TLP_Size - DMA_HA_Msk;
            end if;

         else
            DMA_Snout_Length_i   <= DMA_Snout_Length_i;
            raw_Tail_Length      <= raw_Tail_Length;

         end if;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous Delays: 
--                    State_Is_Snout_r1
--                    State_Is_Body_r1
--
   Syn_Delay_State_is_x:
   process ( dma_clk )
   begin
      if dma_clk'event and dma_clk = '1' then
         State_Is_Snout_r1  <= State_Is_Snout;
         State_Is_Body_r1   <= State_Is_Body;
      end if;

   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_HA_Carry32
--
   FSM_Calc_DMA_HA_Carry32:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_HA_Carry32  <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
            DMA_HA_Carry32  <= '0' & DMA_HA_i(C_DBUS_WIDTH/2-1 downto 2) & "00"; -- temp

         elsif State_Is_Snout = '1' or State_Is_Body  = '1' then
            DMA_HA_Carry32(C_DBUS_WIDTH/2 downto C_MAXSIZE_FLD_BIT_BOT)  <= ('0'& DMA_HA_Var_i(C_DBUS_WIDTH/2-1 downto C_MAXSIZE_FLD_BIT_TOP+1) &
                                                                           (DMA_HA_Var_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and not mxsz_right)
                                                                          ) + mxsz_mid;

         else
            DMA_HA_Carry32  <=  DMA_HA_Carry32;

         end if;

      end if;
   end process;



-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_HA_Var
--
   FSM_Calc_DMA_HA_Var:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_HA_Var_i  <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
            DMA_HA_Var_i  <= DMA_HA_i(C_DBUS_WIDTH-1 downto 2) & "00"; -- temp

         elsif State_Is_Snout_r1 = '1' or State_Is_Body_r1  = '1' then
--         elsif State_Is_Snout = '1' or State_Is_Body  = '1' then
            DMA_HA_Var_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)  <= DMA_HA_Var_i(C_DBUS_WIDTH-1 downto C_DBUS_WIDTH/2)
                                                                 + DMA_HA_Carry32(C_DBUS_WIDTH/2);

            DMA_HA_Var_i(C_DBUS_WIDTH-1 downto C_MAXSIZE_FLD_BIT_BOT)  <= (DMA_HA_Var_i(C_DBUS_WIDTH-1 downto C_MAXSIZE_FLD_BIT_TOP+1) 
                                                                        & (DMA_HA_Var_i(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and not mxsz_right))
                                                                        +  mxsz_mid;
            DMA_HA_Var_i(C_MAXSIZE_FLD_BIT_BOT-1 downto 0)             <= (Others => '0');  -- MaxSize aligned

         else
            DMA_HA_Var_i  <=  DMA_HA_Var_i;

         end if;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  HA64bit
--
   FSM_Calc_HA64bit:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         HA64bit_i         <=  '0';

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
            HA64bit_i      <=  HA_is_64b;
         elsif DMA_HA_Carry32(C_DBUS_WIDTH/2) = '1' then
            HA64bit_i      <=  '1';
         else
            HA64bit_i      <=  HA64bit_i;
         end if;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_PA_Var
--
   FSM_Calc_DMA_PA_Var:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_PA_Var_i   <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
              if  Addr_Inc_i='1' and ThereIs_Snout_i='1'  then
                  DMA_PA_Var_i(CBIT_CARRY-1 downto  0)  <= DMA_PA_current(CBIT_CARRY-1 downto  0)
                                                         + HA_gap(C_MAXSIZE_FLD_BIT_TOP downto  0);
                  DMA_PA_Var_i(C_DBUS_WIDTH-1 downto CBIT_CARRY)  <= DMA_PA_current(C_DBUS_WIDTH-1 downto CBIT_CARRY);
              else
                  DMA_PA_Var_i(C_DBUS_WIDTH-1 downto  0)  <= DMA_PA_current(C_DBUS_WIDTH-1 downto  0);
              end if;

         elsif State_Is_Snout_r1 = '1' then
----         elsif State_Is_Snout = '1' then
              if  Addr_Inc_i= '1' then
                  DMA_PA_Var_i(CBIT_CARRY-1 downto  0)  <= DMA_PA_Var_i(CBIT_CARRY-1 downto 0);
                  DMA_PA_Var_i(C_DBUS_WIDTH-1 downto CBIT_CARRY)  <= DMA_PA_Var_i(C_DBUS_WIDTH-1 downto CBIT_CARRY)
                                                                   + DMA_PA_Snout_Carry(CBIT_CARRY);
              else
                  DMA_PA_Var_i   <= DMA_PA_Var_i;
              end if;

         elsif State_Is_Body_r1  = '1' then
----         elsif State_Is_Body  = '1' then
              if  Addr_Inc_i= '1' then
                  DMA_PA_Var_i(CBIT_CARRY-1 downto  0)  <= DMA_PA_Body_Carry(CBIT_CARRY-1 downto 0);
                  DMA_PA_Var_i(C_DBUS_WIDTH-1 downto CBIT_CARRY)  <= DMA_PA_Var_i(C_DBUS_WIDTH-1 downto CBIT_CARRY)
                                                                   + DMA_PA_Body_Carry(CBIT_CARRY);
              else
                  DMA_PA_Var_i   <= DMA_PA_Var_i;
              end if;

         else
              DMA_PA_Var_i   <= DMA_PA_Var_i;

         end if;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: 
--                  DMA_PA_Loaded_i
--
   FSM_Calc_DMA_PA_Loaded_i:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_PA_Loaded_i   <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
            DMA_PA_Loaded_i <= DMA_PA_current(C_DBUS_WIDTH-1 downto 0);
         else
            DMA_PA_Loaded_i <= DMA_PA_Loaded_i;
         end if;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: DMA_Byte_Counter
---
   FSM_Calc_DMA_Byte_Counter:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         DMA_Byte_Counter <= (OTHERS =>'0');

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
               if ALc_B='0' and ALc_T='1' then
                 DMA_Byte_Counter <= Length_minus;
               else
                 DMA_Byte_Counter <= DMA_Length_i(C_DBUS_WIDTH-1 downto 2) & "00";
               end if;

--         elsif State_Is_Body_r1 = '1' then
         elsif State_Is_Body = '1' then
                DMA_Byte_Counter(C_DBUS_WIDTH-1 downto CBIT_CARRY) <= DMA_Byte_Counter(C_DBUS_WIDTH-1 downto CBIT_CARRY)
                                                                    - DMA_BC_Carry(CBIT_CARRY);
                DMA_Byte_Counter(CBIT_CARRY-1 downto C_MAXSIZE_FLD_BIT_BOT)  <= DMA_BC_Carry(CBIT_CARRY-1 downto C_MAXSIZE_FLD_BIT_BOT);
         else
                DMA_Byte_Counter <= DMA_Byte_Counter;
         end if;

      end if;
   end process;


-- -------------------------------------------------------------
-- Synchronous reg: No_More_Bodies
---
   FSM_Calc_No_More_Bodies:
   process ( dma_clk, dma_reset)
   begin
      if dma_reset = '1' then
         No_More_Bodies_i <= '0';

      elsif dma_clk'event and dma_clk = '1' then

         if State_Is_LoadParam = '1' then
               No_More_Bodies_i  <= not ThereIs_Body_i;

--         elsif State_Is_Body_r1 = '1' then
         elsif State_Is_Body = '1' then
               if DMA_Byte_Counter(C_DBUS_WIDTH-1 downto C_MAXSIZE_FLD_BIT_TOP+1)=C_ALL_ZEROS(C_DBUS_WIDTH-1 downto C_MAXSIZE_FLD_BIT_TOP+1)
                  and (DMA_Byte_Counter(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_left)=C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT)
                  and (DMA_Byte_Counter(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT) and mxsz_mid)/=C_ALL_ZEROS(C_MAXSIZE_FLD_BIT_TOP downto C_MAXSIZE_FLD_BIT_BOT)
                  then
                      No_More_Bodies_i <= '1';
               else
                      No_More_Bodies_i <= '0';
               end if;

         else
               No_More_Bodies_i  <= No_More_Bodies_i;
         end if;

      end if;
   end process;


  -- ------------------------------------------
  -- Configuration pamameters: Param_Max_Cfg
  --
    Syn_Config_Param_Max_Cfg:
    process ( dma_clk, dma_reset)
    begin
       if dma_reset = '1' then  -- 0x0080 Bytes
               mxsz_left      <= "111110";         -- 6 bits
               mxsz_mid       <= "000001";         -- 6 bits
               mxsz_right     <= "000000";         -- 6 bits

       elsif dma_clk'event and dma_clk = '1' then

          case Param_Max_Cfg is

            when "000" =>  -- 0x0080 Bytes
               mxsz_left      <= "111110";
               mxsz_mid       <= "000001";
               mxsz_right     <= "000000";

            when "001" =>  -- 0x0100 Bytes
               mxsz_left      <= "111100";
               mxsz_mid       <= "000010";
               mxsz_right     <= "000001";

            when "010" =>  -- 0x0200 Bytes
               mxsz_left      <= "111000";
               mxsz_mid       <= "000100";
               mxsz_right     <= "000011";

            when "011" =>  -- 0x0400 Bytes
               mxsz_left      <= "110000";
               mxsz_mid       <= "001000";
               mxsz_right     <= "000111";

            when "100" =>  -- 0x0800 Bytes
               mxsz_left      <= "100000";
               mxsz_mid       <= "010000";
               mxsz_right     <= "001111";

            when "101" =>  -- 0x1000 Bytes
               mxsz_left      <= "000000";
               mxsz_mid       <= "100000";
               mxsz_right     <= "011111";

            when Others => -- as 0x0080 Bytes
               mxsz_left      <= "111110";
               mxsz_mid       <= "000001";
               mxsz_right     <= "000000";

          end case;

       end if;
    end process;

    Max_TLP_Size  <= mxsz_mid & CONV_STD_LOGIC_VECTOR(0, C_MAXSIZE_FLD_BIT_BOT);


end architecture Behavioral;
