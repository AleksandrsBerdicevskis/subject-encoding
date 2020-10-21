lang <- "bel"
dataset <- read.csv("subj_data.csv", sep="\t",dec=".", header=TRUE) 

#exclude those clauses where the subject is encoded by a full NP
dataset2 <- dataset[!(dataset$expressed == 1 & dataset$pronexpressed == 0),] 
#set reference levels
dataset2$group2 <- relevel(as.factor(dataset2$group), ref = "non_copular") #non_copular = {bel, rus, ukr}, copular = the rest
dataset2$tense2 <- relevel(as.factor(dataset2$tense), ref = "Past") #Past = l-participles, Nonpast = finite forms

dataset2m <- dataset2[dataset2$clause_type == "simple",]

processlang <- function(dataset3){
    past_pron <- length(dataset3[dataset3$tense=="Past" & dataset3$pronexpressed==1,]$pronexpressed)
    past_zero <- length(dataset3[dataset3$tense=="Past" & dataset3$pronexpressed==0,]$pronexpressed)
    pres_zero <- length(dataset3[dataset3$tense!="Past" & dataset3$pronexpressed==0,]$pronexpressed)
    pres_pron <- length(dataset3[dataset3$tense!="Past" & dataset3$pronexpressed==1,]$pronexpressed)
    total <- past_pron + past_zero + pres_zero + pres_pron
    past <- past_pron + past_zero
    pres <- pres_pron + pres_zero
    zero <- past_zero + pres_zero
    print("No pronoun (overall):")
    print(zero/total)
    print("No pronoun (indexation):")
    print(pres_zero/pres)
    print("No pronoun (l-participles):")
    print(past_zero/past)

    m <- matrix(c(past_pron,past_zero,pres_pron,pres_zero),nrow=2,byrow=T)
    print(m)
    print(chisq.test(m))
    print(cramersV(m))
    
    tense <- glmer(pronexpressed ~  tense2 + (1 |lemma), family=binomial(link=logit), data=dataset3)
    print(summary(tense))

}


library("lsr")
print(lang)


print("All clauses")
dataset_all <- dataset2[dataset2$lang==lang,]
processlang(dataset_all)
print("Simple sentences")
dataset_s <- dataset2m[dataset2m$lang==lang,]
processlang(dataset_s)