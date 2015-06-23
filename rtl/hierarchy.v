/*******************************************************************************************/
/**                                                                                       **/
/** COPYRIGHT (C) 2011, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED          **/
/**                                                                                       **/
/** chip design file include list                                     Rev 0.0  07/17/2011 **/
/**                                                                                       **/
/*******************************************************************************************/
  `include "defines.v"                                     /* control signal mnemonics     */
  `include "control.v"                                     /* processor control            */
  `include "datapath.v"                                    /* processor data path          */
    `include "alu_log.v"                                   /* alu logic unit               */
    `include "alu_math.v"                                  /* alu math unit                */
    `include "alu_shft.v"                                  /* alu shifter unit             */
    `include "aluamux.v"                                   /* alu a input multiplexer      */
    `include "alubmux.v"                                   /* alu b input multiplexer      */
    `include "aluout.v"                                    /* alu output multiplexer       */
  `include "extint.v"                                      /* processor external interface */
  `include "machine.v"                                     /* processor state machine      */
  `include "y80_top.v"                                     /* cpu top level                */






