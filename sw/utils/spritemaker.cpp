/*
Per Lenander 2008

Aniconv tool:
-------------

The tool utilize SDL/SDL_image for graphics conversion
*/

#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

#define SCREEN_WIDTH 640
#define SCREEN_HEIGHT 480
#define SCREEN_DEPTH 32

#include <sstream>
#include <iostream>
#include <fstream>
#include <cstdlib>

using namespace std;

SDL_Surface *screen;

int spriteW = 0;
int spriteH = 0;

/* Ordinary inits */
int InitSDL(void)
{
	if (SDL_Init(SDL_INIT_VIDEO) < 0)
	{
		cerr << "Unable to init SDL: " << SDL_GetError() << endl;
		return 1;
	}

	screen = SDL_SetVideoMode(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_DEPTH, SDL_HWSURFACE | SDL_DOUBLEBUF);
	
	if (!screen)
	{
		cerr << "Unable to set video: " << SDL_GetError() << endl;
		return 1;
	}
	// make sure SDL cleans up before exit
	atexit(SDL_Quit);
	
	return 0;
};

/* Loads the spritesheet (or any image, but this is the only thing it is used for) */
SDL_Surface * LoadImage(std::string s)
{
	SDL_Surface *loaded = NULL;
	
	loaded = IMG_Load(s.c_str());
	
	if(!loaded)		return NULL;
	
	SDL_Surface *optimized = NULL;
	
	optimized = SDL_DisplayFormatAlpha(loaded);
	
	SDL_FreeSurface(loaded);
	
	if(!optimized)		return NULL;
	
	return optimized;
};

SDL_Color GetPixel ( SDL_Surface* pSurface , int x , int y )
{
  SDL_Color color ;
  Uint32 col = 0 ;

  //determine position
  char* pPosition = ( char* ) pSurface->pixels ;

  //offset by y
  pPosition += ( pSurface->pitch * y ) ;

  //offset by x
  pPosition += ( pSurface->format->BytesPerPixel * x ) ;

  //copy pixel data
  memcpy ( &col , pPosition , pSurface->format->BytesPerPixel ) ;

  //convert color
  SDL_GetRGB ( col , pSurface->format , &color.r , &color.g , &color.b ) ;
  return ( color ) ;
}

int main ( int argc, char** argv )
{
	if( argc < 2 )
	{
        cout << "Usage: " << argv[0] << " filename.<jpg/png/bmp> [bpp=16]" << endl;
		return 1;
	}
	
	if( InitSDL() )
		return 1;
	cout << "SDL successfully initialized." << endl;
	
	SDL_Surface *spritesheet = LoadImage( argv[1] );
	if( spritesheet == NULL )
	{
		cout << "Couldn't load " << argv[1] << "!" << endl;
		return 1;
	}

	/* Open an output file */
	string		filename(argv[1]);
	filename	+= ".h";
	ofstream	output(filename.c_str(),ofstream::out);
	if( !output )
	{
		cout << "Couldn't open output file!" << endl;
		return 1;
	}

    int outputBpp = 16;
	if(argc >= 3)
	{
		stringstream ss(argv[2]);
		ss >> outputBpp;

		if(outputBpp != 8 && outputBpp != 16 && outputBpp != 24 && outputBpp != 32)
		{
			cout << "Mode: '" << argv[2] << "' not supported, choose between 8, 16, 24, and 32" << endl;
			return 1;
		}
		else if(outputBpp == 8 && spritesheet->w % 4)
		{
			cout << "Mode: 8bpp requires the width to be divisible by 4!" << endl;
			return 1;
		}
		else if(outputBpp == 16 && spritesheet->w % 2)
		{
			cout << "Mode: 16bpp requires the width to be divisible by 2!" << endl;
			return 1;
		}
	}

	int stride = 1;
	if(outputBpp == 8)
		stride = 4;
	else if(outputBpp == 16)
		stride = 2;

	filename = filename.substr(0, filename.find('.'));

	output << "/* Sprite definition */" << endl << endl;
	output << "/* size: " << spritesheet->w << " * " << spritesheet->h << " at " << outputBpp << "BPP */" << endl << endl;
	output << "#ifndef " << filename << "_H" << endl;
    output << "#define " << filename << "_H" << endl << endl;

    output << "#include \"orgfx_plus.h\"" << endl << endl;


    output << "// This sprite can be loaded by calling:" << endl;
    output << "int init_" << filename << "_sprite();" << endl << endl;

    output << "// The return value is a loaded surface using the orgfxplus_init_surface method" << endl << endl;

	output << "unsigned int " << filename << "[] = {" << endl;

	for(int y = 0; y < spritesheet->h; y++)
	{
		for(int x = 0; x < spritesheet->w; x+=stride)
		{
			unsigned int pixel = 0;
			for(int s = 0; s < stride; s++)
			{
				SDL_Color c = GetPixel(spritesheet, x+s, y);

				if(outputBpp == 8)
				{
					pixel += (unsigned char)(0.3 * c.r + 0.59 * c.g + 0.11 * c.b);
					if(s != 3) pixel = pixel << 8;
				}
				else if(outputBpp == 16)
				{
					c.r = c.r >> 3;
					c.g = c.g >> 2;
					c.b = c.b >> 3;
					pixel += (c.r << 11) | (c.g << 5) | c.b;
					if(s != 1) pixel = pixel << 16;
				}
				else
					pixel = (c.r << 16) | (c.g << 8) | c.b;
			}
			output << pixel << "u, ";			
		}
		output << endl;
	}

	output << "};" << endl << endl;

    output << "int init_" << filename << "_sprite()" << endl;
    output << "{" << endl;
    output << "  return orgfxplus_init_surface(" << spritesheet->w << ", " << spritesheet->h << ", " << filename << ");" << endl;
    output << "}" << endl << endl;

	output << "#endif // " << filename << "_H" << endl;
	
	output.close();
	SDL_FreeSurface( spritesheet );
	
	return 0;
}
