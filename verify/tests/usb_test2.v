`define usbbfm  tb.u_usb_agent.bfm_inst
task usb_test2;

reg [6:0] address;
reg [3:0] endpt;
reg [3:0] Status;
 reg [31:0] ByteCount;

  integer    i,j;
  reg [7:0]  startbyte;
  reg [15:0] mask;
  integer    MaxPktSize;
  reg [3:0]  PackType;


parameter  MYACK   = 4'b0000,
           MYNAK   = 4'b0001,
           MYSTALL = 4'b0010,
           MYTOUT  = 4'b0011,
           MYIVRES = 4'b0100,
           MYCRCER = 4'b0101;

     begin
     address = 7'b000_0001;
     endpt   = 4'b0000;

    $display("%0d: USB Reset  -----", $time);
    `usbbfm.usb_reset(48);

    $display("%0d: Set Address = 1 -----", $time);
    `usbbfm.SetAddress (address);
    `usbbfm.setup(7'h00, 4'h0, Status);
    `usbbfm.printstatus(Status, MYACK);
    `usbbfm.status_IN(7'h00, endpt, Status);
    `usbbfm.printstatus(Status, MYACK);
    #5000;
  
    $display("%0d: Set configuration  -----", $time);
    `usbbfm.SetConfiguration(2'b01);
    `usbbfm.setup(address, 4'b0000, Status);
    `usbbfm.printstatus(Status, MYACK);
    `usbbfm.status_IN(address, 4'b0000, Status);
    `usbbfm.printstatus(Status, MYACK);
    #2000;

    $display("%0d: Configuration done !!!!!!", $time);
     
   // write UART  registers through USB
	
      //////////////////////////////////////////////////////////////////
	
	
    // register word write
    $display("%0d: Performing Register Word Write------------", $time);
    `usbbfm.VenRegWordWr (address, 32'h8, 32'h123);
    #500;

    // register word Read
    $display("%0d: Performing Register Word Read------------", $time);
    `usbbfm.VenRegWordRdCmp (address, 32'h8, 32'h123, ByteCount);
    #500


  
    $display ("USB doing register writes and reads to USB block end \n");

    tb.test_control.finish_test;
  end

endtask
