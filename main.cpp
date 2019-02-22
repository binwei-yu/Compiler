#include <iostream>
#include <set>
#include <cstring>

using namespace std;

int yyparse();

int main(int argc, char **argv)
{
	if (argc == 1) {
		cerr<<argv[0]<<": Too few arguments."<<endl;
		exit(1);
	}
	if (argc > 1 && (strncmp(argv[1], "-h", 2) ==0 || strncmp(argv[1],"-?", 2) ==0)){
		cout<<argv[0]<<": Hello, this is a useful help message."<<endl;
		return 0;
	}
	if (argc < 3) {
		cerr<<argv[0]<<": Too few arguments."<<endl;
		exit(1);
	}

	if (strncmp(argv[argc-3], "-o", 2)){
		cerr<<argv[0]<<": Incorrect specification of input or output."<<endl;
		exit(1);
	}

	string output_filename = string(argv[argc-2]);
	string input_filename = string(argv[argc-1]);

	if (freopen(input_filename.c_str(), "r", stdin) == NULL){
		cerr<<argv[0]<<": File "<<input_filename<<" cannot be opened."<<endl;
		exit(1);
	}
	if (freopen(output_filename.c_str(), "w", stdout) == NULL){
		cerr<<argv[0]<<": File "<<output_filename<<" cannot be written."<<endl;
		exit(1);
	}

	set<string> options;
	for (int i = 1; i < argc && strncmp(argv[i],"-o", 2); i++) options.insert(string(argv[i]));

	if (options.find("-emit-ast")!=options.end()) {
		yyparse();
	}

  	return 0;
}

