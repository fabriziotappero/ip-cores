entity mux is
        port (
                a : in std_logic_vector(5 downto 0); 
                b : in std_logic_vector(5 downto 0);
                s : in std_logic;
                o : out std_logic_vector(5 downto 0);
            );
