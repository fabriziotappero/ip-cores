/*******************************************************************************************/
/**                                                                                       **/
/** ORIGINAL COPYRIGHT (C) 2010, SYSTEMYDE INTERNATIONAL CORPORATION, ALL RIGHTS RESERVED **/
/** COPYRIGHT (C) 2012, SERGEY BELYASHOV                                                  **/
/**                                                                                       **/
/** version definition file                                          Rev  0.0  06/13/2012 **/
/**                                                                                       **/
/*******************************************************************************************/

/*******************************************************************************************/
/*                                                                                         */
/* SELECT ONLY ONE OPTION PER GROUP!  default is first option                              */
/*                                                                                         */
/*******************************************************************************************/

/*******************************************************************************************/
/*                                                                                         */
/* enable/disable refresh register emulation (if enabled then breaks testbench)            */
/*                                                                                         */
/*******************************************************************************************/
// `define RREG_EMU                                         /* enable emulation            */

/*******************************************************************************************/
/*                                                                                         */
/* select CPU or MPU                                                                       */
/*                                                                                         */
/*******************************************************************************************/
// `define Y90_CPU                                         /* stand-alone cpu only         */
// `define Y90_MPU                                         /* integrated version           */
`define Y90_180                                         /* clone version                */

/*******************************************************************************************/
/*                                                                                         */
/* select the operation of the H flag for the CCF instruction                              */
/*                                                                                         */
/*******************************************************************************************/
`define Z80_CCF                                         /* z80 CCF operation            */
// `define Z180_CCF                                        /* z180 CCF operation           */

/*******************************************************************************************/
/*                                                                                         */
/* select the implementation of the MLT instruction                                        */
/*                                                                                         */
/*******************************************************************************************/
`define MUL_NORM                                        /* parallel multiplier          */
// `define MUL_FAST                                        /* serial multiplier            */

/*******************************************************************************************/
/*                                                                                         */
/* select the value reported in the System Status Block for dreq_bus (Y90 MPU Only)        */
/*                                                                                         */
/*******************************************************************************************/
`define DREQ_LOG                                        /* log dreq timeouts            */
// `define DREQ_ACC                                        /* count dreq timeouts          */

/*******************************************************************************************/
/*                                                                                         */
/* select the value reported in the System Status Block for wait_req (Y90 MPU Only)        */
/*                                                                                         */
/*******************************************************************************************/
`define WAIT_LOG                                        /* log wait timeouts            */
// `define WAIT_ACC                                        /* count wait timeouts          */









