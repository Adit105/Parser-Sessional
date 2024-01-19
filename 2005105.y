%{
#include<iostream>
#include<string>
#include<sstream>
#include<fstream>
#include<cstdlib>
#include<vector>
#include "2005105_Symboltable.cpp"

using namespace std;

int yyparse(void);
int yylex(void);

extern FILE* yyin;

int line_count = 1;  // NOTICE
int errorCount = 0;
int scope_count = 1;

FILE* input;
ofstream logStream;
ofstream error;

//int scopeTablesSize = 10;

//Root scopetable for global scope, with new SymbolTable
//ScopeTable* scopeTable = new ScopeTable(scopeTablesSize);
//SymbolTable* symbolTable = new SymbolTable(scopeTable, scopeTablesSize, logStream);

SymbolTable* symbolTable;

/* auxiliary variables and structures and containers */
string type, type_final;  // basially for function declaration-definition
string name, name_final;  // basically for function declaration-definition

struct var{
    string var_name;
    int var_size;  // it is set to -1 for variables
} temp_var;

vector<var> var_list;  /* for identifier(variable, array) insertion into symbolTable */
string tempTypeSpecifier; // Holds type specifier temporarily while variable declaration;

Parameter tempParameter; //Holds parameter temporarily before pushing into parameter List
vector<Parameter> parameterList;  // parameter list for identifiers such as function declaration, definition

vector<string> arg_list;  // argument list for function call

/* auxiliary functions */
void insertVariable(string _type, var var_in) {
    /* symbolTable insertion for variable and array */
    SymbolInfo* symbolInfo = new SymbolInfo(var_in.var_name, "ID");
    symbolInfo->setReturnType(_type);  // setting variable type
    symbolInfo->setArraySize(var_in.var_size);

    symbolTable->insertSymbol(*symbolInfo);
    return ;
}

//Functions for inserting identifiers into SymbolTable

//For variables and arrays
//arraySize set to -1 for variables
void insertVariable(string Type, string Name, int arraySize) {

    SymbolInfo* symbolInfo = new SymbolInfo(Name, "ID");
    symbolInfo->setReturnType(Type);  // setting variable type
    symbolInfo->setArraySize(arraySize);

    symbolTable->Insert(symbolInfo);
    return;
}

//For function declarations and definitions
//FuncDecDefBySize = -2 for declarations and -3 for definitions
void insertFunction(string Type, string Name, int FuncDecDefBySize) {

    SymbolInfo* symbolInfo = new SymbolInfo(Name, "ID");
    symbolInfo->setReturnType(Type);  // setting return type of function
    symbolInfo->setArraySize(FuncDecDefBySize);

    for(Parameter p : parameterList){
        symbolInfo->addToParameterList(p);
    }

    symbolTable->Insert(symbolInfo);
    return;
}

/* yyerror prototype function for reporting syntax error */
void yyerror(string s);
%}

%define api.value.type {SymbolInfo*}

%token CONST_INT CONST_FLOAT ID
%token INT FLOAT VOID IF ELSE FOR WHILE PRINTLN RETURN MAIN CHAR DOUBLE

%token ASSIGNOP NOT INCOP DECOP LOGICOP RELOP ADDOP MULOP
%token LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON 

%token SINGLE_LINE_STRING MULTI_LINE_STRING UNFINISHED_STRING
%token MULTI_LINE_COMMENT UNFINISHED_COMMENT SINGLE_LINE_COMMENT

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start: program {
        logStream << "At line no: " << (line_count-1) << " start: program" << "\n"  << endl;

        $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
        logStream << $1->getName() << "\n"  << endl;
	}
	;

program: program unit {   
        logStream << "At line no: " << line_count << " program: program unit" << "\n"  << endl;

        $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "NON_TERMINAL");
        logStream << $$->getName(); << "\n"  << endl;
    }
	| unit {
        logStream << "At line no: " << line_count << " program: unit" << "\n"  << endl;

        $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
        logStream << $1->getName() << "\n"  << endl;
    }
	;

unit: var_declaration {
        logStream << "At line no: " << line_count << " unit: var_declaration" << "\n"  << endl;

        $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
        logStream << $1->getName() << "\n"  << endl;
    }
    | func_declaration {
        logStream << "At line no: " << line_count << " unit: func_declaration" << "\n"  << endl;

        $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
        logStream << $1->getName() << "\n"  << endl;
    }
    | func_definition {
        logStream << "At line no: " << line_count << " unit: func_definition" << "\n"  << endl;

        $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
        logStream << $1->getName() << "\n"  << endl;
    }
    ;
     
