#include <SFML/Graphics.hpp>

#include <fstream>

#include <string>

int main() {
    std::string string = "";
    sf::Image img;
    img.SetSmooth(0);
    if (!img.LoadFromFile("image.bmp")) {
        return 0;
    }
    for (unsigned int i = 0 ; i < img.GetHeight() ; i++) {
        for (unsigned int j = 0 ; j < img.GetWidth() ; j++) {
            sf::Color c = img.GetPixel(j,i);
            if (c == sf::Color::Black) {
                string += "1,";
            }
            else {
                string += "0,";
            }
        }
    }
    string.erase(string.end()-1);
    std::ofstream f("out.txt");
    if (f.is_open()) {
        f << string;
        f.close();
    }
}
