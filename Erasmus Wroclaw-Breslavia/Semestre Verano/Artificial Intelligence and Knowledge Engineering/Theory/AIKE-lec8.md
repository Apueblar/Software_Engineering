CS276  Information Retrieval and Web Search  Christopher D. Manning  (small changes: Maciej Piasecki)  Lecture 12: Naïve BayesText Classification  https://web.stanford.edu/class/cs276/  Christopher D. Manning,   Prabhakar Raghavan   and   Hinrich  Schütze,  Introduction to Information Retrieval, Cambridge University  Press. 2008.  https://nlp.stanford.edu/IR - book/information - retrieval - book.html

Is this spam?  From: "" <takworlld@hotmail.com>  Subject: real estate is the only way... gem oalvgkay  Anyone can buy real estate with no money down  Stop paying rent TODAY !  There is no need to spend hundreds or even thousands for similar courses  I am 22 years old and I have already purchased 6 properties using the  methods outlined in this truly INCREDIBLE ebook.  Change your life NOW !  =================================================  Click Below to order:  http://www.wholesaledaily.com/sales/nmd.htm  =================================================

Categorization/Classification  n   Given:  n   A description of an instance,   x Î X , where X is the  instance language   or   instance space .  n   Issue: how to represent text documents.  n   A fixed set of categories:  C   =   { c 1 ,   c 2 ,…,   c n }  n   Determine:  n   The category of   x :   c ( x ) Î C,   where   c ( x ) is a  categorization function   whose domain is   X   and  whose range is   C .  n   We want to know how to build categorization functions  (“classifiers”).

Multimedia   GUI Garb.Coll. Semantics ML   Planning  planning  temporal  reasoning  plan  language ...  programming  semantics  language  proof ...  learning  intelligence  algorithm  reinforcement  network...  garbage  collection  memory  optimization  region...  “planning  language  proof  intelligence”  Training  Data:  Test  Data:  Classes:  (AI)  Document Classification  (Programming)   (HCI)  ...   ...  (Note: in real life there is often a hierarchy, not  present in the above problem statement; and you get  papers on ML approaches to Garb. Coll.)

Classification Methods (1)  n   Manual classification  n   Used by Yahoo!, Looksmart, about.com, ODP,  Medline  n   Very accurate when job is done by experts  n   Consistent when the problem size and team is  small  n   Difficult and expensive to scale

Classification Methods (2)  n   Automatic document classification  n   Hand - coded rule - based systems  n   One technique used by CS dept’s spam filter, Reuters,  CIA, Verity, …  n   E.g., assign category if document contains a given  boolean combination of words  n   Standing queries: Commercial systems have complex  query languages (everything in IR query languages +  accumulators)  n   Accuracy is often very high if a rule has been carefully  refined over time by a subject expert  n   Building and maintaining these rules is expensive

Classification Methods (3)  n   Supervised learning of a document - label  assignment function  n   Many systems partly rely on machine learning  (Autonomy, MSN, Verity,   Enkata , Yahoo!, …)  n   k - Nearest Neighbors (simple, powerful)  n   Naive Bayes (simple, common method)  n   SVM   -   Support - vector machines (newer, more powerful)  n   Deep Learning, e.g.   bLSTM   neural networks (the newest)  n   … plus many other methods  n   No free lunch: requires hand - classified training data  n   But data can be built up (and refined) by crowd sourcing  n   Note that many commercial systems use a  mixture of methods

Bayesian Methods  n   Our focus this lecture  n   Learning and classification methods based on  probability theory.  n   Bayes theorem plays a critical role in probabilistic  learning and classification.  n   Build a   generative model   that approximates how  data is produced  n   Uses   prior   probability of each category given no  information about an item.  n   Categorization produces a   posterior   probability  distribution over the possible categories given a  description of an item.

Bayes’ Rule  ! " ! # " ! " ! # " ! $ "   ! " ! # " # " # ! " # ! "   = =  ! "  ! " ! # "  ! # "   ! "  # " # ! "  ! # "   =

