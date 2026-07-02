# Artificial Intelligence & Knowledge Engineering — Exam Questions
**Subject:** Sztuczna inteligencja i inżynieria wiedzy (Artificial Intelligence and Knowledge Engineering)  
**University:** Politechnika Wrocławska (Wrocław University of Technology)  
**Compiled from:** Google Drive folder — all subfolders and files

---

## 📁 Folder Structure Overview

```
Sztuczna inteligencja i inżynieria wiedzy/
├── Egzamin 2025/
│   ├── ang1.jpg                   ← Exam sheet (English), Questions 1–9
│   ├── and2.jpg                   ← Exam sheet (English), Questions 10–17
│   ├── Egzamin termin 1/
│   │   ├── IMG_9008.HEIC          ← Exam sheet (Polish), Questions 6–25 (partial/OCR-degraded)
│   │   └── IMG_9009.HEIC          ← Exam sheet (Polish), Questions partial (OCR-degraded)
│   ├── pytania_testownik/
│   │   ├── 228.txt                ← Testownik question Q228 (Polish)
│   │   └── 241.txt                ← Testownik question Q241 (Polish)
│   ├── qdb-2024-2025/
│   │   ├── 17.txt                 ← Question 17 (Polish) — horizon problem
│   │   └── 237.txt                ← Question about decision trees (mixed PL/EN)
│   └── Testownik link.txt         ← Link to Testownik app
├── Notatki 2024/
│   └── w5 - (...).docx            ← Lecture notes on ML, Decision Trees (study material, not exam Q)
├── si2020_combined_egzamin_obowiazkowy.pdf  ← 2020 lecture slides (search algorithms, etc.)
└── si2020_wszystko_eportal_merged.pdf       ← 2020 full course materials
```

---

## 📋 SECTION 1 — Exam 2025 (English), Questions 1–17
**Source:** `Egzamin 2025/ang1.jpg` (Q1–9) and `Egzamin 2025/and2.jpg` (Q10–17)  
**Language:** English (original)

---

### Q1. Can we effectively formulate every problem as a state space search problem?

- a) No, because we will have too many operators and too high a branching factor in the search graph.
- b) No, because not all problems allow us to define inverse transition operators between states.
- c) Yes, because complex operations can be represented as a combination of simpler operators.
- **d) Yes, because symbolic-arithmetic operations can be represented as operators acting on a computational graph.**

> **Answer:** c) — Complex operations can be represented as combinations of simpler operators, making state space formulation general.

---

### Q2. Is there a place for a deduction-based approach in contemporary artificial intelligence?

- a) No, because practically all contemporary AI systems are based on machine learning.
- **b) Yes, deductive methods allow for the expression of verified knowledge, e.g., in the form of rules, also as sources of knowledge for generative language models (LLMs).**
- c) Yes, because deductive methods are essential for data augmentation.
- d) Yes, because deductive methods are present in every supervised machine learning algorithm as an element of controlling the training process.

> **Answer:** b) — Deductive methods remain relevant for encoding verified knowledge and feeding it into modern LLMs.

---

### Q3. What is arc consistency in constraint satisfaction problems and why is it used?

- a) Arc consistency is the consistency of the path of connected variables in search and an element of partial solution representation.
- **b) Arc consistency guarantees that for any two variables connected by a constraint, their domains contain values that satisfy that constraint.**
- c) Arc consistency is a transformation of the problem, resulting in it consisting of n subproblems, in which the pairs are connected by a single arc.
- d) Arc consistency is a partial order of pairs: variable-heuristic, accelerating the solution finding.

> **Answer:** b) — Arc consistency ensures that for every pair of constrained variables, valid domain values exist on both sides.

---

### Q4. What is the partial order planning algorithm based on?

- a) Hierarchically dividing the problem into areas of local subplans that are next combined.
- b) The lack of distinction between actions that are generated for the same operators.
- **c) Utilising only the necessary constraints in the representation of the plan.**
- d) A partial order plan allows for conflicting sequences of actions, where conflicts are resolved later through additional searching.

> **Answer:** c) — Partial order planning uses only the minimally necessary ordering constraints, leaving actions unordered when order doesn't matter.

---

### Q5. What are the true properties of the evaluation function in algorithms for playing logical games?

