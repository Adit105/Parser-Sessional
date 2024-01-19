#include <bits/stdc++.h>

using namespace std;

class Parameter{
    string name;
    string type;

public:
    Parameter(string Name, string Type){
        name = Name; type = Type;
    }
    Parameter(string Type){
        name = ""; type = Type;
    }

    //Setters Getters
    void setName(string Name) { name = Name; }
    string getName() { return name; }

    void setType(string Type) { type = Type; }
    string getType() { return type; }
}

class SymbolInfo{

    string name;
    string type;
    SymbolInfo* Next;

    //Additional info for parser generation
    string returnType; //Set to return type for function, set to type for variable/array
    int arraySize; //Set to array size for arrays
                      //Further used for separating variables(-1), function declarations(-2) and 
                      //function definitions(-3) in identifier group

    vector<Parameter> parameterList;

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

        this->setParameterList(node->getParameterList());
    }

    //Setters Getters
    //For name
    void setName(string Name){ name = Name; }
    string getName() { return name; }

    //For type
    void setType(string Type) { type = Type; }
    string getType(){ return type; }

    //For next pointer
    void setNext(SymbolInfo* &next){ Next = next; }
    SymbolInfo* getNext(){ return Next; }

    void setReturnType(string rType){ returnType = rType; }
    string getReturnType() { return returnType; }

    void setArraySize(int aSize) { arraySize = aSize; }
    int getArraySize() { return arraySize; }

    void setParameterList(vector<Parameter> pList){ parameterList = pList; }
    vector<Parameter> getParameterList() { return parameterList; }

    void addToParameterList(Parameter param){ parameterList.push_back(param); } 
    Parameter getParameter(int index) { return parameterList[index]; }

    int getParameterListSize(){ return parameterList.size(); }
    void clearParameterList() { parameterList.clear(); }

};