/* Add 
	"`define ADD_FUNCTION "
	 before calling the function `include "../my_function.v".   
*/

`ifdef ADD_FUNCTION 
/*****************************
extract the nth value of an string as a decemila value. the values inside
the string parameter must be seperated by "," e.g 
	parameter mystring = "12,3,8"
then extract_value(mystring,2) is integer 12
*****************************/
	

	function integer extract_value;
		input reg[1000:0] port_size_string;
		input integer value_loc; 
	
		integer end_char;
		integer i,j,width;
		reg[7:0] tmp;
		reg[1000:0] buffer;
		begin 
		width=0;
		i=0;
		j=0;
		if(value_loc>0) begin //locate the start ',' 
			while(j<value_loc) begin
				buffer=(port_size_string >>(i*8));
				tmp = buffer[7:0];
				if(tmp ==",") begin  
					j=j+1'b1;
				end
				i=i+1'b1;
			end//while
		end
		end_char=0;
		j=0;
		while(end_char==0)begin
			buffer=(port_size_string >>(i*8));
			tmp = buffer[7:0];
			if(tmp =="," || tmp ==0) begin
				end_char=1;
			end else begin 
				width= (j==0)? tmp-"0" : width +  ((j*10)*(tmp-"0"));
			end
			i=i+1'b1;
			j=j+1'b1;
		 end//while
		extract_value = width;
		end
	endfunction

/*****************************

return the sum of all values in string

*****************************/

	
	function integer sum_of_all;
		input reg[1000:0] port_size_string;
		integer total_port_num;
		integer i;
		begin 
			total_port_num=number_of_port(port_size_string) ;
			sum_of_all=0;
			for (i=0; i< total_port_num; i=i+1'b1)	begin 
				sum_of_all = sum_of_all+ extract_value(port_size_string,i);
			end//for
		end
	endfunction	
	
	function integer start_loc;
		input reg[1000:0] port_size_string;
		input integer value_num;
		integer i;
		begin 
			start_loc=0;
			for (i=0; i< value_num; i=i+1'b1)	begin 
				start_loc = start_loc + extract_value(port_size_string,i);
			end//for
		end
	endfunction	

	
	
	function integer number_of_port;
		input reg[1000:0] port_size_string;
		integer i;
		begin 
			number_of_port=1;
			while(port_size_string[7:0]!=8'h0) begin 
				if	(port_size_string[7:0]==",")	number_of_port=number_of_port+1'b1;
				port_size_string	=	port_size_string >>8;
			end//while
		end
	endfunction	
	
	
	
	
	/************************
	parameter DEV_EN_ARRAY	="IPx_y:[the specefic value for IP(x,y)];Def:[default value for the rest of IPs]"
	ip_value(ip_x,ip_y,DEV_EN_ARRAY) : will extract the defined value for IP(x,y)
	
	eg:
		parameter O_PORT_WIDTH_ARRAY	="IP0_0:7,7,7,7,7,7,7,7;Def:1";
		parameter O_PORT_WIDTH_0 = ip_value(0,0,O_PORT_WIDTH_ARRAY); // will load "7,7,7,7,7,7,7,7" in O_PORT_WIDTH_0
		parameter O_PORT_WIDTH_5 = ip_value(5,0,O_PORT_WIDTH_ARRAY); // will load "1" in O_PORT_WIDTH_5
	
	**************************/
	
	
function integer string_size;
	input reg [1000:0] string_i;
	begin
	string_size = 0;
	while ( string_i[7:0]!= 0) begin 
		string_size = string_size+ 1'b1;
		string_i = string_i	>> 8;
	end 
	end
endfunction

function reg [1000:0] mask;
	input integer size;
	begin 
	mask=0;
	while (size >0) begin 
		mask = mask<<8;
		mask = mask +8'hFF;
		size = size-1'b1;
	end
	end
endfunction


function integer find_loc;
	input reg [1000:0] string_i;
	input reg [1000:0] array;
	input integer		end_loc;
	integer str_size;
	integer loc;
	begin
		loc=0;
		str_size = string_size(string_i);
		find_loc = -1;
		while ( array[7:0]!=0 && loc!=end_loc) begin 
				  if((array & mask(str_size)) == (string_i & mask(str_size))) find_loc=loc;
				  array = array >> 8;
				  loc =  loc +1'b1;
		end	
	end  
endfunction

function  reg [1000:0] cut_string;
	input reg  [1000:0] string_i;
	input integer start_loc;
	input integer end_loc;
	integer tmp;
	begin 
		if(end_loc < start_loc  ) begin //swap
			tmp=start_loc;
			start_loc = end_loc;
			end_loc	= tmp;
		end
		string_i = string_i & mask(end_loc);
		string_i = string_i >> (start_loc*8);
		cut_string = string_i;
	end
endfunction



function	reg [1000:0] ip_value;	
	input integer ip_x,ip_y;
	input reg [1000:0] ip_array;
	reg  [1000:0] ip_name;
	integer	tmp,i,ip_loc,end_ip_value,size;
	begin 
		//make IPnum string
		ip_name = "IP";
		i=1;
		while(i)begin 
			tmp= ip_x;
			i=0;
			while(tmp>9)begin	tmp=  tmp/10; i=i+1; end
			ip_name = (ip_name << 8 )+ tmp+"0";
			ip_x = ip_x % (10**i);
		end
		ip_name = (ip_name << 8 )+ "_";
		i=1;
		while(i)begin 
			tmp= ip_y;
			i=0;
			while(tmp>9)begin	tmp=  tmp/10; i=i+1; end
			ip_name = (ip_name << 8 )+ tmp+"0";
			ip_y = ip_y % (10**i);
		end
		 ip_name = (ip_name << 8 )+ ":";
		 size=string_size(ip_array);
		 ip_loc= find_loc (ip_name,ip_array,size);
		 if(ip_loc == -1) ip_loc= find_loc("Def:",ip_array,size);
		 end_ip_value =find_loc (";",ip_array,ip_loc);
		 ip_value = cut_string(ip_array,ip_loc,end_ip_value+1);
		
	end
endfunction 
		
function integer s2i;
	input [1000:0] string_i;
	integer  i;
	begin
	s2i =0;
	i=0;
	while (string_i [7:0]!=0) begin 
		s2i = s2i+(string_i [7:0]-"0")* (10**i);
		string_i = string_i >> 8;
		i=i+1'b1;
	end
	end
endfunction	


function integer start_loc_in_array;
	input integer	ip_x,ip_y;
	input integer  max_x_num;
	input [1000: 0] string_i;
	integer x,y,sum;
	begin 
		start_loc_in_array =0;
		for (y=0; y<ip_y; y=y+1) begin 
			for(x=0; x<max_x_num; x=x+1 ) begin 
			  sum = sum_of_all(ip_value(x,y,string_i));
			  // if(sum==0) sum =1;
					start_loc_in_array = start_loc_in_array + sum;
			end
		end//for y
		for(x=0; x<ip_x; x=x+1 ) begin 
		    sum = sum_of_all(ip_value(x,y,string_i));
			  // if(sum==0) sum =1;
				start_loc_in_array = start_loc_in_array + sum;
		end
	end
endfunction


function integer end_loc_in_array;
	input integer	ip_x,ip_y;
	input integer  max_x_num;
	input [1000: 0] string_i;
	integer sum;
	begin 
			end_loc_in_array = start_loc_in_array(ip_x,ip_y,max_x_num,string_i);
			sum = sum_of_all(ip_value(ip_x,ip_y,string_i));
			if(sum==0) sum =1;
			end_loc_in_array = end_loc_in_array + sum-1;
	end
endfunction



`endif
