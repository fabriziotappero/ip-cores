unsigned put_socket(int i){
	file_write(i, "packet");
	return 0;
}

#include "HTTP.h"

//simple echo application
void main(){
	HTTP_GET_response("Hello!\n");
}
