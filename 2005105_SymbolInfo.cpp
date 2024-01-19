#include <bits/stdc++.h>

using namespace std;

class SymbolInfo{

    string name;
    string type;
    SymbolInfo* Next;

public:

    SymbolInfo(){}
    SymbolInfo(string Name, string Type){
        name = Name;
        type = Type;
        Next = NULL;
    }
        SymbolInfo(SymbolInfo* &node){
        name = node->getName();
        type = node->getType();
        Next = node->getNext();
    }

    //Setters Getters
    //For name
    void setName(string Name){
        name = Name;
    }
    string getName(){
        return name;
    }

    //For type
    void setType(string Type){
        type = Type;
    }
    string getType(){
        return type;
    }

    //For next pointer
    void setNext(SymbolInfo* &next){
        Next = next;
    }

    SymbolInfo* getNext(){
        return Next;
    }

};