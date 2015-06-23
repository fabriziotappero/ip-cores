library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity label8AndFeatures is
	generic( CODE_BITS : integer := 10;
				row : natural := 480;
				col : natural := 640);
				
	port (
		ip9 : in std_logic_vector(CODE_BITS-1 downto 0);
		ip8 : in std_logic_vector(CODE_BITS-1 downto 0);
		ip7 : in std_logic_vector(CODE_BITS-1 downto 0);
		ip6 : in std_logic_vector(CODE_BITS-1 downto 0);
		ibin : in std_logic;
		pdata_in : in std_logic_vector(7 downto 0);
		fsync_in : in std_logic;
		fsync_out : out std_logic;
		pdata_o : out std_logic_vector(CODE_BITS-1 downto 0) :=  (others => '0');
		rsync_in : in std_logic;
		rsync_out : out std_logic;
		Reset : in std_logic;
		pclk : in std_logic;
		featureDataStrobe 	: out std_logic;
		acknowledge : in std_logic;
		cntObjects : out std_logic_vector(9 downto 0);
		x_cog : out  std_logic_vector(16 downto 0);
		y_cog : out  std_logic_vector (16 downto 0)
	);
end label8AndFeatures;


architecture struct of label8AndFeatures is


signal a,b,dout,indexMax,equalcnt : std_logic_vector(9 downto 0):=  (others => '0');
signal readAddr: std_logic_vector(9 downto 0);
signal tableReady,tablePreset,we,computeDone : std_logic;
signal hit : std_logic_vector(CODE_BITS-1 downto 0);
signal selectspace : std_logic := '0';
signal pdata_osig : std_logic_vector(CODE_BITS-1 downto 0) :=  (others => '0');
signal pdata_delayed : std_logic_vector(7 downto 0);
signal eindex : std_logic_vector(CODE_BITS-1 downto 0);
signal compuCode : std_logic_vector(9 downto 0);			  
signal mergeEnable, compute : std_logic;
signal refa,refb:std_logic_vector(9 downto 0);
subtype col_range is natural range 0 to col ;
subtype row_range is natural range 0 to row + 1;

