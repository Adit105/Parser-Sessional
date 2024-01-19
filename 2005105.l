%option noyywrap

%x STRING

%x MULTI_LINE_COMMENT
%x SINGLE_LINE_COMMENT

%x NEWLINE

%{
#include<iostream>
#include<string>
#include<fstream>

#include "2005105_Symboltable.cpp"
#include "cmp.tab.h"

using namespace std;

void yyerror(string s);  // yyerror() function for generating error message

extern YYSTYPE yylval;  
extern SymbolTable symbolTable;   // NOTICE

extern int line_count;
extern int error_count;  // NOTICE
int numOfComments = 0;
%}

delim [ \t\r\f\v]
WS {delim}+

NEWLINE \n

Letter [a-zA-Z]

Digit [0-9]
Digits {Digit}+
Number1 {Digits}(\.{Digits})?(E[+-]?{Digits})?
Number2 {Digits}?(\.{Digits})(E[+-]?{Digits})?
Number ({Number1}|{Number2})
UnfinishedDecimal {Digits}?(\.)+(E[+-]?{Digits})?
UnfinishedPower {Digits}?(\.{Digits})?(E[+-]?)+
UnfinishedNumbers ({UnfinishedDecimal}|{UnfinishedPower})
NumerousPointerNumber {Digits}?[\.]+({Digits}?[\.]{Digits}?)+(E[+-]?({Digits}?[\.]?{Digits}?)+)?
pointInPowerNumber {Digits}?(\.{Digits})?(E[+-]?{Digits})?(E[+-]?({Digits}?[\.]{Digits}?)+)

Character \'[^\\\n\r\t\a\v\b\f\0\'\"]\'
EscapeCharacter \'(\\)[ntrvbaf0\\\'\"]\'

