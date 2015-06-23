-------------------------------------------------------------------------------
--
-- Title       : ctrl_dma_adr
-- Author      : Dmitry Smekhov
-- Company     : Instrumental Systems
-- E-mail      : dsmv@insys.ru
--
-- Version     : 1.2
--
-------------------------------------------------------------------------------
--
-- Description :   Узел формирования адреса и размера для текущей операции
--
-------------------------------------------------------------------------------
--
--  Version 1.2  21.01.2011
--				 Адрес расширен до 40 разрядов
--
-------------------------------------------------------------------------------
--
--  Version 1.1  05.04.2010
--				 Добавлен параметр is_dsp48 - разрешение использования
--				 блоков DSP48
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


package	ctrl_dma_adr_pkg is

component ctrl_dma_adr is
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		clk				: in std_logic;	-- тактовая частота
		
		---- Доступ к PICOBLAZE ----
		dma_chn			: in std_logic;							-- номер канала DMA	  
		reg0			: in std_logic_vector( 2 downto 0 );	-- регистр DMA_CTRL
		reg41_wr		: in std_logic;							-- 1 - запись в регистр 41
		
		---- CTRL_EXT_DESCRIPTOR ----
		dsc_adr			: in std_logic_vector( 23 downto 0 );	-- адрес, байты 3..1
		dsc_adr_h		: in std_logic_vector(  7 downto 0 );	-- адрес, байт 4
		dsc_size		: in std_logic_vector( 23 downto 0 );	-- размер, байты 3..1 
																-- разряд 0 определяет направление работы, 0-чтение, 1-запись

		---- Адрес ----
		pci_adr			: out std_logic_vector( 39 downto 0 );	-- текущий адрес 
		pci_size_z		: out std_logic;						-- 1 - размер равен 0
		pci_rw			: out std_logic							-- 0 - чтение, 1 - запись	
	
	);
end component;

end package;


library ieee;
use ieee.std_logic_1164.all;  
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;


entity ctrl_dma_adr is			
	generic(
		is_dsp48		: in integer:=1		-- 1 - использовать DSP48, 0 - не использовать DSP48
	);
	port(
		---- Global ----
		clk				: in std_logic;	-- тактовая частота
		
		---- Доступ к PICOBLAZE ----
		dma_chn			: in std_logic;							-- номер канала DMA	  
		reg0			: in std_logic_vector( 2 downto 0 );	-- регистр DMA_CTRL
		reg41_wr		: in std_logic;							-- 1 - запись в регистр 41
		
		---- CTRL_EXT_DESCRIPTOR ----
		dsc_adr			: in std_logic_vector( 23 downto 0 );	-- адрес, байты 3..1
		dsc_adr_h		: in std_logic_vector(  7 downto 0 );	-- адрес, байт 4
		dsc_size		: in std_logic_vector( 23 downto 0 );	-- размер, байты 3..1

		---- Адрес ----
		pci_adr			: out std_logic_vector( 39 downto 0 );	-- текущий адрес 
		pci_size_z		: out std_logic;						-- 1 - размер равен 0
		pci_rw			: out std_logic							-- 0 - чтение, 1 - запись	
	
	);
end ctrl_dma_adr;


architecture ctrl_dma_adr of ctrl_dma_adr is


signal	port_a0		: std_logic_vector( 17 downto 0 );
signal	port_b0		: std_logic_vector( 17 downto 0 );
signal	port_c0		: std_logic_vector( 47 downto 0 );
signal	port_p0		: std_logic_vector( 47 downto 0 );
signal  opmode		: std_logic_vector( 6 downto 0 );
signal	carry0		: std_logic;


signal	port_a1		: std_logic_vector( 17 downto 0 );
signal	port_b1		: std_logic_vector( 17 downto 0 );
signal	port_c1		: std_logic_vector( 47 downto 0 );
signal	port_p1		: std_logic_vector( 47 downto 0 );
signal	carry1		: std_logic;			   
signal	subtract1	: std_logic;

signal	p2			: std_logic;
signal	n2			: std_logic;

signal	reg410_wr	: std_logic;	 

signal	adr_low		: std_logic_vector( 2 downto 0 );

begin							
	
p2 <= reg0(2);
n2 <= not reg0(2);

-- reg0(2)=1 - изменение адреса: opmode=0x30 carry=1
-- reg0(2)=0 - запись адреса из дескриптора: opmode=0x03 carry=0
opmode	<= '0' & p2 & p2 & "00" & n2 & n2;
carry0  <= p2;		 
carry1  <= p2;		  
subtract1 <= p2;

port_b0 <= dsc_adr( 21 downto 4 );
port_a0 <= x"00" & dsc_adr_h & dsc_adr( 23 downto 22 );  

--port_c0 <= port_p0;
--port_c1 <= port_p1;

port_b1 <= dsc_size( 21 downto 4 );
port_a1 <= "00" & x"0000";

pci_adr( 8 downto 0 ) <= (others=>'0');
pci_adr( 11 downto 9 )  <= adr_low( 2 downto 0 );
pci_adr( 31 downto 12 ) <= port_c0( 19 downto 0 );
pci_adr( 39 downto 32 ) <= port_c0( 27 downto 20 );

