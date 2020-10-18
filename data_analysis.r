library(lmerTest)
library(Hmisc)
langs = c("rus", "ukr", "pol", "cze", "slk", "blg", "slv", "crt", "srb", "hsb")

dataset <- read.csv("subj_data.csv", sep="\t",dec=".", header=TRUE) 

#exclude those clauses where the subject is encoded by a full NP
dataset2 <- dataset[!(dataset$expressed == 1 & dataset$pronexpressed == 0),] 

#set reference levels
dataset2$group2 <- relevel(as.factor(dataset2$group), ref = "non_copular") #non_copular = {bel, rus, ukr}, copular = the rest
dataset2$tense2 <- relevel(as.factor(dataset2$tense), ref = "Past") #Past = l-participles, Nonpast = finite forms

#print(head(dataset2))
print("all clauses: pronouns")
tense3 <- glmer(pronexpressed ~  tense2 * group2 + (1|lemma) + (1|lang), family=binomial(link=logit), data=dataset2)
print(summary(tense3))

#estimate model quality
probs = 1/(1+exp(-fitted(tense3)))
print(somers2(probs, as.numeric(dataset2$pronexpressed)))

#Create figure 3
east_past <- dataset[dataset$tense == "Past" & dataset$group == "non_copular",]
east_nonpast <- dataset[dataset$tense != "Past" & dataset$group == "non_copular",]
swest_nonpast <- dataset[dataset$tense != "Past" & dataset$group != "non_copular",]
swest_past <- dataset[dataset$tense == "Past" & dataset$group != "non_copular",]

barplot(c(mean(east_past$pronexpressed), mean(east_nonpast$pronexpressed), mean(swest_past$pronexpressed), mean(swest_past$pronexpressed)), ylim = c(0,0.20), ylab = "Proportion of pronominal subjects", names.arg = c("East; l-participles", "East; other constructions", "South&West; l-participles", "South&West; other constructions"), cex.names=1.5,cex.lab=1.5)

dev.new()

#create figure 4
zero <- dataset2[dataset2$group == "non_copular" & dataset2$tense == "Past" & dataset2$pronexpressed == 0,]
pron1 <- dataset2[(dataset2$pronexpressed == 1) & (dataset2$group == "non_copular") & (dataset2$tense == "Past"),]
doublee <- dataset2[(dataset2$pronexpressed == 1) & ((dataset2$group == "copular") | (dataset2$group == "non_copular" & dataset2$tense == "Nonpast")),]
index1 <- dataset2[(dataset2$pronexpressed == 0) & ((dataset2$group == "copular") | (dataset2$group == "non_copular" & dataset2$tense == "Nonpast")),]

barplot(c(length(zero$rel), length(pron1$rel), length(index1$rel), length(doublee$rel)), ylim = c(0,120000), ylab = "Number of clauses", names.arg = c("Zero encoding", "Single encoding: pronoun", "Single encoding: indexation", "Double encoding"), cex.names=1.5,cex.lab=1.5)

#run the model on clauses in simple sentences only (mentioned in the article, reported in supplementary materials)
dataset2m <- dataset2[dataset2$clause_type == "simple",]
#print(head(dataset2m))
print("simple sentences")
tense3m <- glmer(pronexpressed ~  tense2 * group2 + (1|lemma) + (1|lang), family=binomial(link=logit), data=dataset2m)
print(summary(tense3m))

#estimate model quality
probs = 1/(1+exp(-fitted(tense3m)))
print(somers2(probs, as.numeric(dataset2m$pronexpressed)))