UnrecognizedCharacter [^ \t\na-zA-Z0-9*/%^&|<>=!'",_.;(){}[\]+-]

InvalidEmptyCharacter \'\'
InvalidCharacter \'[^\\\n\r\t\a\v\b\f\0\'\"]{2,}\'
InvalidEscapeCharacter \'\\[^ \'\r\n]{2,}\'
InvalidCharacters ({InvalidCharacter}|{InvalidEscapeCharacter})

UnfinishedCharacter \'[^\\\n\r\t\a\v\b\f\0\'\"]?[^\'\r\n]*
UnfinishedEscapeCharacter \'(\\)[^\'\r\n]*(\')?
UnfinishedCharacters ({UnfinishedCharacter}|{UnfinishedEscapeCharacter})

Identifier_Chars [_]
ID ({Letter}|{Identifier_Chars})({Letter}|{Digit}|{Identifier_Chars})*
NumberPrefixID {Number}({Letter}|{Digit}|{Identifier_Chars})*

LPAREN \(
RPAREN \)
LCURL \{
RCURL \}
LSQUARE \[
RSQUARE \]
COMMA ,
SEMICOLON ;

IF "if"
FOR "for"
DO "do"
INT "int"

FLOAT "float"
VOID "void"
SWITCH "switch"
DEFAULT "default"

ELSE "else"
WHILE "while"
BREAK "break"
CHAR "char"

DOUBLE "double"
RETURN "return"
CASE "case"
CONTINUE "continue"

BEGIN_MULTILINE_COMMENT "\/\*"
END_MULTILINE_COMMENT "\*\/"

BEGIN_SINGLELINE_COMMENT "//"
END_SINGLELINE_COMMENT	\s*[\n\r<<EOF>>]

DOUBLE_QUOTES "\""


NOT !

ADDOP [+-]

INC "++"
DEC "--"
INCOP ({INC}|{DEC})

MUL "*"
DIV "/"
MOD "%"
MULOP ({MUL}|{DIV}|{MOD})

AND "&"
OR "|"
XOR "^"
LSHIFT "<<"
RSHIFT ">>"
BITOP ({AND}|{OR}|{XOR}|{LSHIFT}|{RSHIFT})

LT "<"
LE "<="
GT ">"
GE ">="
EQ "=="
NE "!="
RELOP ({LT}|{LE}|{GT}|{GE}|{EQ}|{NE})

ASSIGNOP "="

AND_LOGIC_OP "&&"
OR_LOGIC_OP "||"
LOGICOP ({AND_LOGIC_OP}|{OR_LOGIC_OP})

%%

{WS} {}
{NEWLINE} {line_count++;}

{IF} { return IF; }
{FOR} { return FOR; }
{DO} { return DO; }
{INT} {return INT;}

{FLOAT} { return FLOAT; }
{VOID} { return VOID; }
{SWITCH} { return SWITCH; }
{DEFAULT} { return DEFAULT; }

{ELSE} { return ELSE; }
{WHILE} { return WHILE; }
{BREAK} { return BREAK; }
{CHAR} { return CHAR; }

{DOUBLE} { return DOUBLE; }
{RETURN} { return RETURN; }
{CASE} { return CASE; }
{CONTINUE} { return CONTINUE; }
			
{Digits}	{
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "CONST_INT");
    yylval = (YYSTYPE) symbolInfo;
    return CONST_INT;
}
{Number}	{
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "CONST_FLOAT");
    yylval = (YYSTYPE) symbolInfo;
    return CONST_FLOAT;
}
{Character} {
	string character = yytext; character = character[1];

    SymbolInfo* symbolInfo = new  SymbolInfo(character, "CONST_CHAR");
    yylval = (YYSTYPE) symbolInfo;
    return CONST_CHAR;
}
{EscapeCharacter} {
	IncWc();
	string escapeCharacter = "";
	if(strcmp(yytext, "\'\\n\'") == 0) escapeCharacter = '\n';
	if(strcmp(yytext, "\'\\r\'") == 0) escapeCharacter = '\r';
	if(strcmp(yytext, "\'\\t\'") == 0) escapeCharacter = '\t';
	if(strcmp(yytext, "\'\\v\'") == 0) escapeCharacter = '\v';
	if(strcmp(yytext, "\'\\a\'") == 0) escapeCharacter = '\a';
	if(strcmp(yytext, "\'\\f\'") == 0) escapeCharacter = '\f';
	if(strcmp(yytext, "\'\\b\'") == 0) escapeCharacter = '\b';
	if(strcmp(yytext, "\'\\0\'") == 0) escapeCharacter = '\0';
	if(strcmp(yytext, "\'\\'\'") == 0) escapeCharacter = '\'';
	if(strcmp(yytext, "\'\\\"\'") == 0) escapeCharacter = '\"';
	if(strcmp(yytext, "\'\\\\\'") == 0) escapeCharacter = '\\';

	SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "CONST_CHAR");
    yylval = (YYSTYPE) symbolInfo;
    return CONST_CHAR;
}
{UnfinishedNumbers} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "UNFINISHED_NUMBER");
    yylval = (YYSTYPE) symbolInfo;
    return UNFINISHED_NUMBER;
}
{NumerousPointerNumber} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "TOO_MANY_DECIMAL_POINTS");
    yylval = (YYSTYPE) symbolInfo;
    return TOO_MANY_DECIMAL_POINTS;
}
{pointInPowerNumber} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "ILLFORMED_NUMBER");
    yylval = (YYSTYPE) symbolInfo;
    return ILLFORMED_NUMBER;
}
{InvalidEmptyCharacter} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "EMPTY_CONST_CHAR");
    yylval = (YYSTYPE) symbolInfo;
    return EMPTY_CONST_CHAR;
}
{UnfinishedCharacters} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "UNFINISHED_CONST_CHAR");
    yylval = (YYSTYPE) symbolInfo;
    return UNFINISHED_CONST_CHAR;
}
{InvalidCharacters} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "MULTICHAR_CONST_CHAR");
    yylval = (YYSTYPE) symbolInfo;
    return MULTICHAR_CONST_CHAR;
}
{UnrecognizedCharacter} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "UNRECOGNIZED_CHAR");
    yylval = (YYSTYPE) symbolInfo;
    return UNRECOGNIZED_CHAR;
}
{NumberPrefixID} {
    SymbolInfo* symbolInfo = new  SymbolInfo(escapeCharacter, "INVALID_ID_SUFFIX_NUM_PREFIX");
    yylval = (YYSTYPE) symbolInfo;
    return INVALID_ID_SUFFIX_NUM_PREFIX;
}

{NOT} {return NOT;}
{ADDOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "ADDOP");
    yylval = (YYSTYPE) symbolInfo;
    return ADDOP;
}
{INCOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "INCOP");
    yylval = (YYSTYPE) symbolInfo;
    return INCOP;
}

{MULOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "MULOP");
    yylval = (YYSTYPE) symbolInfo;
    return MULOP;
}
{BITOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "BITOP");
    yylval = (YYSTYPE) symbolInfo;
    return BITOP;
}
{ASSIGNOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "ASSIGNOP");
    yylval = (YYSTYPE) symbolInfo;
    return ASSIGNOP;
}
{LOGICOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "LOGICOP");
    yylval = (YYSTYPE) symbolInfo;
    return LOGICOP;
}
{RELOP} {
    SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "RELOP");
    yylval = (YYSTYPE) symbolInfo;
    return RELOP;
}

{LPAREN} { return LPAREN; }
{RPAREN} { return RPAREN; }

{LCURL} { return LCURL; }
{RCURL} { return RCURL; }

{LSQUARE} { return LTHIRD; }
{RSQUARE} { return RTHIRD; }

{COMMA} { return COMMA; }
{SEMICOLON} { return SEMICOLON; }
			
	
{ID} {
	SymbolInfo* symbolInfo = new  SymbolInfo(yytext, "ID");
    yylval = (YYSTYPE) symbolInfo;
    return ID;
 }




 {DOUBLE_QUOTES} {BEGIN(STRING); logStringLiteral += yytext;}
<STRING>{DOUBLE_QUOTES} {
	BEGIN(INITIAL); logStringLiteral += yytext;
	if(!multi_string_state){
        SymbolInfo* symbolInfo = new  SymbolInfo(tokenStringLiteral, "SINGLE_LINE_STRING");
        yylval = (YYSTYPE) symbolInfo;
	}
	else{
        SymbolInfo* symbolInfo = new  SymbolInfo(tokenStringLiteral, "MULTI_LINE_STRING");
        yylval = (YYSTYPE) symbolInfo;
	}
	
	line_count += multi_line_count;
	multi_line_count = 0;

    bool tempStringState = multi_string_state;
	multi_string_state = false;
	logStringLiteral="";
	tokenStringLiteral="";

    if(!tempStringState) return SINGLE_LINE_STRING;
    else return MULTI_LINE_STRING;
}

<STRING>. {
	logStringLiteral += yytext; 
	tokenStringLiteral += yytext;
}
<STRING>\\. {
	logStringLiteral += yytext;
	if(strcmp(yytext, "\\n") == 0) {tokenStringLiteral += '\n';}
	if(strcmp(yytext, "\\r") == 0) tokenStringLiteral += '\r';
	if(strcmp(yytext, "\\t") == 0) tokenStringLiteral += '\t';
	if(strcmp(yytext, "\\v") == 0) tokenStringLiteral += '\v';
	if(strcmp(yytext, "\\a") == 0) tokenStringLiteral += '\a';
	if(strcmp(yytext, "\\f") == 0) tokenStringLiteral += '\f';
	if(strcmp(yytext, "\\b") == 0) tokenStringLiteral += '\b';
	if(strcmp(yytext, "\\0") == 0) tokenStringLiteral += '\0';
	if(strcmp(yytext, "\\'") == 0) tokenStringLiteral += '\'';
	if(strcmp(yytext, "\\\"") == 0) tokenStringLiteral += '\"';
	if(strcmp(yytext, "\\\\") == 0) tokenStringLiteral += '\\';
}
<STRING>\n {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

    SymbolInfo* symbolInfo = new  SymbolInfo(tokenStringLiteral, "UNFINISHED_STRING");
    yylval = (YYSTYPE) symbolInfo;
	error_count++;

	line_count++;
	multi_string_state = false;
	logStringLiteral="";
	tokenStringLiteral="";

    return UNFINISHED_STRING;
}
<STRING>\\\n {
	multi_line_count++;
	multi_string_state = true;
	logStringLiteral += "\\\n";
	tokenStringLiteral += "";
}
<STRING><<EOF>> {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

	SymbolInfo* symbolInfo = new  SymbolInfo(tokenStringLiteral, "UNFINISHED_STRING");
    yylval = (YYSTYPE) symbolInfo;
	error_count++;

	multi_string_state = false;
	stringLiteral="";

    return UNFINISHED_STRING;
}


 {BEGIN_MULTILINE_COMMENT} {BEGIN(MULTI_LINE_COMMENT); stringLiteral += yytext;}