- **a) The evaluation function must be consistent with the payoff function for terminal nodes and estimate it for all intermediate states.**
- b) It must return 0 for the terminal node of the game tree and be consistent with the payoff function for the others.
- c) The evaluation function is a heuristic function for the cost of winning in one move.
- d) The evaluation function is any linear function of the set of features describing the game state.

> **Answer:** a) — The evaluation function must agree with payoff at terminal nodes and provide estimates for intermediate (non-terminal) states.

---

### Q6. Why is it important for the heuristic to be admissible in state space search?

- **a) An admissible heuristic does not hide the problem and returns values no higher than the actual cost.**
- b) Because it allows for comparing values between nodes.
- c) Because only an admissible heuristic defines equivalence classes of nodes based on its values.
- d) Because it does not hide the path leading to a node that satisfies the goal test.

> **Answer:** a) — An admissible heuristic never overestimates the true cost, which guarantees optimality in algorithms like A*.

---

### Q7. When do positions in the game tree become stable (quiescent)?

- a) Stable (quiescent) positions are those for which there is a balance between attacking moves and moves that create threats.
- b) Positions in the game tree become stable (quiescent) when their subtrees become balanced after applying alpha-beta pruning.
- **c) Stable (quiescent) positions are those for which the situation in the game does not correlate with significant changes in the value of the evaluation function over the next few moves.**
- d) Stable (quiescent) positions are below the depth that defines the horizon problem in the game tree.

> **Answer:** c) — Quiescent positions are "calm" states where the evaluation function value is unlikely to change dramatically in the near future.

---

### Q8. How does constraint propagation affect the efficiency of a constraint problem-solving algorithm?

- a) It is an alternative approach to backtracking search based on heuristic forward searching.
- b) Constraint propagation shifts the search to the level of local operations within the variable domains.
- **c) Constraint propagation dynamically reduces the effective size of the variable domains.**
- d) It breaks the problem into independent subproblems of constraint solving within individual pairs of variables.

> **Answer:** c) — Constraint propagation prunes domain values that cannot participate in any valid solution, shrinking the search space dynamically.

---

### Q9. Do planning algorithms differ from heuristic state space search?

- a) Planning algorithms are heuristic search algorithms based on a partial order graph heuristic.
- **b) Planning algorithms utilise knowledge from the symbolic representation of state change operators.**
- c) Planning algorithms do not build a complete transition graph from the initial state to the final state, but only a forest of partial graphs.
- d) Planning algorithms build the action graph deterministically and later apply heuristics to linearise the partial order graph into the final graph.

> **Answer:** b) — Planning algorithms exploit the symbolic structure of operators (preconditions, effects) to guide search more effectively than blind heuristic search.

---

### Q10. Why does unsupervised machine learning work and to what extent?

- a) Unsupervised machine learning operates on the basis of transformation of some attributes into decision classes based on correlation analysis.
- **b) Unsupervised machine learning explores similarities between objects to make property transfers or determine equivalence classes.**
- c) Unsupervised machine learning relies on the augmentation of labelled data based on data clustering.
- d) Unsupervised machine learning only works when the results of data clustering are correlated with an accepted class hierarchy for the data.

> **Answer:** b) — Unsupervised learning discovers structure by measuring similarity, enabling clustering and property inference without labels.

---

### Q11. What is the order of assigning attributes to the nodes of the decision tree?

- a) Any order is acceptable as long as the attributes with the highest InfoGain value are chosen.
- b) A single path contains a group of attributes determined by a clustering algorithm and then subjected to unsupervised attribute selection.
- c) The assignment of attributes to nodes results from an unsupervised contextual assessment of cross-entropy.
- **d) The order in each path of the tree (root-leaf) results from the reduction of uncertainty.**

> **Answer:** d) — Attributes are ordered by their information gain (reduction of entropy/uncertainty), so the most informative attribute is placed closest to the root.

---

### Q12. What needs to be done to adapt decision trees, which are inherently symbolic, to operate on numerical values?

- **a) It is necessary to quantize numerical attributes in a way statistically adjusted in terms of intervals for each attribute individually.**
- b) Functions should be introduced that assign appropriate symbols to numerical values from the training data.
- c) Numerical values that may appear in the input data can simply be treated as individual symbols.
- d) To the tree nodes corresponding to numerical values, functions should be assigned that calculate the choice of the outgoing branch.

