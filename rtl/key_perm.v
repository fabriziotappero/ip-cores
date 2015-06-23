
`include "../bench/timescale.v"

// this module do a key 64bits perm
// author: mengxipeng
//              mengxipeng@gmail.com


module key_perm(i_key,o_key);
    input   [63:0] i_key;                
    output  [63:0] o_key;

    assign o_key={ 
                        i_key[6'h1b],i_key[6'h20],i_key[6'h09],i_key[6'h37],
                        i_key[6'h29],i_key[6'h0d],i_key[6'h3e],i_key[6'h08],
                        i_key[6'h02],i_key[6'h0c],i_key[6'h27],i_key[6'h25],
                        i_key[6'h12],i_key[6'h0e],i_key[6'h38],i_key[6'h35],
                        i_key[6'h18],i_key[6'h03],i_key[6'h34],i_key[6'h30],
                        i_key[6'h2f],i_key[6'h3d],i_key[6'h2a],i_key[6'h22],
                        i_key[6'h0a],i_key[6'h1f],i_key[6'h26],i_key[6'h06],
                        i_key[6'h15],i_key[6'h3a],i_key[6'h14],i_key[6'h1a],
                        i_key[6'h2c],i_key[6'h19],i_key[6'h11],i_key[6'h0f],
                        i_key[6'h01],i_key[6'h21],i_key[6'h2e],i_key[6'h3f],
                        i_key[6'h28],i_key[6'h07],i_key[6'h0b],i_key[6'h16],
                        i_key[6'h00],i_key[6'h23],i_key[6'h2b],i_key[6'h17],
                        i_key[6'h05],i_key[6'h31],i_key[6'h33],i_key[6'h24],
                        i_key[6'h1d],i_key[6'h1c],i_key[6'h3c],i_key[6'h39],
                        i_key[6'h10],i_key[6'h13],i_key[6'h3b],i_key[6'h1e],
                        i_key[6'h36],i_key[6'h32],i_key[6'h04],i_key[6'h2d] 
                 };
endmodule
