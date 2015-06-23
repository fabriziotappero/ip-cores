// ------------------ multiByteReadWrite.v ----------------------
`include "timescale.v"
`include "i2cSlaveTB_defines.v"


module multiByteReadWrite();
reg ack;
reg [31:0] readData;
reg [7:0] dataByteRead;
//reg [7:0] dataMSB;

// ------------------ write ----------------------
task write;
input [7:0] i2cAddr;
input [7:0] regAddr;
input [31:0] data;
input stop;

begin
  $write("I2C Write: At [0x%0x] = 0x%0x\n", regAddr, data);

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, i2cAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );

  //slave reg address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, regAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h10); //WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Slave reg address sent, SR = 0x%x\n", dataByteRead );

  //data[31:24]
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, data[31:24]);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h10); //WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[31:24] sent, SR = 0x%x\n", dataByteRead );

  //data[23:16]
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, data[23:16]);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h10); //WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[23:16] sent, SR = 0x%x\n", dataByteRead );

  //data[15:8]
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, data[15:8]);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h10); //WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[15:8] sent, SR = 0x%x\n", dataByteRead );

  //data[7:0]
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, data[7:0]);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, stop, 6'b010000}); //STO?, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[7:0] sent, SR = 0x%x\n", dataByteRead );

end
endtask

// ------------------ read ----------------------
task read;
input [7:0] i2cAddr;
input [7:0] regAddr;
input [31:0] expectedData;
output [31:0] data;
input stop;

begin

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, i2cAddr);  //write
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );
  #5000;

  //slave reg address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, regAddr);
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, stop, 6'b010000}); //STO?, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Slave reg address sent, SR = 0x%x\n", dataByteRead );
  #5000;

  //i2c address
  testHarness.u_wb_master_model.wb_write(1, `TXR_REG, {i2cAddr[7:1], 1'b1}); //read
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h90); //STA, WR
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("I2C device address sent, SR = 0x%x\n", dataByteRead );

  //data[31:24]
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h20); //RD, ACK
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[31:24] rxed, SR = 0x%x\n", dataByteRead );
  testHarness.u_wb_master_model.wb_read(1, `RXR_REG, readData[31:24]);

  //data[23:16]
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h20); //RD, ACK
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[23:16] rxed, SR = 0x%x\n", dataByteRead );
  testHarness.u_wb_master_model.wb_read(1, `RXR_REG, readData[23:16]);

  //data[15:8]
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , 8'h20); //RD, ACK
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[15:8] rxed, SR = 0x%x\n", dataByteRead );
  testHarness.u_wb_master_model.wb_read(1, `RXR_REG, readData[15:8]);

  //data[7:0]
  testHarness.u_wb_master_model.wb_write(1, `CR_REG , {1'b0, 1'b0, 6'b101000}); //STO, RD, NAK
  testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  while (dataByteRead[1] == 1'b1) //while trans in progress
    testHarness.u_wb_master_model.wb_read(1, `SR_REG , dataByteRead);
  //$write("Data[7:0] rxed, SR = 0x%x\n", dataByteRead );
  testHarness.u_wb_master_model.wb_read(1, `RXR_REG, readData[7:0]);

  data = readData; 
  if (data != expectedData) begin
    $write("***** I2C Read ERROR: At 0x%0x. Expected 0x%0x, got 0x%0x\n", regAddr, expectedData, data);
    $stop;
  end
  else
    $write("I2C Read: At [0x%0x] = 0x%0x\n", regAddr, data);
end
endtask

endmodule