Maximum a posteriori   Hypothesis  ! " # $%&'$(   ! " # "   A "  %&#   !  "  ! "  ! " ! # "  $%&'$(   ! "  # " # ! "  $ # !  =  ! " ! # " $%&'$(   ! " ! # "  $ ! !  =   As   P(D)   is  constant

Maximum likelihood   Hypothesis  If all hypotheses are a priori equally likely,   we only  need to consider the   P ( D|h )   term:  ! " # $%&'$(   ! " # !   $ !  %&   !  "

Naive Bayes Classifiers  Task: Classify a new instance   D   based on a tuple of attribute  values   into one of the classes   c j   Î   C ! " " " #   ! ! !   " #   ! =  ! " " " # $ %&'(%)   * +   ! "  # A  %C'   ( ( ( A ' A   "  !  !  =  ! " " " #  ! # ! $ " " " #  %&'(%)  * +  * +  !  " " !  # $   % % % C  $ C $ % % % C  "   !  !  !  =  ! " ! # $ $ $ " %&'(%)   * +   ! ! "  # $  $ % $ C C C %  !  !  !  =

Naïve Bayes Classifier:  Naïve Bayes Assumption  n   P ( c j )  n   Can be estimated from the frequency of classes in  the training examples.  n   P ( x 1 ,x 2 ,…,x n |c j )  n   O( |X| n • |C| ) parameters  n   Could only be estimated if a very, very large  number of training examples was available.  Naïve Bayes Conditional Independence Assumption:  n   Assume that the probability of observing the  conjunction of attributes is equal to the product of the  individual probabilities   P ( x i | c j ).

Flu  X 1  X 2  X 5  X 3  X 4  fever sinus   cough runnynose   muscle - ache  The Naïve Bayes Classifier  n   Conditional Independence Assumption:  features detect term presence and are  independent of each other given the class:  n   This model is appropriate for binary variables  n   Multivariate binomial model  ! " # ! " # ! " # ! " $ $ #   % & ' % '   ! " # ! " # ! " # ! " " #   • • • =   ! "

Learning the Model  n   First attempt: maximum likelihood estimates  n   simply use the frequencies in the data  ! "  ! # "  ! $ " %  !  ! " "  ! "   # $ %  # $ C ' %  # C (   =  = =  =  C  X 1  X 2  X 5  X 3  X 4  X 6  !  " # !  " $   %  %  ! "  ! " #   =  =

n   What if we have seen no training cases where patient had no flu  and muscle aches?  n   Zero probabilities cannot be conditioned away, no matter the  other evidence!  Problem with Max Likelihood  !  " #  " $ #  " % # &   '  '   =  =  = =  = = =   !" # $  !" # % C $  !" # % C '  ! =   !   ! "   " # $ " $   ! " # $ ! # $ %&' &() !  Flu  X 1  X 2  X 5  X 3  X 4  fever sinus   cough runnynose   muscle - ache  ! " # ! " # ! " # ! " $ $ #   % & ' % '   ! " # ! " # ! " # ! " " #   • • • =   ! "

Smoothing to Avoid Overfitting  ! " # $  " # % C $  " % '  (  ( ) )  ( )   + =  + = =  =   ! "  # ! $ "  ! % " &  n   Somewhat more subtle version  # of values of  X i  ! " # $  !% " # C ' $  " C (  )  * + ) * + +  ) * +   + =  + = =  =   ! "  ! # "  ! $ " %   # #  #  overall fraction in  data where  X i =x i,k  extent of  “smoothing”

Stochastic Language Models  n   Models   probability   of generating strings (each  word in turn) in the language (commonly all  strings over   ∑). E.g., unigram model  0.2   the  0.1   a  0.01   man  0.01   woman  0.03   said  0.02   likes  …  the   man   likes   the   woman  0.2   0.01   0.02   0.2   0.01  multiply  Model M  P(s | M) = 0.00000008

