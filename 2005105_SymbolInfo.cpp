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

//For parse Tree, creating a class for the treeNodes
//Indicates the part of the input file that matched a production rule
class parseTreeNode{
    int startLine; //line_count where the node started
    int endLine; //line_count where the node ended

    string name; //Actual part from the file that matched
    string productionRule; //The rule that it matched with

    vector<parseTreeNode*> childProductionList;

    public:
    parseTreeNode(int sl, int el, string Name, string pr){
        startLine = sl; endLine = el;
        name = Name; productionRule = pr;
    }

    //Setters getters
    void setStartLine(int sl) { startLine = sl; }
    int getStartLine() { return startLine; }

    void setEndLine(int el) { endLine = el; }
    int getEndLine() {return endLine; }

    void setName(string Name) { name = Name; }
    string getName() { return name; }

    void setProductionRule(string pr) { productionRule = pr; }
    string getProductionRule() { return productionRule; }

    void setChildProductionList(vector<parseTreeNode*> list){ childProductionList = list; }
    vector<parseTreeNode*> getChildProductionList() { return childProductionList; }

    string getProduction_withLine(){
        string productionLine = productionRule + "\t" + "<Line: " + startLine + "-" + endLine + ">" + "\n"; 
        return productionLine;
    }

    string getName_withLine(){
        string nameLine = name + "\t" + "<Line: " + startLine + ">" + "\n"; 
        return nameLine;
    }

    void addToChildProductionList(parseTreeNode* &pNode){ childProductionList.push_back(pNode); }
    parseTreeNode* getChildProduction(int index){ return childProductionList[index]; }

    int getChildProductionListSize() { return childProductionList.size(); }
    void clearChildProductionList() { childProductionList.clear(); }
}

class parseTree{
    parseTreeNode *root;

    parseTree(parseTreeNode* &Root){
        root = Root;
    }

    parseTree() {}
    void setRoot(parseTreeNode* &Root){ root = Root; }
    parseTreeNode* getRoot() { return root; }

    void printParseTree(){
        recursivePrintParseTree(root, 0);
    }

    void recursivePrintParseTree(parseTreeNode* pNode, int spaceCount){

        for(int i=0; i<spaceCount; i++){
            cout<<" ";
        }

        cout<<pNode.getProduction_withLine()<<endl;

        int childProductionListSize = pNode.getChildProductionListSize();
        if(childProductionListSize > 0){
            for(int i=0; i<childProductionListSize; i++){
                recursivePrintParseTree(pNode.getChildProduction(i), spaceCount+1);
            }
        }

        return;
    }
}

//In symbolInfo, all identifiers have the type = ID
//Variables have arraySize = -1, function declarations = -2, definitions = -3
//Arrays have their own arraySize, which is >= 0
//Variable/array type, or function return type is stored in returnType;

class SymbolInfo{

    string name;
    string type;
    SymbolInfo* Next;

    //Additional info for parser generation
    string returnType; //Set to return type for function, set to type for variable/array
    int arraySize; //Set to array size for arrays
                      //Further used for separating variables(-1), function declarations(-2) and 
                      //function definitions(-3) in identifier group

    vector<Parameter> parameterList; //For function identifiers

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