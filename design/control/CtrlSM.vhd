-------------------------------------------------------------------------------
-- File Name :  CtrlSM.vhd
--
-- Project   : JPEG_ENC
--
-- Module    : CtrlSM
--
-- Content   : CtrlSM
--
-- Description : CtrlSM core
--
-- Spec.     : 
--
-- Author    : Michal Krepa
--
-------------------------------------------------------------------------------
-- History :
-- 20090301: (MK): Initial Creation.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- LIBRARY/PACKAGE ---------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- generic packages/libraries:
-------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- user packages/libraries:
-------------------------------------------------------------------------------
library work;
  use work.JPEG_PKG.all;
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ENTITY ------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
entity CtrlSM is
  port 
  (
        CLK                : in  std_logic;
        RST                : in  std_logic;
        
        -- output IF
        outif_almost_full  : in  std_logic;

        -- HOST IF
        sof                : in  std_logic;
        img_size_x         : in  std_logic_vector(15 downto 0);
        img_size_y         : in  std_logic_vector(15 downto 0);
        jpeg_ready         : out std_logic;       
        jpeg_busy          : out std_logic;

        -- FDCT
        fdct_start         : out std_logic;
        fdct_ready         : in  std_logic;
        fdct_sm_settings   : out T_SM_SETTINGS;
       
        -- ZIGZAG
        zig_start          : out std_logic;
        zig_ready          : in  std_logic;
        zig_sm_settings    : out T_SM_SETTINGS;
        
        -- Quantizer
        qua_start          : out std_logic;
        qua_ready          : in  std_logic;
        qua_sm_settings    : out T_SM_SETTINGS;
        
        -- RLE
        rle_start          : out std_logic;
        rle_ready          : in  std_logic;
        rle_sm_settings    : out T_SM_SETTINGS;
        
        -- Huffman
        huf_start          : out std_logic;
        huf_ready          : in  std_logic;
        huf_sm_settings    : out T_SM_SETTINGS;
        
        -- ByteStuffdr
        bs_start           : out std_logic;
        bs_ready           : in  std_logic;
        bs_sm_settings     : out T_SM_SETTINGS;
        
        -- JFIF GEN
        jfif_start         : out std_logic;
        jfif_ready         : in  std_logic;
        jfif_eoi           : out std_logic;
        
        -- OUT MUX
        out_mux_ctrl       : out std_logic
   );
end entity CtrlSM;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
----------------------------------- ARCHITECTURE ------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture RTL of CtrlSM is


  constant NUM_STAGES   : integer := 6;
  
  constant CMP_MAX      : std_logic_vector(2 downto 0) := "100";

  type T_STATE is (IDLES, JFIF, HORIZ, COMP, VERT, EOI);
  type ARR_FSM is array(NUM_STAGES downto 1) of std_logic_vector(1 downto 0);
  
  type T_ARR_SM_SETTINGS is array(NUM_STAGES+1 downto 1) of T_SM_SETTINGS;
  signal Reg             : T_ARR_SM_SETTINGS;
  signal main_state      : T_STATE;
  signal start           : std_logic_vector(NUM_STAGES+1 downto 1);
  signal idle            : std_logic_vector(NUM_STAGES+1 downto 1);
  signal start_PB        : std_logic_vector(NUM_STAGES downto 1);
  signal ready_PB        : std_logic_vector(NUM_STAGES downto 1);
  signal fsm             : ARR_FSM;
  signal start1_d        : std_logic;
  signal RSM             : T_SM_SETTINGS;
  signal out_mux_ctrl_s  : std_logic;
  signal out_mux_ctrl_s2 : std_logic;
  
