CC = g++

ekcc:	lex.yy.c ekcc.tab.c expression.o
	$(CC) lex.yy.c ekcc.tab.c expression.cpp main.cpp -Wno-deprecated -std=c++11 -o ekcc -ll

lex.yy.c:	
	flex ekcc.l

ekcc.tab.c:	
	bison -d -v ekcc.y

expression.o: expression.h expression.cpp
	$(CC) -c expression.cpp -std=c++11

clean:
	rm -f *.o *~ lex.yy.c ekcc.tab.c ekcc.tab.h ekcc ekcc.output
