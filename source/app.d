import std.stdio, std.file, std.conv, std.string, core.exception;

struct Element{
    int atomicNumber;
    string atomicSymbol;
    string elementName;
}

class Word{
    string part;
    Word[] subsets;
    Element represents = {-1};
    bool isTopLevel;

    this(string word, string part = null){
        this.isTopLevel = part is null;
        this.part = (this.isTopLevel)? word : part;
        try{
            this.represents = elementList[part.toLower];
            this.part = this.represents.atomicSymbol;
        }catch(RangeError e){}
        if(word.length > 0){
            this.subsets ~= new Word(word[1..$], word[0..1]);
        }
        if(word.length > 1){
            this.subsets ~= new Word(word[2..$], word[0..2]);
        }
    }

    private int getAmtOfElements(){
        int selfInfo = (this.represents.atomicNumber != -1)? 1 : 0;
        if(this.subsets is null){
            return selfInfo;
        }
        int total = selfInfo;
        foreach(subset; this.subsets){
            total += subset.getAmtOfElements;
        }
        return total;
    }

    private int getAmtOfProtons(){
        int selfInfo = (this.represents.atomicNumber == -1)? 0 : this.represents.atomicNumber;
        if(this.subsets is null){
            return selfInfo;
        }
        int total = selfInfo;
        foreach(subset; this.subsets){
            total += subset.getAmtOfProtons;
        }
        return total;
    }

    Word[] wordByChunks(){
        auto word = (this.isTopLevel)? null : [this];
        if(this.subsets.length != 0){
            if(this.subsets.length == 1){
                word ~= subsets[0].wordByChunks;
            }else if(this.subsets[0].getAmtOfElements != this.subsets[1].getAmtOfElements){
                word ~= this.subsets[(this.subsets[0].getAmtOfElements > this.subsets[1].getAmtOfElements)? 0 : 1].wordByChunks;
            }else if(this.subsets[0].getAmtOfProtons != this.subsets[1].getAmtOfProtons){
                word ~= this.subsets[(this.subsets[0].getAmtOfProtons > this.subsets[1].getAmtOfProtons)? 0 : 1].wordByChunks;
            }else{
                word ~= this.subsets[0].wordByChunks;
            }
        }
        return word;
    }

    override string toString(){
        string representation;
        foreach(chunk; this.wordByChunks){
            representation ~= chunk.part;
        }
        return representation;
    }

    string[] asElements(){
        string[] pieces;
        foreach(chunk; this.wordByChunks){
            pieces ~= (chunk.represents.atomicNumber != -1)? chunk.represents.elementName : chunk.part;
        }
        return pieces;
    }
}

Element[string] elementList;

void main(){
    foreach(line; File("C:\\Users\\Saurabh Totey\\Documents\\Programming\\Workspace\\ChemSpelling\\source\\elementlist.csv").byLineCopy){
        auto elementInfo = line.split(",");
        elementList[elementInfo[1].toLower] = Element(elementInfo[0].to!int, elementInfo[1], elementInfo[2].strip);
    }
    auto input = readln.strip.split(" ");
    Word[] chemWords;
    foreach(word; input){
        chemWords ~= new Word(word);
        write(chemWords[$ - 1].toString ~ " ");
    }
    writeln;
    foreach(index; 0..chemWords.length){
        write(chemWords[index].asElements, " ");
    }
}
