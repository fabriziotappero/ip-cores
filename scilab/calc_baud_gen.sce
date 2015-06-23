// a short script to calaculate the baud rate generation parameters for the 
// UART to Bus core 
mode(-1)

// define the GCD function since Scilab prefers to use a different function as gcd 
function x = gcdn(a,b)
x = zeros(length(b),length(a));
for n=1:length(a),
	for m=1:length(b),
		x=a(n);
		y=b(m);
		while y~=0
			r=modulo(x,y);
			x=y;
			y=r;
		end 
		x(m,n) = x;
	end 
end 
endfunction 

// request the required clock rate and baud rate parameters 
dig_labels = ["Clock Frequency in MHz"; "UART Baud Rate in bps"];
default_val = ["40"; "115200"];
params = evstr(x_mdialog("Enter Core Parameters", dig_labels, default_val));

// extract the parameters 
global_clock_freq = params(1)*1e6;
baud_rate = params(2);

// calculate the baud rate generator parameters 
D_BAUD_FREQ = 16*baud_rate / gcdn(global_clock_freq, 16*baud_rate);
D_BAUD_LIMIT = (global_clock_freq / gcdn(global_clock_freq, 16*baud_rate)) - D_BAUD_FREQ;

// print the values to the command window 
printf("Calculated core baud rate generator parameters:\n");
printf("    D_BAUD_FREQ  = 12''d%d\n", D_BAUD_FREQ);
printf("    D_BAUD_LIMIT = 16''d%d\n", D_BAUD_LIMIT);

// open a message with the calculated values 
mes_str = ["Calculated core baud rate generator parameters:"; ...
           "    D_BAUD_FREQ  = "+string(D_BAUD_FREQ); ...
           "    D_BAUD_LIMIT = "+string(D_BAUD_LIMIT); ...
           ""; ...
           "The verilog definition can be copied from the following lines:"; ...
           "`define D_BAUD_FREQ  12''d"+string(D_BAUD_FREQ); ...
           "`define D_BAUD_LIMIT 16''d"+string(D_BAUD_LIMIT);
           ];
messagebox(mes_str);
