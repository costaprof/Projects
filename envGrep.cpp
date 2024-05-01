#include <iostream>
#include <fstream>
#include <string>
#include <cstring>
using namespace std;



void function1(string s) {

    fstream file("env.txt");

    if(!file.is_open()) cout<<"Error1"<<endl;
    else {
        // size_t linePos;
        size_t var;
        string line, pre, pos;
        while (getline(file, line)) {
            //linePos = file.tellg();
            size_t found = line.find(s);
            if(found != string::npos) {
                var = line.find("=");
                if(var != string::npos) {
                    if(found < var) continue;
                    else cout<<line<<endl;
                }
            }
        }
    }
}


void function2(string s) {

    fstream file("env.txt");

    if(!file.is_open()) cout<<"Error2"<<endl;
    else {

        size_t var;
        string line, pre, pos;
        while (getline(file, line)) {
            //linePos = file.tellg();
            size_t found = line.find(s);
            if(found != string::npos) {
                var = line.find("=");
                if(var != string::npos) {
                    if(found < var) continue;
                    else {
                        pre = line.substr(0, var);
                        cout<<pre<<endl;
                    }
                }
            }
        }
    }
}


void function3(string s) {
    fstream file("env.txt");

    if(!file.is_open()) cout<<"Error3"<<endl;
    else {
        string line;
        size_t var;
        string pre, pos,userinputToLower,originalLine;
        for(char c : s) userinputToLower+= tolower(c);
        while(getline(file, line)) {
            originalLine = "";
            for(char c : line) originalLine+= tolower(c);
            size_t found = originalLine.find(userinputToLower);
            if(found != string::npos) {
                var = originalLine.find("=");
                if(var != string::npos) {
                    if(found < var) continue;
                    else cout<<line<<endl;
                }
            }

        }
    }
}


void function4(string s) {

    fstream file("env.txt");

    if(!file.is_open()) cout<<"Error3"<<endl;
    else {
        string line;
        size_t var;
        string pre, pos,userinputToLower,originalLine;
        for(char c : s) userinputToLower+= tolower(c);
        while(getline(file, line)) {
            originalLine = "";
            for(char c : line) originalLine+= tolower(c);
            size_t found = originalLine.find(userinputToLower);
            if(found != string::npos) {
                var = originalLine.find("=");
                if(var != string::npos) {
                    if(found < var) continue;
                    else {
                        pre = line.substr(0,var);
                        cout<<pre<<endl;
                    }
                }
            }
        }
    }
}


int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 4) {
        cout << "Error: Invalid number of arguments" << endl;
        return 1;
    }

    if (strcmp(argv[1], "-n") == 0) {
        if (argc == 3) {
            function2(argv[2]);
        } else {
            cout << "Error: Missing argument after -n" << endl;
            return 1;
        }
    } else if (strcmp(argv[1], "-i") == 0) {
        if (argc == 3) {
            function3(argv[2]);
        } else {
            cout << "Error: Missing argument after -i" << endl;
            return 1;
        }
    } else if ((strcmp(argv[1], "-n") == 0 && argc == 4 && strcmp(argv[2], "-i") == 0) || 
               (strcmp(argv[1], "-i") == 0 && argc == 4 && strcmp(argv[2], "-n") == 0)) {
        function4(argv[3]);
    } else {
        function1(argv[1]);
    }

    return 0;
}

/*int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 4) {
        cout << "Error: Invalid number of arguments" << endl;
        return 1;
    }

    if (strcmp(argv[1], "-n") == 0) {
        if (argc == 3) {
            function2(argv[2]);
        } else {
            cout << "Error: Missing argument after -n" << endl;
            return 1;
        }
    } else if (strcmp(argv[1], "-i") == 0) {
        if (argc == 3) {
            function3(argv[2]);
        } else {
            cout << "Error: Missing argument after -i" << endl;
            return 1;
        }
}
	else if ((strcmp(argv[1], "-n") == 0 && argc == 4 && strcmp(argv[2], "-i") == 0) || (strcmp(argv[1], "-i") == 0 && argc == 4 && strcmp(argv[2], "-n") == 0)) {
    		function4(argv[3]);
	} else {
    	cout << "Error: Invalid command" << endl;
   	return 1;
}
}
	 else {
        function1(argv[1]);
    }

    return 0;
}*/


/*int main(int argc, char *argv[]) {
    if ((argc<2) || (argc>4)) {
        cout << "Error: Invalid number of arguments" << endl;
        return 1; // Return error code
    }

    if (strcmp(argv[1], "-n") == 0) {
        if (argc == 3) {
            function2(argv[2]);
        } else {
            cout << "Error: Missing argument after -n" << endl;
            return 1; // Return error code
        }

    } else if (strcmp(argv[1], "-i") == 0) {
        if (argc == 3) {
            function3(argv[2]);
        } else {
            cout << "Error: Missing argument after -i" << endl;
            return 1; // Return error code
        }
    } else if (strcmp(argv[1], "-n") == 0 && strcmp(argv[2], "-i") == 0) {
        if (argc == 4) {
            function4(argv[3]);
        } else {
            cout << "Error: Missing argument after -i" << endl;
            return 1; // Return error code
        }
    } else if (strcmp(argv[1], "-i") == 0 && strcmp(argv[2], "-n") == 0) {
        if (argc == 4) {
            function4(argv[3]);
        } else {
            cout << "Error: Missing argument after -n" << endl;
            return 1; // Return error code
        }
    } else {
        cout << "Error: Invalid command" << endl;
        return 1; // Return error code
    }
}
	else {
        function1(argv[1]);
    }

    return 0; // Return success code
}*/

/*int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 4) {
        cout << "Error: Incorrect number of arguments" << endl;
    } else if (argc == 2) {
        const char* s1 = "-n";
        const char* s2 = "-i";
        if (strcmp(argv[1], s1) == 0) {
            function2(argv[2]);
        } else if (strcmp(argv[1], s2) == 0) {
            function2(argv[3]);
        } else {
            cout << "Error: Invalid command" << endl;
        }
    } else {
        function4(argv[3]);
    }
    return 0;
}*/



/*int main(int argc, char *argv[]) { // envGrep -n -i Muster
    if((argc<1)||(argc>4)) {
	cout<<"Error"<<endl;
}
    else if (argc == 1) { // envGrep
        function1(argv[1]);
    }
    else if(argc == 2) {
        const char* s1 = "-n";
        const char* s2 = "-i";
        if(strcmp(argv[1],s1)==0) {
		function2(argv[2]);
	} // envGrep -n Muster
        	else if(strcmp(argv[1],s2)==0){
			function2(argv[3]);
		}
			else {
				cout<<"Error 2.nd fct"<<endl;
			}
    }
    else {
	function4(argv[3]);
	}
return 0;
    }
*/
