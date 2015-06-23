module rom (clk, reset, enable, rw_mask, rd, wr, address, data_in, data_out);
  
  parameter Mk  =  1;
  parameter N   = 16;
   
  input                 clk       ;
  input                 reset     ;
  input                 enable    ;
  input   [N-1:0]       rw_mask   ;
  input   [(Mk*10-1):0] address   ;
  input                 rd        ;
  input                 wr        ;
  input   [N-1:0]       data_in   ;
  output  [N-1:0]       data_out  ;
  
  // use fixed size rom
  //rom_1kx16 rom_1kx16_inst0 ();
  
  // OR
  
  // use parameterised rom
  ram_mk_x_n #(Mk, N) rom_mk_x_n_0  (
                                      clk       ,
                                      reset     ,
                                      enable    ,
                                      rw_mask   ,
                                      rd        ,
                                      1'b0      , // no writes allowed
                                      address   ,
                                      data_in   ,
                                      data_out
                                    );
                              
  initial
  begin
    $readmemh("rom_data.vh", rom_mk_x_n_0.mem);
  end
endmodule
