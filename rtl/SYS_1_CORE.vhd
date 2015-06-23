-- #########################################################
-- #       << ATLAS Project - System Controller 1 >>       #
-- # ***************************************************** #
-- #  -> Memory Management Unit                            #
-- #  -> Clock Information                                 #
-- # ***************************************************** #
-- #  Last modified: 28.11.2014                            #
-- # ***************************************************** #
-- #  by Stephan Nolting 4788, Hanover, Germany            #
-- #########################################################

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.atlas_core_package.all;

entity sys_1_core is
-- ###############################################################################################
-- ##       Clock Speed Configuration                                                           ##
-- ###############################################################################################
  generic (
        clk_speed_g     : std_ulogic_vector(31 downto 0) := (others => '0') -- clock speed (in Hz)
      );
  port	(
-- ###############################################################################################
-- ##           Host Interface                                                                  ##
-- ###############################################################################################

        clk_i           : in  std_ulogic; -- global clock line
        rst_i           : in  std_ulogic; -- global reset line, sync, high-active
        ice_i           : in  std_ulogic; -- interface clock enable, high-active
        w_en_i          : in  std_ulogic; -- write enable
        r_en_i          : in  std_ulogic; -- read enable
        adr_i           : in  std_ulogic_vector(02 downto 0); -- access address
        dat_i           : in  std_ulogic_vector(15 downto 0); -- write data
        dat_o           : out std_ulogic_vector(15 downto 0); -- read data

        sys_mode_i      : in  std_ulogic; -- current operating mode
        int_exe_i       : in  std_ulogic; -- interrupt beeing executed

-- ###############################################################################################
-- ##           Memory Interface                                                                ##
-- ###############################################################################################

        mem_ip_adr_o    : out std_ulogic_vector(15 downto 0); -- instruction page
        mem_dp_adr_o    : out std_ulogic_vector(15 downto 0)  -- data page
      );
end sys_1_core;

architecture sys_1_core_behav of sys_1_core is

  -- register addresses --
  constant mmu_irq_base_c    : std_ulogic_vector(02 downto 0) := "000"; -- r/w: base page for irqs
  constant mmu_sys_i_page_c  : std_ulogic_vector(02 downto 0) := "001"; -- r/w: system mode i page
  constant mmu_sys_d_page_c  : std_ulogic_vector(02 downto 0) := "010"; -- r/w: system mode d page
  constant mmu_usr_i_page_c  : std_ulogic_vector(02 downto 0) := "011"; -- r/w: user mode i page
  constant mmu_usr_d_page_c  : std_ulogic_vector(02 downto 0) := "100"; -- r/w: user mode d page
  constant mmu_i_page_link_c : std_ulogic_vector(02 downto 0) := "101"; -- r:   linked i page
  constant mmu_d_page_link_c : std_ulogic_vector(02 downto 0) := "110"; -- r:   linked d page
  constant mmu_sys_info_c    : std_ulogic_vector(02 downto 0) := "111"; -- r:   system info
  -- sys info register (uses auto-pointer):
  -- 1st read access: clock speed low
  -- 2nd read access: clock speed high

  -- registers --
  signal mmu_irq_base    : std_ulogic_vector(15 downto 0);
  signal mmu_sys_i_page  : std_ulogic_vector(15 downto 0);
  signal mmu_sys_d_page  : std_ulogic_vector(15 downto 0);
  signal mmu_usr_i_page  : std_ulogic_vector(15 downto 0);
  signal mmu_usr_d_page  : std_ulogic_vector(15 downto 0);
  signal mmu_i_page_link : std_ulogic_vector(15 downto 0);
  signal mmu_d_page_link : std_ulogic_vector(15 downto 0);

  -- buffers / local signals --
  signal i_sys_tmp, i_usr_tmp : std_ulogic_vector(15 downto 0);
  signal d_sys_tmp, d_usr_tmp : std_ulogic_vector(15 downto 0);
  signal mode_buf             : std_ulogic_vector(01 downto 0);
  signal sys_info             : std_ulogic_vector(15 downto 0);
  signal sys_info_adr         : std_ulogic_vector(01 downto 0);

