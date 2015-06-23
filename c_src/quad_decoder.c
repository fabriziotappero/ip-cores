/*-----------------------------------------------------------------------------
*   File:   quad_decoder.c
*   Desc:   Test suite for functional verification of the quadrature
*           decoder module.
*   Date:   Initiated Oct. 2009
*   Auth:   Scott Nortman, Bridge Electronic Design LLC
*
*   Current Version: v1.0.0
*
*   Revision History
*
*
*   When        Who                 What
*   ---------------------------------------------------------------------------
*   10/2009     S. Nortman          Initial development started.
*   7/2010      S. Nortman          Added comments, clean code, release v1.0.0
*
*----------------------------------------------------------------------------*/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <drv_ioport.h>
#include "devices.h"
#include "hardware.h"
#include "quad_decoder.h"

#ifndef ABS
#define ABS( x )                ( (x < 0)?(0-x):(x) )
#endif

/* Number of counts when performing random count test */
#define NUM_CNTS ( 1000 )

extern uint8_t quad_irq_flag;
extern uint32_t quad_irq_qsr;
static ioport_t *ioport;

#define QUAD_IOPORT_ID  WB_PRTIO_1

void quad_dcdr_test( uint32_t base_add )
{
    int32_t temp = 0;
    int32_t delta, count, a, error_count;
    volatile uint32_t *ptr = (volatile uint32_t *)base_add;
    uint8_t errFlag = FALSE;

    // Test QCR after reset; we expect 0
    printf("\nTesting reset value of QCR register...\n");
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if(  temp != 0 )
        printf("QCR register [ FAILED ], value is 0x%08X.\n", temp);
    else
        printf("QCR register [ PASSED ], value is 0x%08X.\n", temp);

    //Test QSR after reset; we expect a 0
    printf("\nTesting reset value of QSR register...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if(  temp != 0 )
        printf("QSR register [ FAILED ], value is 0x%08X.\n", temp);
    else
        printf("QSR register [ PASSED ], value is 0x%08X.\n", temp);

    //Test QRW want 0
    printf("\nTesting reset value of QRW register...\n");
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if(  temp != 0 )
        printf("QRW register [ FAILED ], value is 0x%08X.\n", temp);
    else
        printf("QRW register [ PASSED ], value is 0x%08X.\n", temp);

    printf("Writing all zeros...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) = 0;
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) = 0;
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0;

    printf("\nTesting zero value of QCR register...\n");
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if(  temp != 0 )
        printf("QCR register [ FAILED ], value is 0x%08X.\n", temp);
    else
        printf("QCR register [ PASSED ], value is 0x%08X.\n", temp);

    printf("\nTesting zero value of QSR register...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if(  temp != 0 )
        printf("QSR register [ FAILED ], value is 0x%08X.\n", temp);
    else
        printf("QSR register [ PASSED ], value is 0x%08X.\n", temp);

    printf("\nTesting zero value of QRW register...\n");
    //temp = QUAD_DCDR_QRW_REG( ptr );
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if(  temp != 0 )
        printf("QRW register [ FAILED ], value is 0x%08X.\n", temp);
    else
        printf("QRW register [ PASSED ], value is 0x%08X.\n", temp);


    printf("\nWriting to bit locations in QCR register...\n");
    printf("Writing 1 to bit 0...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_ECNT);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<QCR_ECNT) )
        printf("QCR bit 0 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<QCR_ECNT), temp );
    else
        printf("QCR bit 0 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<QCR_ECNT);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 0 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<QCR_ECNT), temp );
    else
        printf("QCR bit 0 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 1 to bit 1...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<1);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<QCR_CTDR) )
        printf("QCR bit 1 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<QCR_CTDR), temp );
    else
        printf("QCR bit 1 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<1);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 1 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<1), temp );
    else
        printf("QCR bit 1 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 1 to bit 2...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<2);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<QCR_INEN) )
        printf("QCR bit 2 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<QCR_INEN), temp );
    else
        printf("QCR bit 2 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<2);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 2 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<2), temp );
    else
        printf("QCR bit 2 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 1 to bit 3...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<3);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<3) )
        printf("QCR bit 3 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<3), temp );
    else
        printf("QCR bit 3 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<3);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 3 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<3), temp );
    else
        printf("QCR bit 3 [ PASSED ], got 0x%08X.\n", temp );


    printf("Writing 1 to bit 4...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<4);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<4) )
        printf("QCR bit 4 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<4), temp );
    else
        printf("QCR bit 4 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<4);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 4 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<4), temp );
    else
        printf("QCR bit 4 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 1 to bit 5...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<5);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    //This bit is auto-cleared, so we want it to read 0 (PLAT)
    if( temp == (1<<5) )
        printf("QCR bit 5 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<5), temp );
    else//zero
        printf("QCR bit 5 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<5);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 5 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<5), temp );
    else
        printf("QCR bit 5 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 1 to bit 6...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<6);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<6) )
        printf("QCR bit 6 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", 0, temp );
    else
        printf("QCR bit 6 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<6);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 6 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<6), temp );
    else
        printf("QCR bit 6 [ PASSED ], got 0x%08X.\n", temp );


    printf("Writing 1 to bit 7...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<7);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<7) )
        printf("QCR bit 7 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<7), temp );
    else
        printf("QCR bit 7 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 0 again...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<7);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp )
        printf("QCR bit 7 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<7), temp );
    else
        printf("QCR bit 7 [ PASSED ], got 0x%08X.\n", temp );

    //Bit 8 is auto cleared (QLAT)
    printf("Writing 1 to bit 8...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<8);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp == (1<<8) )
        printf("QCR bit 8 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (0<<8), temp );
    else
        printf("QCR bit 8 [ PASSED ], got 0x%08X.\n", temp );

    printf("Writing 1 to bit 9...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<9);
    temp = QUAD_DCDR_QCR_REG( Base_QUAD_DECODER);
    if( temp != (1<<9) )
        printf("QCR bit 9 [ FAILED ], wanted 0x%08X, got 0x%08X.\n", (1<<9), temp );
    else
        printf("QCR bit 9 [ PASSED ], got 0x%08X.\n", temp );

    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) = 0;
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) = 0;
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0;

    // test QRW register by writing and reading a value
    printf("Writing 0x55555555 to QRW...\n");
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0x55555555;

    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 0x55555555 )
        printf("QRW [ FAILED ], wanted 0x55555555, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], got 0x55555555.\n");

    printf("Writing 0xAAAAAAAA to QRW...\n");
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0xAAAAAAAA;
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 0xAAAAAAAA )
        printf("QRW [FAILED ], wanted 0xAAAAAAAA, got 0x%08X.\n", temp );
    else
        printf("QRW [PASSED ], got 0xAAAAAAAA.\n");

    printf("Latching current quad_count (0x00000000) into QRW...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], got 0x00000000.\n");

    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0;
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], got 0x00000000.\n");

    //stimulate quad signals 1 count; confirm couting is disabled
    printf("Stimulating Quadrature Signals 1 count (disabled)...\n");
    quad_dcdr_sim( 1, 0 );
    //Latch count, confirm 0 reading
    printf("Latching current quad_count (0x00000000) into QRW...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], got 0x00000000.\n");

    printf("Enabling counting...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_ECNT);
    quad_dcdr_sim( 1, 0 );
    //Latch count, confirm 0 reading
    printf("Latching current quad_count (0x00000001) into QRW...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 1 )
        printf("QRW [ FAILED ], wanted 0x00000001, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0x00000001, got 0x%08X.\n", temp );

    printf("Counting back to 0...\n");
    quad_dcdr_sim( -1, 0 );
    printf("Latching current quad_count (0x00000000) into QRW...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0x00000000, got 0x%08X.\n", temp );


    //trigger underflow
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER) |= 0x0F; //clear all status bits
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QSR [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QSR [ PASSED ], wanted 0x00000000, got 0x%08X.\n", temp );

    //Quad count is still zero
    printf("Counting back to 0xFFFFFFFF...\n");
    quad_dcdr_sim( -1, 0 );
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 0xFFFFFFFF )
        printf("QRW [ FAILED ], wanted 0xFFFFFFFF, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0xFFFFFFFF, got 0x%08X.\n", temp );

    printf("checking status bit...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp == (1<<QSR_CTUN) )
        printf("QSR [ PASSED ], QSR_CTUN SET, got 0x%02X.\n", temp);
    else
        printf("QSR [ FAILED ], wanted 0x%02X, got 0x%02X.\n", (1<<QSR_CTUN), temp);

    // Clear bit by writing a 1 to the correspoding location
    printf("Clearing status bit, rechecking...\n");
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER) |= (1<<QSR_CTUN);

    printf("Rechecking status bit...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp == (1<<QSR_CTUN) )
        printf("QSR [ FAILED ], QSR_CTUN SET, 0x00, got 0x%02X\n", temp);
    else
        printf("QSR [ PASSED ] QSR_CTUN CLEARED.\n");

    //Count is now at 0xFFFFFFFF
    printf("Generating overflow event...\n");
    quad_dcdr_sim( 1, 0 );
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], got 0x00000000.\n");

    //check bit
    printf("Checking status bit...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp == (1<<QSR_CTOV) )
        printf("QSR [ PASSED ], QSR_CTOV SET.\n");
    else
        printf("QSR [ FAILED ], wanted 0x00, got 0x%02X.\n", temp);

    printf("Clearing status bit QSR_CTOV...\n");
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER) |= (1<<QSR_CTOV);

    printf("Rechecking status bit...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp == (1<<QSR_CTOV) )
        printf("QSR [ FAILED ], QSR_CTOV SET, 0x00, got 0x%02X\n", temp);
    else
        printf("QSR [ PASSED ] QSR_CTOV CLEARED, 0x%02X\n", temp);

    //generate error
    printf("Generating quadrature signal error...\n");
    quad_dcdr_sim( 0, 1 ); //generate error
    //check qsr
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp == (1<<QSR_QERR) )
        printf("QSR [ PASSED ], QSR_QERR SET.\n");
    else
        printf("QSR [ FAILED ], wanted 0x00, got 0x%02X.\n", temp);

    printf("Clearing error bit...\n");
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_QERR);
    printf("Rechecking status bit...\n");
    temp = QUAD_DCDR_QSR_REG( Base_QUAD_DECODER );
    if( temp == (1<<QSR_QERR) )
        printf("QSR [ FAILED ], QSR_QERR SET, 0x00, got 0x%02X\n", temp);
    else
        printf("QSR [ PASSED ] QSR_QERR CLEARED, 0x%02X\n", temp);

    printf("Confirming no count change...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0x00000000, got 0x%08X.\n", temp );

    printf("Testing direction change...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_CTDR);
    printf("Counting..\n");
    quad_dcdr_sim( -1, 0 );
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 1 )
        printf("QRW [ FAILED ], wanted 0x00000001, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0x00000001, got 0x%08X.\n", temp );

    printf("Back to 0...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &= ~(1<<QCR_CTDR);
    quad_dcdr_sim( -1, 0 );
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp )
        printf("QRW [ FAILED ], wanted 0x00000000, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], got 0x00000000.\n");

    //Check ISR
    printf("Checking ISR for QERR...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ error, expected flag to be false...\n");
        quad_irq_flag = 0;
    }
    else
        printf("IRQ flag FALSE, triggering error...\n");


    //enable int
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |=  (1<<QCR_QEIE);
    quad_dcdr_sim( 0, 1 );
    printf("Rechecking...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    }
    else
        printf("IRQ [ FAILED ], flag false...\n");

    //clear int
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_QERR);
    printf("Rechecking after clear...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    }
    else
        printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    //gen underflow interrupt
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |=  (1<<QCR_UNIE);
    quad_dcdr_sim( -1,0 );
    printf("Checking ISR for CTUN...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    }
    else
       printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    //clear int
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_CTUN);
    printf("Rechecking after clear...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    }
    else
        printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    //gen over interrupt
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |=  (1<<QCR_OVIE);
    quad_dcdr_sim( 1,0 );
    printf("Checking ISR for CTOV...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    }
    else
       printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    //clear int
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_CTOV);
    printf("Rechecking after clear...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 ){
        printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    }
    else
        printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

//test index input
    //set value manually
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) &=  ~( (1<<QCR_ICHA) | (1<<QCR_ICHB) );
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= ( (1<<QCR_IDXL)|(1<<QCR_INIE)|(1<<QCR_INEN) );
    printf("Asserting IDX...\n");
    ioport_set_value( ioport, 0, 0x04 );//chb=0, cha=0, idx=1
    printf("QSR: 0x%02X\n", QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) );
    //printf("Checking ISR for INEV...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
       printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    else
       printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    //leave idx asserted, clear flag, bit should still be set
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_INEV);
    printf("Rechecking ISR for INEV...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
       printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    else
       printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    //Now disable index enable bit, clear the status register, and confirm that the IRQ
    //  is deasserted.
    printf("Turn idx off...\n");
    ioport_set_value( ioport, 0, 0x00 );
    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_INEV);
    printf("Rechecking ISR for INEV...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
       printf("IRQ [ FAILED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));
    else
       printf("IRQ [ PASSED ], QSR: 0x%02X.\n",  QUAD_DCDR_QSR_REG( Base_QUAD_DECODER));

    printf("Preloading count 0x55555555...\n");
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0x55555555;        //Write to QRW
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_PLCT);    //Latch QRW to internal count
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0xDEADDEAD;        //Write different data into QRW
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);     //Latch internal count into QRW
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 0x55555555 )
        printf("QRW [ FAILED ], wanted 0x55555555, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0x55555555, got 0x%08X.\n", temp );

    printf("Preloading count 0xAAAAAAAA...\n");
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0xAAAAAAAA;
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_PLCT);
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0xDEADDEAD;        //Write different data into QRW
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER) |= (1<<QCR_QLAT);
    temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );
    if( temp != 0xAAAAAAAA )
        printf("QRW [ FAILED ], wanted 0xAAAAAAAA, got 0x%08X.\n", temp );
    else
        printf("QRW [ PASSED ], wanted 0xAAAAAAAA, got 0x%08X.\n", temp );
///////////////////////////////////////////////////////////////////////////////////////////////

    //Test CCME
    printf("Testing CCME...\n");
    temp = (QUAD_DCDR_QSR_REG( Base_QUAD_DECODER )&(1<<QSR_CCME))>>QSR_CCME;
    printf("Checking QSR, pre testing...\n");
    if( temp )
        printf("CCME [ FAILED ], wanted 0, got %d\n", temp );
    else
        printf("CCME [ PASSED ], wanted 0, got %d\n", temp );
    printf("CCME=0, CMIE=0, Asserting QLAT\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_QLAT);
    temp = (QUAD_DCDR_QSR_REG( Base_QUAD_DECODER )&(1<<QSR_CCME))>>QSR_CCME;
    printf("Checking QSR...\n");
    if( temp )
        printf("CCME [ FAILED ], wanted 0, got %d\n", temp );
    else
        printf("CCME [ PASSED ], wanted 0, got %d\n", temp );
    printf("Checking IRQ...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
        printf("IRQ [ FAILED ], wanted 0, got 1\n");
    else
        printf("IRQ [ PASSED ], wanted 0, got 0\n");

    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0xDEADDEAD;
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_PLCT);
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0;

    printf("Enabling CCME...\n");
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= ( (1<<QCR_CCME) | (1<<QCR_CMIE) );
    temp = (QUAD_DCDR_QSR_REG( Base_QUAD_DECODER )&(1<<QSR_CCME))>>QSR_CCME;
    printf("Checking QSR...\n");
    if( temp )
        printf("CCME [ FAILED ], wanted 0, got %d\n", temp );
    else
        printf("CCME [ PASSED ], wanted 0, got %d\n", temp );

    printf("Quad Count =/= QRW, Checking IRQ...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
        printf("IRQ [ FAILED ], wanted 0, got 1\n");
    else
        printf("IRQ [ PASSED ], wanted 0, got 0\n");

    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_QLAT);

    temp = (QUAD_DCDR_QSR_REG( Base_QUAD_DECODER )&(1<<QSR_CCME))>>QSR_CCME;
    printf("Quad Count == QRW, Checking QSR...\n");
    if( temp )
        printf("CCME [ PASSED ], wanted 1, got %d\n", temp );
    else
        printf("CCME [ FAILED ], wanted 1, got %d\n", temp );

    printf("Quad Count == QRW, Checking IRQ...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
        printf("IRQ [ PASSED ], wanted 1, got 1\n");
    else
        printf("IRQ [ FAILED ], wanted 0, got 0\n");

    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = 0x01234567;

    QUAD_DCDR_QSR_REG( Base_QUAD_DECODER ) |= (1<<QSR_CCME);

    temp = (QUAD_DCDR_QSR_REG( Base_QUAD_DECODER )&(1<<QSR_CCME))>>QSR_CCME;
    printf("Quad Count =/= QRW, cleared QSR, Checking QSR...\n");
    if( temp )
        printf("CCME [ FAILED ], wanted 0, got %d\n", temp );
    else
        printf("CCME [ PASSED ], wanted 0, got %d\n", temp );

    printf("Quad Count =/= QRW, cleared QSR, Checking IRQ...\n");
    temp = ioport_get_value( ioport, 0 );
    if( (temp&(1<<7))>>7 )
        printf("IRQ [ FAILED ], wanted 0, got 1\n");
    else
        printf("IRQ [ PASSED ], wanted 0, got 0\n");





#endif

    count = 0;
    error_count = 0;
    QUAD_DCDR_QRW_REG( Base_QUAD_DECODER ) = count;
    QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_PLCT);
     QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) &= ~(1<<QCR_INEN);



    printf("Starting random count test...\n");
    for(a=0;a<NUM_CNTS;a++)
    {

        //printf("%d\n", a);
        delta = rand();

        if( delta%2 )
            delta = 0-delta;

        //track absolute count
        count += delta;

        quad_dcdr_sim( delta, 0 );

        //verufy change
       QUAD_DCDR_QCR_REG( Base_QUAD_DECODER ) |= (1<<QCR_QLAT);
 #if 0
        temp = ioport_get_value( ioport, 0 );
        temp |= (1<<7);
        ioport_set_value( ioport, 0, temp );
        temp &= ~(1<<7);
        ioport_set_value( ioport, 0, temp );
#endif
        temp = QUAD_DCDR_QRW_REG( Base_QUAD_DECODER );


        if( temp != count ){
            printf("[ FAILED ], wanted 0x%08X, got 0x%08X.\n", count, temp );
            error_count++;
        }
        //else
        //    printf("[ PASSED ], got 0x%08X.\n", temp );


    }

    printf("Finished random count test, %d errors.\n", error_count );

}

int8_t quad_dcdr_ioinit( void )
{
    //init dio
    ioport = ioport_open( QUAD_IOPORT_ID );

    if( ioport )
        return 0;
    else
        return -1;
}

//assume port0 => ch A, port1 => ch b, port2 => index
uint8_t quad_dcdr_sim( int32_t steps, int8_t error )
{
    uint32_t num_steps = ABS( steps );
    int8_t  direction = 0;
    uint32_t current_step = 0;
    uint32_t current_state = 0;


    //See if we want to create an intentional error
    if( error ){
        current_state = ioport_get_value( ioport, 0 );
        //Cause changes in both bits simultaneously for error
        ioport_set_value( ioport, 0, (current_state^0x03)&0x03 );
    }
    else{

        if (steps < 0)
            direction = -1;
        else
            direction = 1;

        for( current_step = 0; current_step < num_steps; current_step++)
        {


            //get current state
            current_state = ioport_get_value( ioport, 0 );

            switch( current_state & 0x00000003 ){

                case 0x00:
                    if( direction == 1 )
                        ioport_set_value( ioport, 0, 0x01);
                    else
                        ioport_set_value( ioport, 0, 0x02);
                    break;

                case 0x01:
                    if( direction == 1 )
                        ioport_set_value( ioport, 0, 0x03);
                    else
                        ioport_set_value( ioport, 0, 0x00);
                    break;

                case 0x03:
                    if( direction == 1 )
                        ioport_set_value( ioport, 0, 0x02);
                    else
                        ioport_set_value( ioport, 0, 0x01);
                    break;

                case 0x02:
                    if( direction == 1 )
                        ioport_set_value( ioport, 0, 0x00);
                    else
                        ioport_set_value( ioport, 0, 0x03);
                    break;
            }
        }
    }

    return( ioport_get_value( ioport, 0 ) & 0x03 );

}//end quad_dcdr_sim