> **Answer:** a) — Numerical attributes must be discretized (binned) into intervals, with thresholds statistically chosen from training data.

---

### Q13. How does training a neural network change it for specific tasks?

- a) The network remains the same, for example, the number of neurons and their types do not change; only the structure of the network is reorganized, including the positions of selected neurons, according to individual decision paths.
- b) As a result of training, activation paths related to the recognition of specific classes are created within the neural network during its use.
- c) Training the network causes the network parameters to adjust gradient-wise to a softmax probability distribution correlated with the given set of classes.
- **d) As a result of training, the connections between neurons are adjusted, and some may even be suppressed, due to changes in weights and the distribution of values generated at the outputs.**

> **Answer:** d) — Training modifies connection weights; some connections are strengthened while others are weakened or effectively disabled, tuning the network for the task.

---

### Q14. What is the significance of document segmentation for the functioning of the RAG system?

- **a) Segmentation determines the detail of the response by defining the size of the text window as the basis for providing the answer. The size and method of segmenting text (fragments of documents) can facilitate the precise determination of the basis for generating a response.**
- b) *(option b not clearly readable in source)*
- c) Segmentation does not affect the precision of the responses given they are generated by a large language model (LLM), but it is crucial for processing efficiency.
- d) Document segmentation in the database facilitates the generation of concise responses of limited length.

> **Answer:** a) — In RAG (Retrieval-Augmented Generation), segmentation size directly affects retrieval granularity and the quality of the evidence passed to the LLM.

---

### Q15. How does a neural network classify input data?

- a) Each layer of the network defines the projection of input signals onto the set of classes, and at the end, the output layer performs aggregation and voting according to the softmax scheme.
- b) The neural structures of a non-recurrent network form a forest of fuzzy classification trees built from subsets of neurons.
- **c) Activation functions shape the level of output signals, and in the output layer, the signals from the neurons are interpreted according to the assumed classification task.**
- d) The neural network in the input layer selects attributes and processes their chosen subset into a stimulation vector, which then passes through the subsequent layers and influences the output neurons in a gradient-wise way.

> **Answer:** c) — Activation functions transform signals layer by layer; in the output layer the neuron activations are mapped to class probabilities (e.g., via softmax).

---

### Q16. What can we use the k-nearest neighbors (k-NN) algorithm for?

- **a) It allows for making assumptions about the selected properties of unknown objects based on the exploration of an assumed similarity measure.**
- b) The k-NN algorithm can be used to evaluate the results of classification by a supervised algorithm.
- c) It enables the generation of a hierarchical structure of classes for the input data.
- d) It allows for discovering the optimal partitioning of input data and determining the number of classes — the parameter k — that are represented in that data.

> **Answer:** a) — k-NN infers properties of unknown instances by finding the k most similar known examples, based on a chosen distance/similarity metric.

---

### Q17. Why do we distinguish between the retrieval and re-ranking phases in Semantic Retrieval?

- a) This is due to the use of neural networks of varying depths and the orthogonal perspectives on comparing queries and documents.
- b) Because the matching of the query in the RAG system gradually transitions from the document level, through fragments, to sentences.
- **c) The goal is to maximize the accuracy of the cut-off ranking of the retrieved documents while minimizing computational resource consumption.**
- d) Both phases define different perspectives on comparing texts; sentence to sentence and word to word in the second case.

> **Answer:** c) — Fast first-stage retrieval (e.g., dense embeddings) narrows the candidate set; a heavier re-ranker then refines the top results without applying expensive computation to all documents.

---

