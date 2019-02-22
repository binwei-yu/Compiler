#include <iostream>
#include <utility>
#include <vector>
#include <string>
#include <fstream>

using namespace std;

enum yaml_value_type {SCALAR,MAPS,LIST};
typedef enum yaml_value_type value_t;

class exp_t{
public:
	value_t type;
	string scalar;
	vector<pair<string, exp_t> > maps;
	vector<exp_t> list;
	exp_t();
	exp_t(string scalar);
	exp_t(vector<string>, vector<exp_t>);
	exp_t(vector<exp_t>);
};



class YAMLFile{
public:
	exp_t content;
	void print();
	void output(string filename);
private:
	void out_indentation(ostream* s, int level);
	void out_helper(ostream* s, exp_t* c, int level);
	void out(ostream* s);
};