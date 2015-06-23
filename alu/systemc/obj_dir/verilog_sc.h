#include <cstdlib>
class verilog_sc {
public:
    // CONSTRUCTORS
    verilog_sc() {}
    ~verilog_sc() {}
    // METHODS
    // This function will be called from a instance created in Verilog
    inline uint32_t randomit() {
     return random() % (1 << 16);
    }
};
