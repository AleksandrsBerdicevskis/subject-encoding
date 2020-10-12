#require 'translit'

PATH = ARGV[0]

THRESHOLD_SUBJ = 0
THRESHOLD_TOTAL = 0

PRONOUNS = {"rus"=>["я", "ты", "мы", "вы", "он", "она", "оно", "они"], "ukr" => ["я", "ти", "ми", "ви", "він", "вона", "воно", "вони"], "pol"=>["ja","ty","my","wy","on","ona","ono","oni","one"], "cze"=>["já","ty","my","vy","on","ona","ono","oni","ony","one"], "slk"=>["ja","ty","my","vy","on","ona","ono","oni","ony"], "srb"=>["ja","ti","mi","vi","on","ona","ono","oni","one"], "crt"=>["ja","ti","mi","vi","on","ona","ono","oni","one"],"blg"=>["аз", "ти", "ние", "вие", "той", "тя", "то", "те"], "slv"=>["jaz","ti","mi","vi","on","ona","ono","oni","one"], "bel"=>["я", "ты", "мы", "вы", "ён", "яна", "яно", "яны"], "hsb" => ["ja", "ty", "wón", "wona", "wono", "my", "wy"]}
PRONOUNS12 = {"rus"=>["я", "ты", "мы", "вы"], "ukr" => ["я", "ти", "ми", "ви"],"pol"=>["ja","ty","my","wy"], "cze"=>["já","ty","my","vy"],"slk"=>["ja","ty","my","vy"], "srb"=>["ja","ti","mi","vi"],"crt"=>["ja","ti","mi","vi"],"blg"=>["аз", "ти", "ние", "вие"],"slv"=>["jaz","ti","mi","vi"], "bel"=>["я", "ты", "мы", "вы"], "hsb" => ["ja", "ty", "my", "wy"]}
#in Slovenian treebank mi and vi are actually forms of ja and ti, the same is true for Upper Sorbian (and for dual in both languages). Not a problem for us.

RELHASH = {"conj" => "coord", "parataxis" => "coord", "csubj" => "subord", "ccomp" => "subord", "xcomp" => "subord", "advcl" => "subord", "acl" => "subord", "root" => "main"}
CHECK_COORD = false

def check_for_subj_child(hash, sentence, lang)
    nosubject = true
    pronsubject = false
    pron12subject = false
    if !hash["children"].nil?
        hash["children"].each do |child|
        if sentence[child]["rel"].include?("subj") #both csubj and nsubj! both pass and non-pass
        #expressed = 1
        nosubject = false
        if PRONOUNS[lang].include?(sentence[child]["lemma"])
            pronsubject = true
            if PRONOUNS12[lang].include?(sentence[child]["lemma"])
             pron12subject = true
            end
        end
        
            break                
            end
        end
    end
    return [nosubject,pronsubject,pron12subject]
end

def check_for_subord_child(hash, sentence)
    subord = false
    if !hash["children"].nil?
        hash["children"].each do |child|
            if RELHASH[sentence[child]["rel"].split(":")[0]] == "subord"
                subord = true
                break                
            end
        end
    end
    return subord
end



files = {"bel" => "Belarusian.conllu", "rus"=>"Russian.conllu", "ukr" => "Ukrainian.conllu", "pol" => "Polish.conllu", 
"cze" => "Czech.conllu", "slk" => "Slovak.conllu", "blg" => "Bulgarian.conllu", "slv" => "Slovenian.conllu","crt"=>"Croatian.conllu","srb"=>"Serbian.conllu", "test" => "test.conllu", "ocs" => "Old_Church_Slavonic.conllu", "orv" => "Old_Russian.conllu", "hsb" => "Upper_Sorbian.conllu"}


detfile = File.open("subj_data.csv", "w:utf-8")
detfile.puts "lemma\tsentence\ttense\taspect\tsperson\texpressed\tpronexpressed\tpron12expressed\tlang\tgroup\trel\tclause_type"
langs = ["bel", "rus", "ukr", "pol", "cze", "slk", "blg", "slv", "crt", "srb", "hsb"]


