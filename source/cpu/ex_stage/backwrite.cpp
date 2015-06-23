#include "backwrite.h"

void backwrite::do_backwrite()
{
	ex_id_forward.write(ex_id_forward_s.read());
}