## 📋 SECTION 2 — Exam 2025 (Polish, Termin 1), Questions 6–25
**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC` and `IMG_9009.HEIC`  
**Language:** Polish (original) — translated to English below  
**Note:** Images were photographed handwritten exam sheets; some text is OCR-degraded.

---

### Q6 (PL). Jak propagacja ograniczeń wpływa na efektywność algorytmu rozwiązywania problemów z ograniczeniami?
**How does constraint propagation affect the efficiency of a constraint problem-solving algorithm?**

- a) Jest to alternatywne podejście do przeszukiwania z powracaniem oparte na heurystycznym przeszukiwaniu w przód.  
  *(It is an alternative approach to backtracking search based on heuristic forward searching.)*
- b) Propagacja ograniczeń przenosi przeszukiwanie na poziom lokalnych operacji w obrębie dziedzin zmiennych.  
  *(Constraint propagation shifts the search to the level of local operations within the variable domains.)*
- **c) Propagacja ograniczeń dynamicznie zmniejsza efektywny rozmiar dziedzin zmiennych.**  
  *(Constraint propagation dynamically reduces the effective size of the variable domains.)*
- d) Rozbija problem na niezależne podproblemy w obrębie poszczególnych par zmiennych.  
  *(It breaks the problem into independent subproblems within individual pairs of variables.)*

> **Answer:** c)

---

### Q7 (PL). Kiedy używana jest spójność łukowa (arc consistency)?
**When is arc consistency used?**

- a) Jako element zapisu częściowego rozwiązania, w wyniku którego problem składa się z podproblemów gdzie pary są powiązane jednym łukiem.  
  *(As an element of partial solution encoding, resulting in subproblems where pairs are connected by a single arc.)*
- **b) Dla dowolnych dwóch zmiennych powiązanych ograniczeniem ich dziedziny zawierają wartości spełniające to ograniczenie.**  
  *(For any two variables connected by a constraint, their domains contain values satisfying that constraint.)*
- c) Jest to porządek częściowy par zmienna-heurystyka, przyspieszający znajdowanie rozwiązania.  
  *(It is a partial order of variable-heuristic pairs, accelerating solution finding.)*

> **Answer:** b)

---

### Q8 (PL). Dlaczego ważne jest, aby heurystyka była akceptowalna (admissible)?
**Why is it important for the heuristic to be admissible?**

- **a) Nie ukrywa problemu i zwraca wartości nie wyższe niż rzeczywisty koszt.**  
  *(It does not hide the problem and returns values no higher than the actual cost.)*
- b) Ponieważ pozwala na porównywanie wartości pomiędzy węzłami.  
  *(Because it allows comparing values between nodes.)*
- c) Ponieważ tylko akceptowalna heurystyka wyznacza klasy równoważności węzłów.  
  *(Because only an admissible heuristic defines equivalence classes of nodes.)*
- d) Ponieważ nie ukrywa ścieżki prowadzącej do węzła spełniającego test celu.  
  *(Because it does not hide the path leading to a node that satisfies the goal test.)*

> **Answer:** a)

---

### Q9 (PL). Kiedy pozycje w drzewie gry stają się stabilne (quiescent)?
**When do positions in the game tree become stable (quiescent)?**

- **a) Stabilne pozycje to takie, dla których sytuacja w grze nie koreluje się z zasadniczymi zmianami wartości funkcji oceniającej w kilku kolejnych posunięciach.**  
  *(Stable positions are those for which the game situation does not correlate with significant changes in the evaluation function over the next few moves.)*
- b) Pozycje, dla których jest równowaga ruchów atakujących i ruchów stwarzających zagrożenie.  
  *(Positions for which there is a balance between attacking moves and threat-creating moves.)*
- c) Drzewo gry staje się stabilne, gdy jego poddrzewa stają się zrównoważone po obcinaniu alfa-beta.  
  *(The game tree becomes stable when its subtrees become balanced after alpha-beta pruning.)*
- d) Pozycje stabilne są poniżej głębokości wyznaczającej problem horyzontu w drzewie gry.  
  *(Stable positions are below the depth defining the horizon problem in the game tree.)*

> **Answer:** a)

---

### Q10 (PL). Czym różnią się algorytmy planowania od heurystycznego przeszukiwania przestrzeni stanów?
**Do planning algorithms differ from heuristic state space search?**

- a) To algorytmy heurystycznego przeszukiwania oparte na heurystyce grafu porządku częściowego.  
  *(They are heuristic search algorithms based on a partial order graph heuristic.)*
- b) Algorytmy planowania nie budują kompletnego grafu przejścia od stanu początkowego do końcowego, a jedynie las grafów częściowych.  
  *(Planning algorithms do not build a complete transition graph, only a forest of partial graphs.)*
- **c) Algorytmy planowania wykorzystują wiedzę z symbolicznej reprezentacji operatorów zmiany stanu.**  
  *(Planning algorithms utilize knowledge from the symbolic representation of state change operators.)*
- d) Budują graf akcji deterministycznie i stosują heurystyki później do linearyzacji grafu porządku częściowego.  
  *(They build the action graph deterministically and apply heuristics later to linearize the partial order graph.)*

> **Answer:** c)

---

### Q11 (PL). Jakie są prawdziwe właściwości funkcji oceniającej w algorytmach grania w gry logiczne?
**What are the true properties of the evaluation function in algorithms for playing logical games?**

- a) Musi zwrócić 0 dla węzła końcowego drzewa gry i być zgodna z funkcją wypłaty dla pozostałych.  
  *(It must return 0 for the terminal node of the game tree and be consistent with the payoff function for the others.)*
- b) Funkcja oceniająca to funkcja heurystyczna kosztu wygrania w jednym ruchu.  
  *(The evaluation function is a heuristic function of the cost of winning in one move.)*
- **c) Funkcja oceniająca musi być zgodna z funkcją wypłaty dla węzłów końcowych oraz estymować ją dla wszystkich stanów pośrednich.**  
  *(The evaluation function must be consistent with the payoff function for terminal nodes and estimate it for all intermediate states.)*
- d) Funkcja oceniająca to dowolna funkcja liniowa zbioru cech opisujących stan gry.  
  *(The evaluation function is any linear function of the set of features describing the game state.)*

> **Answer:** c)

---

### Q17 (PL). Problem horyzontu w algorytmie grania w grę logiczną to:
**The horizon problem in a game-playing algorithm is:**

**Source:** `Egzamin 2025/qdb-2024-2025/17.txt`

- a) Ograniczona pojemność pamięci na dalsze rozwinięcie ścieżki w drzewie gry.  
  *(Limited memory capacity for further expansion of the path in the game tree.)*
- b) Zbliżone wartości funkcji oceniającej w kolejnych posunięciach, co utrudnia wybór ruchu.  
  *(Similar values of the evaluation function in consecutive moves, making it difficult to choose a move.)*
- **c) Zatrzymanie i nawrócenie z przeszukiwania drzewa gry przed momentem, w którym warunki na planszy się diametralnie zmieniają.**  
  *(Stopping and backtracking from the game tree search before the board conditions change dramatically.)*
- d) Możliwość analizy tylko części planszy gry ze względu na bardzo dużą złożoność gry.  
  *(The ability to analyze only part of the game board due to very high game complexity.)*

> **Answer:** c) — The horizon problem occurs when the search depth limit is reached just before a crucial board change, causing the algorithm to miss important consequences.

---

### Q20 (PL). [Neural network — local minima problem]
**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC` (OCR-degraded)