pasttenses = Hash.new(["Past"]) #rus, ukr, pol, czech, slovak, bel
#pasttenses["blg"] = ["Past","Imp"]
#pasttenses["crt"] = ["Past","Imp"]
pasttenses["slv"] = ["unknown"]
#pasttenses["srb"] = ["unknown"]
#pasttenses["blg"] = ["unknown"]
personhash = {"1"=>"12","2"=>"12","3"=>"3","unknown"=>"unknown"}

def findfeat(feats,feat) #finds the value of a given feat
    value = "unknown"
    feats2 = feats.split("|")
    feats2.each do |feat_value|
        feat_value2 = feat_value.split("=")
    if feat_value2[0] == feat
        value = feat_value2[1]
        break
    end
    end
    return value
end
    

langs.each do |lang|
    STDERR.puts lang
    if ["rus","ukr", "bel"].include?(lang)
        group = "non_copular"
    else
        group = "copular"
    end

    pasttense = pasttenses[lang]
    f = File.open("#{PATH}\\#{files[lang]}","r:utf-8")
    

    sentences = []
    sentence = Hash.new{|hash, key| hash[key] = Hash.new;} 
    verbs = Hash.new{|hash, key| hash[key] = Hash.new(0);} 
    verbs_output = Hash.new{|hash, key| hash[key] = Array.new;} 
    text = ""
    
    f.each_line do |line|
        line1 = line.strip
        #STDERR.puts line1
        if line1[0..5]=="# text"
            text = line1.split("=")[1][1..-1].gsub("\"","'")
        elsif line1 != "" and line1[0] != "#"
            line2 = line1.split("\t") 
        
        sentence[line2[0]]["form"] = line2[1] #form
        sentence[line2[0]]["lemma"] = line2[2] #lemma
        sentence[line2[0]]["pos"] = line2[3] #pos
        
        sentence[line2[0]]["feats"] = line2[5] #feats
        sentence[line2[0]]["head"] = line2[6] #head
        sentence[line2[0]]["rel"] = line2[7] #rel
        if sentence[line2[6]]["children"].nil? #skip for 0?
            sentence[line2[6]]["children"] = [line2[0]]
        else 
            sentence[line2[6]]["children"] << line2[0] #head: children
        end    
        
        elsif line1 == ""        
            sentences << sentence
            sentence.each_pair do |node, hash| 
            if hash["pos"] == "VERB" and ( (["test","rus","ukr","bel"].include?(lang) and findfeat(hash["feats"],"VerbForm")=="Fin" and findfeat(hash["feats"],"Tense")!="unknown") or (["pol","cze","slk"].include?(lang) and findfeat(hash["feats"],"Tense")!="unknown") or (["srb","slv"].include?(lang) and ((findfeat(hash["feats"],"Gender")!="unknown" and findfeat(hash["feats"],"Number")!="unknown" and findfeat(hash["feats"],"Case")=="unknown") or (findfeat(hash["feats"],"Tense")!="unknown"))) or (["crt","blg"].include?(lang) and ((findfeat(hash["feats"],"VerbForm")=="Part" and findfeat(hash["feats"],"Tense")=="Past") or (findfeat(hash["feats"],"VerbForm")=="Fin" and findfeat(hash["feats"],"Tense")!="Unknown")) ) ) #and !["csubj", "ccomp", "xcomp", "advcl", "acl"].include?(hash["rel"])
            if verbs[hash["lemma"]]["Past"] == 0 
                verbs[hash["lemma"]]["Past"] = Hash.new(0)
            end
            if verbs[hash["lemma"]]["Nonpast"] == 0 
                verbs[hash["lemma"]]["Nonpast"] = Hash.new(0)
            end
            verbs[hash["lemma"]]["freq"] += 1 #total frequency
            
            
            if pasttense.include?(findfeat(hash["feats"],"Tense")) and (lang!="blg" or (lang=="blg" and findfeat(hash["feats"],"VerbForm")=="Part"))
                tense = "Past"
            else
                tense = "Nonpast"
            end
            
            verbs[hash["lemma"]][tense]["freq"]+=1
            
            subjectinfo = check_for_subj_child(hash, sentence, lang)
            nosubject = subjectinfo[0]
            pronsubject = subjectinfo[1]
            pron12subject = subjectinfo[2]
            if CHECK_COORD
                if nosubject and hash["rel"] == "conj" 
                    hash2 = sentence[hash["head"]] #we are going up, to the first conjunct. In principle other conjuncts can be checked as well
                    
                    subjectinfo = check_for_subj_child(hash2, sentence, lang)
                    nosubject = subjectinfo[0]
                    pronsubject = subjectinfo[1]
                    pron12subject = subjectinfo[2]
                end
            end
            
            expressed = 0                             
            pronexpressed = 0
            pron12expressed = 0
            
            if !nosubject
                expressed = 1
                verbs[hash["lemma"]][tense]["subj"] += 1
                if pronsubject
                    pronexpressed = 1
                if pron12subject
                    pron12expressed = 1
                end
                end
            end
            
            if pron12expressed == 1
                verbs[hash["lemma"]][tense]["expr12"] += 1
            else    
                verbs[hash["lemma"]][tense]["none"] += 1
            end
            
            if ["rus","ukr","blg","bel"].include?(lang)
                #printlemma = Translit.convert(hash["lemma"])
                printlemma = hash["lemma"]
            else
                printlemma = hash["lemma"]
            end
            
            clause_type = RELHASH[hash["rel"].split(":")[0]] #to cover subtypes like acl:relcl
            if clause_type == "main"
                if !check_for_subord_child(hash, sentence)
                    clause_type = "simple"
                end
            end

            verbs_output[hash["lemma"]] << "#{printlemma}\t#{text}\t#{tense}\t#{findfeat(hash["feats"],"Aspect")}\t#{personhash[findfeat(hash["feats"],"Person")]}\t#{expressed}\t#{pronexpressed}\t#{pron12expressed}\t#{lang}\t#{group}\t#{hash["rel"]}\t#{clause_type}" #12 will ALWAYS be pronexpressed, while 3 won't. Remove this bias?
            end
        end
            sentence = Hash.new{|hash, key| hash[key] = Hash.new;} 
        end
    end
    
    total_expr12_past = 0
    total_expr12_nonpast = 0
    total_none_past = 0
    total_none_nonpast = 0
    
    #o.puts "Verb\texpr12_past\texpr12_nonpast\ttotal_past\ttotal_nonpast"
    verbs.each_pair do |verb, value|
        if value["Past"]["freq"] > THRESHOLD_TOTAL and value["Nonpast"]["freq"] > THRESHOLD_TOTAL and (value["Nonpast"]["subj"] + value["Past"]["subj"]) > THRESHOLD_SUBJ 
            
            total_expr12_past += value["Past"]["expr12"]
            total_expr12_nonpast += value["Nonpast"]["expr12"]
            #total_none_past += value["Past"]["none"]
            #total_none_nonpast += value["Nonpast"]["none"]
        
            
                #pastnone = value["Past"]["none"].to_f/value["Past"]["freq"].to_f 
                #nonpastnone = value["Nonpast"]["none"].to_f/value["Nonpast"]["freq"].to_f 
            pastexpr = value["Past"]["expr12"].to_f/value["Past"]["freq"].to_f 
            nonpastexpr = value["Nonpast"]["expr12"].to_f/value["Nonpast"]["freq"].to_f 
                
            #o.puts "#{verb}\t#{pastexpr}\t#{nonpastexpr}\t#{value["Past"]["freq"]}\t#{value["Nonpast"]["freq"]}"
            verbs_output[verb].each do |output|
                #od.puts output
                detfile.puts output
            end
            
        end
    end
    
    #o.puts "total_expr12_past\t#{total_expr12_past}"
    #o.puts "total_expr12_nonpast\t#{total_expr12_nonpast}"
    #o.puts "total_none_past\t#{total_none_past}"
    #o.puts "total_none_nonpast\t#{total_none_nonpast}"
    
end
