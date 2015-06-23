%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                                                                    %%%%
%%%%  File           : cordic_iterative_code.m                          %%%%
%%%%  Project        : YAC (Yet Another CORDIC Core)                    %%%%
%%%%  Creation       : Feb. 2014                                        %%%%
%%%%  Limitations    :                                                  %%%%
%%%%  Platform       : Linux, Mac, Windows                              %%%%
%%%%  Target         : Octave, Matlab                                   %%%%
%%%%                                                                    %%%%
%%%%  Author(s):     : Christian Haettich                               %%%%
%%%%  Email          : feddischson@opencores.org                        %%%%
%%%%                                                                    %%%%
%%%%                                                                    %%%%
%%%%%                                                                  %%%%%
%%%%                                                                    %%%%
%%%%  Description                                                       %%%%
%%%%   Script to create VHDL and C code.                                %%%%
%%%%   Two functionalities are created:                                 %%%%
%%%%                                                                    %%%%
%%%%         - A division by a fixed value                              %%%%
%%%%           (to remove the cordic gain)                              %%%%
%%%%                                                                    %%%%
%%%%         - Atan/Atanh/Linear lookup table                           %%%%
%%%%%                                                                  %%%%%
%%%%                                                                    %%%%
%%%%  TODO                                                              %%%%
%%%%        Some documentation and function description                 %%%%
%%%%                                                                    %%%%
%%%%                                                                    %%%%
%%%%                                                                    %%%%
%%%%                                                                    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%                                                                    %%%%
%%%%                  Copyright Notice                                  %%%%
%%%%                                                                    %%%%
%%%% This file is part of YAC - Yet Another CORDIC Core                 %%%%
%%%% Copyright (c) 2014, Author(s), All rights reserved.                %%%%
%%%%                                                                    %%%%
%%%% YAC is free software; you can redistribute it and/or               %%%%
%%%% modify it under the terms of the GNU Lesser General Public         %%%%
%%%% License as published by the Free Software Foundation; either       %%%%
%%%% version 3.0 of the License, or (at your option) any later version. %%%%
%%%%                                                                    %%%%
%%%% YAC is distributed in the hope that it will be useful,             %%%%
%%%% but WITHOUT ANY WARRANTY; without even the implied warranty of     %%%%
%%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  %%%%
%%%% Lesser General Public License for more details.                    %%%%
%%%%                                                                    %%%%
%%%% You should have received a copy of the GNU Lesser General Public   %%%%
%%%% License along with this library. If not, download it from          %%%%
%%%% http://www.gnu.org/licenses/lgpl                                   %%%%
%%%%                                                                    %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






function cordic_iterative_code( outfile )

if ~exist( 'outfile', 'var' )
   outfile = 'autogen_code.txt';
end

fid = fopen( outfile, 'w' );

% TODO: calculate these values
K0 = 0.607252935009;
K1 = 0.207497067763;
%prod( sqrt( 1-2.^(-2 .* [ 1 : 100000 ] ) ) )


signs = get_rm_gain_shifts( K0, 30 );
print_rm_gain_code( fid, signs, K0, 1, 1, 0 );

signs = get_rm_gain_shifts( K1, 30 );
print_rm_gain_code( fid, signs, K1, 1, 1, 1 );

signs = get_rm_gain_shifts( K0, 30 );
print_rm_gain_code( fid, signs, K0, 1, 0, 0 );

signs = get_rm_gain_shifts( K1, 30 );
print_rm_gain_code( fid, signs, K1, 1, 0, 1 );

MAX_A_WIDTH = 32;
print_angular_lut( fid, MAX_A_WIDTH );


fclose( fid );

end