Stochastic Language Models  n   Model   probability   of generating any string  0.2   the  0.01   class  0.0001   sayst  0.0001   pleaseth  0.0001   yon  0.0005   maiden  0.01   woman  Model M1   Model M2  maiden class   pleaseth   yon the  0.0005 0.01   0.0001   0.0001 0.2  0.01 0.0001   0.02   0.1 0.2  P(s|M2) > P(s|M1)  0.2   the  0.0001   class  0.03   sayst  0.02   pleaseth  0.1   yon  0.01   maiden  0.0001   woman

Unigram and higher - order models  n  n   Unigram Language Models  n   Bigram (generally,   n - gram) Language Models  n   Other Language Models  n   Grammar - based models (PCFGs), etc.  n   Probably not the first thing to try in IR  = P (   )   P (   |   )   P (   |   )   P (   |   )  P (   ) P (   ) P (   ) P (   )  P (   )  P (   ) P (   |   ) P (   |   ) P (   |   )  Easy.  Effective!

Naïve Bayes via a class conditional  language model = multinomial NB  n   Effectively, the probability of each class is done  as a class - specific unigram language model  Cat  w 1   w 2   w 3   w 4   w 5   w 6

Using Multinomial Naive Bayes Classifiers  to Classify Text: Basic method  n   Attributes are text positions, values are words.  n   Still too many possibilities  n   Assume that classification is   independent   of the  positions of the words  n   Use same parameters for each position  n   Result is bag of words model (over tokens not types)  ! " #$%#& & ' ! " ()*& & ' ! ' +*,-+%  ! " ' ! ' +*,-+%  .  /  /  ! " ! !  # $  B  ! B !  # $  C'  $ ( ) $ ( ) $ )  $ ( ) $ ) $  = = =  =  !  !   "  !

n   Text j   ¬   single document containing all   docs j  n   for each word   x k   in   Vocabulary  n   n k   ¬   number of occurrences of   x k   in   Text j  n  Naïve Bayes: Learning  n   From training corpus, extract   Vocabulary  n   Calculate required   P ( c j )   and   P ( x k   | c j )   terms  n   For each   c j   in   C   do  n   docs j   ¬   subset of documents for which the target class is   c j  n  ! !  " ! #   !"#$%&'$() *  *  # + ,   -  . -  !  !  +  +  "  ! "#$%&'()* + , + )#)-. !  ! !  / 0   !  !  "#$%  $ &   !

Naïve Bayes: Classifying  n   positions   ¬   all word positions in current document  which contain tokens found in   Vocabulary  n   Return   c NB ,   where  ! " "  =   !"#$B$"C# $  ' $ '  ( )  *+   ) , - ) - )   ! " # ! # $%&'$(  )

Naive Bayes: Time Complexity  n   Training Time : O(| D | L d   + | C || V |))  where   L d   is the average length of a document in   D.  n   Assumes   V   and all   D i   ,   n i , and   n ij   pre - computed in O(| D | L d )  time during one pass through   all of   the data.  n   Generally   just O(| D | L d ) since usually | C || V | < | D | L d  n   Test Time : O(| C |   L t )  where   L t   is the average length of a test document.  n   Very efficient overall, linearly proportional to the time  needed to just read in all the data.  Why?

Underflow Prevention  n   Multiplying lots of probabilities, which are  between 0 and   1 by definition, can   result in  floating - point underflow.  n   Since log( xy ) = log( x ) + log( y ), it is better to  perform all computations by summing logs of  probabilities rather than multiplying probabilities.  n   Class with highest final un - normalized log  probability score is still the most probable.  ! " "  + =   !"#$B$"C# $  ' $ '  ( )  *+   ) , - ) - )   ! " # $%& ! # $%& '(&)'*  +

Note: Two Models  n   Model 1: Multivariate binomial  n   One feature  X w   for each word in dictionary  n  X w   = true in document  d   if  w   appears in  d  n   Naive Bayes assumption:  n   Given the document’s topic, appearance of one word in  the document tells us nothing about chances that another  word appears  n   This is the model used in the binary  independence model in classic probabilistic  relevance feedback in hand - classified data  (Maron in IR was a very early user of NB)

