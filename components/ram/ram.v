module ram (clk, reset, enable, rw_mask, rd, wr, address, data_in, data_out);
  
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
  ram_mk_x_n #(Mk, N) ram_1k_x_16_0 (
                                      clk       ,
                                      reset     ,
                                      enable    ,
                                      rw_mask   ,
                                      rd        ,
                                      rw        ,
                                      address   ,
                                      data_in   ,
                                      data_out
                                    );
  
endmodule