func_declaration: type_specifier ID embedded LPAREN parameter_list RPAREN embedded_out_dec SEMICOLON {
        logStream << "At line no: " << line_count << " func_declaration: type_specifier ID LPAREN parameter_list RPAREN SEMICOLON" << "\n"  << endl;

        $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)$5->getName()+(string)")"+(string)";"+(string)"\n"+(string)"\n", "NON_TERMINAL");
        logStream << $$->getName() << endl;

        name = (string)$2->getName();
        parameterList.clear();
    }
    | type_specifier ID embedded LPAREN RPAREN embedded_out_dec SEMICOLON {
        logStream << "At line no: " << line_count << " func_declaration: type_specifier ID LPAREN RPAREN SEMICOLON" << "\n"  << endl;

        $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)")"+(string)";"+(string)"\n"+(string)"\n", "NON_TERMINAL");
        logStream << $$->getName() << endl;

        name = (string)$2->getName();
        parameterList.clear();
    }
    ;
		 
func_definition: type_specifier ID embedded LPAREN parameter_list RPAREN embedded_out_def compound_statement {
        logStream << "At line no: " << line_count << " func_definition: type_specifier ID LPAREN parameter_list RPAREN compound_statement" << "\n"  << endl;

        $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)$5->getName()+(string)")"+(string)$8->getName()+(string)"\n"+(string)"\n", "NON_TERMINAL");
        logStream << $$->getName() << endl;

        name = (string)$2->getName();
    }
    | type_specifier ID embedded LPAREN RPAREN embedded_out_def compound_statement {
        logStream << "At line no: " << line_count << " func_definition: type_specifier ID LPAREN RPAREN compound_statement" << "\n"  << endl;

        $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)"("+(string)")"+(string)$7->getName()+(string)"\n"+(string)"\n", "NON_TERMINAL");
        logStream << $$->getName() << endl;

        name = (string)$2->getName();
    }
    ;		
//name = $1->getName();
embedded: {
            /* NOTICE: embedded action */
            type_final = type;
            name_final = name;
    }
    ;	

embedded_out_dec: {

            SymbolInfo* lookupNode = symbolTable->Lookup(name_final);

            if(lookupNode == NULL){ //Not previously declared/defined
                //Inserting into symbolTable, -2 denoting function declaration
                insertFunction(type_final, name_final, -2); 
            }
            else{//Previously declared
                error << "Error at line no: " << line_count << " multiple declaration of " << name_final << "\n" << endl;
                errorCount++;
            }
    }
    ;		

embedded_out_def: {

            SymbolInfo* lookupNode = symbolTable->Lookup(name_final);

            if(lookupNode == NULL) { //Not previously declared/defined
                //Inserting into symbolTable, -3 denoting function definition
                insertFunction(type_final, name_final, -3);
            } 

            else if(lookupNode->getArraySize() == -1) {
                /* Previously declared variable found */
                error << "Error at line no: " << line_count << " variable with name " << name_final << " declared earlier\n" << endl;
                errorCount++;
            }

            else if(lookupNode->getArraySize() == -3) {
                /* Previously defined function found */
                error << "Error at line no: " << line_count << " multiple definition of " << name_final << "\n" << endl;
                errorCount++;
            } 

            else {/* Previously declared function found, so no problem */

                /* Checking consistencies within declaration and definition*/
                if(lookupNode->getReturnType() != type_final) {
                    /* return type not matching */
                    error << "Error at line no: " << line_count << " inconsistent function definition with its declaration for " << name_final << "\n" << endl;
                    errorCount++;

                } 

                //Two cases for void param**
                //Void param provided in declaration, no param provided in definition, no problem
                else if(lookupNode->getParameterListSize()==1 && parameterList.size()==0 && lookupNode->getParameter(0).getType()=="void") {
                    lookupNode->setArraySize(-3);  // NOTICE: given function declaration has a matching definition, so it can be called
                } 
                //No param provided in declaration, void param provided in definition, no problem
                else if(lookupNode->getParameterListSize()==0 && parameterList.size()==1 && parameterList[0].getType()=="void") {
                    lookupNode->setArraySize(-3);  // NOTICE: given function declaration has a matching definition, so it can be called
                } 
                //Two cases for void param**

                //Parameter list size between declaration and definition not matching 
                else if(lookupNode->getParameterListSize() != parameterList.size()) {
                    error << "Error at line no: " << line_count << " inconsistent function definition with its declaration for " << name_final << "\n" << endl;
                    errorCount++;
                } 

                //Parameter list size between declaration and definiton matching, so now we match params' types
                else {

                    bool validParameterList = true; //Valid if all parameters are valid

                    // Checking parameter list size 
                    if(lookupNode->getParameterListSize() == parameterList.size()) {
                        //Size matched, set identifier as function defintion
                        lookupNode->setArraySize(-3);
                    } else {
                        //Size not matched, function definition not valid
                        validParameterList = false;
                    }

                    // Checking params' types
                    if(validParameterList){ //If sizes matched, only then we check types
                        for(int i=0; i<parameterList.size(); i++) {
                            if(lookupNode->getParameter(i).getType() != parameterList[i].getType()) {
                                validParameterList = false; //If any of the param's type does not match
                                break;                      //function definition is invalid
                            }
                        }
                    }

                    if(!validParameterList){
                        error << "Error at line no: " << line_count << " inconsistent function definition with its declaration for " << name_final << "\n" << endl;
                        errorCount++;
                    }

                }
            }
    }
    ;	

