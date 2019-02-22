%{
#include <iostream>
#include <string>
#include "expression.h"
using namespace std;
int yyerror(string s);
int yylex(void);

%}

%union{
  int		int_val;
  string*	str_val;
  exp_t* yaml_value;
}

%start input 

%token <str_val> TOKEN_LIT  "integer_literal"
%token <str_val> TOKEN_FLIT  "float_literal"
%token <str_val> TOKEN_SLIT "string_literal"
%token TOKEN_DAND   "and"
%token TOKEN_DOR    "or"
%token TOKEN_DEQUAL   "=="
%token TOKEN_EQUAL    "="
%token TOKEN_GREATER    "<"
%token TOKEN_LESS   ">"
%token TOKEN_PLUS   "+"
%token TOKEN_MINUS    "-"
%token TOKEN_STAR   "*"
%token TOKEN_DIVID    "/"
%token TOKEN_EXCLAM   "!"
%token TOKEN_LBRACE   "lbrace"
%token TOKEN_RBRACE   "rbrace"
%token TOKEN_LPAREN   "("
%token TOKEN_RPAREN   ")"
%token TOKEN_COMMA    ","
%token TOKEN_SEMICOL    ".,"
%token TOKEN_VOID   "void"
%token TOKEN_CINT   "cint"
%token TOKEN_INT    "int"
%token TOKEN_SFLOAT   "sfloat"
%token TOKEN_FLOAT    "float"
%token TOKEN_NOALIAS    "noalias"
%token TOKEN_REF    "ref"
%token TOKEN_DEF    "def"
%token TOKEN_IF     "if"
%token TOKEN_ELSE   "else"
%token TOKEN_WHILE    "while"
%token TOKEN_EXTERN   "extern"
%token TOKEN_PRINT    "print"
%token TOKEN_RETURN   "return"
%token <str_val> TOKEN_VAR
%token <str_val> TOKEN_GID   
%token TOKEN_UKNOWN


%type <yaml_value>    prog 
%type <yaml_value>   extern
%type <yaml_value>   externs
%type <yaml_value>    func
%type <yaml_value>    funcs
%type <yaml_value>    blk
%type <yaml_value>    stmts
%type <yaml_value>    stmt
%type <yaml_value>    exps
%type <yaml_value>    exp
%type <yaml_value>    binop
%type <yaml_value>    uop
%type <str_val>   lit
%type <str_val>   flit
%type <str_val>   slit
/* %type <name>   ident */
%type <str_val>    var
%type <str_val>    globid
%type <str_val>   type
%type <yaml_value>    vdecls
%type <yaml_value>    tdecls
%type <yaml_value>    vdecl

/* Precedence (increasing) and associativity:
   a+b+c is (a+b)+c: left associativity
   a+b*c is a+(b*c): the precedence of "*" is higher than that of "+". */
%right "then" "else"
%right  "="
%left TOKEN_DOR
%left TOKEN_DAND
%left "=="
%left   "<" ">" ""
%left   "+" "-"
%left   "*" "/"
%right  "!" 


%%

input:		/* empty */
		|	prog { 
      auto res = YAMLFile();
      res.content.type = MAPS;
      res.content = *$1;
      //cout<<$1->maps.size()<<endl;
      res.print();
    }
		;

prog
  : funcs      {
    $$ = new exp_t({"name", "funcs"}, {exp_t("prog"), *$1});}
  | externs funcs  {
    $$ = new exp_t({"name", "funcs", "externs"}, {exp_t("prog"), *$2, *$1});}
  ;


funcs
  : func {
    vector<exp_t> v;
    v.push_back(*$1);
    auto tmp = exp_t(v);
    $$ = new exp_t({"name","funcs"},{exp_t("funcs"),tmp});
  }
  | funcs func {
      $1->maps[1].second.list.push_back(*$2);
      $$ = $1;
  }
  ;

externs
  : extern {
    vector<exp_t> v;
    v.push_back(*$1);
    auto tmp = exp_t(v);
    $$ = new exp_t({"name","externs"},{exp_t("externs"),tmp});
  }
  | externs extern {
      $1->maps[1].second.list.push_back(*$2);
      $$ = $1;
  }
  ;


extern
  : TOKEN_EXTERN type globid "(" ")" ".," {
    $$ = new exp_t({"name", "ret_type", "globid"},
                                {exp_t("extern"), exp_t(*$2), exp_t(*$3)});
  }
  | TOKEN_EXTERN type globid "(" tdecls ")" ".,"{
    $$ = new exp_t({"name", "ret_type", "globid", "tdecls"},
                                {exp_t("extern"), exp_t(*$2), exp_t(*$3), *$5});
  }
  ;    

func
  : "def" type globid "(" ")" blk {
    $$ = new exp_t({"name", "ret_type", "globid", "blk"},
                                {exp_t("func"), *$2, *$3, *$6});
  }
  | "def" type globid "(" vdecls ")" blk{
    $$ = new exp_t({"name", "ret_type", "globid",  "blk", "vdecls"},
                                {exp_t("func"), *$2, *$3, *$7, *$5 });
  }
  ;

blk 
  : "lbrace" "rbrace"{
   $$ = new exp_t({"name", "contents"},
                                {exp_t("blk"), exp_t("")});
  }

  | "lbrace" stmts "rbrace"{
       $$ = new exp_t({"name", "contents"},
                                {exp_t("blk"), *$2});
  }
  ;

stmts
  : stmt {
    vector<exp_t> v;
    v.push_back(*$1);
    auto tmp = exp_t(v);
    $$ = new exp_t({"name","stmts"}, {exp_t("stmts"),tmp});
  }
  | stmts stmt {
      $1->maps[1].second.list.push_back(*$2);
      $$ = $1;
  }
  ;

