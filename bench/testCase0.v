// ---------------------------------- testcase0.v ----------------------------
`include "timescale.v"
`include "usbHostSlave_h.v"
`include "usbHostControl_h.v"
`include "usbHostSlaveTB_defines.v"

module testCase0();

reg ack;
reg [7:0] data;
reg [15:0] dataWord;
reg [7:0] dataRead;
reg [7:0] dataWrite;
reg [7:0] USBAddress;
reg [7:0] USBEndPoint;
reg [7:0] transType;
integer dataSize;
integer i;
integer j;

initial
begin
  $write("\n\n");
  #1000;

  testHarness.u_wb_master_model.wb_read(1, `SIM_HOST_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_VERSION_REG , dataRead);
  $display("Host Version number = 0x%0x\n", dataRead);
  testHarness.u_wb_master_model.wb_read(1, `SIM_SLAVE_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_VERSION_REG , dataRead);
  $display("Slave Version number = 0x%0x\n", dataRead);

  $write("Testing host register read/write  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  $write("--- PASSED\n");
  $write("Testing slave register read/write  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h70);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h70);
  $write("--- PASSED\n");

  $write("Testing register reset  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_CONTROL_REG , 8'h2);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_CONTROL_REG , 8'h2);
  #1000;
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h00);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h00);
  $write("--- PASSED\n");
  #1000;

  $write("Configure host and slave mode.  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_CONTROL_REG , 8'h1);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `HOST_SLAVE_CONTROL_BASE+`HOST_SLAVE_CONTROL_REG , 8'h0);

  $write("Connect full speed  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h70);
  #20000;
  //expecting connection event interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  //expecting full speed connect
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_CONNECT_STATE_REG , 6'h02);
  //expecting change in reset state event, and change in vbus state event
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h24);
  //expecting full speed connect and vbus present
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_LINE_STATUS_REG , 8'h06);
  $write("--- PASSED\n");

  $write("Cancel interrupts  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h24);
  //expecting all interrupts cancelled
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h00);
  //expecting all interrupts cancelled
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h00);
  $write("--- PASSED\n");
  #1000;

  $write("Disconnect  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h30);
  #10000;
  //expecting connection event interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  //expecting disconnect state
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_CONNECT_STATE_REG , 8'h00);
  //expecting change in reset state event
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  //expecting vbus present, and disconnect state
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_LINE_STATUS_REG , 8'h04);
  //cancel interrupts
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  $write("--- PASSED\n");


  $write("Connect full speed  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h70);
  #20000;
  //expecting connection event interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  //expecting full speed connect
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_CONNECT_STATE_REG , 8'h02);
  //expecting change in reset state event
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  //expecting full speed connect and vbus present
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_LINE_STATUS_REG , 8'h06);
  //cancel interrupts
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h00);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h00);
  $write("--- PASSED\n");
  #1000;


  $write("Host forcing reset  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h1c);
  #20000;
  //expecting change in reset state event
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  //expecting vbus present, and disconnect state
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_LINE_STATUS_REG , 8'h04);
  //cancel interrupt
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  $write("--- PASSED\n");

  $write("Connect full speed  ");
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_LINE_CONTROL_REG , 8'h18);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h70);
  #20000;
  //expecting no host interrupts
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h00);
  //expecting full speed connect
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`RX_CONNECT_STATE_REG , 8'h02);
  //expecting change in reset state event
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  //expecting full speed connect and vbus present
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_LINE_STATUS_REG , 8'h06);
  //cancel interrupts
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h04);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h04);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h00);
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h00);
  $write("--- PASSED\n");
  #1000;

  $write("Trans test: Device address = 0x00, 2 byte SETUP transaction to Endpoint 0. ");
  USBAddress = 8'h00;
  USBEndPoint = 8'h00;
  transType = `SETUP_TRANS;
  dataSize = 2;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h71);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_ADDRESS , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`EP0_CTRL_REG , 8'h03);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  data = 8'h00;
  for (i=0; i<dataSize; i=i+1) begin
    testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , data);
    data = data + 1'b1;
  end
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #20000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h01);
  //endpoint enabled, and endpoint ready cleared
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`EP0_CTRL_REG , 8'h01);
  $write("Checking receive data  ");
  data = 8'h00;
  for (i=0; i<dataSize; i=i+1) begin
    testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `EP0_RX_FIFO_BASE + `FIFO_DATA_REG , data);
    data = data + 1'b1;
  end
  $write("--- PASSED\n");

  $write("Trans test: Device address = 0x5a, 20 byte OUT DATA0 transaction to Endpoint 1. ");
  USBAddress = 8'h5a;
  USBEndPoint = 8'h01;
  transType = `OUTDATA0_TRANS;
  dataSize = 20;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h71);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_ADDRESS , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`EP1_CTRL_REG , 8'h03);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  data = 8'h00;
  for (i=0; i<dataSize; i=i+1) begin
    testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HOST_TX_FIFO_BASE + `FIFO_DATA_REG , data);
    data = data + 1'b1;
  end
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #20000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h01);
  //endpoint enabled, and endpoint ready cleared
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`EP1_CTRL_REG , 8'h01);
  $write("Checking receive data  ");
  data = 8'h00;
  for (i=0; i<dataSize; i=i+1) begin
    testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `EP1_RX_FIFO_BASE + `FIFO_DATA_REG , data);
    data = data + 1'b1;
  end
  $write("--- PASSED\n");

  $write("Trans test: Device address = 0x01, 2 byte IN transaction to Endpoint 2. ");
  USBAddress = 8'h01;
  USBEndPoint = 8'h02;
  transType = `IN_TRANS;
  dataSize = 2;
  //enable endpoint, and make ready
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_CONTROL_REG , 8'h71);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_ADDRESS , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`EP2_CTRL_REG , 8'h03);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ADDR_REG , USBAddress);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_ENDP_REG , USBEndPoint);
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_TRANS_TYPE_REG , transType);
  data = 8'h00;
  for (i=0; i<dataSize; i=i+1) begin
    testHarness.u_wb_master_model.wb_write(1, `SIM_SLAVE_BASE_ADDR + `EP2_TX_FIFO_BASE + `FIFO_DATA_REG , data);
    data = data + 1'b1;
  end
  testHarness.u_wb_master_model.wb_write(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`TX_CONTROL_REG , 8'h01);
  #20000
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HCREG_BASE+`INTERRUPT_STATUS_REG , 8'h01);
  //expecting transaction done interrupt
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`SC_INTERRUPT_STATUS_REG , 8'h01);
  //endpoint enabled, and endpoint ready cleared
  testHarness.u_wb_master_model.wb_cmp(1, `SIM_SLAVE_BASE_ADDR + `SCREG_BASE+`EP2_CTRL_REG , 8'h01);
  $write("Checking receive data  ");
  data = 8'h00;
  for (i=0; i<dataSize; i=i+1) begin
    testHarness.u_wb_master_model.wb_cmp(1, `SIM_HOST_BASE_ADDR + `HOST_RX_FIFO_BASE + `FIFO_DATA_REG , data);
    data = data + 1'b1;
  end
  $write("--- PASSED\n");

  $write("Finished all tests\n");
  $stop;	

end

endmodule

