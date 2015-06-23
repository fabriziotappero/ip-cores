library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VCOMPONENTS.ALL;


entity system_tb is
end system_tb;

architecture STRUCTURE of system_tb is

  constant sys_clk_period     : time    := 10.000000 ns;
  constant wb_clk_period      : time    := 13.333333 ns;
  constant sys_rst_length     : time    := 160 ns;

  constant SYNCH_PART         : integer := 1;
  constant SYNCH_SUBPART      : integer := 2;
  constant SYNCH_SUBSUBPART   : integer := 3;

  constant SUBSUBPART_LENGTH  : integer := 15;  -- 10 clock cycles
  constant SUBPART_LENGTH     : integer := 5;  -- 7 times SUBSUBPART_LENGTH
  constant PART_LENGTH        : integer := 5;  -- 6 times SUBPART_LENGTH

  component system is
    port (
      sys_clk_pin          : in  std_logic;
      sys_rst_pin          : in  std_logic;
      to_synch_in_pin      : in  std_logic_vector( 0 to 31 );
      from_synch_out_pin   : out std_logic_vector( 0 to 31 );
      wb_clk_pin           : in  std_logic;
      wb_rst_pin           : in  std_logic
    );
  end component;


   signal sys_clk : std_logic;
   signal sys_rst : std_logic := '1';
   signal wb_clk  : std_logic;
   signal wb_rst  : std_logic;


   signal to_synch_in       : std_logic_vector( 0 to 31 );
   signal from_synch_out    : std_logic_vector( 0 to 31 );
   signal tb_synch_out      : std_logic_vector( 0 to 31 )   := ( others => '0' );

   procedure SendSynch( signal synch_out : OUT std_logic_vector;
                                COMMAND :     integer ) is
   begin
      synch_out( COMMAND ) <= '1';
      wait for sys_clk_period*1;
      synch_out( COMMAND ) <= '0';
   end procedure SendSynch;


begin

   to_synch_in <= from_synch_out or tb_synch_out;
   


   dut : system
      port map (
         sys_clk_pin          => sys_clk,
         sys_rst_pin          => sys_rst,
         to_synch_in_pin      => to_synch_in,
         from_synch_out_pin   => from_synch_out,
         wb_clk_pin           => wb_clk,
         wb_rst_pin           => wb_rst
      );


   --
   -- generate plb-clk
   -- 
   process
   begin
      sys_clk <= '0';
      loop
         wait for (sys_clk_period/2);
         sys_clk <= not sys_clk;
      end loop;
   end process;


   --
   --
   --
   process
   begin
      wb_clk  <= '0';
      loop
         wait for (wb_clk_period/2);
         wb_clk  <= not wb_clk;
      end loop;
   end process;




   process
   begin
      sys_rst <= '1';
      wb_rst  <= '1';
      wait for ( sys_rst_length );
      wb_rst  <= not wb_rst;
      sys_rst <= not sys_rst;
      wait;
   end process;


   process
   begin

    wait until sys_rst = '0';
    -- wait until masters a ready
    wait for sys_clk_period * 10;


    while true loop
      for i in 0 to PART_LENGTH-1 loop
         SendSynch( tb_synch_out, SYNCH_PART );

         for j in 0 to SUBPART_LENGTH-1 loop
            SendSynch( tb_synch_out, SYNCH_SUBPART );

            for k in 0 to SUBSUBPART_LENGTH loop
               SendSynch( tb_synch_out, SYNCH_SUBSUBPART );
               wait for (SUBSUBPART_LENGTH * sys_clk_period );
            end loop;


         end loop;


      end loop;

   end loop;

   end process;
   



end architecture STRUCTURE;

