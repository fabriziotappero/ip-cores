

// Code for Fast Hadamhard Transforms
// Developed by Kaushal D. Buch
// March, 2007.


module fht ( clk, reset, data_i , data_o );


input clk,reset ;
input [7:0] data_i ;

output [7:0] data_o ;


wire clk,reset ;
wire [7:0] data_i,comp ;

reg [7:0] data_o ;


reg [7:0] data_d,a,b,data_od,a_d,b_d,comp_d,temp_d,temp ;
reg [1:0] cnt ;
reg data_valid ;

always@(posedge clk or negedge reset)
begin
  if(!reset)
  begin
    data_d  <= 'b0 ;
    comp_d  <= 'b0 ;
    temp_d  <= 'b0 ;
  end
  else
  begin
    data_d  <= data_i ;
    comp_d  <= comp ; 
    temp_d  <= temp ;
  end
end

always@(posedge clk or negedge reset)
begin
  if(!reset)
  begin
    cnt     <= 'b0 ;
  end
  else if(cnt < 2'b11)
  begin
    cnt     <= cnt + 'b1 ;
  end
  else
  begin
    cnt     <= 'b0 ;
  end
end


always@(cnt or data_d or a or b or temp_d)
begin
  case(cnt)
  2'b00 : begin
	    temp  =  data_d  ;
	    data_valid = 'b0 ;
	  end

  2'b01 : begin
	    temp  =  comp_d  ;
	    data_valid = 'b0 ;
	  end
	  
  2'b10 : begin
	    temp  =  comp_d  ;
	    data_valid = 'b1 ;
	  end
  default : begin
	    temp = temp_d    ;
	    data_valid = 'b0 ;
            end
  endcase
end

assign comp = {temp[6] - temp[7], temp[4] - temp[5], temp[2] - temp[3],
  temp[0] - temp[1], temp[6] + temp[7], temp[4] + temp[5], temp[2]
  + temp[3], temp[0] + temp[1]} ;

always@(posedge clk or negedge reset)
begin
  if(!reset)
  begin
    data_o  <= 'b0 ;
  end
  else if(data_valid)
  begin
    data_o  <= temp ;
  end
end

endmodule




  
 
