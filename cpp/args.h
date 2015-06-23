/*
  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada at ieee.org

*/

#include <string>
#include <vector>
#include <algorithm>
#include <cstdlib>
#include <iostream>

typedef std::vector<struct argument_t*> arg_vector_t;

struct argument_t {
protected:
	int imin, imax;
	float fmin, fmax;
	bool limits;
	template<typename A> bool pass( A a, A b, A x ) { return x>=a && x<=b; }
public:
  std::string short_name, long_name;
  typedef enum { integer, text, flag, real } arg_type;
  arg_type type;
  std::string description;
  // possible states
  int integer_value;
  std::string string_value;
  float real_value;  
  bool state, req;
	
	bool parse_hex;
  
  argument_t( arg_vector_t& av, const char* long_name, arg_type type,
    const char* desc="", bool required=false ) 
    : long_name(long_name), type( type ), description( desc ),
      req(required), state(false), integer_value(0), real_value(0),
			parse_hex(false), limits(false)
  {
    if( !this->long_name.empty() ) {
      this->short_name = "-" + this->long_name.substr(0,1);
      this->long_name = "--" + this->long_name;
    }
    av.push_back(this);
  }
  void set() { state=true; }
  bool is_set() { return state; }
	// range control
	void setlimits( int min, int max ) {
		if( type == integer ) {
			imin = min;
			imax = max;
			limits = true;
		}
		else if( type == real ) {
			fmin = (float) min;
			fmax = (float) max;
			limits = true;
		}
		else throw "Cannot apply integer limits to this type of input argument";
	}
	void setlimits( float min, float max ) {
		if( type == real ) {
			fmin = min;
			fmax = max;
			limits = true;
		}
		else throw "Cannot apply real limits to this type of input argument";
	}	
	bool passlimits() {
		if( !limits ) return true;
		if( type == real ) return pass( fmin, fmax, real_value );
		else if ( type == integer ) return pass( imin, imax, integer_value );
		return false;
	}
};



class Args {
  arg_vector_t& legal_args;
  argument_t* def_arg;
  std::string program_name;
  argument_t help_arg;
  void clean_args() {
    for( int j=0; j<legal_args.size(); j++ ) {
      argument_t& a = *legal_args[j];
      if( a.short_name=="-h" && a.long_name!="help" )
        { help_arg.short_name.clear(); break; } // remove -h for help if already used
    }
  }
  void throw_error( std::string x ) /*throw const char**/ { throw x.c_str(); }
public:
  Args( int argc, char *argv[], arg_vector_t& legal_args ) //throw const char *
  : legal_args( legal_args ), 
    help_arg( legal_args, "help", argument_t::flag, "Display usage information")
  {
    clean_args(); // eliminate duplicated values
    // look for default argument
    def_arg=NULL;
    for( int j=0; j<legal_args.size(); j++ ) {
      if ( legal_args[j]->short_name.empty() && legal_args[j]->long_name.empty() )
        if( def_arg==NULL ) def_arg = legal_args[j];
        else throw "Cannot set more than one default argument.";
    }
    if( def_arg && def_arg->type!=argument_t::integer && def_arg->type!=argument_t::text )
      throw "Default arguments can only be integer or text";

    program_name = argv[0];
    for( int k=1; k<argc; k++ ) {
      bool matched=false;
      for( int j=0; j<legal_args.size(); j++ ) {
        argument_t& a = *legal_args[j];
        if( a.long_name==argv[k] || a.short_name==argv[k] ) {
          if( a.type == argument_t::flag ) { a.set(); matched=true; continue; }
          if( a.type == argument_t::text ) {
            k++;
            if( k>=argc ) throw_error("Expecting input after "+a.long_name+" param");
            a.string_value = argv[k];
            a.set();
            matched=true;
            continue;
          }
          if( a.type == argument_t::integer ) {
            k++;
            if( k>=argc ) throw_error("Expecting input after "+a.long_name+" param");
						if( !a.parse_hex ) 
	            a.integer_value = atoi(argv[k]);						
						else {
							errno = 0;
							a.integer_value = strtol( argv[k], NULL, 16 ); 
							if( errno ) throw "Cannot parse hexadecimal argument";							
						}
						if( !a.passlimits() ) throw_error("Argument "+a.long_name+" is not within its allowed range");
            a.set();
            matched=true;
            continue;
          }
          if( a.type == argument_t::real ) {
            k++;
            if( k>=argc ) throw_error("Expecting input after "+a.long_name+" param");
            a.real_value = atof(argv[k]);
						if( !a.passlimits() ) throw_error("Argument "+a.long_name+" is not within its allowed range");
            a.set();
            matched=true;
            continue;
          }
        }
      }
      if( !matched && def_arg!=NULL )
        if( def_arg->state )
          throw_error( "Unknown parameter " + std::string(argv[k] ));
        else {
          if( def_arg->type==argument_t::integer ) def_arg->integer_value=atoi(argv[k]);
          if( def_arg->type==argument_t::text ) def_arg->string_value=argv[k];
          def_arg->set();
        }
    }
    if( help_arg.is_set() ) return; // do not perform more checks
    // check that all required parameters are present
    for( int j=0; j<legal_args.size(); j++ ) {
      argument_t& a = *legal_args[j];
      if( a.req && !a.state ) {
        std::string pname;
        if( !a.long_name.empty() ) pname=a.long_name;
        else if( !a.short_name.empty() ) pname=a.short_name;
        throw_error("Parameter "+pname+" is required.");
      }
    }
  }
  void check_ilegal_combinations( arg_vector_t& ilegal ) {
    int count=0;
    std::string names;
    for( int k=0; k < ilegal.size(); k++ )
      if( ilegal[k]->is_set() ) { count++; names += " " + ilegal[k]->long_name; }
    if( count>1 ) throw_error( "Parameters" + names + " cannot be used together" );
  }
  bool help_request() { if( help_arg.is_set() ) show_help(); return help_arg.is_set(); }
  std::string brackets( const argument_t& a, std::string s ) {
    return a.req ?  "<"+s+">" : "["+s+"]"; 
  }
  void show_help() {
    std::cout << "Usage: " << program_name << " ";  
    if( def_arg!=NULL )
      std::cout << brackets( *def_arg, def_arg->description.empty() ? "parameter " : def_arg->description);
    std::cout << "\n";
    for( int j=0; j<legal_args.size(); j++ ) {
      argument_t& a = *legal_args[j];    
      if( a.long_name.empty() && a.long_name.empty() ) continue;
      std::cout << "\t";
      std::string aux;
      if( !a.long_name.empty() ) aux = a.long_name;
      if( !a.long_name.empty() && !a.short_name.empty() ) aux += " | ";
      if( !a.short_name.empty() ) aux+= a.short_name;
      std::cout << brackets( a, aux );
      switch( a.type ) {
        case argument_t::integer: std::cout << " followed by integer number. "; break;
        case argument_t::real   : std::cout << " followed by real number. "; break;        
        case argument_t::text   : std::cout << " followed by string. "; break;        
      }
      if( !a.description.empty() ) std::cout << ":  " << a.description;
      std::cout << "\n";
    }
  }
};