parameter_list: parameter_list COMMA type_specifier ID {
            logStream << "At line no: " << line_count << " parameter_list: parameter_list COMMA type_specifier ID" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName()+(string)" "+(string)$4->getName(), "NON_TERMINAL");
            logStream << $$->getName() << endl;

            //Adding parameter to list
            tempParameter.setType((string)$3->getName());
            tempParameter.setName((string)$4->getName());

            parameterList.push_back(tempParameter);
    }
        | parameter_list COMMA type_specifier {
            logStream << "At line no: " << line_count << " parameter_list: parameter_list COMMA type_specifier" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << endl;

            //Adding parameter to list            
            tempParameter.setType((string)$3->getName());
            tempParameter.setName("");

            parameterList.push_back(tempParameter);
    }
        | type_specifier id {
            logStream << "At line no: " << line_count << " parameter_list: type_specifier ID" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName(), "NON_TERMINAL");
            logStream << $$->getName() << endl;

            //Adding parameter to list            
            tempParameter.setType((string)$1->getName());
            tempParameter.setName((string)$2->getName());

            parameterList.push_back(tempParameter);
    }
        | type_specifier {
            logStream << "At line no: " << line_count << " parameter_list: type_specifier" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << endl;

            //Adding parameter to list
            tempParameter.setType((string)$1->getName());
            tempParameter.setName("");

            parameterList.push_back(tempParameter);
    }
    ;

compound_statement: LCURL embedded_in statements RCURL {
            logStream << "At line no: " << line_count << " compound_statement: LCURL statements RCURL" << "\n"  << endl;

            $$ = new SymbolInfo((string)"{ "+(string)"\n"+(string)$3->getName()+(string)"}"+(string)"\n", "NON_TERMINAL");  // NOTICE
            logStream << $$->getName() << endl;

            //Printing all scopetables before exiting current scopetable as per offline requirement
            symbolTable->printAllScopeTable(logStream);
            symbolTable->ExitScope();
    }
    | LCURL embedded_in RCURL {
            logStream << "At line no: " << line_count << " compound_statement: LCURL RCURL" << "\n"  << endl;

            $$ = new SymbolInfo((string)"{ "+(string)"\n"+(string)"\n"+(string)"}"+(string)"\n", "NON_TERMINAL");  // NOTICE
            logStream << $$->getName() << endl;

            //Printing all scopetables before exiting current scopetable as per offline requirement
            symbolTable->printAllScopeTable(logStream);
            symbolTable->ExitScope();
    }
        ;

embedded_in: {
            /* NOTICE: embedded action */
            symbolTable->EnterScope();

            /* If a new parameter list is applicable for new scope, we need to insert them into 
            SymbolTable as identifiers (variable) */

            //No params, or void provided
            if(parameterList.size()==1 && parameterList[0].getType()=="void") {
                //No actions necessary
            } 
            //At least one non-void param provided
            else {

                for(Parameter p : parameterList){
                    insertVariable(p.getType(), p.getName(), -1);
                }

            }

            //Clearing parameter list for next usage
            parameterList.clear(); 
    }
    ;
 		    
