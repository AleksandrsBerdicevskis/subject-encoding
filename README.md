# subject-encoding
This repository contains the data and the scripts that are necessary to reproduce the results reported in:

Berdicevskis, Aleksandrs, Karsten Schmidtke-Bode and Ilja Seržant. 2020. Subjects tend to be coded only once: Corpus-based and grammar-based evidence for an efficiency-driven trade-off. In: Proceedings of the 19th International Workshop on Treebanks and Linguistic Theories (TLT).

The repository contains the following files and folders:
- corpus_analysis.rb: a script that goes through the UD corpora (train, dev and test concatenated). If a language has several UD corpora, they have to be concatenated into a single on (use  ud_merge_perlang.rb)

- subj_data.csv is a tab-separated file which contains the data analyzed in Section 3 of the article (it is the output of corpus_analysis.rb and the input for data_analysis.r). It has the following columns:
  - lemma (verb lemma);
  - sentence (full sentence where the verb occurs; note that our level of analysis is the clause, sentences are provided just as wide context);
  - tense (tense-mood combination which has two values with somewhat imprecise names: Past (=l-participles) and Nonpast (all other forms);
  - aspect (Imp = imperfective or Perf = perfective);
  - sperson (subject person as can be inferred from the verbal form. Possible values: 3, 12 (=1 or 2), unknown);
  - expressed (1 or 0: whether there is a free syntactic subject of any kind (either pronoun or full NP));
  - pronexpressed (1 or 0: whether there is a free syntactic subject encoded by a personal pronoun);
  - pron12expressed ((1 or 0: whether there is a free syntactic subject encoded by a first- or second-person pronoun);
  - lang (language ISO code);
  - group (language group: non_copular (= East Slavic) or copular (= South and West Slavic));
  - rel (incoming syntactic relation for the verb);
  - clause_type (as inferred from the UD annotation: simple, main, subord(inate) or coord(inate). Note that only non-first conjuncts are treated as coordinate clauses, while first conjuncts are treated as simple clauses).

- ud_merge_perlang.rb: a script that goes through all UD 2.6 treebanks and merges all treebanks for the same language into a single file. Set the IN and OUT paths at the beginning of the script

- data_analysis.r: an R script that performs the statistical analysis described in Section 3 and creates the figures. Make sure the necessary packages are installed, change the R directory to the folder with subj_data.csv

- model_simple.pdf: the description and results of the model (mentioned in Section 3) that was fit to clauses in simple sentences (and first conjuncts in coordinated constructions) only.

- lang.r: a bonus (draft) script for running analyses of individual languages (not discussed in the paper).

- Indexation_WALS data.txt: data extracted from WALS that were used for the analysis in Section 2. The names of the columns are self-explanatory (Index = Indexation).