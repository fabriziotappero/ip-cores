
#include <iostream>
#include <string>
#include <istream>
#include <fstream>
#include <iomanip>

#include "pex_board.h"
#include "factory.h"

BRD_API board* create_board()
{
    return new pex_board();
}
