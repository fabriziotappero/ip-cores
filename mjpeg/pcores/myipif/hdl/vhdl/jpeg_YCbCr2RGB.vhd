------------------------------------------------------------------
-- Two clock cycles delay
--
-- TODO: 
-- - remove reset ???
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jpeg_YCbCr2RGB is
	port(
		Clk			: in std_logic;
		reset_i		: in std_logic;
		
		context_i	: in  std_logic_vector(3 downto 0);
		Y_i			: in std_logic_vector(8 downto 0);
		Cb_i			: in std_logic_vector(8 downto 0);
		Cr_i			: in std_logic_vector(8 downto 0);
		
		context_o	: out  std_logic_vector(3 downto 0);
		R_o			: out std_logic_vector(7 downto 0);
		G_o			: out std_logic_vector(7 downto 0);
		B_o			: out std_logic_vector(7 downto 0);

		-- flow control
		datavalid_i	: in std_logic;
		datavalid_o	: out std_logic;
		ready_i		: in  std_logic;
		ready_o		: out std_logic
	);
end entity jpeg_YCbCr2RGB; 



architecture IMP of jpeg_YCbCr2RGB is

	signal datavalid, datavalid_D : std_logic := '0';
	signal ready : std_logic := '0';
	signal ce : std_logic :='1';
	signal reset : std_logic :='1';
	
	signal context, context_D : std_logic_vector(3 downto 0) := (others=>'0'); 
	signal R, R_D, G, G_D, B, B_D : std_logic_vector(7 downto 0) := (others=>'0'); 
	signal tmp_R, tmp_G, tmp_B : integer := 0;
	signal tmp_R_D, tmp_G_D, tmp_B_D : integer := 0;
 	signal Y, Cb, Cr :  std_logic_vector(7 downto 0) := (others=>'0'); 

begin

	process(Y_i, Cb_i, Cr_i, R, G, B)
		variable tmp_Y : integer := 0;
		variable int_Y, int_Cb, int_Cr : integer := 0; 
	begin

		-- level shift and convertion to integer
		-- 8-bit may (intentionally) overflow here
		int_Y  := conv_integer(signed(Y_i));
		int_Cb := conv_integer(signed(Cb_i));
		int_Cr := conv_integer(signed(Cr_i));
	
		-- to use integer arithmetic
		tmp_Y := 1024*(int_Y+128);

		-- YCbCr2RBG 
		tmp_R_D <= tmp_Y +                 1436*(int_Cr);
		tmp_G_D <= tmp_Y -  352*(int_Cb) -  731*(int_Cr);
		tmp_B_D <= tmp_Y + 1815*(int_Cb);

	end process;


	-- one additional clock cycle to meet timing constraints on the xup board
	process(Clk)
	begin
		if rising_edge(Clk) then
			if ce='1' then
				tmp_R <= tmp_R_D;
				tmp_G <= tmp_G_D;
				tmp_B <= tmp_B_D;
			end if;
		end if;
	end process;



	process(tmp_R, tmp_G, tmp_B)
		variable tmp_R2, tmp_G2, tmp_B2 : integer := 0;
	begin
		tmp_R2 := tmp_R;
		tmp_G2 := tmp_G;
		tmp_B2 := tmp_B;

		-- check boundaries
		if(tmp_R<0) then
			tmp_R2 := 0;
		elsif(tmp_R>255*1024) then
			tmp_R2 := 255*1024;
		end if;
		if(tmp_G<0) then
			tmp_G2 := 0;
		elsif(tmp_G>255*1024) then
			tmp_G2 := 255*1024;
		end if;
		if(tmp_B<0) then
			tmp_B2 := 0;
		elsif(tmp_B>255*1024) then
			tmp_B2 := 255*1024;
		end if;
	
		R_D <= conv_std_logic_vector(tmp_R2/1024, 8);
		G_D <= conv_std_logic_vector(tmp_G2/1024, 8);
		B_D <= conv_std_logic_vector(tmp_B2/1024, 8);
	
	end process;


	-- flowcontroll
	ready_o		<= ready_i;
	ce 			<= ready_i;

	process(Clk)
	begin
		if rising_edge(Clk) then
				context		<= context_i;
				context_o	<= context;
			if reset_i ='1' then
				context		<= (others=>'0');
				context_o	<= (others=>'0');
				datavalid	<= '0';
				datavalid_o	<= '0';
			elsif ce='1' then
				datavalid	<= datavalid_i;	
				datavalid_o	<= datavalid;	
				R_o <= R_D;
				G_o <= G_D;
				B_o <= B_D;
			end if;	
		end if;
	end process;

end IMP;
