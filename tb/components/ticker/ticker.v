module ticker;
  
  parameter interval  = 10000 ;
  parameter enable    = 1     ;
  
  always
  begin
    if ($time % interval == 0)
    begin
      if (enable)
        $display("Time has reached [%0t ps]", $time);
    end
    #1;
  end
  
endmodule
