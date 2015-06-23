/*
  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada at ieee.org

*/

#include "args.h"

using namespace std;

int main(int argc, char *argv[] ) {
  arg_vector_t arg_list;
  argument_t number( arg_list, "number", argument_t::integer, "My number", false );
  argument_t mystr( arg_list, "string", argument_t::text, "My string", true );
  argument_t def( arg_list, "", argument_t::text, "default argument", true );
  try{
    cout << "argc = " << argc << "\n";
    Args arg_info( argc, argv, arg_list );
    if( arg_info.help_request() ) return 0;
    if( number.is_set() ) { 
      cout << "Number = " << number.integer_value << "\n"; }
    if( mystr.is_set() ) { 
      cout << "String = " << mystr.string_value << "\n"; }  
    return 0;
  }
  catch( char const* ex ) {
    cout << "Exception: " << ex << "\n";
    return 1;
  }
}
