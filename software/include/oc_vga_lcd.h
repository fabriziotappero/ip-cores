/*
/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Include file for OpenCores VGA/LCD Controller              ////
////                                                             ////
////  File    : oc_vga_lcd.h                                     ////
////  Function: c-include file                                   ////
////                                                             ////
////  Authors: Richard Herveille (richard@asics.ws)              ////
////           www.opencores.org                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                    www.asics.ws                             ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
*/

/*
 * Definitions for the Opencores VGA/LCD Controller Core
 */

/* --- Register definitions --- */
	
/* ----- Read-write access                                            */

#define OC_VGA_CTRL  0x000      /* Control register                   */	
#define OC_VGA_STAT  0x004      /* Status register                    */	
#define OC_VGA_HTIM  0x008      /* Horizontal Timing register         */	
#define OC_VGA_VTIM  0x00c      /* Vertical Timing register           */
#define OC_VGA_HVLEN 0x010      /* Horizontal/Vertical length register*/
#define OC_VGA_VBARA 0x014      /* Video Base Address register A      */
#define OC_VGA_VBARB 0x018      /* Video Base Address register B      */
										
/* ----- Bits definition                                              */
	
/* ----- Control register                                             */
                                /* bits 31-16 are reserved            */	
#define OC_VGA_BL  (1<<15)      /* Blank level bit:                   */
#define OC_VGA_CSL (1<<14)      /* Composite Sync. level bit          */
#define OC_VGA_VSL (1<<13)      /* Vertical Sync. level bit           */
#define OC_VGA_HSL (1<<12)      /* Horizontal Sync. level bit         */
                                /*     0  - Positive                  */
                                /*     1  - Negative                  */
#define OC_VGA_PC  (1<<11)      /* Pseudo Color (only for 8bpp mode)  */
                                /*     0  - 8bpp gray scale           */
                                /*     1  - 8bpp pseudo color         */
#define OC_VGA_CD  (1<< 9)      /* Color Depth                        */
                                /*     00 -  8bits per pixel          */
                                /*     01 - 16bits per pixel          */
                                /*     10 - 24bits per pixel          */
                                /*     11 - reserved                  */
#define OC_VGA_VBL (1<< 7)      /* Video burst length                 */
                                /*     00 - 1 cycle                   */
                                /*     01 - 2 cycle                   */
                                /*     10 - 4 cycle                   */
                                /*     11 - 8 cycle                   */
#define OC_VGA_CBSWE (1<<6)     /* CLUT Bank Switch Enable bit        */
#define OC_VGA_VBSWE (1<<5)     /* Video Bank Switch Enable bit       */
#define OC_VGA_CBSIE (1<<4)     /* CLUT Bank Switch Interrupt enable  */
#define OC_VGA_VBSIE (1<<3)     /* Video Bank Switch Interrupt enable */
#define OC_VGA_HIE   (1<<2)     /* Horizontal Interrupt enable        */
#define OC_VGA_VIE   (1<<1)     /* Vertical Interrupt enable          */
#define OC_VGA_VEN   (1<<0)     /* Video Enable bit                   */
                                /*     1  - Enabled                   */
                                /*     0  - Disabled                  */

/* ----- Status register                                              */
                                /* bits 31-18 are reserved            */	
#define OC_VGA_ACMP (1<<17)     /* Active CLUT Memory Page            */
#define OC_VGA_AVMP (1<<16)     /* Active Video Memory Page           */
                                /* bits 15-8 are reserved             */
#define OC_VGA_CBSINT (1<<7)    /* CLUT Bank Switch Interrupt pending */
#define OC_VGA_VBSINT (1<<6)    /* Bank Switch Interrupt pending      */
#define OC_VGA_HINT   (1<<5)    /* Horizontal Interrupt pending       */
#define OC_VGA_VINT   (1<<4)    /* Vertical Interrupt pending         */
                                /* bits 3-2 are reserved              */
#define OC_VGA_LUINT  (1<<1)    /* LineFIFO Underrun interrupt pending*/
#define OC_VGA_SINT   (1<<0)    /* System Error Interrupt pending     */


/* ----- Horizontal/Vertical Timing registers                         */

#define OC_VGA_TSYNC (1<<24)    /* Synchronization pulse width        */
#define OC_VGA_TGDEL (1<<16)    /* Gate delay time                    */
#define OC_VGA_TGATE (1<< 0)    /* Gate time                          */


/* ----- Horizontal and Vertcial Length registers                     */

#define OC_VGA_THLEN (1<<16)    /* Horizontal length                  */
#define OC_VGA_TVLEN (1<< 0)    /* Vertical length                    */


/* bit testing and setting macros                                     */

#define OC_ISSET(reg,bitmask)       ((reg)&(bitmask))
#define OC_ISCLEAR(reg,bitmask)     (!(OC_ISSET(reg,bitmask)))
#define OC_BITSET(reg,bitmask)      ((reg)|(bitmask))
#define OC_BITCLEAR(reg,bitmask)    ((reg)|(~(bitmask)))
#define OC_BITTOGGLE(reg,bitmask)   ((reg)^(bitmask))
#define OC_REGMOVE(reg,value)       ((reg)=(value))