function print_angular_lut( fid, MAX_A_WIDTH )


    values = round( atan( 2.^-[0:MAX_A_WIDTH] ) / pi * 2^(MAX_A_WIDTH-1)  );


    fprintf( fid,  '-- Auto-generated function \n' );
    fprintf( fid,  '-- by matlab (see c_octave/cordic_iterative_code.m)\n'         );
    fprintf( fid,  'function angular_lut( n : integer; mode : std_logic_vector; ANG_WIDTH : natural ) return signed is\n'    );
    fprintf( fid,  '   variable result : signed( ANG_WIDTH-1 downto 0 );\n'   );
    fprintf( fid,  '   variable temp : signed( MAX_A_WIDTH-1 downto 0 );\n' );
    fprintf( fid,  '      begin\n' );
    fprintf( fid,  '      if mode = VAL_MODE_CIR then\n' );
    fprintf( fid,  '         case n is\n' );
    for x = 0 : 10 
    val     = floor( atan( 2^-x ) * 2^(MAX_A_WIDTH+2-1) );
    fprintf( fid,  '            when %d => temp := "', x );
    fprintf( fid,  '%c',           dec2bin( val, MAX_A_WIDTH+2 ) ); 
    fprintf( fid,  '"; \t-- %d\n', val );
    end
    fprintf( fid,  '            when others => temp := to_signed( 2**(MAX_A_WIDTH-1-n), MAX_A_WIDTH );\n' );
    fprintf( fid,  '         end case;\n' );
    fprintf( fid,  '      elsif mode = VAL_MODE_HYP then\n' );
    fprintf( fid,  '         case n is\n' );
    for x = 1 : 10
    val = floor( atanh( 2^-x ) * 2^(MAX_A_WIDTH+2-1)  );
    fprintf( fid,  '            when %d => temp := "', x );
    fprintf( fid,  '%c', dec2bin( val, MAX_A_WIDTH+2 ) );
    fprintf( fid,  '"; \t-- %d\n', val);
    end 
    fprintf( fid,  '            when others => temp := to_signed( 2**(MAX_A_WIDTH-1-n), MAX_A_WIDTH );\n' );
    fprintf( fid,  '         end case;\n' );
    fprintf( fid,  '      elsif mode = VAL_MODE_LIN then\n' );
    fprintf( fid,  '         temp := ( others => ''0'' );\n' );
    fprintf( fid,  '         temp( temp''high-1-n downto 0  ) := ( others => ''1'' );\n' );    
    fprintf( fid,  '      end if;\n' );
    fprintf( fid,  '   result := temp( temp''high downto temp''high-result''length+1 );\n' );
    fprintf( fid,  '   return result;\n' );
    fprintf( fid,  'end function angular_lut;\n' );
end


function print_rm_gain_code( fid, signs, value, force_pos_err, c_or_vhdl, plus_one )


    % Default values for arguments 
    if ~exist( 'force_pos_err', 'var' )
        force_neg_err = 0;
    end

    if ~exist( 'c_or_vhdl', 'var' )
        c_or_vhdl = 0;
    end
    
    val_str = sprintf( '%4.2f', value );
    val_str( val_str == '.' ) = ('_' );
 
    if c_or_vhdl
        fprintf( fid, '/*  Auto-generated procedure to multiply "x" with %f */\n', value );
        fprintf( fid, '/* "shifts" defines the number of shifts, which are used */\n' );
        fprintf( fid,  'switch( shifts )\n{\n' );      
    end
    i_shift = 1;
    for x = 1 : length( signs )
        if signs( x ) ~= 0
            
            tmp     = signs( 1 : x );
            
            
            err = value - sum( tmp .* 2.^-( 1 : length( tmp ) ) );
            if force_pos_err 
                if err < 0 

                    if( tmp( end ) == 1 )
                        tmp( end+1 ) = -1;
                        tmp( end-1 ) = 0;
                    else
                        tmp( end-1 ) = -1;
                        tmp( end   ) =  0;
                    end
                end
                err = value - sum( tmp .* 2.^-( 1 : length( tmp ) ) );
            end

            index               = 1 : length( tmp );
            index( tmp == 0 )   = [];
            tmp( tmp == 0 )     = [];
            tmp2                =  cell( size ( tmp ) );
            tmp2( tmp ==  1 )   = { '+' };
            tmp2( tmp == -1 )   = { '-' };
            
            if c_or_vhdl
                
                % C-Code
                if plus_one
                    fprintf( fid,  '   case %d: x = x ', i_shift );
                else
                    fprintf( fid,  '   case %d: x = ', i_shift );
                end
                
                for y = 1 : length( tmp2 )
                    fprintf( fid,  '%c ( x >> %d ) ', tmp2{ y }, index( y ) );
                end
                fprintf( fid,  '; break; /* error: %.10f */ \n', err );
            else
                
                % VHDL CODE
                
                fprintf( fid, '\n\n--\n' );
                fprintf( fid, '-- Auto-generated procedure to multiply "a" with %f iteratively\n', value );
                fprintf( fid, '-- a_sh is a temporary register to store the shifted value, and \n' );
                fprintf( fid, '-- sum is a temporary register to sum up the result\n' );
                fprintf( fid, '--\n' );
                fprintf( fid, 'procedure mult_%s_%.2d( signal a    : in    signed; \n', val_str, i_shift );
                fprintf( fid, '                   signal a_sh : inout signed; \n' );
                fprintf( fid, '                   signal sum  : inout signed; \n' );
                fprintf( fid, '                          cnt  : in    natural ) is \n' );
                fprintf( fid, '   begin\n' );
                fprintf( fid, '      case cnt is\n' );
                
                if plus_one
                fprintf( fid, '         when   0 => sum  <= a;\n' );                       
                else
                fprintf( fid, '         when   0 => sum  <= to_signed( 0, sum''length );\n' );   
                end
                fprintf( fid, '                     a_sh <= SHIFT_RIGHT( a, %d ); \n', index( 1 ) );
                fprintf( fid, '         when   1 => sum  <= sum %c a_sh; \n', tmp2{ 1 } );

                for y = 2 : length( tmp2 )
                fprintf( fid, '                 a_sh <= SHIFT_RIGHT( a, %d );\n', index( y ) );
                fprintf( fid, '         when %3.d => sum <= sum %c a_sh; \n', y, tmp2{ y } );
                end
                fprintf( fid, '         when others => sum <= sum;\n' );
                fprintf( fid, '     end case;\n' );
                fprintf( fid, 'end procedure mult_%s_%.2d;\n', val_str, i_shift );
            end
            i_shift = i_shift+1;
        end

    end
    if c_or_vhdl
        fprintf( fid,  '   default: x = x; break;\n}\n' );
    end
    
    
    if ~c_or_vhdl
        fprintf( fid, '\n\n--\n' );
        fprintf( fid, '-- Auto-generated procedure to multiply "a" with %f iteratively\n', value );
        fprintf( fid, '-- a_sh is a temporary register to store the shifted value, and \n' );
        fprintf( fid, '-- sum is a temporary register to sum up the result\n' );
        fprintf( fid, '--\n' );
        fprintf( fid, 'procedure mult_%s( signal   a       : in    signed; \n', val_str );
        fprintf( fid, '                   signal   a_sh    : inout signed; \n' );
        fprintf( fid, '                   signal   sum     : inout signed; \n' );
        fprintf( fid, '                            cnt     : in    natural; \n' );
        fprintf( fid, '                   constant RM_GAIN : in    natural ) is \n' );
        fprintf( fid, '   begin\n' );
        fprintf( fid, '      case RM_GAIN is\n' );
        for y = 1 : length( tmp2 )
        fprintf( fid, '         when %d => mult_%s_%.2d( a, a_sh, sum, cnt  );\n', y, val_str, y );
        end
        fprintf( fid, '         when others => mult_%s_%.2d( a, a_sh, sum, cnt  );\n', val_str, y );       
        fprintf( fid, '      end case;\n' );
        fprintf( fid, 'end procedure mult_%s;\n', val_str );
    end
    

