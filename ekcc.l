%{
#include <iostream>
#include <string>
#include "expression.h"
using namespace std;
#include "ekcc.tab.h"

extern int yylineno;
int yyerror(string s);
%}

%option nounput

string \"[^"]*\"
ident [a-zA-Z_][a-zA-Z0-9_]*

%%

"#".*   		{ /* Ignore comment */ }

[0-9]+  		{ string* s = new string(yytext); yylval.str_val = s; return TOKEN_LIT;  }
[0-9]+(\.[0-9]*)	{ string* s = new string(yytext); yylval.str_val = s; return TOKEN_FLIT;  }
{string}		{ string* s = new string(yytext); yylval.str_val = s; return TOKEN_SLIT; }	

"+"     		{ return TOKEN_PLUS;   	}
"-"     		{ return TOKEN_MINUS;  	}
"*"     		{ return TOKEN_STAR;   	}
"/"     		{ return TOKEN_DIVID;  	}
"=="    		{ return TOKEN_DEQUAL; 	}
"="     		{ return TOKEN_EQUAL;  	}
"<"     		{ return TOKEN_GREATER;	}
">"     		{ return TOKEN_LESS;   	}
"!"     		{ return TOKEN_EXCLAM; 	}
"&&"    		{ return TOKEN_DAND;   	}
"||"    		{ return TOKEN_DOR;    	}

"{"     		{ return TOKEN_LBRACE; 	}
"}"     		{ return TOKEN_RBRACE; 	}
"("     		{ return TOKEN_LPAREN; 	}
")"     		{ return TOKEN_RPAREN; 	}
","     		{ return TOKEN_COMMA;  	}
";"     		{ return TOKEN_SEMICOL;	}

"void"  		{ return TOKEN_VOID;   	}
"cint"  		{ return TOKEN_CINT;   	}
"int"   		{ return TOKEN_INT;    	}
"sfloat"		{ return TOKEN_SFLOAT; 	}
"float" 		{ return TOKEN_FLOAT;  	}

"noalias"		{ return TOKEN_NOALIAS;	}
"ref"   		{ return TOKEN_REF;    	}

"print" 		{ return TOKEN_PRINT;  	}
"return"		{ return TOKEN_RETURN; 	}

"def"   		{ return TOKEN_DEF;    	}
"if"    		{ return TOKEN_IF;     	}
"else"  		{ return TOKEN_ELSE;   	}
"while" 		{ return TOKEN_WHILE;  	}
"extern"		{ return TOKEN_EXTERN; 	}
"print" 		{ return TOKEN_PRINT;  	}
"return"		{ return TOKEN_RETURN; 	}
$[ \t]*{ident}		{ string ss = string(yytext); int var_idx = 1;
        		  while (ss[var_idx]==' '||ss[var_idx]=='\t') var_idx++;
        		  string * s = new string(ss.substr(var_idx)); yylval.str_val = s; return TOKEN_VAR; }
{ident} 		{ string* s = new string(yytext); yylval.str_val = s; return TOKEN_GID; }

[ \r\t]+		{ /* Ignore space and line break */ }
[\n]    		{ yylineno++;          	}
.       		{ string err = "unrecognizable word ";
        		  err = err + "\"" + yytext + "\"";
        		  yyerror(err); 	}