var_declaration: type_specifier declaration_list SEMICOLON {
            logStream << "At line no: " << line_count << " var_declaration: type_specifier declaration_list SEMICOLON" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)" "+(string)$2->getName()+(string)";"+(string)"\n"+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName();  << endl;

            tempTypeSpecifier = (string)$1->getName();
            if(tempTypeSpecifier == "void"){
                error << "Error at line no: " << line_count << " variable type can not be void " << "\n" << endl;
                errorCount++;

                tempTypeSpecifier = "float"; //by default, void type specifier, mistakenly provided, will be converted to floats
            }

            /* //NOTICE: symbolTable insertion
            if($1->getName() == "void") {
                error << "Error at line no: " << line_count << " variable type can not be void " << "\n" << endl;
                errorCount++;

                for(int i=0; i<var_list.size(); i++) {
                    insertVariable("float", var_list[i]);  // NOTICE: by default, void type variables are float type
                }
            } 
            else {
                for(int i=0; i<var_list.size(); i++) {
                    insertVariable((string)$1->getName(), var_list[i]);
                }
            }

            var_list.clear();
            */
    }
 	;
 		 
type_specifier: INT {
            //$$ = new SymbolInfo("int", "NON_TERMINAL");
            logStream << "At line no: " << line_count << " type_specifier: INT" << "\n"  << endl;
            logStream << "int" << "\n"  << endl;

            type = "int";
    }
 		| FLOAT {
            //$$ = new SymbolInfo("float", "NON_TERMINAL");
            logStream << "At line no: " << line_count << " type_specifier: FLOAT" << "\n"  << endl;
            logStream << "float" << "\n"  << endl;

            type = "float";
    }
 		| VOID {
            //$$ = new SymbolInfo("void", "NON_TERMINAL");
            logStream << "At line no: " << line_count << " type_specifier: VOID" << "\n"  << endl;
            logStream << "void" << "\n"  << endl;

            type = "void";
    }
 	;

id: ID {
            //$$ = new SymbolInfo((string)$1->getName(), "NON_TERMINAL");
            name = $1->getName();
    }
    ;
 		
declaration_list: declaration_list COMMA ID {
            logStream << "At line no: " << line_count << " declaration_list: declaration_list COMMA ID" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << endl;

            string variableName = (string)$3->getName();

            // Checking if variable was previously declared
            SymbolInfo* lookupNode = symbolTable->Lookup(variableName);

            if(lookupNode != NULL) {
                error << "Error at line no: " << line_count << " multiple declaration of " << variableName << "\n" << endl;
                errorCount++;
            }

            insertVariable(tempTypeSpecifier, variableName, -1); //-1 will be set as arraySize for denoting variable as identifier

            /* //keeping track of identifier(variable) 
            temp_var.var_name = (string)$3->getName();
            temp_var.var_size = -1;

            var_list.push_back(temp_var);
            */
    }
 		| declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {
            logStream << "At line no: " << line_count << " declaration_list: declaration_list COMMA ID LTHIRD CONST_INT RTHIRD" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)","+(string)$3->getName()+(string)"["+(string)$5->getName()+(string)"]", "NON_TERMINAL");
            logStream << $$->getName() << endl;

            string variableName = (string)$3->getName();
            int variableSize = atoi( (string)$5->getName() );

            // Checking if variable was previously declared
            SymbolInfo* lookupNode = symbolTable->Lookup(variableName);

            if(lookupNode != NULL) {
                error << "Error at line no: " << line_count << " multiple declaration of " << variableName << "\n" << endl;
                errorCount++;
            }

            insertVariable(tempTypeSpecifier, variableName, variableSize); //variableSize will be set as arraySize for array

            /* //keeping track of identifier(array)
            temp_var.var_name = (string)$3->getName();

            stringstream temp_str((string) $5->getName());
            temp_str >> temp_var.var_size;

            var_list.push_back(temp_var);
            */
    }
 		| ID {
            logStream << "At line no: " << line_count << " declaration_list: ID" << "\n"  << endl;

            //$$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << (string)$1->getName() << "\n"  << endl;

            string variableName = (string)$3->getName();

            // Checking if variable was previously declared
            SymbolInfo* lookupNode = symbolTable->Lookup(variableName);

            if(lookupNode != NULL) {
                error << "Error at line no: " << line_count << " multiple declaration of " << variableName << "\n" << endl;
                errorCount++;
            }

            insertVariable(tempTypeSpecifier, variableName, -1); //-1 will be set as arraySize for denoting variable as identifier

            /* //keeping track of identifier(variable) 
            temp_var.var_name = (string)$1->getName();
            temp_var.var_size = -1;

            var_list.push_back(temp_var);
            */
    }
 		| id LTHIRD CONST_INT RTHIRD {
            logStream << "At line no: " << line_count << " declaration_list: ID LTHIRD CONST_INT RTHIRD" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)"["+(string)$3->getName()+(string)"]", "NON_TERMINAL");
            logStream << $$->getName() << endl;

            string variableName = (string)$3->getName();
            int variableSize = atoi( (string)$5->getName() );

            // Checking if variable was previously declared
            SymbolInfo* lookupNode = symbolTable->Lookup(variableName);

            if(lookupNode != NULL) {
                error << "Error at line no: " << line_count << " multiple declaration of " << variableName << "\n" << endl;
                errorCount++;
            }

            insertVariable(tempTypeSpecifier, variableName, variableSize); //variableSize will be set as arraySize for array

            /* //keeping track of identifier(array) 
            temp_var.var_name = (string)$1->getName();

            stringstream temp_str((string) $3->getName());
            temp_str >> temp_var.var_size;

            var_list.push_back(temp_var);
            */
    }
 	;
 		  
