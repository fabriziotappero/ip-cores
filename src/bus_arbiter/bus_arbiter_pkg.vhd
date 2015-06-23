package bus_arbiter_pkg is

type vci_master is
	record 
		dev_clk   : array(integer range 0 to dev_count-1) of std_logic;  --clock option
		dev_addr  : array(integer range 0 to dev_count-1) of std_logic_vector(23 downto 0);
		dev_do    : array(integer range 0 to dev_count-1) of std_logic_vector(15 downto 0);
		dev_di    : array(integer range 0 to dev_count-1) of std_logic_vector(15 downto 0);
     
		dev_wr    : array(integer range 0 to dev_count-1) of std_logic;  --write not read signal
		dev_val   : array(integer range 0 to dev_count-1) of std_logic;
		dev_ack   : array(integer range 0 to dev_count-1) of std_logic;
		
	end record;




end bus_arbiter_pkg;