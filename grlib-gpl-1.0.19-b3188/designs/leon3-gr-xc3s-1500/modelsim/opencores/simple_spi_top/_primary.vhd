library verilog;
use verilog.vl_types.all;
entity simple_spi_top is
    port(
        prdata_o        : out    vl_logic_vector(7 downto 0);
        pirq_o          : out    vl_logic;
        sck_o           : out    vl_logic;
        mosi_o          : out    vl_logic;
        ssn_o           : out    vl_logic_vector(7 downto 0);
        pclk_i          : in     vl_logic;
        prst_i          : in     vl_logic;
        psel_i          : in     vl_logic;
        penable_i       : in     vl_logic;
        paddr_i         : in     vl_logic_vector(2 downto 0);
        pwrite_i        : in     vl_logic;
        pwdata_i        : in     vl_logic_vector(7 downto 0);
        miso_i          : in     vl_logic
    );
end simple_spi_top;
