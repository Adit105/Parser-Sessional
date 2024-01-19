flex 1605023.l
bison -d -t -v 1605023.y
g++ -g lex.yy.c 1605023.tab.c -g
./a.out input.txt