begin

  -- MMU Register Update ---------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    mmu_reg_up: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          mmu_irq_base    <= start_page_c; -- (others => '0');
          mmu_sys_i_page  <= start_page_c;
          mmu_sys_d_page  <= start_page_c;
          mmu_usr_i_page  <= start_page_c; -- (others => '0');
          mmu_usr_d_page  <= start_page_c; -- (others => '0');
          mmu_i_page_link <= start_page_c; -- (others => '0');
          mmu_d_page_link <= start_page_c; -- (others => '0');
          i_sys_tmp       <= start_page_c;
          d_sys_tmp       <= start_page_c;
          i_usr_tmp       <= start_page_c; -- (others => '0');
          d_usr_tmp       <= start_page_c; -- (others => '0');
          mode_buf        <= system_mode_c & system_mode_c; -- start in system mode
        elsif (ice_i = '1') then

          -- auto update --
          mode_buf  <= mode_buf(0) & sys_mode_i;
          i_sys_tmp <= mmu_sys_i_page;
          d_sys_tmp <= mmu_sys_d_page;
          i_usr_tmp <= mmu_usr_i_page;
          d_usr_tmp <= mmu_usr_d_page;

          -- exception processing ----------------------------------------------------------
          -- ----------------------------------------------------------------------------------
          if (int_exe_i = '1') then
            mmu_sys_i_page <= mmu_irq_base; -- system-mode base page for irqs
            mmu_sys_d_page <= mmu_irq_base; -- system-mode base page for irqs
            i_sys_tmp      <= mmu_irq_base; -- system-mode base page for irqs
            d_sys_tmp      <= mmu_irq_base; -- system-mode base page for irqs
            if (mode_buf(1) = user_mode_c) then -- we were in usr mode
              mmu_i_page_link <= i_usr_tmp; -- save current sys i-page
              mmu_d_page_link <= d_usr_tmp; -- save current sys d-page
            else -- we were in sys mode
              mmu_i_page_link <= i_sys_tmp; -- save current sys i-page
              mmu_d_page_link <= d_sys_tmp; -- save current sys d-page
            end if;

          -- data transfer -----------------------------------------------------------------
          -- ----------------------------------------------------------------------------------
          elsif (w_en_i = '1') then -- valid write
            case (adr_i) is
              when mmu_irq_base_c    => mmu_irq_base    <= dat_i; -- system-mode base page
              when mmu_sys_i_page_c  => mmu_sys_i_page  <= dat_i; -- system instruction page
              when mmu_sys_d_page_c  => mmu_sys_d_page  <= dat_i; -- system data page
              when mmu_usr_i_page_c  => mmu_usr_i_page  <= dat_i; -- user instruction page
              when mmu_usr_d_page_c  => mmu_usr_d_page  <= dat_i; -- user data page
--            when mmu_i_page_link_c => mmu_i_page_link <= dat_i; -- instruction page link
--            when mmu_d_page_link_c => mmu_d_page_link <= dat_i; -- data page link
              when others            => null; -- do nothing
            end case;
          end if;
        end if;
      end if;
    end process mmu_reg_up;

    -- page output --
    mem_ip_adr_o <= i_usr_tmp when (sys_mode_i = user_mode_c) else i_sys_tmp;
    mem_dp_adr_o <= d_usr_tmp when (sys_mode_i = user_mode_c) else d_sys_tmp;


  -- MMU Read Access -------------------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    r_acc: process(adr_i, mmu_irq_base, mmu_sys_i_page, mmu_sys_d_page, mmu_usr_i_page,
                   mmu_usr_d_page, mmu_i_page_link, mmu_d_page_link, sys_info)
    begin
      case (adr_i) is
        when mmu_irq_base_c    => dat_o <= mmu_irq_base;    -- system-mode base page
        when mmu_sys_i_page_c  => dat_o <= mmu_sys_i_page;  -- system instruction page
        when mmu_sys_d_page_c  => dat_o <= mmu_sys_d_page;  -- system data page
        when mmu_usr_i_page_c  => dat_o <= mmu_usr_i_page;  -- user instruction page
        when mmu_usr_d_page_c  => dat_o <= mmu_usr_d_page;  -- user data page
        when mmu_i_page_link_c => dat_o <= mmu_i_page_link; -- instruction page link
        when mmu_d_page_link_c => dat_o <= mmu_d_page_link; -- data page link
        when mmu_sys_info_c    => dat_o <= sys_info;        -- system info
        when others            => dat_o <= (others => '0'); -- dummy output
      end case;
    end process r_acc;


  -- System Info Output Control --------------------------------------------------------------------------
  -- --------------------------------------------------------------------------------------------------------
    sys_info_ctrl: process(clk_i)
    begin
      if rising_edge(clk_i) then
        if (rst_i = '1') then
          sys_info_adr <= (others => '0');
        elsif (r_en_i = '1') and (ice_i = '1') and (adr_i = mmu_sys_info_c) then
          sys_info_adr <= std_ulogic_vector(unsigned(sys_info_adr) + 1);
        end if;
      end if;
    end process sys_info_ctrl;

    -- output selector --
    sys_info_out: process(sys_info_adr)
    begin
      case (sys_info_adr) is
        when "00" => sys_info <= clk_speed_g(15 downto 00);
        when "01" => sys_info <= clk_speed_g(31 downto 16);
        when "10" => sys_info <= clk_speed_g(15 downto 00);
        when "11" => sys_info <= clk_speed_g(31 downto 16);
        when others => sys_info <= (others => '0');
      end case;
    end process sys_info_out;



end sys_1_core_behav;
