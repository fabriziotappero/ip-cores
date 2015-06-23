library verilog;
use verilog.vl_types.all;
entity ac97_dma_req is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        cfg             : in     vl_logic_vector(7 downto 0);
        status          : in     vl_logic_vector(1 downto 0);
        full_empty      : in     vl_logic;
        dma_req         : out    vl_logic;
        dma_ack         : in     vl_logic
    );
end ac97_dma_req;