statements: statement {
            logStream << "At line no: " << line_count << " statements: statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
	    | statements statement {
            logStream << "At line no: " << line_count << " statements: statements statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
	;
	   
statement: var_declaration {
            logStream << "At line no: " << line_count << " statement: var_declaration" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)$1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | expression_statement {
            logStream << "At line no: " << line_count << " statement: expression_statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | compound_statement {
            logStream << "At line no: " << line_count << " statement: compound_statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)$1->getName()+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | FOR LPAREN expression_statement embedded_exp embedded_void expression_statement embedded_exp embedded_void expression embedded_exp embedded_void RPAREN statement {
            logStream << "At line no: " << line_count << " statement: FOR LPAREN expression_statement expression_statement expression RPAREN statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)"for"+(string)"("+(string)$3->getName()+(string)$6->getName()+(string)$9->getName()+(string)")"+(string)$13->getName()+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | IF LPAREN expression embedded_exp RPAREN embedded_void statement %prec LOWER_THAN_ELSE {
            logStream << "At line no: " << line_count << " statement: IF LPAREN expression RPAREN statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)"if"+(string)"("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | IF LPAREN expression embedded_exp RPAREN embedded_void statement ELSE statement {
            logStream << "At line no: " << line_count << " statement: IF LPAREN expression RPAREN statement ELSE statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)"if"+(string)"("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)" else"+(string)$9->getName()+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | WHILE LPAREN expression embedded_exp RPAREN embedded_void statement {
            logStream << "At line no: " << line_count << " statement: WHILE LPAREN expression RPAREN statement" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)"while"+(string)"("+(string)$3->getName()+(string)")"+(string)$7->getName()+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | PRINTLN LPAREN ID RPAREN SEMICOLON {
            logStream << "At line no: " << line_count << " statement: PRINTLN LPAREN ID RPAREN SEMICOLON" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)"println"+(string)"("+(string)$3->getName()+(string)")"+(string)";"+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | RETURN expression SEMICOLON {
            logStream << "At line no: " << line_count << " statement: RETURN expression SEMICOLON" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)"return "+(string)$2->getName()+(string)";"+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            // Can not return void expression here 
            if($2->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;
            } 
    }
    ;

embedded_exp: {
            /* NOTICE: embedded action */
            type_final = type;
    }
        ;	

embedded_void: {
            
            /* void checking  */
            if(type_final == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

            } 
    }
    ;	
	  
expression_statement: SEMICOLON {
            logStream << "At line no: " << line_count << " expression_statement: SEMICOLON" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)";"+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            // type setting -> **************************
            $$->setReturnType("int");
            type = "int";
    }		
        | expression SEMICOLON {
            logStream << "At line no: " << line_count << " expression_statement: expression SEMICOLON" << "\n"  << endl;

            $$ = new SymbolInfo((string)"\t"+(string)$1->getName()+(string)";"+(string)"\n", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

           // type setting -> **************************
           $$->setReturnType($1->getReturnType());
           type = $1->getReturnType();
    }
    ;
	  
variable: ID {
            //Since it is not called as a function, it is a variable
            //This is not variable declaration, this is variable being used in an expression
            logStream << "At line no: " << line_count << " variable: ID" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;         

            /* declaration checking & type setting */
            SymbolInfo* temp = symbolTable->Lookup($1->getName());

            if(temp == NULL) {
                error << "Error at line no: " << line_count << " undeclared variable " << $1->getName() << "\n" << endl;
                errorCount++;
                
                //**********************************************************************************
                $$->setReturnType("float");  // NOTICE: by default, undeclared variables are of float type
            } 
            else { //Variable previously declared
                if(temp->getReturnType() != "void") $$->setReturnType(temp->getReturnType()); //void type checking

                else $$->setReturnType("float");  //matching function found with return type void, $$ modified(not required)
            }

            //Checking whether it is variable or not
            //Can be an array or a function with the same name
            if((temp!=NULL) && (temp->getArraySize()!=-1)) {
                error << "Error at line no: " << line_count << " type mismatch(not variable)" << "\n" << endl;
                errorCount++;
            }
    }
        | id LTHIRD expression RTHIRD {
            //An array
            logStream << "At line no: " << line_count << " variable: ID LTHIRD expression RTHIRD" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)"["+(string)$3->getName()+(string)"]", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* declaration checking & type setting */
            SymbolInfo* temp = symbolTable->Lookup($1->getName());

            if(temp == NULL) {
                error << "Error at line no: " << line_count << " undeclared variable " << $1->getName() << "\n" << endl;
                errorCount++;

                $$->setReturnType("float");  // NOTICE: by default, undeclared variables are of float type
            } 
            else { //Variable previously declared
                if(temp->getReturnType() != "void") $$->setReturnType(temp->getReturnType()); //void type checking

                else $$->setReturnType("float");  //matching function found with return type void, $$ modified(not required)
            }

            /* checking whether it is array or not */
            if((temp!=NULL) && (temp->getArraySize() < 0)) {
                error << "Error at line no: " << line_count << " type mismatch(not array)" << "\n" << endl;
                errorCount++;
            }

            //SemA:  Array index checking
            if($3->getReturnType() != "int") {
                error << "Error at line no: " << line_count << " non-integer array index" << "\n" << endl;
                errorCount++;
            }            

            //SemA: If it's a function, it cannot have void return type when called within an expression
            if($3->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;
            } 
    }
    ;
	 
expression: logic_expression {
            logStream << "At line no: " << line_count << " expression: logic_expression" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis might be required -> NOTICE: think about void function */
            $$->setReturnType($1->getReturnType());
            type = $1->getReturnType();
    }
        | variable ASSIGNOP logic_expression {
            logStream << "At line no: " << line_count << " expression: variable ASSIGNOP logic_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)" = "+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            //Void function cannot be called within expression
            if($3->getReturnType() == "void") {

                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                $3->setReturnType("float");  // by default, float type
            } 

            //Checking type consistency for assignment
            if($1->getReturnType() != $3->getReturnType()) {
                error << "Error at line no: " << line_count << " type mismatch(" << $1->get_Type() << "=" << $3->get_Type() << ")" << "\n" << endl;
                errorCount++;
            }

            $$->setReturnType($1->getReturnType());
            type = $1->getReturnType();
    }
    ;
			
logic_expression: rel_expression {
            logStream << "At line no: " << line_count << " logic_expression: rel_expression" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis might be required */
            $$->setReturnType($1->getReturnType());
    }
        | rel_expression LOGICOP rel_expression {
            logStream << "At line no: " << line_count << " logic_expression: rel_expression LOGICOP rel_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis (type-casting) might be required */

            /* void checking  */
            if($1->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
            } 

            if($3->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
            }

            /* type casting */
            $$->setReturnType("int");
    }
        ;
			
rel_expression: simple_expression {
            logStream << "At line no: " << line_count << " rel_expression: simple_expression" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis might be required */
            $$->setReturnType($1->getReturnType());
    }
		| simple_expression RELOP simple_expression	{
            logStream << "At line no: " << line_count << " rel_expression: simple_expression RELOP simple_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis (type-casting) might be required */

            /* void checking  */
            if($1->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
            } 

            if($3->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
            }

            /* type casting */
            $$->setReturnType("int");
    }
		;
				
simple_expression: term {
            logStream << "At line no: " << line_count << " simple_expression: term" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl; 

            /* type setting  */
            $$->setReturnType($1->getReturnType());
    }
        | simple_expression ADDOP term {
            logStream << "At line no: " << line_count << " simple_expression: simple_expression ADDOP term" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis (type-casting) required  */

            /* void checking  */
            if($1->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                 $1->setReturnType("float");  // by default, float type
            } 

            if($3->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                $3->setReturnType("float");  // by default, float type
            }

            /* type setting (with type casting if required) */
            if($1->getReturnType()=="float" || $3->getReturnType()=="float") {
                $$->setReturnType("float");
            } else {
                $$->setReturnType($1->getReturnType());  // basically, int
            }
    }
    ;
					
term: unary_expression {
            logStream << "At line no: " << line_count << " term: unary_expression" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting  */
            $$->setReturnType($1->getReturnType());
    }
        |  term MULOP unary_expression {
            logStream << "At line no: " << line_count << " term: term MULOP unary_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName()+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis (type-casting, mod-operands checking) required */

            /* void checking  */
            if($1->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
                $1->setReturnType("float");  // by default, float type
            } 

            if($3->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
                $3->setReturnType("float");  // by default, float type
            } 

            /* type setting (with semantic analysis) */
            if(($2->getName() == "%") && ($1->getReturnType() != "int" || $3->getReturnType() != "int")) {
                /* type-checking for mod operator */
                error << "Error at line no: " << line_count << " operand type mismatch for modulus operator" << "\n" << endl;
                errorCount++;

                $$->setReturnType("int");  // type-conversion
            } else if(($2->getName() != "%") && ($1->getReturnType() == "float" || $3->getReturnType() == "float")) {
                $$->setReturnType("float");  // type-conversion
            } else {
                $$->setReturnType($1->getReturnType());
            }
    }
    ;

unary_expression: ADDOP unary_expression {
            logStream << "At line no: " << line_count << " unary_expression: ADDOP unary_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)$2->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* void checking  */
            if($2->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
                $$->setReturnType("float");  // by default, float type
            } else {
                /* type setting */
                $$->setReturnType($2->getReturnType());
            }
    }  
        | NOT unary_expression {
            logStream << "At line no: " << line_count << " unary_expression: NOT unary_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)"!"+(string)$2->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* void checking */
            if($2->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
            }

            /* type casting */
            $$->setReturnType("int");
    }
        | factor {
            logStream << "At line no: " << line_count << " unary_expression: factor" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting */
            $$->setReturnType($1->getReturnType());
    }
        ;
	
factor: variable {
            logStream << "At line no: " << line_count << " factor: variable" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting */
            $$->setReturnType($1->getReturnType());
    }
        | id LPAREN argument_list RPAREN {
            logStream << "At line no: " << line_count << " factor: ID LPAREN argument_list RPAREN" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)"("+(string)$3->getName()+(string)")", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting -> NOTICE: semantic analysis (matching argument_list with parameter_list) required */
            SymbolInfo* temp = symbolTable->Lookup($1->getName());

            if(temp == NULL) {
                /* no such id found */
                error << "Error at line no: " << line_count << " no such identifier found" << "\n" << endl;
                errorCount++;

                $$->set_Type("float");  // NOTICE: by default, float type

            } else if(temp->getArraySize() != -3) {
                /* no such function definition found */
                error << "Error at line no: " << line_count << " no such function definition found" << "\n" << endl;
                errorCount++;

                $$->setReturnType("float");  // NOTICE: by default, float type

            } 
            else {
                /* matching argument with parameter list */
                if(temp->getParameterListSize()==1 && arg_list.size()==0 && temp->getParameter(0).getType()=="void") {
                    /* consistent function call & type setting */
                    $$->setReturnType(temp->getReturnType());

                } 
                else if(temp->getParameterListSize() != arg_list.size()) {
                    /* inconsistent function call */
                    error << "Error at line no: " << line_count << " inconsistent function call" << "\n" << endl;
                    errorCount++;

                    $$->setReturnType("float");  // NOTICE: by default, float type

                } 
                else {
                    int i;

                    for(i=0; i<arg_list.size(); i++) {
                        if(temp->getParameter(i).getType() != arg_list[i]) {
                            break;
                        }
                    }

                    if(i != arg_list.size()) {
                        /* inconsistent function call */
                        error << "Error at line no: " << line_count << " inconsistent function call" << "\n" << endl;
                        errorCount++;

                        $$->setReturnType("float");  // NOTICE: by default, float type

                    } else {
                        /* consistent function call & type setting */
                        $$->setReturnType(temp->getReturnType());
                    }
                }
            }

            arg_list.clear();  // NOTICE
    }
        | LPAREN expression RPAREN {
            logStream << "At line no: " << line_count << " factor: LPAREN expression RPAREN" << "\n"  << endl;

            $$ = new SymbolInfo((string)"("+(string)$2->getName()+(string)")", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* void checking  */
            if($2->getReturnType() == "void") {
                /* void function call within expression */
                error << "Error at line no: " << line_count << " void function called within expression" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
                $2->setReturnType("float");  // by default, float type
            } 

            /* type setting */
            $$->setReturnType($2->getReturnType());
    }
        | CONST_INT {
            logStream << "At line no: " << line_count << " factor: CONST_INT" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting */
            $$->setReturnType("int");
    }
        | CONST_FLOAT {
            logStream << "At line no: " << line_count << " factor: CONST_FLOAT" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting */
            $$->setReturnType("float");
    }
        | variable INCOP {
            logStream << "At line no: " << line_count << " factor: variable INCOP" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)"++", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting */
            $$->setReturnType($1->getReturnType());
    }
        | variable DECOP {
            logStream << "At line no: " << line_count << " factor: variable DECOP" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)"--", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* type setting */
            $$->setReturnType($1->getReturnType());
    }
    ;
	
