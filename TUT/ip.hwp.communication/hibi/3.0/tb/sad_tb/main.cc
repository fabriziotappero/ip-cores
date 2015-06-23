/*
 * Author: Lasse Lehtonen
 *
 * Main() for SAD hibi testbench: instantiates
 * top-level and stimuli, and starts the execution
 *
 * $Id: main.cc 2010 2011-10-07 08:16:05Z ege $
 *
 */

#include "stimuli.hh"
#include "top_level.hh"


#include <cstdlib>
#include <iostream>
using namespace std; // Bad

#include <systemc>
using namespace sc_core; // And more BADs
using namespace sc_dt;




int sc_main(int argc, char* argv[])
{
   /*
    * Create top level and the stimuli creator. 
    * Stimuli creator calls the agents in the toplevel.
    * Agents communicate using a hierarchical HIBI.
    */

   TopLevel topLevel("HIBI_TESTBENCH");
   Stimuli  stimuli("STIMULI", topLevel);   
   
   /*
    * Run the simulation
    */

   
   sc_start();
      
   
   /*
    * Cleaning things if necessary
    */

   return EXIT_SUCCESS;
}

// Local Variables:
// mode: c++
// c-file-style: "ellemtel"
// c-basic-offset: 3
// End:

