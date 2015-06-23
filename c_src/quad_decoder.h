/*------------------------------------------------------------------------------
*   File:   quad_decoder.h
*   Desc:   Header file for the baseline quadrature decoder driver API.
*   Date:   Initiated October, 2009
*   Auth:   Scott Nortman, Bridge Electronic Design LLC
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

#ifndef _QUAD_DECODER_H_
#define _QUAD_DECODER_H_

#include <stdint.h>

#ifndef TRUE
#define TRUE 1
#endif

#ifndef FALSE
#define FALSE 0
#endif

/* Registers and bit definitions */

/* Quadrature Control Register, offset from base address */
#define QUAD_DCDR_QCR_REG( handle ) ( *(volatile uint32_t *)(handle+0x00) )
#define QCR_ECNT                    ( 0 )       /* Enable Count bit */
#define QCR_CTDR                    ( 1 )       /* Count direction bit */
#define QCR_INEN                    ( 2 )       /* Index enable enable bit */
#define QCR_INZC                    ( 3 )       /* Index zero count bit */
#define QCR_INIE                    ( 4 )       /* Index interrupt enable */
#define QCR_PLCT                    ( 5 )       /* Pre-load count bit */
#define QCR_UNIE                    ( 6 )       /* Underflow interrupt enable bit */
#define QCR_OVIE                    ( 7 )       /* Overflow interrupt enable bit */
#define QCR_QLAT                    ( 8 )       /* Quadrature count latch bit */
#define QCR_ICHA                    ( 9 )       /* Index CHA set */
#define QCR_ICHB                    ( 10 )      /* Index CHB set */
#define QCR_IDXL                    ( 11 )      /* Index level set */
#define QCR_QEIE                    ( 12 )      /* Quadrature error interrupt enable bit */
#define QCR_INRC                    ( 13 )      /* index event causes a read of quad count into QRW */
#define QCR_CCME                    ( 14 )      /* Quadrature Compare Match Enable */
#define QCR_CMIE                    ( 15 )      /* Quad. Compare Match Interrupt Enable */

/* Quadrature status register */
#define QUAD_DCDR_QSR_REG( handle ) ( *(volatile uint32_t *)(handle+0x04))
#define QSR_QERR                    ( 0 )       /* Quadrature error status bit */
#define QSR_CTOV                    ( 1 )       /* Quadrature counter overflow status bit */
#define QSR_CTUN                    ( 2 )       /* Quadrature counter underflow status bit */
#define QSR_INEV                    ( 3 )       /* Index event status bit */
#define QSR_CCME                    ( 4 )       /* Count Compare Match Event */

/* Quadrature count read / write register */
#define QUAD_DCDR_QRW_REG( handle ) ( *(volatile uint32_t *)(handle+0x08))

/*  Function:   quad_dcdr_test
*   Desc:       Performs a test of the quadrature decoder module.  See the
*               comments in the source file for more information.
*   Args:       uint32_t base_add, the base address offset
*   Ret:        None
*   Note:       Must be called after a successful call to quad_dcdr_ioinit.
*               This function calls quad_dcdr_sim.
*/
void quad_dcdr_test( uint32_t base_add );

/*  Function:
*   Desc:
*   Args:
*   Ret:
*   Note:
*/
int8_t quad_dcdr_ioinit( void );

/*  Function:
*   Desc:
*   Args:
*   Ret:
*   Note:
*/
uint8_t quad_dcdr_sim( int32_t steps, int8_t error );

#endif /* _QUAD_DECODER_H_ */
