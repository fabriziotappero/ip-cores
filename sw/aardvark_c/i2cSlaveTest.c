/*=========================================================================
| 
|--------------------------------------------------------------------------
| 
| File    : i2cSlaveTest.c
|--------------------------------------------------------------------------
| 
|--------------------------------------------------------------------------
 ========================================================================*/

//=========================================================================
// INCLUDES
//=========================================================================
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "aardvark.h"

#ifdef _MSC_VER
#define fileno _fileno
#endif


//=========================================================================
// CONSTANTS
//=========================================================================
#define I2C_BITRATE 400 // kHz


//=========================================================================
// STATIC FUNCTIONS
//=========================================================================
static int testRegs (Aardvark handle, unsigned char LEDstate)
{
    int res, i, count;
    unsigned char data_out[16];
    unsigned char data_in[16];
    unsigned char expected_data [] = {LEDstate, 0xab, 0xcd, 0xef, 0x12, 0x34, 0x56, 0x78};
    

    // Set address reg = 0
    data_out[0] = 0x00;
    res = aa_i2c_write(handle, 0x3c, AA_I2C_NO_FLAGS, 1, data_out);
    if (res < 0)  return res;
    
    if (res == 0) {
        printf("error: slave device 0x38 not found\n");
        return -1;
    }

    // Write to registers 0 through 3
    data_out[0] = 0x00;
    data_out[1] = LEDstate;
    data_out[2] = 0xab;
    data_out[3] = 0xcd;
    data_out[4] = 0xef;
    res = aa_i2c_write(handle, 0x3c, AA_I2C_NO_FLAGS, 5, data_out);
    if (res < 0)  return res;



    // Set address reg = 0
    data_out[0] = 0x00;
    res = aa_i2c_write(handle, 0x3c, AA_I2C_NO_FLAGS, 1, data_out);
    if (res < 0)  return res;
    if (res == 0) {
        printf("error: slave device 0x38 not found\n");
        return -1;
    }
    //read 8 bytes
    count = aa_i2c_read(handle, 0x3c, AA_I2C_NO_FLAGS, 8, data_in);
    if (count < 0) {
        printf("error: %s\n", aa_status_string(count));
        return -1;
    }
    if (count == 0) {
        printf("error: no bytes read\n");
        printf("  are you sure you have the right slave address?\n");
        return -1;
    }
    else if (count != 8) {
        printf("error: read %d bytes (expected 8)\n", count);
        return -1;
    }
    // Dump the data to the screen
    //printf("\nData read from device:");
    for (i = 0; i < count; ++i) {
        //printf("Reg[0x%02x] = 0x%02x\n", i, data_in[i]);
        if (expected_data[i] != data_in[i]) {
          printf("Reg[0x%02x] expected 0x%02x got 0x%02x\n", i, expected_data[i], data_in[i]);
          return -1;
        }
    }
    //printf("\n");

    return 0;
}


//=========================================================================
// MAIN PROGRAM
//=========================================================================
int main (int argc, char *argv[]) {
    Aardvark handle;
    int   port    = 0;
    int   bitrate = 100;
    int   res     = 0;
    //FILE *logfile = 0;
    int   i;
    unsigned char LEDstate;

    if (argc < 2) {
        printf("usage: i2cSlaveTest PORT\n");
        return 1;
    }

    port = atoi(argv[1]);

    // Open the device
    handle = aa_open(port);
    if (handle <= 0) {
        printf("Unable to open Aardvark device on port %d\n", port);
        printf("Error code = %d\n", handle);
        return 1;
    }

    // Enable logging
    //logfile = fopen("log.txt", "at");
    //if (logfile != 0) {
    //    aa_log(handle, 3, fileno(logfile));
    //}

    // Ensure that the I2C subsystem is enabled
    aa_configure(handle,  AA_CONFIG_SPI_I2C);
    
    // Enable the I2C bus pullup resistors (2.2k resistors).
    // This command is only effective on v2.0 hardware or greater.
    // The pullup resistors on the v1.02 hardware are enabled by default.
    aa_i2c_pullup(handle, AA_I2C_PULLUP_NONE);
    
    // Power the board using the Aardvark adapter's power supply.
    // This command is only effective on v2.0 hardware or greater.
    // The power pins on the v1.02 hardware are not enabled by default.
    aa_target_power(handle, AA_TARGET_POWER_NONE);

    // Set the bitrate
    bitrate = aa_i2c_bitrate(handle, I2C_BITRATE);
    printf("Bitrate set to %d kHz\n", bitrate);

    i = 0;
    LEDstate = 0x89;
    do {
      i++;
      res = testRegs(handle, LEDstate);
      if (i % 100 == 0) {
        if (LEDstate == 0x89) LEDstate = 0x88; else LEDstate = 0x89;
        printf("Test loop: %d\n", i);
        fflush(stdout);
      }  
    } while (i <= 100000 && res >= 0);
    if (res < 0)
        printf("error: %s\n", aa_status_string(res));
    else
        printf("All tests passed\n");

    // Close the device and exit
    aa_close(handle);

    // Close the logging file
    //fclose(logfile);
   
    return 0;
}