end

function signs = get_rm_gain_shifts( value, N_shifts )
    %N_steps = 50;
    %signs       = zeros( 1, N_steps );
    signs       = [  ];
    from_p_n = 1;   % comming from pos or neg
    
    prev_pos_err = inf;
    prev_neg_err = inf;
    i_shift = 0;
    x = 0;
    
    while i_shift < N_shifts
        x = x + 1; 
        if isempty( signs ) 
            tmp = 0;
        else
            tmp = sum( signs .* 2.^-( 1 : length( signs ) ) );
        end;
        
        pos_err = value - ( tmp + 2^-x );
        neg_err = value - ( tmp - 2^-x );
        signs( end+1 ) = 0;
        if      from_p_n == 1 && pos_err < 0  ... 
            ||  from_p_n == 0 && neg_err > 0 
            prev_pos_err = pos_err;
            prev_neg_err = neg_err;
            continue
        end
        i_shift = i_shift+1;
        
        if from_p_n == 1 && abs( prev_pos_err ) < abs( pos_err )
            signs( x-1 ) = 1;
            from_p_n = 0;
            neg_err2 = value - ( tmp - 2^-x );
            if neg_err2 < 0
                signs( x ) = -1;
            end
            
        elseif from_p_n == 0 && abs( prev_neg_err ) < abs( neg_err )
            signs( x-1 ) = -1;
            from_p_n = 1;
            pos_err2 = value - ( tmp + 2^-x );
            if pos_err2 > 0
                signs( x ) =  1;
            end
            
            
        elseif from_p_n == 1 && abs( prev_pos_err ) >= abs( pos_err )
            signs( x ) = 1;
            
        elseif from_p_n == 0 && abs( prev_pos_err ) >= abs( pos_err )
            signs( x ) = -1;
            
        end
        prev_pos_err = pos_err;
        prev_neg_err = neg_err;

    end

end