<MULTI_LINE_COMMENT>{END_MULTILINE_COMMENT} {
	BEGIN(INITIAL); stringLiteral += yytext;

	SymbolInfo* symbolInfo = new  SymbolInfo(stringLiteral, "MULTI_LINE_COMMENT");
    yylval = (YYSTYPE) symbolInfo;

	line_count += multi_line_count;
	multi_line_count = 0;

	stringLiteral = "";	
    return MULTI_LINE_COMMENT;
}
<MULTI_LINE_COMMENT>. {
	stringLiteral += yytext;
}

<MULTI_LINE_COMMENT>\\. {
		stringLiteral += yytext;
}
<MULTI_LINE_COMMENT>\n {
	multi_line_count++;
	stringLiteral += "\n";
}
<MULTI_LINE_COMMENT><<EOF>> {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

    SymbolInfo* symbolInfo = new  SymbolInfo(stringLiteral, "UNFINISHED_COMMENT");
    yylval = (YYSTYPE) symbolInfo;
	error_count++;

	multi_string_state = false;
	stringLiteral="";

    return UNFINISHED_COMMENT;
}

{BEGIN_SINGLELINE_COMMENT} {BEGIN(SINGLE_LINE_COMMENT); stringLiteral += yytext; multi_line_count++;}
<SINGLE_LINE_COMMENT>{END_SINGLELINE_COMMENT} {
	BEGIN(NEWLINE);

    SymbolInfo* symbolInfo = new  SymbolInfo(stringLiteral, "SINGLE_LINE_COMMENT");
    yylval = (YYSTYPE) symbolInfo;

	line_count += multi_line_count;
	multi_line_count = 0;
	stringLiteral = "";	

    return SINGLE_LINE_COMMENT;
}
<SINGLE_LINE_COMMENT>. {
    stringLiteral += yytext;
}
<SINGLE_LINE_COMMENT>\\\n {
	multi_line_count++;
	stringLiteral += "\\\n";
}
<SINGLE_LINE_COMMENT><<EOF>> {
	BEGIN(INITIAL);

	line_count += multi_line_count;
	multi_line_count = 0;

	SymbolInfo* symbolInfo = new  SymbolInfo(stringLiteral, "SINGLE_LINE_COMMENT");
    yylval = (YYSTYPE) symbolInfo;

	multi_string_state = false;
	stringLiteral="";

    return SINGLE_LINE_COMMENT;
}





{NEWLINE} {
	BEGIN(NEWLINE);
	line_count++;
	//cout<<line_count<<"  "<<indentation_tab_count<<endl;
}
<NEWLINE>[\t] {
	newline_tab_count++;
}
<NEWLINE>[ ] {
	newline_space_count++;
}
<NEWLINE>[^ \t] {
	if(strcmp(yytext, "}") == 0) indentation_tab_count--;

	int currentTab = newline_tab_count;
	if(newline_space_count%4==0){
		currentTab += (newline_space_count/4);
	}

	if((indentation_tab_count == currentTab) && (newline_space_count%4==0)){
		//No action required
	}
	else if(strcmp(yytext, "\n") == 0){
		//No action required
	}
	else if(newline_space_count == 0){
		//logStream<<"Line# "<<line_count<<": warning, "<<indentation_tab_count<<" of tabs needed but got "<<newline_tab_count<<" tabs."<<endl;
        
        //SymbolInfo* symbolInfo = new  SymbolInfo(stringLiteral, "INDENTATION_WARNING");
        //yylval = (YYSTYPE) symbolInfo;

		warning_count++;
	}
	else if(newline_space_count != 0){
		//logStream<<"Line# "<<line_count<<": Warning, tab requrired but got space."<<endl;

		warning_count++;
	}

	newline_space_count =0;
	newline_tab_count = 0;
	if(strcmp(yytext, "}") == 0) indentation_tab_count++;

	BEGIN(INITIAL);
	yyless(0);
}
<<EOF>> {
	//printAllScopeTable();

	//logStream<<"Total lines: "<<line_count<<endl;
	//logStream<<"Total errors: "<<error_count<<endl;
	//logStream<<"Total warnings: "<<warning_count<<endl;

	return 0;
}

%%