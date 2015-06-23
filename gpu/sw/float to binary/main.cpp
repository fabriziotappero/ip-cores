#include <array>
#include <limits>
#include <cmath>
#include <cstdint>
#include <iostream>
#include <bitset>
#include <stdexcept>

const std::array<float, 8> ks = {
    -std::numeric_limits<float>::infinity(),
    -1.f,
    0.f,
    1.f,
    std::exp(1.f),
    std::acos(-1.f),
    std::numeric_limits<float>::infinity(),
    std::numeric_limits<float>::quiet_NaN(),
};

union float_bits_to_uint32 {
    float_bits_to_uint32(const float &F) : f(F) {}
    operator std::uint32_t() const {return u32;}
private:
    float f;
    std::uint32_t u32;
};

int main() {
    std::size_t i;
    std::string line;
    float x;

    std::cout<<"float  :  sign exponent fraction\n\n";

    for (i = 0; i < ks.size(); i++) {
        std::cout<<ks[i]<<"  :  "<<std::bitset<32>(float_bits_to_uint32(ks[i])).to_string().insert(9, " ").insert(1, " ")<<"\n\n";
    }

    while (true) {
        std::getline(std::cin, line);
        if (line == "exit") break;

        try {
            x = std::stof(line);
        } catch(std::out_of_range) {
            std::cout<<"Error: out of range.\n\n";
            continue;
        } catch(std::invalid_argument) {
            std::cout<<"Error: invalid argument.\n\n";
            continue;
        }

        std::cout<<x<<"  :  "<<std::bitset<32>(float_bits_to_uint32(x)).to_string().insert(9, " ").insert(1, " ")<<"\n\n";
    }

    return EXIT_SUCCESS;
}
