library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity modem is
  port ( clk            : in  std_logic;
         rsti            : in  std_logic;
         rxserial       : in  std_logic;
         txserial       : out std_logic;
         pmem_ready     : out std_logic;
         pIin           : out std_logic_vector(13 downto 0);
         pmem_block     : out std_logic;
         pOutput_enable : out std_logic;
         pwen           : out std_logic;
         paddress_read  : out std_logic_vector(5 downto 0);
         paddress_write : out std_logic_vector(6 downto 0);
         Iout_rx          : out std_logic_vector(13 downto 0);
         Qout_rx          : out std_logic_vector(13 downto 0);
         Output_enable_rx : out std_logic;
         addrout_out_rx   : out std_logic_vector(5 downto 0);
         mem_block_tx : out std_logic;
         mem_ready_tx : out std_logic;
         wen_tx       : out std_logic;
         address_tx   : out std_logic_vector (5 downto 0);
         i_tx         : out std_logic_vector(11 downto 0);
         q_tx         : out std_logic_vector(11 downto 0)
         );
end modem;

architecture modem of modem is

  component txmodem
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      serial        : in  std_logic;
      Iout          : out std_logic_vector(13 downto 0);
      Output_enable : out std_logic;
      addrout_out   : in  std_logic_vector(5 downto 0)
      );
  end component;

  component txrx
    port (
      clk           : in  std_logic;
      rst           : in  std_logic;
      Output_enable : in  std_logic;
      mem_block     : in  std_logic;
      mem_ready     : out std_logic;
      wen           : out std_logic;
      address_read : out std_logic_vector(5 downto 0);
      address_write: out std_logic_vector(6 downto 0)
      );
  end component;

  component rxmodem
    port (
      clk : in std_logic;
      rst : in std_logic;
      mem_ready     : in  std_logic;
      Iin           : in  std_logic_vector(11 downto 0);
      mem_block     : out std_logic;
      wen           : in  std_logic;
      addrin_in     : in  std_logic_vector(6 downto 0);
      txserial : out std_logic
      );
  end component;

   component BUFGP
         port (I: in std_logic; O: out std_logic);
   end component;
   signal rst:  std_logic;


  signal mem_ready     : std_logic;
  signal Iin           : std_logic_vector(13 downto 0);
  signal mem_block     : std_logic;
  signal Output_enable : std_logic;
  signal wen           : std_logic;
  signal address_read  : std_logic_vector(5 downto 0);
  signal address_write : std_logic_vector(6 downto 0);
  
begin
   U1:  BUFGP port map (I => rsti, O => rst);


  txmodem_1 : txmodem
    port map (
      clk           => clk,
      rst           => rst,
      serial        => rxserial,
      Iout          => Iin,
      Output_enable => Output_enable,
      addrout_out   => address_read
      );

  txrx_1 : txrx
    port map (
      clk           => clk,
      rst           => rst,
      Output_enable => Output_enable,
      mem_block     => mem_block,
      mem_ready     => mem_ready,
      wen           => wen,
      address_read       => address_read,
      address_write       => address_write);

  rxmodem_1 : rxmodem
    port map (
      clk           => clk,
      rst           => rst,
      mem_ready     => mem_ready,
      Iin           => Iin(13 downto 2),
      mem_block     => mem_block,
      wen           => wen,
      addrin_in     => address_write,
      txserial      => txserial
      );

end modem;
