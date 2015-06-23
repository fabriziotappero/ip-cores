#include "regger.h"

regger::regger()
{
}

void regger::SetDriverToRTL()
{
    cout << "to be implemented" << endl;
}

void regger::SetRTLToDriver()
{
    cout << "In Dev" << endl;
/*
    for(int i=0; i<driver_params.size(); i++)
    {

        for(int j=0; j<rtl_params.size(); j++)
        {
            if(driver_params[i].name == rtl_params.name)
            {
                fstream fout( c_file.c_str(), fstream::in | fstream::out);
                while(fout)
                {
                    //fout.seekp( 0, ios_base::beg );
                    //fout.seekp()
                    //fout.write( "####", 4 );
                    //fout.close();
                }
            }
        }
    }
    */
}

void regger::ShowRegs()
{
    int width = 40;

    // for all driver regs, check what params that have the same name.
    cout << "REG" << setw(width) << "C" << setw(width) << "Verilog" << setw(width) << "Status"<< endl;
    for(unsigned int i=0; i<driver_params.size(); i++)
    {
        bool match = false;
        cout << driver_params[i].name << setw(width-driver_params[i].name.size())  << driver_params[i].prefix << " " << driver_params[i].value;
        for(unsigned int j=0; j<rtl_params.size(); j++)
        {
            if(rtl_params[j].name == driver_params[i].name )
            {
                match = true;
                cout << setw(width-(driver_params[i].prefix.size()+driver_params[i].value.size()+1)) <<  rtl_params[j].prefix << " " << rtl_params[j].value;

                // check if the same value is stored in booth values
                if(rtl_params[j].value == driver_params[i].value)
                    cout << endl;
                else
                    cout << setw(width-(rtl_params[j].prefix.size()+rtl_params[j].value.size()+1)) << "Warning, not matching!" << endl;
                break;
            }
        }
        if(!match)
            cout << setw(width-(driver_params[i].prefix.size()+driver_params[i].value.size()+1)) << ":(" << setw(width) << "Warning, Lonely Reg" << endl;
    }
    //check what regs exists in rtl but not in driver
    for(unsigned int j=0; j<rtl_params.size(); j++)
    {
        bool match = false;
        for(unsigned int i=0; i<driver_params.size(); i++)
        {
            if(rtl_params[j].name == driver_params[i].name )
            {
                match = true;
                break;
            }
        }
        if(!match)
            cout << rtl_params[j].name << setw(width-rtl_params[j].name.size()) << ":(" << setw(width-2) << rtl_params[j].prefix << " " << rtl_params[j].value << setw(width-(rtl_params[j].prefix.size()+rtl_params[j].value.size()+1)) << "Warning, Lonely Reg" << endl;
    }

}

#define LINELENGTH 1024

void regger::ScanFiles()
{
    ifstream fin;
    char line[LINELENGTH];

    fin.open(c_file.c_str());
    // scan .c file
    // locate params and add to rtl_params
    while(fin)
    {
        fin.getline(line,LINELENGTH);
        string sline = line;
        int pos = sline.find("#define");
        if(pos != -1)
        {
            param parameter;
            // get name:
            int start = sline.find_first_not_of(" ",pos+7);
            int end = sline.find_first_of(" ",start+1);
            string name = sline.substr(start,end-start);
            parameter.name = name;

            //debug
          //  cout  << start << " to " << end << ", ";

            // get var
            // first locates + else set start to first none space.
            start = sline.find_first_of("+",end+1);
            if(start != -1)
            {
                // if + found, then check if there is a 0x notation
                start = sline.find_first_of("x",start);
                // in no 0x natation, "start" value after space, else "start" value after x.
                if(start == -1)
                    start = sline.find_first_not_of(" ",end+1);
                else
                {
                    parameter.prefix = "0x";
                    start +=1;
                }
            }
            else
                start = sline.find_first_not_of(" ",end+1);

            // make sure we are not on a space.
            start = sline.find_first_not_of(" ",start);

            // end is after ) if found
            end = sline.find_first_of(")",start);
            if(end == -1)
            {
                // if no ) found, end after space, if no space found, end in end of row
                end = sline.find_first_of(" ",start);
                if(end == -1)
                    end = sline.size();
            }

            //final check, do we still have 0x notation?
            int check = sline.find("x",start);
            if(check != -1 && check < end)
            {
                parameter.prefix = "0x";
                start = check +1;
            }


           // cout << "Errcheck: " << start << "and" << end << "," << end-start << endl;
            string value = sline.substr(start,end-start);
            parameter.value = value;

            // strore parameter
            driver_params.push_back(parameter);

            //debug
         //   cout  << start << " to " << end << " is " << name << " and " << value << endl;
        }


    }
    fin.close();
    //cout << "next file" << endl;
    // scan.v file
    // locate define and add to driver_params
    fin.open(verilog_file.c_str());
    while(fin)
    {
        fin.getline(line,LINELENGTH);
        string sline = line;
        int pos = sline.find("parameter");
        if(pos != -1)
        {
            param parameter;
            // get name:
            int start = sline.find_first_of(" ",pos+1);
            start = sline.find_first_not_of(" ",start);
            int end = sline.find_first_of(" ",start+1);
            string name = sline.substr(start,end-start);
            parameter.name = name;

            // get prefix:
            start = sline.find_first_of("=",end+1);

            start = sline.find_first_not_of(" ",start+1);
            end =  sline.find_first_of("h",start);
            if(end == -1)
                end = start;
            else
                end +=1;

            parameter.prefix = sline.substr(start,end-start);


            // get var:
            int fnutt = sline.find_first_of("'",start+1);
            if(fnutt != -1)
                start = fnutt+2;

            end = sline.find_first_of(";",start+1);

            // make sure that no "=" signs are left in value.
            int equalSign = sline.find_first_of("=",start);
            if(equalSign != -1)
                start = sline.find_first_not_of(" ",equalSign+1);

            string value = sline.substr(start,end-start);
            parameter.value = value;

            // strore parameter
            rtl_params.push_back(parameter);

            //debug
            //cout << start << " to " << end << " is " << name << " and " << value << endl;
        }
    }
    fin.close();
}

void regger::AddFile(string cfile, string rtlfile)
{
 c_file = cfile;
 verilog_file = rtlfile;
 //cout << c_file << " " << verilog_file << endl;
}
