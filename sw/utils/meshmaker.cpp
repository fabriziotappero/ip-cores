/*
Per Lenander 2012

Meshconv tool:
-------------
Converts obj files into a .h file
*/

#include <sstream>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <cstdlib>
#include <ctime>

#define GFX_PIXEL_16(R,G,B) (((R >> 3) << 11) | ((G >> 2) << 5) | (B>>3))

using namespace std;

class Point
{
public:
	Point(float X = 0, float Y = 0, float Z = 0)
		: x(X), y(Y), z(Z)
	{}

	float x, y, z;
};

class Face
{
public:
    Face(int P1 = 0, int P2 = 0, int P3 = 0,
         unsigned int Color1 = 0, unsigned int Color2 = 0, unsigned int Color3 = 0)
        : v1(P1), v2(P2), v3(P3), color1(Color1), color2(Color2), color3(Color3)
	{
		vt1 = vt2 = vt3 = 0;
		vn1 = vn2 = vn3 = 0;
	}

	void ParseLine(stringstream& ss)
	{
		// Parse vertex, texture and normal coordinates for p1
		ss >> v1;
		if(ss.peek() == '/')
		{
			ss.ignore();

			if(ss.peek() != '/')
				ss >> vt1;

			if(ss.peek() == '/')
			{
				ss.ignore();
				ss >> vn1;
			}
		}

		// Parse vertex, texture and normal coordinates for p2
		ss >> v2;
		if(ss.peek() == '/')
		{
			ss.ignore();

			if(ss.peek() != '/')
				ss >> vt2;

			if(ss.peek() == '/')
			{
				ss.ignore();
				ss >> vn2;
			}
		}

		// Parse vertex, texture and normal coordinates for p3
		ss >> v3;
		if(ss.peek() == '/')
		{
			ss.ignore();

			if(ss.peek() != '/')
				ss >> vt3;

			if(ss.peek() == '/')
			{
				ss.ignore();
				ss >> vn3;
			}
		}

		unsigned char r, g, b;
		// Temporary
		r = rand() % 256;
		g = rand() % 256;
		b = rand() % 256;

        color1 = GFX_PIXEL_16(r,g,b); // TODO: color

        r = rand() % 256;
        g = rand() % 256;
        b = rand() % 256;

        color2 = GFX_PIXEL_16(r,g,b); // TODO: color

        r = rand() % 256;
        g = rand() % 256;
        b = rand() % 256;

        color3 = GFX_PIXEL_16(r,g,b); // TODO: color

		// .obj uses 1 indexed, reduce
		v1--;
		v2--;
		v3--;

		vt1--;
		vt2--;
		vt3--;

		vn1--;
		vn2--;
		vn3--;
	}

    int v1, v2, v3;    // points
    int vt1, vt2, vt3; // texture coords (uvs)
    int vn1, vn2, vn3; // normals
    unsigned int color1, color2, color3;
};

int main ( int argc, char** argv )
{
	if( argc < 2 )
	{
        cout << "Usage: " << argv[0] << " filename.obj [bpp=16]" << endl;
		return 1;
	}

	srand(time(NULL));

	string		filename(argv[1]);

	ifstream input;
	input.open(filename.c_str(), ifstream::in);

	if( !input )
	{
		cout << "Couldn't load " << filename << "!" << endl;
		return 1;
	}

    int outputBpp = 16;
	if(argc >= 3)
	{
		stringstream ss(argv[2]);
		ss >> outputBpp;

		if(outputBpp != 8 && outputBpp != 16 && outputBpp != 32)
		{
			cout << "Mode: '" << argv[2] << "' not supported, choose between 8, 16 and 32" << endl;
			return 1;
		}
	}

	// Load mesh into internal structure
	vector<Face> faces;
	vector<Point> verts;
	vector<Point> uvs;
	vector<Point> normals;

	// Parse obj file
	while(input)
	{
		char buf[1024];
		input.getline(buf, 1024);
		string s(buf);

		if(s.empty())
			continue;

		stringstream ss(s);
		string type;
		ss >> type;

		if(type[0] == '#')
			continue;
		else if(type == "v") // Vertex coordinates: x y z [w] (discarded)
		{
			Point p;
			ss >> p.x >> p.y >> p.z;
			verts.push_back(p);
		}
		else if(type == "vt") // Texture coordinates: u [v] [w]
		{
			Point t;
			ss >> t.x >> t.y >> t.z;
			uvs.push_back(t);
		}
		else if(type == "vn") // Normals: x y z, does not have to be unit
		{
			Point n;
			ss >> n.x >> n.y >> n.z;
			normals.push_back(n);
		}
		else if(type == "f") // Face
		{
			Face f;
			f.ParseLine(ss);
			faces.push_back(f);
		}
	}

	// Done loading
	input.close();

	/* Open an output file */
	filename	+= ".h";
	ofstream	output(filename.c_str(),ofstream::out);
	if( !output )
	{
		cout << "Couldn't open output file!" << endl;
		return 1;
	}

	// ------------------------- //
	// Write mesh to output file //
	// ------------------------- //
	filename = filename.substr(0, filename.find('.'));

	output << "/* Mesh definition */" << endl << endl;
	output << "#ifndef " << filename << "_H" << endl;
	output << "#define " << filename << "_H" << endl;

    output << "#include \"orgfx_3d.h\"" << endl << endl;

    // Init function
    output << "// Call this function to get an initialized mesh:" << endl;
    output << "orgfx_mesh init_" << filename << "_mesh();" << endl << endl;

    // define the number of faces, verts and uvs
    output << "unsigned int " << filename << "_nverts = " << verts.size() << ";" << endl << endl;
    output << "unsigned int " << filename << "_nuvs   = " << uvs.size() << ";" << endl << endl;
    output << "unsigned int " << filename << "_nfaces = " << faces.size() << ";" << endl << endl;

    // define all verts
    output << "orgfx_point3 " << filename << "_verts[] = {" << endl;
    for(unsigned int i = 0; i < verts.size(); i++)
        output << "{" << verts[i].x << ", " << verts[i].y << ", " << verts[i].z << "}," << endl;
    output << "};" << endl << endl;

    // define all uvs
    output << "orgfx_point2 " << filename << "_uvs[] = {" << endl;
    for(unsigned int i = 0; i < uvs.size(); i++)
        output << "{" << uvs[i].x << ", " << uvs[i].y << "}," << endl;
    output << "};" << endl << endl;

    // define all faces
    output << "orgfx_face " << filename << "_faces[] = {" << endl;
    for(unsigned int i = 0; i < faces.size(); i++)
    {
        const Face& f = faces[i];
        output << "{" << f.v1 << "u, " << f.v2 << "u, " << f.v3 << "u, "
               << f.vt1 << "u, " << f.vt2 << "u, " << f.vt3 << "u, "
               << f.color1 << "u, " << f.color2 << "u, " << f.color3 << "u}," << endl;
    }
    output << "};" << endl << endl;

    output << "orgfx_mesh init_" << filename << "_mesh()" << endl;
    output << "{" << endl;
    output << "  return orgfx3d_make_mesh(" << filename << "_faces,"  << endl
           << "                           " << filename << "_nfaces," << endl
           << "                           " << filename << "_verts,"  << endl
           << "                           " << filename << "_nverts," << endl
           << "                           " << filename << "_uvs,"    << endl
           << "                           " << filename << "_nuvs);"  << endl;
    output << "}" << endl << endl;

	output << "#endif // " << filename << "_H" << endl;

	// done!
	output.close();

	return 0;
}