*(Full question text partially illegible due to image quality)*  
Partial reconstruction: **"Co zrobić, gdy sieć utknęła w minimum lokalnym?"**  
*(What to do when the network is stuck in a local minimum?)*

- a) Jeśli uda się w minimum lokalnym to jest dobra wartość...  
- b) Minimum lokalne to niska wartość funkcji błędu dla pewnego podzbioru — **poprzez okresowe zwiększanie wag za pomocą wariantów z momentum (cosine warmup).**  
  *(Local minimum is a low error value for a subset — counter via periodic weight increases using momentum/cosine warmup variants.)*
- c) Aby zapobiec utykaniu sieci w lokalnym minimum należy przeprowadzić przeskalowanie wag wybranej warstwy.  
  *(To prevent sticking in local minima, rescale weights of selected layers.)*

> **Note:** This question's text is OCR-degraded from a photograph; the core topic is neural network local minima and strategies to escape them.

---

### Q21 (PL). Wskaż prawdziwe stwierdzenie dotyczące walidacji krzyżowej:
**Indicate the true statement about cross-validation:**

**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC`

- a) Do poprawnego przeprowadzenia całego procesu — k-krotna walidacja krzyżowa to testowanie klasyfikatora na k podzbiorach danych.  
  *(For correct execution — k-fold cross-validation is testing the classifier on k subsets of data.)*
- b) Powtarzanie cykli uczenia po tym jak wynik się już ustabilizował powoduje overfitting.  
  *(Repeating learning cycles after the result has already stabilized causes overfitting.)*
- c) **K-krotna walidacja krzyżowa gwarantuje uniknięcie efektu nadmiernego dopasowania** *(k-fold cross-validation guarantees avoidance of overfitting — partially true as a control measure).*

> **Note:** Partial OCR degradation. Core concept: k-fold cross-validation splits data into k parts, using each as a test set once, averaging results.
>
> **Enriched explanation (sourced from `Notatki 2024/w5...docx`):** K-fold cross-validation splits the dataset into K equal parts ("folds"). The model is trained K times; on each run, one fold is held out as the test set and the remaining K−1 folds are used for training. The K results are then averaged to give the final performance estimate. This makes (b) the most defensible standalone true statement — continuing training cycles after the validation result has stabilized is a classic cause of overfitting — while (c) overstates what k-fold CV actually guarantees: it is an *evaluation/diagnostic* technique, not a mechanism that prevents overfitting by itself.

---

### Q22 (PL). Jeżeli generatywny model językowy (LLM) wykazuje obniżoną jakość na pewnej klasie zadań, co powinniśmy zrobić?
**If a generative language model (LLM) shows reduced quality on a certain class of tasks, what should we do?**

**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC`