Two Models  n   Model 2: Multinomial = Class conditional unigram  n   One feature  X i   for each word pos in document  n   feature’s values are all words in dictionary  n   Value of  X i   is the word in position  i  n   Naïve Bayes assumption:  n   Given the document’s topic, word in one position in the  document tells us nothing about words in other positions  n   Second assumption:  n   Word appearance does not depend on position  n   Just have one multinomial feature predicting all words  ! " # ! " #   ! " # $ ! " # $   % &   = = =  for all positions   i,j , word   w , and class   c

Parameter estimation  fraction of documents of topic   c j  in which word   w   appears  n   Binomial model:  n   Multinomial model:  n   Can create a mega - document for topic   j   by concatenating all  documents in this topic  n   Use frequency of   w   in mega - document  = =   ! " # $   ! "   # $ % &  fraction of times in which  word   w   appears  across all documents of topic   c j  = =   ! " # $   ! "   # $ % &

Classification  n   Multinomial vs Multivariate binomial?  n   Multinomial is in general better  n   See results figures later

NB example  n   Given: 4 documents  n   D1 (sports): China soccer  n   D2 (sports): Japan baseball  n   D3 (politics): China trade  n   D4 (politics): Japan Japan exports  n   Classify:  n   D5: soccer  n   D6: Japan  n   Use  n   Add - one smoothing  n   Multinomial model  n   Multivariate binomial model

Feature Selection: Why?  n   Text collections have   a large number of   features  n   10,000   –   1,000,000 unique words … and more  n   May make using a particular classifier feasible  n   Some classifiers can’t deal with 100,000 of features  n   Reduces training time  n   Training time for some methods is quadratic or  worse in the number of features  n   Can improve generalization (performance)  n   Eliminates noise features  n   Avoids overfitting

Feature selection: how?  n   Two ideas:  n   Hypothesis testing statistics:  n   Are we confident that the value of one categorical  variable is associated with the value of another  n   Chi - square test ( c 2   test)  n   Information theory:  n   How much information does the value of one categorical  variable give you about the value of another  n   Mutual information  n   They’re similar, but   c 2   measures confidence in association,  (based on available statistics), while MI measures extent of  association (assuming perfect knowledge of probabilities)

c 2   statistic (CHI)  n   c 2 is interested in (fo   –   fe) 2 /fe summed over all table entries: is  the observed number what you’d expect given the marginals?  n   The null hypothesis is rejected with confidence .999,  n   since 12.9 > 10.83 (the value for .999 confidence).  ! ""# $ % & $ #' &(&) * ! &(&) &+"" % +"' * ! +"' +"" %  ,+ $ ( * ! ,+ $ ( - % '+ $ * ! '+ $ ' % * ! % ! . %  ' '  ' ' ' '  < = ! + ! +  ! + ! = ! =   "  !  " " # $ %  #  9500  500  (4.75)  (0.25)  (9498) 3 Class   ¹   auto  (502) 2 Class = auto  Term   ¹   jaguar Term = jaguar   expected:   f e  observed:   f o

There is a simpler formula for 2x2   c 2 :  c 2   statistic (CHI)  N   =  A   +  B   +  C   +  D  D   = #(¬ t , ¬ c ) B   = #( t ,¬ c )  C   = #(¬ t , c ) A   = #( t , c )  Value for complete independence of term and category?

Feature selection via Mutual  Information  n   In training set, choose   k   words which best  discriminate (give most info on) the categories.  n   The Mutual Information between a word, class is:  n   For each word   w   and each category   c  !   ! "   "  =   ! " # $ %   ! " # $ %   & ' & '  & # '  ()* & # ' & # '   !   " #   #   " !  " !  " !  # $ # $  # # $  # # $ " ! %