gen_dsp48: if( is_dsp48=1 ) generate

dsp0: DSP48 
  generic map(

        AREG            => 1,
        B_INPUT         => "DIRECT",
        BREG            => 1,
        CARRYINREG      => 1,
        CARRYINSELREG   => 1,
        CREG            => 1,
        LEGACY_MODE     => "MULT18X18S",
        MREG            => 1,
        OPMODEREG       => 1,
        PREG            => 1,
        SUBTRACTREG     => 1
        )

  port map(
        --BCOUT                   : out std_logic_vector(17 downto 0);
        P                       => port_p0,
        --PCOUT                   : out std_logic_vector(47 downto 0);

        A                       => port_a0,
        B                       => port_b0,
        BCIN                    => (others=>'0'),
        C                       => port_c0,
        CARRYIN                 => carry0,
        CARRYINSEL              => "00",
        CEA                     => '1',
        CEB                     => '1',
        CEC                     => '1',
        CECARRYIN               => '1',
        CECINSUB                => '1',
        CECTRL                  => '1',
        CEM                     => '1',
        CEP                     => '1',
        CLK                     => clk,
        OPMODE                  => opmode,
        PCIN                    => (others=>'0'),
        RSTA                    => '0',
        RSTB                    => '0',
        RSTC                    => '0',
        RSTCARRYIN              => '0',
        RSTCTRL                 => '0',
        RSTM                    => '0',
        RSTP                    => '0',
        SUBTRACT                => '0'
      );


	  
dsp1: DSP48 
  generic map(

        AREG            => 1,
        B_INPUT         => "DIRECT",
        BREG            => 1,
        CARRYINREG      => 1,
        CARRYINSELREG   => 1,
        CREG            => 1,
        LEGACY_MODE     => "MULT18X18S",
        MREG            => 1,
        OPMODEREG       => 1,
        PREG            => 1,
        SUBTRACTREG     => 1
        )

  port map(
        --BCOUT                   : out std_logic_vector(17 downto 0);
        P                       => port_p1,
        --PCOUT                   : out std_logic_vector(47 downto 0);

        A                       => port_a1,
        B                       => port_b1,
        BCIN                    => (others=>'0'),
        C                       => port_c1,
        CARRYIN                 => carry1,
        CARRYINSEL              => "00",
        CEA                     => '1',
        CEB                     => '1',
        CEC                     => '1',
        CECARRYIN               => '1',
        CECINSUB                => '1',
        CECTRL                  => '1',
        CEM                     => '1',
        CEP                     => '1',
        CLK                     => clk,
        OPMODE                  => opmode,
        PCIN                    => (others=>'0'),
        RSTA                    => '0',
        RSTB                    => '0',
        RSTC                    => '0',
        RSTCARRYIN              => '0',
        RSTCTRL                 => '0',
        RSTM                    => '0',
        RSTP                    => '0',
        SUBTRACT                => subtract1
      );
	  
	  
pci_size_z <= port_p1( 47 );

end generate;

gen_no_dsp48: if( is_dsp48=0 ) generate
	
pr_adr: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( p2='1' ) then
			port_p0( 19 downto 0 ) <= port_c0( 19 downto 0 ) + 1 after 1 ns;
		else
			port_p0( 19 downto 0 ) <= dsc_adr( 23 downto 4 ) after 1 ns;
		end if;
	end if;		
end process;
	

pr_size: process( clk ) begin
	if( rising_edge( clk ) ) then
		if( p2='1' ) then
			port_p1( 18 downto 0 ) <= port_c1( 18 downto 0 ) - 1 after 1 ns;
		else
			port_p1( 18 downto 0 ) <= '0' & dsc_size( 21 downto 4 ) after 1 ns;
		end if;
	end if;
end process;

pci_size_z <= port_p1( 18 );

end generate;	
	
gen_ram: for ii in 0 to 27 generate	  

ram0:	ram16x1d 
		port map(
			we 	=> reg41_wr,
			d 	=> port_p0(ii),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			spo	=> port_c0(ii),
			dpra0 => '0',
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '1'
		);

ram1:	ram16x1d 
		port map(
			we 	=> reg41_wr,
			d 	=> port_p1(ii),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			spo	=> port_c1(ii),
			dpra0 => '0',
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '1'
		);
		
end generate;		 

port_c0( 47 downto 28 ) <= (others=>'0');
port_c1( 47 downto 28 ) <= (others=>'0');




reg410_wr <= reg41_wr and n2;

ram2:	ram16x1d 
		port map(
			we 	=> reg410_wr,
			d 	=> dsc_size(0),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			spo	=> pci_rw,
			dpra0 => '0',
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '1'
		);

		
		
gen_ram_low: for ii in 0 to 2 generate	  

ram_low:	ram16x1d 
		port map(
			we 	=> reg41_wr,
			d 	=> dsc_adr(ii+1),
			wclk => clk,
			a0	=> dma_chn,
			a1	=> '0',
			a2	=> '0',
			a3	=> '0',
			spo	=> adr_low(ii),
			dpra0 => '0',
			dpra1 => '0',
			dpra2 => '0',
			dpra3 => '1'
		);

		
end generate;		 
		
end ctrl_dma_adr;
