#include <bits/stdc++.h>
#include "2005105_Symboltable.cpp"

using namespace std;

class actionController{
    SymbolTable* symbolTable;
    string opcode;
    string symbolName;
    string symbolType;
    string validCommands[7] = {"I", "D", "L", "P", "E", "S", "Q"};

public:
    //Constructors
    actionController(SymbolTable* newSt){
        symbolTable = newSt;
    }

    //Destructor
    ~actionController(){
        delete symbolTable;
    }

    //Checks if given command is a valid command
    bool commandValidity(){
        for(string str: validCommands){
            if(str==opcode) return true;
        }
        return false;
    }

    //Checks if given command has valid arguments
    bool argumentCountValidity(string commandLine){
        char delimiter = ' ';
        int argumentCount = -1;

        //Splitting commandLine into words and
        //Storing opcode with operands
        stringstream commandStr(commandLine);
        string word;
        while(!commandStr.eof()){

            getline(commandStr, word, delimiter);

            argumentCount += 1;
            if(argumentCount==0) opcode = word;
            if(argumentCount==1) symbolName = word;
            if(argumentCount==2) symbolType = word;

            //cout<<word<<endl;
        }

        //Returning false for all invalid argument counts
        if(argumentCount > 2) return false;
        if( opcode=="I" && (argumentCount!=2) ) return false;
        if( opcode=="D" && (argumentCount!=1) ) return false;
        if( opcode=="L" && (argumentCount!=1) ) return false;
        if( opcode=="P" && (argumentCount!=1) ) return false;
        if( opcode=="E" && (argumentCount!=0) ) return false;
        if( opcode=="S" && (argumentCount!=0) ) return false;

        return true;
    }

    bool commandExecution(string commandLine, ofstream &outstream){
        if(!argumentCountValidity(commandLine)){
            outstream<<"Wrong number of arguments for the command "<<opcode<<endl;
            return false;
        }
        if(!commandValidity()){
            outstream<<"Invalid command"<<endl;
            return false;
        }

        if(opcode=="I"){
            symbolTable->Insert(symbolName, symbolType, outstream);
        }
        if(opcode=="D"){
            symbolTable->Delete(symbolName, outstream);
        }
        if(opcode=="L"){
            symbolTable->Lookup(symbolName, outstream);
        }
        if(opcode=="S"){
            symbolTable->EnterScope(outstream);
        }
        if(opcode=="E"){
            symbolTable->ExitScope(outstream);
        }
        if(opcode=="P"){
            if(symbolName=="C"){
                symbolTable->printCurrentScopeTable(outstream);
            }
            else if(symbolName=="A"){
                symbolTable->printAllScopeTable(outstream);
            }
            else{
                outstream<<"Invalid argument for the command P"<<endl;
            }
        }
        if(opcode=="Q"){
            symbolTable->FreeAllScopeTables(outstream);
        }
        
    }
};

/*

int main(void){

    //Initiating file operations
    ifstream instream("input.txt");
    if(!instream){
        cout<<"Input file not available"<<endl;
        return -1;
    }
    ofstream outstream("output.txt");
    if(!outstream){
        cout<<"Output file not available"<<endl;
        return -2;
    }

    int commandCount = 0;
    string commandLine;

    int scopeTablesSize;
    instream>>scopeTablesSize;

    //Root scopetable for global scope, with new SymbolTable
    ScopeTable* scopeTable = new ScopeTable(scopeTablesSize);
    SymbolTable* symbolTable = new SymbolTable(scopeTable, scopeTablesSize, outstream);
    actionController ac(symbolTable);

    //Reading and passing command for execution
    getline(instream, commandLine);
    while(!instream.eof()){
        commandCount++;
        getline(instream, commandLine);
        outstream<<"Cmd "<<commandCount<<": " <<commandLine<<"\r\t";

        ac.commandExecution(commandLine, outstream);
    }

    //Closing file operations
    instream.close();
    outstream.close();
    return 0;
}

*/


//g++ -o main 2005105_main.cpp
