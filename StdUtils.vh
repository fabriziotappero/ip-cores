/*
    standart utils verilog include
*/

function integer clog2 (input integer num); // this function calculates ceil(log2(num))
begin    
    num = num - 1;                          // without this statement clog2(32) will be 6 but must be 5    
    for (clog2 = 0; num > 0; clog2 = clog2 + 1)        
        num = num >> 1;
end
endfunction