argument_list: arguments {
            logStream << "At line no: " << line_count << " argument_list: arguments" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        | {
            //Empty/ epsilin production rule************************************
            logStream << "At line no: " << line_count << " argument_list: <epsilon-production>" << "\n"  << endl;
            
            $$ = new SymbolInfo("", "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;
    }
        ;
	
arguments: arguments COMMA logic_expression {
            logStream << "At line no: " << line_count << " arguments: arguments COMMA logic_expression" << "\n"  << endl;

            $$ = new SymbolInfo((string)$1->getName()+(string)", "+(string)$3->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* void checking  */
            if($3->getReturnType() == "void") {
                /* void function call within argument of function */
                error << "Error at line no: " << line_count << " void function called within argument of function" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
                $3->setReturnType("float");  // by default, float type
            } 

            /* keeping track of encountered argument */
            arg_list.push_back($3->getReturnType());
    }
        | logic_expression {
            logStream << "At line no: " << line_count << " arguments: logic_expression" << "\n"  << endl;

            $$ = new SymbolInfo($1->getName(), "NON_TERMINAL");
            logStream << $$->getName() << "\n"  << endl;

            /* void checking  */
            if($1->getReturnType() == "void") {
                /* void function call within argument of function */
                error << "Error at line no: " << line_count << " void function called within argument of function" << "\n" << endl;
                errorCount++;

                /* type setting (if necessary) */
                $1->setReturnType("float");  // by default, float type
            } 

            /* keeping track of encountered argument */
            arg_list.push_back($1->getReturnType());
    }
    ;
 

%%


int main(int argc, char* argv[]) {
	if(argc != 2) {
		cout << "Input file name not provided for parsing." << endl;
		return 0;
	}

    input = fopen(argv[1], "r");

    if(input == NULL) {
		cout << "input file not opened properly, terminating program..." << endl;
		exit(0);
	}

	logStream.open("2005105_log.txt", ios::out);
	error.open("2005105_error.txt", ios::out);
	
	if(logStream.is_open() != true) {
		cout << "Log file not available" << endl;
		fclose(input);
		
		exit(0);
	}
	
	if(error.is_open() != true) {
		cout << "Error file not available" << endl;
		fclose(input);
		logStream.close();
		
		exit(0);
	}
	
    int scopeTablesSize = 10;
	ScopeTable* scopeTable = new ScopeTable(scopeTablesSize);
    symbolTable = new SymbolTable(scopeTable, scopeTablesSize, logStream);
	
	yyin = input;
    yyparse();  // processing starts

    logStream << endl;
	symbolTable->printAllScopeTable(logStream);
	symbolTable->ExitScope();

	logStream << "Total Lines: " << (--line_count) << endl;  // NOTICE here: line_count changed (July 19) -> works for sample
	logStream << "\n" << "Total Errors: " << errorCount << endl;
    error << "\n" << "Total Errors: " << errorCount << endl;
	
	fclose(yyin);
	logStream.close();
	error.close();
	
	return 0;
} 

void yyerror(string s) {
    /* it may be modified later */
    logStream << "At line no: " << line_count << " " << s << endl;

    line_count++;
    errorCount++;
    
    return ;
}