stmt  
  : blk { $$ = $1;}
  | "return" ".," {$$ = new exp_t({"name","exp"}, {exp_t("ret"),exp_t("")});}
  | "return" exp ".," {$$ = new exp_t({"name", "exp"}, {exp_t("ret"), *$2});}
  | vdecl "=" exp ".," {$$ = new exp_t({"name", "vdecl", "exp"}, {exp_t("vardeclstmt"), *$1, *$3});}
  | exp ".," {$$ = new exp_t({"name", "exp"},{exp_t("expstmt"), *$1});}
  | "while" "(" exp ")" stmt {$$ = new exp_t({"name","cond","stmt"},{exp_t("while"),*$3,*$5});}
  | "if" "(" exp ")" stmt %prec "then" {$$ = new exp_t({"name","cond","stmt"},{exp_t("if"),*$3,*$5});}
  | "if" "(" exp ")" stmt "else" stmt {$$ = new exp_t({"name","cond","stmt","else_stmt"},{exp_t("if"),*$3,*$5,*$7});}
  | "print" exp ".," {$$ = new exp_t({"name","exp"},{exp_t("print"),*$2});}
  | "print" slit ".," {$$ = new exp_t({"name","string"},{exp_t("printslit"),*$2});}
  ;

exps
  : exp  {
    vector<exp_t> v;
    v.push_back(*$1);
    auto tmp = exp_t(v);
    $$ = new exp_t({"name","exps"},{exp_t("exps"),tmp});
  }
  | exps "," exp {

      $1->maps[1].second.list.push_back(*$3);
      $$ = $1;
  }
  ;

exp 
  : "(" exp ")" {$$ = $2;}
  | binop {$$ = $1;}
  | uop {$$ = $1;}
  | lit {$$ = new exp_t({"name","value"},{exp_t("lit"),exp_t(*$1)});}
  | flit {$$ = new exp_t({"name","value"},{exp_t("flit"),exp_t(*$1)});}
  | var {$$ = new exp_t({"name","var"},{exp_t("varval"),exp_t(*$1)});}
  | globid "(" ")" {$$ = new exp_t({"name", "globid"},{exp_t("funccall"), exp_t(*$1)});}
  | globid "(" exps ")" {$$ = new exp_t({"name", "globid","params"},{exp_t("funccall"), exp_t(*$1), *$3});}
  ;

binop
  : exp "*" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("mul"),*$1,*$3});}
  | exp "/" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("div"),*$1,*$3});}
  | exp "+" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("add"),*$1,*$3});}
  | exp "-" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("sub"),*$1,*$3});}
  | var "=" exp {$$ = new exp_t({"name","var","exp"},{exp_t("assign"),*$1,*$3});}
  | exp "==" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("eq"),*$1,*$3});}
  | exp "<" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("lt"),*$1,*$3});}
  | exp ">" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("gt"),*$1,*$3});}
  | exp "and" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("and"),*$1,*$3});}
  | exp "or" exp {$$ = new exp_t({"name","op","lhs","rhs"},{exp_t("binop"),exp_t("or"),*$1,*$3});}
  ;

uop 
  : "!" exp {$$ = new exp_t({"name","op","exp"},{exp_t("uop"),exp_t("not"),*$2});}
  | "-" exp {$$ = new exp_t({"name","op","exp"},{exp_t("uop"),exp_t("minus"),*$2});}
  ;

lit
  : "integer_literal" {$$ = $1;}
  ;

flit
  : "float_literal" {$$ = $1;}
  ;

slit  : "string_literal" {$$ = $1;}
      ;

var 
  : TOKEN_VAR {$$ = $1;}
  ;

globid  
  : TOKEN_GID {$$ = $1;}
  ;

type
  : TOKEN_INT {$$ = new string("int");}
  | TOKEN_CINT {$$ = new string("cint");}
  | TOKEN_FLOAT {$$ = new string("float");}
  | TOKEN_SFLOAT {$$ = new string("sfloat");}
  | TOKEN_VOID {$$ = new string("void");}
  | TOKEN_REF type {$$ = new string("ref "+*$2); }
  | TOKEN_NOALIAS TOKEN_REF type {$$ = new string("noalias ref "+*$3); }
  ;

vdecls  
  : vdecl {
    vector<exp_t> v;
    v.push_back(*$1);
    auto tmp = exp_t(v);
    $$ = new exp_t({"name","vars"}, {exp_t("vdecls"),tmp});
  }
  | vdecls "," vdecl {
      $1->maps[1].second.list.push_back(*$3);
      $$ = $1;
  }
  ;

tdecls
  : type {
    vector<exp_t> v;
    v.push_back(exp_t(*$1));
    auto tmp = exp_t(v);
    $$ =  new exp_t({"name","types"}, {exp_t("tdecls"),tmp});
  }
  | tdecls "," type {
      $1->maps[1].second.list.push_back(exp_t(*$3));
      $$ = $1;
  }

vdecl 
  : type var {$$ = new exp_t({"node","type","var"},{exp_t("vdecl"),exp_t(*$1),exp_t(*$2)});}
  ;


%%

int yyerror(string s)
{
  extern int yylineno;	// defined and maintained in lex.c
  extern char *yytext;	// defined and maintained in lex.c
  
  cerr << "error: " << s << " (line " << yylineno << ")\n";
  exit(EXIT_FAILURE);
}

int yyerror(char *s)
{
  return yyerror(string(s));
}


