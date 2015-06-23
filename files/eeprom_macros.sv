// Timing with undefined `DS1621_STANDARD ( more than 100kHz)

// for Opencores users:
// Delays are system bus specific. Adapt them to your system bus timing.
// Tasks are acceptable by both 24LC16B and DS1621S devices.
// "write/read" are the tasks from the bus interface
// (create your own interface or change the write read just to be the tasks).
// "data" is the value returned by the interface task.
// Format: Bit      2,      1,      0
//                  WP     SCL     SDA
//              if EEPROM
//              is present
//

task  iic__stop();
 #500  write( 3'b000 );
 #1100 write( 3'b010 );
 #900  write( 3'b011 );
endtask

task  iic_ctlop( bit [3:0] EE_or_DS, bit [2:0] blk_adr, bit op, output bit ACK );
 #1150 write( 3'b011 );
 #650  write( 3'b010 );
 #650  write( 3'b000 );
 #650  write( {2'b00, EE_or_DS[3]} );
 #650  write( {2'b01, EE_or_DS[3]} );
 #650  write( {2'b00, EE_or_DS[3]} );
 #650  write( {2'b00, EE_or_DS[2]} );
 #650  write( {2'b01, EE_or_DS[2]} );
 #650  write( {2'b00, EE_or_DS[2]} );
 #650  write( {2'b00, EE_or_DS[1]} );
 #650  write( {2'b01, EE_or_DS[1]} );
 #650  write( {2'b00, EE_or_DS[1]} );
 #650  write( {2'b00, EE_or_DS[0]} );
 #650  write( {2'b01, EE_or_DS[0]} );
 #650  write( {2'b00, EE_or_DS[0]} );
 #650  write( {2'b00, blk_adr[2]} );
 #650  write( {2'b01, blk_adr[2]} );
 #650  write( {2'b00, blk_adr[2]} );
 #650  write( {2'b00, blk_adr[1]} );
 #650  write( {2'b01, blk_adr[1]} );
 #650  write( {2'b00, blk_adr[1]} );
 #650  write( {2'b00, blk_adr[0]} );
 #650  write( {2'b01, blk_adr[0]} );
 #650  write( {2'b00, blk_adr[0]} );
 #650  write( {2'b00, op} );
 #650  write( {2'b01, op} );
 #650  write( 3'b001 );  // ACK check
 #1250 write( 3'b011 );  //
 #650  read( ACK );
 #650  write( 3'b000 );  // ACK end with SCL=0 & SDA=0 (hold time is 0 for devices on IIC)
 #650  write( 3'b001 );
endtask

task  iic_write( bit stop, bit [7:0] data, output bit ACK );
 #750  write( {2'b00, data[7]} );
 #650  write( {2'b01, data[7]} );
 #650  write( {2'b00, data[7]} );
 #650  write( {2'b00, data[6]} );
 #650  write( {2'b01, data[6]} );
 #650  write( {2'b00, data[6]} );
 #650  write( {2'b00, data[5]} );
 #650  write( {2'b01, data[5]} );
 #650  write( {2'b00, data[5]} );
 #650  write( {2'b00, data[4]} );
 #650  write( {2'b01, data[4]} );
 #650  write( {2'b00, data[4]} );
 #650  write( {2'b00, data[3]} );
 #650  write( {2'b01, data[3]} );
 #650  write( {2'b00, data[3]} );
 #650  write( {2'b00, data[2]} );
 #650  write( {2'b01, data[2]} );
 #650  write( {2'b00, data[2]} );
 #650  write( {2'b00, data[1]} );
 #650  write( {2'b01, data[1]} );
 #650  write( {2'b00, data[1]} );
 #650  write( {2'b00, data[0]} );
 #650  write( {2'b01, data[0]} );
 #650  write( {2'b00, data[0]} );
 #650  write( 3'b001 );  // ACK check
 #650  write( 3'b011 );  //
 #650  read( ACK );
 #650  write( 3'b000 );  // ACK end with SCL=0 & SDA=0 (hold time is 0 for devices on IIC)
    if ( stop )  iic__stop;
    else
 #650  write( 3'b001 );
endtask

task  iic__read( bit stop, output bit [7:0] data );
bit  data_bit;
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
       write( 3'b001 );
 #1250 write( 3'b011 );
 #650  read( data_bit );  data = {data[6:0], data_bit};
    if ( stop ) begin
 #650  write( 3'b001 ); // NO ACK
 #1250 write( 3'b011 );
       iic__stop;
    end
    else begin
 #650  write( 3'b000 ); // ACK
 #1250 write( 3'b010 );
 #650  write( 3'b000 );
 #650  write( 3'b001 );
    end
endtask