- **a) Rozszerzyć zbiór instrukcji treningowych i powtórzyć fazę dostrajania (fine-tuning) instrukcji, a następnie ponowić fazę wyrównywania (alignment).**  
  *(Expand the set of training instructions and repeat the instruction fine-tuning phase, then redo the alignment phase.)*
- b) Zwiększyć wielkość korpusu tekstów do treningu wstępnego (pre-training) i kontynuować trening wstępny modelu.  
  *(Increase the pre-training corpus size and continue pre-training.)*
- c) Włączyć instrukcje treningowe dla tej klasy zadań do zbioru tekstów i od początku powtórzyć cały proces treningu.  
  *(Include training instructions for that task class in the text corpus and repeat the entire training process from scratch.)*
- d) Wyłączyć tę klasę zadań z dostrajania (fine-tuning) i w całości przekazać je podejściu opartemu na uczeniu przez wzmocnienie.  
  *(Exclude that task class from fine-tuning and fully delegate it to reinforcement learning.)*

> **Answer:** a) — For task-specific performance degradation, targeted instruction fine-tuning and alignment is the appropriate remedy.

---

### Q23 (PL). W jaki sposób można poprawić zdolność sieci neuronowej do generalizacji?
**How can we improve the generalization ability of a neural network?**

**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC`

- a) Poprzez zamianę miejscami wylosowanych par neuronów pomiędzy poziomami.  
  *(By swapping randomly selected pairs of neurons between layers.)*
- b) Podstawienie losowo wybranych wartości wag do grup neuronów wyselekowanych przez algorytm klastrowania.  
  *(Substituting randomly chosen weight values into neuron groups selected by a clustering algorithm.)*
- **c) Zastosowanie techniki dropout polegającej na wyłączaniu losowo wybranego podzbioru neuronów w każdej iteracji treningu.**  
  *(Applying the dropout technique by randomly disabling a subset of neurons in each training iteration.)*
- d) Można losowo przełączać wybrane powiązania między neuronami, aby uniezależnić sieć od wewnętrznej struktury.  
  *(Randomly switch selected connections between neurons to make the network independent of internal structure.)*

> **Answer:** c) — Dropout is the standard regularization technique that prevents co-adaptation of neurons, improving generalization.

---

### Q24 (PL). Jaki będzie wynik unifikacji dla wyrażenia: a(X, c(d,Z), b(X,e)) z a(2, Y, b(2,e))?
**What will be the result of unification for: a(X, c(d,Z), b(X,e)) with a(2, Y, b(2,e))?**

**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC`

- a) X=2, Y=b(2,e), Z=b(2,e)
- b) X=G345, Y=G345, Z=G345
- c) X=2, Y=G442, Z=G442
- **d) X=d, Y=e, Z=b(d,e)**
- e) brak unifikacji *(no unification)*

> **Answer:** d) — Unifying a(X, c(d,Z), b(X,e)) with a(2, Y, b(2,e)): X=2 from 1st arg; Y=c(d,Z) from 2nd arg; b(X,e)=b(2,e) → X=2 confirmed; Z must be resolved from Y=c(d,Z). Full correct answer depends on the exact expression — the source image is partially OCR-degraded.

---

### Q25 (PL). Do rozpoznawania kształtów na obrazie najlepiej zastosować:
**For recognizing shapes in an image, the best approach is:**

