#include <bits/stdc++.h>
#include "2005105_SymbolInfo.cpp"

using namespace std;

class ScopeTable{

    string scopeTableID;
    int tableSize;
    SymbolInfo** scopeTable;
    ScopeTable* parentScopeTable;
    int childCount;

public:

    //Getters Setters
    //For scopeTableID
    void setScopeTableID(string tableid){ scopeTableID = tableid; }
    string getScopeTableID() { return scopeTableID; }

    //For tableSize
    void setTableSize(int n){ tableSize = n; }
    int getTableSize(){ return tableSize; }

    //For scopeTable
    void setScopeTable() {
        scopeTable = new SymbolInfo*[tableSize];
        for(int i=0; i<tableSize; i++)
            scopeTable[i] = NULL;
     }
    SymbolInfo** getScopeTable(){ return scopeTable; }

    //For child Count
    void setChildCount(int n) { childCount = n; }
    int getChildCount() { return childCount; }

    //For parent ScopeTable
    void setParentScopeTable(ScopeTable* &parentST){ parentScopeTable = parentST; }
    ScopeTable* getParentScopeTable() { return parentScopeTable; }

    //Constructors
    ScopeTable(int n){

        tableSize = n;
        scopeTable = new SymbolInfo*[tableSize];
        for(int i=0; i<tableSize; i++)
            scopeTable[i] = NULL;

        parentScopeTable = NULL;
    }

    //Destructor
    ~ScopeTable(){
        for(int i=0; i<tableSize; i++)
            delete scopeTable[i];
        
        delete scopeTable;
    }

    //Elemental operations at the scopeTable
    //Helper functions for the major functions at the scopeTable

    //Inserting an element at a certain position
    bool setAtScopeTable(int position, SymbolInfo* &newNode){

        int chainCount = 1;
        //Postion at scopeTable not empty
        if(scopeTable[position]){

            //Finding last position to insert new node
            SymbolInfo* symbolInfoNode = scopeTable[position];
            while(symbolInfoNode){

                //If node is already inserted, returns false
                if((symbolInfoNode->getName()==newNode->getName())){
                    //outstream<<"'"<<newNode->getName()<<"' already exists in the current ScopeTable# "<<this->getScopeTableID()<<endl;
                    return false;
                }
                if(symbolInfoNode->getNext()){
                    symbolInfoNode = symbolInfoNode->getNext();
                    chainCount += 1;
                }
                else{
                    chainCount += 1;
                    symbolInfoNode->setNext(newNode);
                    //outstream<<"Inserted  at position <"<<position+1<<", "<<chainCount<<">"<<" of ScopeTable# "<<this->getScopeTableID()<<endl;
                    return true;
                }               
            }
        }

        //Postion at scopeTable empty
        else{
            scopeTable[position] = newNode;
            //outstream<<"Inserted  at position <"<<position+1<<", "<<chainCount<<">"<<" of ScopeTable# "<<this->getScopeTableID()<<endl;
            return true;
        }

        //By default
        return false;
    }

    //Looking up an element at a certain position
    SymbolInfo* lookUpElementAtScopeTable(int position, string name){

        //No element at the position
        if(!scopeTable[position]) return NULL;

        else{
            int chainCount =1;

            //Checking all nodes at position
            SymbolInfo* symbolInfoNode = scopeTable[position];
            do{
                
                //Finding match with desired element
                if( (symbolInfoNode->getName()==name) ){
                    //outstream<<"'"<<name<<"' found at position <"<<position+1<<", "<<chainCount<<"> of ScopeTable# "<<this->getScopeTableID()<<endl;
                    return symbolInfoNode;
                }
                chainCount++;
                symbolInfoNode = symbolInfoNode->getNext();
            }
            while(symbolInfoNode);

        }

        //By default
        return NULL;
    }

    bool deleteFromScopeTable(int position, string name){
        
        //No element at the position
        if(!scopeTable[position]){
            //outstream<<"Not found in the current ScopeTable# "<<this->getScopeTableID()<<endl;
            return false;
        }

        else{
            int chainCount = 1;
            //Checking all nodes at the position
            SymbolInfo* symbolInfoNode = scopeTable[position];
            //Finding match with the first node at that position
                if((symbolInfoNode->getName()==name)){
                    scopeTable[position] = symbolInfoNode->getNext();

                    delete symbolInfoNode;
                    //outstream<<"Deleted '"<<name<<"' from position <"<<position+1<<", "<<chainCount<<"> of ScopeTable# "<<this->getScopeTableID()<<endl;
                    return true;
                }


            while(symbolInfoNode->getNext()){
                
                chainCount += 1;

                //Finding match with the other nodes at the position
                if((symbolInfoNode->getNext()->getName()==name)){
                    SymbolInfo* prevNode = symbolInfoNode;
                    symbolInfoNode = symbolInfoNode->getNext();
                    SymbolInfo* nextNode = symbolInfoNode->getNext();

                    prevNode->setNext(nextNode);
                    delete symbolInfoNode;
                    //outstream<<"Deleted '"<<name<<"' from position "<<" <"<<position+1<<", "<<chainCount<<"> of ScopeTable# "<<this->getScopeTableID()<<endl;
                    return true;
                }
                symbolInfoNode = symbolInfoNode->getNext();
            }

        }

        //By default
        //outstream<<"Not found in the current ScopeTable# "<<this->getScopeTableID()<<endl;
        return false;
    }

    //Elemental operations at the scopeTable
    //Helper functions for the major functions at the scopeTable


    //Hash Function for Table Operation
    unsigned long long sdbmHashFunction(string name){
        unsigned long long hash = 0;
        int c;

        for(int i=0; i<name.length(); i++){
            c = (int)name[i];
            hash = c + (hash<<6) + (hash<<16) - hash;
        }

        return hash%tableSize;
    }


    //Major operations on scopeTable for public use
    //Returning true if successful, false otherwise
    bool Insert(string name, string type){
        SymbolInfo* newSymbolInfo = new SymbolInfo(name, type);
        
        int hashValue = sdbmHashFunction(name);
        if(this->setAtScopeTable(hashValue, newSymbolInfo)) return true;
        
        return false;
    }

    bool Insert(SymbolInfo* &newSymbolInfo){
        
        int hashValue = sdbmHashFunction(newSymbolInfo->getName());
        if(this->setAtScopeTable(hashValue, newSymbolInfo)) return true;
        
        return false;
    }

    SymbolInfo* Lookup(string name){

        int hashValue = sdbmHashFunction(name);
        SymbolInfo* lookupNode = this->lookUpElementAtScopeTable(hashValue, name);
        if(lookupNode) return lookupNode;
        
        return NULL;
    }

    bool Delete(string name){

        int hashValue = sdbmHashFunction(name);
        if(this->deleteFromScopeTable(hashValue, name)) return true;

        return false;
    }

    void Print(ofstream &outstream){
        outstream<<"ScopeTable# "<<this->getScopeTableID()<<endl<<"\t";

        for(int i=0; i<tableSize; i++){
            outstream<<i+1;

            SymbolInfo* currentNode = scopeTable[i];
            if(currentNode){
                while(currentNode){
                    outstream<<" --> ("<<currentNode->getName()<<","<<currentNode->getType()<<")";
                    currentNode = currentNode->getNext();
                }
            }

            outstream<<endl;
            if(i<tableSize-1) outstream<<"\t";
        }
        
        return;
    }

};