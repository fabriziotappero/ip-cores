/*****************************************************
  Verify the Read/Write in ST Flash
*****************************************************/


task spi_test;
begin

 $display("############################################");
 $display("   Testing ST Flash Read/Write Access       ");
 $display("############################################");
 

  tb_top.spi_init(); // SPI Tb Init
  tb_top.spi_chip_no = 2'b00; // Select the Chip Select to zero
  // Write Enable command
  tb_top.spi_write_byte(8'h6); // Write Enable instruction
  tb_top.spi_sector_errase(24'h00);
  tb_top.spi_wait_busy;

  // Page Write
  tb_top.spi_write_byte(8'h6); // Write Enable instruction
  tb_top.spi_page_write(24'h00);
  tb_top.spi_wait_busy;

  // Page Read
  tb_top.spi_page_read_verify(24'h00); // Read and verify 256 Bytes


  tb_top.spi_tb_status; // SPI Tb Init
end
endtask