**Source:** `Egzamin 2025/Egzamin termin 1/IMG_9008.HEIC`

- **a) Sieć splotową (Convolutional Neural Network — CNN), ponieważ jej wagi dzielone przestrzennie umożliwiają pomijanie nieistotnych pikseli.**  
  *(A Convolutional Neural Network (CNN), because its spatially shared weights allow ignoring irrelevant pixels.)*
- b) Wielokierunkową sieć typu LSTM, która analizuje wielokierunkowe związki pomiędzy pikselami.  
  *(A multi-directional LSTM network that analyzes multi-directional relationships between pixels.)*
- c) Sieć typu BERT trenowaną w zadaniu maskowania ze względu na jej zdolność do rekontekstualizacji.  
  *(A BERT-type network trained on the masking task due to its re-contextualization ability.)*
- d) Sieć splotową (CNN) ponieważ umożliwia stopniowe wyodrębnianie cech hierarchicznych w kolejnych warstwach.  
  *(A CNN because it allows gradual hierarchical feature extraction in successive layers.)*

> **Answer:** a) or d) — Both point to CNNs; a) emphasizes spatial weight sharing, d) emphasizes hierarchical feature extraction. Both are correct properties of CNNs for shape recognition. The canonical answer is **d)** (hierarchical feature extraction).

---

## 📋 SECTION 3 — Testownik Questions (Polish), 2024–2025
**Source:** `Egzamin 2025/pytania_testownik/` and `Egzamin 2025/qdb-2024-2025/`

These questions come from the student Testownik question bank for the course.

---

### Q228 (PL). Jak propagacja ograniczeń wpływa na efektywność algorytmu rozwiązywania problemów z ograniczeniami?
**How does constraint propagation affect the efficiency of a constraint problem-solving algorithm?**

**Source:** `pytania_testownik/228.txt`  
**Answer key code:** QQ0010 (correct answer: option c)

- a) Jest to alternatywne podejście do przeszukiwania z powracaniem oparte na heurystycznym przeszukiwaniu w przód.  
  *(It is an alternative to backtracking search based on heuristic forward searching.)*
- b) Propagacja ograniczeń przenosi przeszukiwanie na poziom lokalnych operacji w obrębie dziedzin zmiennych.  
  *(Constraint propagation shifts the search to the level of local operations within variable domains.)*
- **c) Propagacja ograniczeń dynamicznie zmniejsza efektywny rozmiar dziedzin zmiennych.**  
  *(Constraint propagation dynamically reduces the effective size of variable domains.)*
- d) Rozbija problem na niezależne podproblemy rozwiązywania ograniczeń w obrębie poszczególnych par zmiennych.  
  *(It breaks the problem into independent subproblems of constraint solving within individual pairs of variables.)*

> **Answer:** c)

---

### Q241 (PL). Do czego możemy użyć algorytmu k-najbliższych sąsiadów (k-NN)?
**What can we use the k-nearest neighbors (k-NN) algorithm for?**

**Source:** `pytania_testownik/241.txt`  
**Answer key code:** QQ1000 (correct answer: option a)

- **a) Pozwala na formułowanie założeń dotyczących wybranych właściwości nieznanych obiektów na podstawie eksploracji przyjętej miary podobieństwa.**  
  *(It allows formulating assumptions about selected properties of unknown objects based on exploration of an assumed similarity measure.)*
- b) Algorytm k-NN może być użyty do oceny wyników klasyfikacji przez algorytm nadzorowany.  
  *(The k-NN algorithm can be used to evaluate results of classification by a supervised algorithm.)*
- c) Umożliwia generowanie hierarchicznej struktury klas dla danych wejściowych.  
  *(It enables generating a hierarchical class structure for input data.)*
- d) Pozwala na odkrycie optymalnego podziału danych wejściowych i określenie liczby klas — parametru k — które są reprezentowane w tych danych.  
  *(It allows discovering the optimal partitioning of input data and determining the number of classes — parameter k — represented in that data.)*

> **Answer:** a)

---

### Q17b (PL). Problem horyzontu w algorytmie grania w grę logiczną to:
**The horizon problem in a logical game-playing algorithm is:**

**Source:** `qdb-2024-2025/17.txt`  
**Answer key code:** X0010 (correct answer: option c)

