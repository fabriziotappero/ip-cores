#include <iostream>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <string>
#include <vector>
#include <cstring>
#include <cerrno>

int main(int argc, char *argv[])
{
	std::istream *src = &std::cin;
	std::ostream *dst = &std::cout;
	std::cerr << "Intel HEX to Verilog readmemh converter" << std::endl;
	if (argc > 1) {
		std::fstream *file = new std::fstream(argv[1], std::ios::in);
		src = file;
		if (!file->is_open()) {
			const char *err = strerror(errno);
			std::cerr << "Failed to open input file: " << err << std::endl;
			return 1;
		}
		if (argc > 2) {
			file = new std::fstream(argv[2], std::ios::out);
			dst = file;
			if (!file->is_open()) {
				const char *err = strerror(errno);
				std::cerr << "Failed to open output file: " << err << std::endl;
				return 1;
			}
		}
	} else
		std::cerr << "Usage:\n\t" << argv[0] << "[<input file> [<output file>]]\n" << "By default standard input and output are used" << std::endl;

	std::string line;
	std::vector<unsigned char> buffer;
	int nline = 0;
	*dst << std::uppercase;
	while(std::getline(*src, line)) {
		++nline;
		if (line.empty())
			continue;
		char c[3];
		std::istringstream str(line);
		str >> c[0];
		if (c[0] != ':') {
			std::cerr << "Line " << nline << " has invalid format:\n'" << line << '\'' << std::endl;
			return 1;
		}
		buffer.clear();
		unsigned crc = 0;
		str.clear();
		c[2] = '\0';
		c[0] = '\0';
		while(str >> c[1]) {
			if (c[0] == '\0') {
				c[0] = c[1];
				continue;
			}
			std::istringstream str(c);
			unsigned x;
			if (!(str >> std::hex >> x)) {
				std::cerr << "Invalid entry size at line " << nline << std::endl;
				return 1;
			}
			buffer.push_back((unsigned char)x);
			crc += x;
			c[0] = '\0';
		}
		std::cerr << std::endl;
		if ((char)crc) {
			std::cerr << "Invalid CRC of line " << nline << std::endl;
			return 1;
		}
		if (buffer.size() < 5) {
			std::cerr << "Invalid size of line " << nline << std::endl;
			return 1;
		}
		if (buffer[3] == 1)	//end of file
			break;
		int size = buffer[0];
		int address = (buffer[1] << 8) + buffer[2];
		*dst << '@' << std::hex << std::setw(4) << std::setfill('0') << address;
		for(std::vector<unsigned char>::iterator i = buffer.begin() + 4, e = buffer.end()-1; i != e; ++i)
			*dst << ' ' << std::hex << std::setw(2) << std::setfill('0') << unsigned(*i);
		*dst << '\n';
	}

	if (dst != &std::cout)
		delete dst;
	if (src != &std::cin)
		delete src;
	return 0;
}
