#include <bits/stdc++.h>
#include "2005105_Scopetable.cpp"

using namespace std;

class SymbolTable{

    ScopeTable* root;
    ScopeTable* currentScopeTable;
    int scopeTablesSize;

    public:

    //Getters Setters
    //For root scopetable
    void setRoot(ScopeTable* &node){ root = node; }
    ScopeTable* getRoot() { return root; }

    //For current scopetable
    void setCurrentScopeTable(ScopeTable* &newCurrentTable) { currentScopeTable = newCurrentTable; }
    ScopeTable* getCurrentScopeTable() { return currentScopeTable; }

    //For all scopetable size
    void setScopeTablesSize( int n ) { scopeTablesSize = n; }
    int getScopeTableSize() { return scopeTablesSize; }

    //Constructors
    SymbolTable(ScopeTable* &node, int n, ofstream &outstream){
        scopeTablesSize = n;

        node->setScopeTableID("1");
        node->setChildCount(0);

        root = node;
        currentScopeTable = root;

        //outstream<<"\tScopeTable# "<<root->getScopeTableID()<<" created"<<endl;
    }

    //Destructor
    ~SymbolTable(){
        delete root;
    }

    //Entering a new scope
    bool EnterScope(){
        ScopeTable* newScopeTable = new ScopeTable(scopeTablesSize);

        ScopeTable* newParentScopeTable = currentScopeTable;
        currentScopeTable = newScopeTable;

        newParentScopeTable->setChildCount(newParentScopeTable->getChildCount()+1);

        currentScopeTable->setScopeTableID( newParentScopeTable->getScopeTableID() + "."+to_string(newParentScopeTable->getChildCount()) );
        currentScopeTable->setChildCount(0);
        currentScopeTable->setParentScopeTable(newParentScopeTable);

        //outstream<<"ScopeTable# "<<currentScopeTable->getScopeTableID()<<" created"<<endl;
        return true;
    }

    //Exiting current scope
    bool ExitScope(){

        if(currentScopeTable==root){
            //outstream<<"ScopeTable# "<<root->getScopeTableID()<<" cannot be deleted"<<endl;
            return false;
        }
        ScopeTable* exitingScopeTable = currentScopeTable;
        currentScopeTable = exitingScopeTable->getParentScopeTable();

        string exitingScopeTableID = exitingScopeTable->getScopeTableID();
        delete exitingScopeTable;
        //outstream<<"ScopeTable# "<<exitingScopeTableID<<" deleted"<<endl;
        return true;
    }

    bool Insert(string name, string type){
        return currentScopeTable->Insert(name, type);
    }

    bool Delete(string name){
        return currentScopeTable->Delete(name);
    }

    bool Lookup(string name){

        ScopeTable* lookupTable = currentScopeTable;
        
        while(lookupTable){
            bool found = lookupTable->Lookup(name);
            if(found) return true;
            else lookupTable = lookupTable->getParentScopeTable();
        }

        //outstream<<"'"<<name<<"' not found in any of the ScopeTables"<<endl;
        return false;
    }

    void printCurrentScopeTable(ofstream &outstream){
        currentScopeTable->Print(outstream);
        return;
    }

    void printAllScopeTable(ofstream &outstream){

        ScopeTable* printTable = currentScopeTable;

        while(printTable){
            printTable->Print(outstream);
            printTable = printTable->getParentScopeTable();
            if(printTable) outstream<<"\t";
        }

        return;
    }

    void FreeAllScopeTables(){
        ScopeTable* temp = currentScopeTable;

        while(currentScopeTable){
            currentScopeTable = temp->getParentScopeTable();

            string tempScopeTableID = temp->getScopeTableID();
            delete temp;
            //outstream<<"ScopeTable# "<<tempScopeTableID<<" deleted"<<endl<<"\t";
            
            temp = currentScopeTable;
        }
    }

};