- a) Ograniczona pojemność pamięci na dalsze rozwinięcie ścieżki w drzewie gry.  
  *(Limited memory capacity for further expansion of the path in the game tree.)*
- b) Zbliżone wartości funkcji oceniającej w kolejnych posunięciach, co utrudnia wybór ruchu.  
  *(Similar evaluation function values in consecutive moves, making move selection difficult.)*
- **c) Zatrzymanie i nawrócenie z przeszukiwania drzewa gry przed momentem, w którym warunki na planszy się diametralnie zmieniają.**  
  *(Stopping and backtracking from the game tree search before the board conditions change dramatically.)*
- d) Możliwość analizy tylko części planszy gry ze względu na bardzo dużą złożoność gry.  
  *(The ability to analyze only part of the game board due to very high game complexity.)*

> **Answer:** c)

---

### Q237 (EN/PL). What needs to be done to adapt decision trees, which are inherently symbolic, to operate on numerical values?

**Source:** `qdb-2024-2025/237.txt`  
**Answer key code:** X0010 (correct answer: option c/d depending on version)

- a) Należy wprowadzić przypisanie odpowiednich symboli do wartości numerycznych jako indywidualnych symboli.  
  *(It is necessary to introduce the assignment of appropriate symbols to numerical values as individual symbols.)*
- b) Funkcje, które mogą pojawić się w danych wejściowych, można po prostu traktować jako symbole indywidualne.  
  *(Values that may appear in the input data can simply be treated as individual symbols.)*
- **c) Dla węzłów drzewa odpowiadających wartościom numerycznym należy przypisać funkcje, które wyznaczają podział na przedziały dla każdego atrybutu indywidualnie, statystycznie dopasowane na podstawie danych treningowych.**  
  *(For tree nodes corresponding to numerical values, assign functions that determine the interval split for each attribute individually, statistically fitted from training data.)*
- d) Do węzłów drzewa odpowiadających wartościom numerycznym należy przypisać funkcje, które obliczają wybór wychodzącej gałęzi.  
  *(To tree nodes corresponding to numerical values, assign functions that calculate the choice of the outgoing branch.)*

> **Answer:** c) — Numerical values must be discretized by finding optimal threshold splits per attribute, determined from training data statistics.

---

## 📋 SECTION 4 — Topic Summary: Key Concepts Referenced in Exam Questions

The following topics are covered across all exam questions and should be studied thoroughly:

| Topic | Questions |
|---|---|
| State space search formulation | Q1 |
| Deductive reasoning / rule-based AI | Q2 |
| Constraint Satisfaction Problems (CSP): arc consistency, propagation | Q3, Q8, Q228, Q6-img |
| Partial order planning | Q4, Q9 |
| Game tree search: evaluation function, quiescence, horizon problem | Q5, Q7, Q17, Q11-img |
| Admissible heuristics (A*) | Q6, Q8-img |
| Decision trees: attribute ordering, numerical values, InfoGain/entropy | Q11, Q12, Q237 |
| Neural networks: training, generalization, dropout, local minima | Q13, Q23, Q20-img |
| RAG systems: document segmentation, semantic retrieval, re-ranking | Q14, Q17 |
| Neural network classification mechanism | Q15 |
| k-NN algorithm | Q16, Q241 |
| Unsupervised machine learning | Q10 |
| LLM fine-tuning and alignment | Q22 |
| Unification in logic programming | Q24 |
| CNN for image recognition | Q25 |
| K-fold cross-validation | Q21 |

---

## 📌 Notes for AI Processing

- Questions with **answer key codes** (e.g., `QQ1000`, `X0010`) use binary encoding where each digit represents one option (a/b/c/d), with `1` = correct answer.
- Some questions from photographed exam sheets (`IMG_9008.HEIC`, `IMG_9009.HEIC`) have partial OCR degradation — the content was reconstructed as accurately as possible.
- The 2020 PDF files (`si2020_combined_egzamin_obowiazkowy.pdf`, `si2020_wszystko_eportal_merged.pdf`) are lecture slides covering search algorithms, environment types, and AI fundamentals — not question banks, but useful background material.
- The `Notatki 2024` folder contains study notes (not questions) on ML, decision trees, ID3, C4.5 — useful for answers but not exam questions themselves.
