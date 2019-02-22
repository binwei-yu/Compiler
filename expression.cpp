#include "expression.h"

exp_t::exp_t(){

}

exp_t::exp_t(string s){
	type = SCALAR;
	scalar = s;
}

exp_t::exp_t(vector<string> s, vector<exp_t> c){
	type = MAPS;
	for (int i = 0; i < s.size(); i++) maps.push_back(make_pair(s[i], c[i]));
}

exp_t::exp_t(vector<exp_t> c){
	type = LIST;
	for (auto & elem:c) list.push_back(elem);

}

void YAMLFile::print(){
	out(&cout);
}

void YAMLFile::output(string filename){
	ostream* pt = new ofstream(filename);
	out(pt);
	delete pt;
}

void YAMLFile::out_indentation(ostream* s, int level){
	for (int i = 0; i < level; i++) (*s)<<"  ";
}

void YAMLFile::out_helper(ostream* s, exp_t* c, int level){
	switch(c->type){
		case SCALAR:{
			//write right after the :, and prints a new line
			(*s)<<" "<<c->scalar<<endl;
			break;
		}
		case MAPS:{
			(*s)<<endl;
			for (auto &elem : c->maps){
				out_indentation(s, level);
				(*s)<<elem.first<<":";
				out_helper(s, &(elem.second), level+1);
			}
			break;
		}
		case LIST:{
			(*s)<<endl;
			for (auto &elem : c->list){
				out_indentation(s, level);
				(*s)<<"-";
				out_helper(s, &elem, level+1);
			}
			break;
		}
	}
}

void YAMLFile::out(ostream* s){
	(*s)<<"---";
	out_helper(s, &content, 0);
	(*s)<<"..."<<endl;
}