-------------------------------------------------------------------------------
-- Architecture: begin
-------------------------------------------------------------------------------
begin

  fdct_sm_settings <= Reg(1);
  zig_sm_settings  <= Reg(2);
  qua_sm_settings  <= Reg(3);
  rle_sm_settings  <= Reg(4);
  huf_sm_settings  <= Reg(5);
  bs_sm_settings   <= Reg(6);

  fdct_start    <= start_PB(1);
  ready_PB(1)   <= fdct_ready;
  
  zig_start     <= start_PB(2);
  ready_PB(2)   <= zig_ready;
  
  qua_start     <= start_PB(3);
  ready_PB(3)   <= qua_ready;
  
  rle_start     <= start_PB(4);
  ready_PB(4)   <= rle_ready;
  
  huf_start     <= start_PB(5);
  ready_PB(5)   <= huf_ready;
  
  bs_start      <= start_PB(6);
  ready_PB(6)   <= bs_ready;
  
  -----------------------------------------------------------------------------
  -- CTRLSM 1..NUM_STAGES
  -----------------------------------------------------------------------------
  G_S_CTRL_SM : for i in 1 to NUM_STAGES generate
  
    -- CTRLSM 1..NUM_STAGES
    U_S_CTRL_SM : entity work.SingleSM
    port map
    (
        CLK          => CLK,
        RST          => RST,      
        -- from/to SM(m)   
        start_i      => start(i),      
        idle_o       => idle(i),
        -- from/to SM(m+1) 
        idle_i       => idle(i+1),      
        start_o      => start(i+1),
        -- from/to processing block
        pb_rdy_i     => ready_PB(i),     
        pb_start_o   => start_PB(i),
        -- state out
        fsm_o        => fsm(i)
    );
  end generate G_S_CTRL_SM;
  
  idle(NUM_STAGES+1) <= not outif_almost_full;
  
  -------------------------------------------------------------------
  -- Regs
  -------------------------------------------------------------------
  G_REG_SM : for i in 1 to NUM_STAGES generate
    p_reg1 : process(CLK, RST)
    begin
      if RST = '1' then
        Reg(i) <= C_SM_SETTINGS;
      elsif CLK'event and CLK = '1' then
        if start(i) = '1' then
          if i = 1 then
            Reg(i).x_cnt   <= RSM.x_cnt;
            Reg(i).y_cnt   <= RSM.y_cnt;
            Reg(i).cmp_idx <= RSM.cmp_idx;
          else
            Reg(i) <= Reg(i-1);
          end if;                  
        end if;
      end if;
    end process;
  end generate G_REG_SM;
  
  -------------------------------------------------------------------
  -- Main_SM
  -------------------------------------------------------------------
  p_main_sm : process(CLK, RST)
  begin
    if RST = '1' then
      main_state        <= IDLES;
      start(1)          <= '0';
      start1_d          <= '0';
      jpeg_ready        <= '0';
      RSM.x_cnt         <= (others => '0');
      RSM.y_cnt         <= (others => '0');
      jpeg_busy         <= '0';
      RSM.cmp_idx       <= (others => '0');
      out_mux_ctrl_s    <= '0';
      out_mux_ctrl_s2   <= '0';
      jfif_eoi          <= '0';
      out_mux_ctrl      <= '0';
      jfif_start        <= '0';
    elsif CLK'event and CLK = '1' then
      start(1)          <= '0';
      start1_d          <= start(1);
      jpeg_ready        <= '0';
      jfif_start        <= '0';
      out_mux_ctrl_s2   <= out_mux_ctrl_s;
      out_mux_ctrl      <= out_mux_ctrl_s2;
      
      case main_state is
        -------------------------------
        -- IDLE
        -------------------------------
        when IDLES =>
          if sof = '1' then
            RSM.x_cnt    <= (others => '0');
            RSM.y_cnt    <= (others => '0');
            jfif_start   <= '1';
            out_mux_ctrl_s <= '0';
            jfif_eoi     <= '0';
            main_state <= JFIF;
          end if;
          
        -------------------------------
        -- JFIF
        -------------------------------
        when JFIF =>      
          if jfif_ready = '1' then
            out_mux_ctrl_s <= '1';
            main_state   <= HORIZ;
          end if;
          
        -------------------------------
        -- HORIZ
        -------------------------------
        when HORIZ =>      
          if RSM.x_cnt < unsigned(img_size_x) then
            main_state <= COMP;
          else
            RSM.x_cnt      <= (others => '0');
            main_state <= VERT;
          end if;          
          
        -------------------------------
        -- COMP
        -------------------------------
        when COMP =>
          if idle(1) = '1' and start(1) = '0' then
            if RSM.cmp_idx < unsigned(CMP_MAX) then
              start(1)   <= '1';
            else
              RSM.cmp_idx    <= (others => '0');
              RSM.x_cnt      <= RSM.x_cnt + 16;
              main_state <= HORIZ;
            end if;
          end if;
        
        -------------------------------
        -- VERT
        -------------------------------
        when VERT =>       
          if RSM.y_cnt < unsigned(img_size_y)-8 then
            RSM.x_cnt <= (others => '0');
            RSM.y_cnt <= RSM.y_cnt + 8;
            main_state <= HORIZ;
          else
            if idle(NUM_STAGES downto 1) = (NUM_STAGES-1 downto 0 => '1') then
              main_state     <= EOI;
              jfif_eoi       <= '1';
              out_mux_ctrl_s <= '0';
              jfif_start     <= '1';
            end if;
          end if;
        
        -------------------------------
        -- VERT
        -------------------------------
        when EOI =>
          if jfif_ready = '1' then
            jpeg_ready   <= '1';
            main_state   <= IDLES;
          end if;
        
        -------------------------------
        -- others
        -------------------------------
        when others =>
          main_state <= IDLES;

      end case;
      
      if start1_d = '1' then
        RSM.cmp_idx    <= RSM.cmp_idx + 1;
      end if;
      
      if main_state = IDLES then
        jpeg_busy <= '0';
      else
        jpeg_busy <= '1';
      end if;
       
    end if;
  end process;  



end architecture RTL;
-------------------------------------------------------------------------------
-- Architecture: end
-------------------------------------------------------------------------------