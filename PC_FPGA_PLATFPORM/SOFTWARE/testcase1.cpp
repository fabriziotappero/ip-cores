/*
 * Copyright (C) 2011 Simon A. Berger
 * 
 *  This program is free software; you may redistribute it and/or modify its
 *  under the terms of the GNU Lesser General Public License as published by the Free
 *  Software Foundation; either version 2 of the License, or (at your option)
 *  any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 *  for more details.
 */

#include <stdio.h>

#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <cmath>
#include <iostream>
#include "fpga_com.h"
#include "background_reader.h"

int main() {

    fpga_con_t fc;
   
    fpga_con_init( &fc, "192.168.1.1", 21844, 21845 );   
    
    fpga_bgr_t bgr;

    fpga_bgr_init( &bgr, fc.s, 1024 * 1024 * 10 );
    
    fpga_bgr_start( &bgr );
    
    
    fpga_con_send_init_packet( &fc );
    
    bool do_char = !false;
    bool do_short = !false;
    bool do_int = true;
    bool do_long = true;
    bool do_float = true;
    bool do_double = true;
    const int N = 127;
    if(do_char)
    {
        char test[N];
        for( int i = 0; i < N; i++ ) {
        
            test[i] = i;// + 'a';
            
        }

        fpga_con_send_charv( &fc, test, N);
        
        
        char rec[N];
        fpga_con_rpack_char(&fc,N);
        fpga_bgr_recv_charv(&bgr, rec, N );

        
        printf( "recv char: \n" );
        for( int i = 0; i < N; i++ ) {
            printf( " recv: %d %d\n", test[i], rec[i] ); 
        }
        
    }
    if(do_short)
    {
        
        short test[N];
        for( int i = 0; i < N; i++ ) {
        
            test[i] = i;
            
        }

        fpga_con_send_shortv( &fc, test, N);
        
        
        short rec[N];
        fpga_con_rpack_short(&fc,N);
        fpga_bgr_recv_shortv(&bgr, rec, N );

        
        printf( "recv short: \n" );
        for( int i = 0; i < N; i++ ) {
            printf( " recv: %d %d\n", test[i], rec[i] ); 
        

        }
       
        
       
    }
    if( do_int )
    {
        int test[N];
        for( int i = 0; i < N; i++ ) {
        
            test[i] = i;
            
        }

        fpga_con_send_intv( &fc, test, N);
        
        
        
    
        int rec[N];
        fpga_con_rpack_int(&fc,N);
        fpga_bgr_recv_intv(&bgr, rec, N );

        
        printf( "recv int: \n" );
        for( int i = 0; i < N; i++ ) {
            printf( " recv: %d %d\n", test[i], rec[i] ); 
        }
        
    }
    if( do_long )
    {
        int64_t test[N];
        for( int i = 0; i < N; i++ ) {
        
            test[i] = i * int64_t(1024) * 1024 * 1024;
            
        }

        fpga_con_send_longv( &fc, test, N);
        
        
        int64_t rec[N];
        fpga_con_rpack_long(&fc,N);
        fpga_bgr_recv_longv(&bgr, rec, N );

        
        printf( "recv long: \n" );
        for( int i = 0; i < N; i++ ) {
            std::cout << " recv " << test[i] << " " << rec[i] << std::endl;
        }
    }
    
    if( do_float )
    {
        float test[N];
        for( int i = 0; i < N; i++ ) {
        
            test[i] = i * 100000;
            
        }

        fpga_con_send_floatv( &fc, test, N);
        
        
        float rec[N];
        fpga_con_rpack_float(&fc,N);
        fpga_bgr_recv_floatv(&bgr, rec, N );

        
        printf( "recv float: \n" );
        for( int i = 0; i < N; i++ ) {
            printf( " recv: %f %f\n", test[i], rec[i] ); 
        }
    }
    
    if(do_double)
    {
        double test[N];
        for( int i = 0; i < N; i++ ) {
        
            test[i] = i * 1000000;
            
        }

        fpga_con_send_doublev( &fc, test, N);
        
        double rec[N];
        fpga_con_rpack_double(&fc,N);
        fpga_bgr_recv_doublev(&bgr, rec, N );

        
        printf( "recv double: \n" );
        for( int i = 0; i < N; i++ ) {
            printf( " recv: %f %f\n", test[i], rec[i] ); 
        }
    }
 
    fpga_bgr_stop_interrupt_join(&bgr);
    fpga_bgr_delete(&bgr);
    
    
}