Feature selection via MI (contd.)  n   For each category we build a list of   k   most  discriminating terms.  n   For example (on 20 Newsgroups):  n   sci.electronics:   circuit, voltage, amp, ground, copy,  battery, electronics, cooling, …  n   rec.autos:   car, cars, engine, ford, dealer, mustang,  oil, collision, autos, tires, toyota, …  n   Greedy: does not account for correlations between  terms  n   Why?

Feature Selection  n   Mutual Information  n   Clear information - theoretic interpretation  n   May select rare uninformative terms  n   Chi - square  n   Statistical foundation  n   May select very slightly informative frequent terms  that are not very useful for classification

Feature Selection   (M.P.)  n   Heuristics  n   Not based on theoretical foundations  n   But often performing very well  n   Just use the commonest terms?  n   In practice, this is often 90% as good  n   tf.idf (or tf x idf) term weights  n   very popular, correlated with Pointwise MI  n   term frequency ( tf   )  n   or   wf , some measure of term density in a doc  n   inverse document frequency ( idf   )  n   measure of informativeness of a term: its rarity across  the whole corpus

Feature selection for NB  n   In general feature selection is   necessary   for  binomial NB.  n   Otherwise   you suffer from noise, multi - counting  n   “Feature selection” really means something  different for multinomial NB. It means dictionary  truncation  n   The multinomial NB model only has 1 feature  n   This “feature selection” normally isn’t needed for  multinomial NB, but may help a fraction with  quantities that are badly estimated

Feature selection pitfall   (M.P.)  n   By selecting   features   we learn about the domain  n   Selected features show what is important  n   In small collections, they capture accidental  dependencies  n   Overfitting  n   too much adapting to the test documents  n   feature selection on the whole collection  n   i.e.   also   on the test documents!!  n   Weighting on the whole collection  n   Learning about behaviour of features ALSO from  the test documents!!

Evaluating Categorization  n   Evaluation must be done on test data that are  independent of the training data (usually a  disjoint set of instances).  n   Classification accuracy :   c / n   where   n   is the total  number of test instances and   c   is the number of  test instances correctly classified by the system.  n   Results can vary based on sampling error due to  different training and test sets.  n   Average results over multiple training and test  sets (splits of the overall data) for the best  results.

Example: AutoYahoo!  n   Classify 13,589 Yahoo! webpages in “Science” subtree into 95  different topics (hierarchy depth 2)

Sample Learning Curve  (Yahoo Science Data): need more!

WebKB Experiment  n   Classify webpages from CS departments into:  n   student, faculty, course,project  n   Train on ~5,000 hand - labeled web pages  n   Cornell, Washington, U.Texas, Wisconsin  n   Crawl and classify a new site (CMU)  n   Results:  Student   Faculty   Person   Project   Course   Departmt  Extracted   180   66   246   99   28   1  Correct   130   28   194   72   25   1  Accuracy:   72%   42%   79%   73%   89%   100%

NB Model Comparison

Violation of NB Assumptions  n   Conditional independence  n   “Positional independence”  n   Examples?

Naïve Bayes Posterior  Probabilities  n   Classification results of naïve Bayes (the class  with maximum posterior probability) are usually  fairly accurate.  n   However, due to the inadequacy of the  conditional independence assumption, the actual  posterior - probability numerical estimates are not.  n   Output probabilities are generally very close to 0  or 1.

When does Naive Bayes work?  Sometimes NB  performs well even  if the Conditional  Independence  assumptions are  badly   violated.  Classification is  about predicting  the correct class  label and NOT  about accurately  estimating  probabilities.  Assume two classes   c 1   and   c 2 . A new case  A   arrives.  NB will classify   A   to   c 1   if:  P(A, c 1 )>P(A, c 2 )  !"#AB C '   !"#AB E '   )*+,,-./-#  #B0N+*-!2.P+P4*405   67C   676C   B C  8,049+0:;-!2.P+P4*405  P5-<=  676>   676?   B C  Besides the big error in estimating the  probabilities the classification is still   correct.  Correct estimation   Þ   accurate prediction  but   NOT  accurate prediction   Þ   Correct estimation