begin

	equtbl : entity work.equivalenceTable Port map
			( a 				=> a,	
           b 				=> b,	
		     c 				=> refa,--contents of memory locations are set for merging not just labels	
           d 				=> refb,	
			  we				=> we,	
			  readAddr		=> readAddr,	
           dout 			=> dout,	
			  equalcnt		=> equalcnt,
           fsync 			=> fsync_in,	
           tableReady	=> tableReady,	
			  tablePreset 	=> tablePreset,
			  space			=> selectspace,
			  reset			=> Reset,	
           clk 			=> pclk,
			  SetdoutrefA     => refa,
			  SetdoutrefB     => refb
			  );
	

		
	MAC : entity work.mac_module 
	       generic map( ROW=>row, COL=>col,CODE_BITS=>CODE_BITS)
	       Port Map
			(	code => pdata_osig,	
				fsync_in => fsync_in,
				rsync_in => rsync_in,
				Reset => reset,
				pclk => pclk,
				pdata_in => pdata_delayed,
			   tablePreset 	=> tablePreset,				
				divready_out => computeDone,
				selectspace	=> selectspace,
				y_cog => y_cog,
				compuCode => compuCode,
				mergeEnable => mergeEnable,
				compute => compute,
				x_cog => x_cog
			);
			
	Sequencer : entity work.compuSequencer Port map
			( clk => pclk,
           reset => fsync_in,
			  tableReady => tableReady,
			  computeDone => computeDone,
			  featureDataStrobe => featureDataStrobe,
			  acknowledge => acknowledge,
			  indexMax => indexMax,
           eqData => dout,
           eqAddress => readAddr,
           compuCode => compuCode,
			  cntObjects => cntObjects,
           mergeEnable => mergeEnable,
           compute => compute,
           tablePreset => tablePreset
			);
						a <= (others=>'0') when reset= '1' else --check all the conditions for labelling
						    ip6 when (ibin = '1' and ip7 /= 0 and ip6 /= 0) else
						    ip6 when (ibin = '1' and ip8 /= 0 and ip6 /= 0) else
						    ip6 when (ibin = '1' and ip9 /= 0 and ip6 /= 0) else
						    ip8 when (ibin = '1' and ip8 /= 0 and ip9 /= 0) else
						    ip7 when (ibin = '1' and ip7 /= 0 and ip9 /= 0) else
							 ip7 when (ibin = '1' and ip7 /= 0 and ip8 /= 0) else
							 ip6 when (ibin = '1' and ip7 /= 0 and ip6 /= 0) else
							 ip8 when (ibin = '1' and ip8 /= 0) else
							 ip6 when (ibin = '1' and ip6 /= 0)else
							 ip9 when (ibin=  '1' and ip9 /= 0) else
							 ip7 when (ibin=  '1' and ip7 /= 0) else
							 eindex when ibin='1' else
							 (others=> '0');
						 
						 b <=(others=>'0') when reset= '1' else 
						    ip7 when (ibin = '1' and ip7 /= 0 and ip6 /= 0) else
						    ip8 when (ibin = '1' and ip8 /= 0 and ip6 /= 0) else
						    ip9 when (ibin = '1' and ip9 /= 0 and ip6 /= 0) else
						    ip9 when (ibin = '1' and ip8 /= 0 and ip9 /= 0) else
						    ip9 when (ibin = '1' and ip7 /= 0 and ip9 /= 0) else
							 ip8 when (ibin = '1' and ip7 /= 0 and ip8 /= 0) else
							 ip7 when (ibin = '1' and ip7 /= 0 and ip6 /= 0) else
							 ip8 when (ibin = '1' and ip8 /= 0) else
							 ip6 when (ibin = '1' and ip6 /= 0) else
							 ip9 when (ibin=  '1' and ip9 /= 0) else
							 ip7 when (ibin=  '1' and ip7 /= 0) else
							 eindex when ibin='1' else
							 (others =>'0');
						 --eindex <= eindex+1 when (ibin = '1' and ip6 = 0 and ip7 = 0 and ip8=0 and ip9=0) ;
						 
						 
--						 pdata_o <= refa when (refa < refb) and ibin='1'   else
--                              refb when ibin ='1' else
--						            (others=>'0');
						    we <=   '1' when (ip6 /= 0 or ip7 /= 0 or ip8/=0 or ip9/=0) else
							         '0';
	
	label8: process(pclk,Reset) 
	-- This process performs 8-connectivity labeling of the binary input video stream on input port ibin
	-- Only the first pass of the labeling process is done. This means that the information stored in the 
	-- table of equvivalences must be read in order to identify all pixels belonging 
	-- to one single image component. The equvivalences are stored in block-RAMs through the ports of 
	-- equtbl : entity work.equivalenceTable. This entity actually contains two tables of equvivalences.
	-- One is written to during the labelling process and the other can be used for post processing when
	-- image component features are calculated.

	begin
	     if Reset = '1' then
			eindex <= conv_std_logic_vector(1,CODE_BITS);
			--a <= (others=>'0');
			--b <= (others=>'0');
			hit <= (others=>'0');
			--we  <= '0';
		elsif pclk'event and pclk = '1' then
				 
			--we  <= '0';
			if (ibin = '1' and ip6 = 0 and ip7 = 0 and ip8=0 and ip9=0) then
			eindex <= eindex+1 ;
			end if;
			if refa < refb and ibin='1' then
			   pdata_osig <= refa;
				elsif ibin='1' then
				pdata_osig <= refb;
				else
				pdata_osig <= (others => '0');
			end if;
			if fsync_in = '1' then
			   indexMax <= eindex;
				eindex <= conv_std_logic_vector(1,CODE_BITS);
				hit <= (others=>'0');
	           
	         end if;
				fsync_out <= fsync_in;
			     rsync_out <= rsync_in;
				  pdata_delayed <= pdata_in;				
				  end if;--pclk'event
	end process label8;

	pdata_o <= pdata_osig;
	
end struct;