library verilog;
use verilog.vl_types.all;
entity ac97_in_fifo is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        en              : in     vl_logic;
        mode            : in     vl_logic_vector(1 downto 0);
        din             : in     vl_logic_vector(19 downto 0);
        we              : in     vl_logic;
        dout            : out    vl_logic_vector(31 downto 0);
        re              : in     vl_logic;
        status          : out    vl_logic_vector(1 downto 0);
        full            : out    vl_logic;
        empty           : out    vl_logic
    );
end ac97_in_fifo;
