library(lmerTest)
library(Hmisc)
langs = c("rus", "ukr", "pol", "cze", "slk", "blg", "slv", "crt", "srb", "hsb")

#filename = paste("subj_data.csv",sep="")
dataset <- read.csv("subj_data.csv", sep="\t",dec=".", header=TRUE) 
dataset2 <- dataset[!(dataset$expressed == 1 & dataset$pronexpressed == 0),] #excluding those clauses where the subject is encoded by a full NP

dataset2$group2 <- relevel(as.factor(dataset2$group), ref = "non_copular") #non_copular = {bel, rus, ukr}, copular = the rest
dataset2$tense2 <- relevel(as.factor(dataset2$tense), ref = "Past") #Past = l-participles, Nonpast = finite forms

#print(head(dataset2))
print("all clauses: pronouns")
tense3 <- glmer(pronexpressed ~  tense2 * group2 + (1|lemma) + (1|lang), family=binomial(link=logit), data=dataset2)
print(summary(tense3))



probs = 1/(1+exp(-fitted(tense3)))

print(somers2(probs, as.numeric(dataset2$pronexpressed)))



east_past <- dataset[dataset$tense == "Past" & dataset$group == "non_copular",]
east_nonpast <- dataset[dataset$tense != "Past" & dataset$group == "non_copular",]
swest_nonpast <- dataset[dataset$tense != "Past" & dataset$group != "non_copular",]
swest_past <- dataset[dataset$tense == "Past" & dataset$group != "non_copular",]


dataset2m <- dataset2[dataset2$rel != "csubj" & dataset2$rel != "ccomp" & dataset2$rel !=  "xcomp" & dataset2$rel !=   "advcl" & dataset2$rel !=   "acl",]
#print(head(dataset2m))
print("main clauses: pronouns")
tense3m <- glmer(pronexpressed ~  tense2 * group2 + (1|lemma) + (1|lang), family=binomial(link=logit), data=dataset2m)
print(summary(tense3m))



barplot(c(mean(east_past$pronexpressed), mean(east_nonpast$pronexpressed), mean(swest_past$pronexpressed), mean(swest_past$pronexpressed)), ylim = c(0,0.20), ylab = "Proportion of pronominal subjects", names.arg = c("East; l-participles", "East; other constructions", "South&West; l-participles", "South&West; other constructions"))



zero <- dataset2[dataset2$group == "non_copular" & dataset2$tense == "Past" & dataset2$pronexpressed == 0,]
pron1 <- dataset2[(dataset2$pronexpressed == 1) & (dataset2$group == "non_copular") & (dataset2$tense == "Past"),]
doublee <- dataset2[(dataset2$pronexpressed == 1) & ((dataset2$group == "copular") | (dataset2$group == "non_copular" & dataset2$tense == "Nonpast")),]
index1 <- dataset2[(dataset2$pronexpressed == 0) & ((dataset2$group == "copular") | (dataset2$group == "non_copular" & dataset2$tense == "Nonpast")),]

print(length(doublee$rel))
print(length(zero$rel))
print(length(index1$rel))
print(length(pron1$rel))
barplot(c(length(zero$rel), length(pron1$rel), length(index1$rel), length(doublee$rel)), ylim = c(0,120000), ylab = "Number of clauses", names.arg = c("Zero encoding", "Single encoding: pronoun", "Single encoding: index", "Double encoding"))