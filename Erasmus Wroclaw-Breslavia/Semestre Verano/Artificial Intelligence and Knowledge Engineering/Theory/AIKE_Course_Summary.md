# Artificial Intelligence & Knowledge Engineering - Course Summary
*Wrocław University of Science and Technology (WUST) | Maciej Piasecki, Halina Kwaśnicka*

---

## Table of Contents
1. [Problem Solving by Searching](#1-problem-solving-by-searching)
2. [Game Playing (Adversarial Search)](#2-game-playing-adversarial-search)
3. [Constraint Satisfaction Problems (CSP)](#3-constraint-satisfaction-problems-csp)
4. [Planning & STRIPS](#4-planning--strips)
5. [Logical Inference & Knowledge Representation](#5-logical-inference--knowledge-representation)
6. [Introduction to Machine Learning & Decision Trees](#6-introduction-to-machine-learning--decision-trees)
7. [Case-Based Reasoning & Unsupervised Learning](#7-case-based-reasoning--unsupervised-learning)
8. [Naïve Bayes & Statistical Classification](#8-naïve-bayes--statistical-classification)
9. [Neural Networks & Deep Learning](#9-neural-networks--deep-learning)
10. [Reinforcement Learning](#10-reinforcement-learning)
11. [Large Language Models & Prompt Engineering](#11-large-language-models--prompt-engineering)
12. [Semantic Retrieval, RAG & LLM-Based Agents](#12-semantic-retrieval-rag--llm-based-agents)

---

## 1. Problem Solving by Searching

### Core Concepts
A **search problem** is defined by: an **initial state**, a set of **operators** (actions), a **goal test**, and a **path cost**. The state space is the set of all reachable states.

Key properties of problem environments: observable, deterministic, sequential, static, discrete.

### Uninformed (Blind) Search
These algorithms have no information about the distance to the goal.

- **BFS (Breadth-First Search):** explores level by level. Complete and optimal (if costs uniform), but high memory usage - O(b^d).
- **DFS (Depth-First Search):** explores deep paths first. Low memory - O(bm), but not optimal, not complete in infinite spaces.
- **Uniform Cost Search:** expands the cheapest node first. Optimal if step costs > 0.
- **Iterative Deepening (ID-DFS):** combines DFS memory efficiency with BFS completeness. Optimal for uniform costs.

### Informed (Heuristic) Search
Use a **heuristic function h(n)** - estimated cost from node n to the goal.

- **Greedy Best-First:** expands node with lowest h(n). Fast but not optimal.
- **A\* Search:** expands node with lowest f(n) = g(n) + h(n), where g(n) is actual cost from start. **Optimal and complete** if h(n) is **admissible** (never overestimates the true cost).
- **IDA\*:** iterative deepening version of A\*. Memory-efficient.
- **SMA\* (Simplified Memory-Bounded A\*):** uses available memory; forgets the shallowest, highest-cost nodes when memory is full, storing their cost in their ancestor.

### Local Search
Used when the path doesn't matter - only the final state.

- **Hill Climbing:** repeatedly moves to the neighbour with lower loss. Problem: gets stuck in **local optima**.
- **Tabu Search:** allows worsening moves to escape local optima; maintains a "tabu list" of visited states.
- **Simulated Annealing:** probabilistically accepts worse moves - probability decreases over time.

### Key Exam Points
- An **admissible heuristic** never overestimates → guarantees A\* optimality.
- Every problem **can** be formulated as a state space search (operators can represent any symbolic-arithmetic computation).
- IDA\* main drawback: re-expands states already visited (no memory of them).

---

## 2. Game Playing (Adversarial Search)

### Game Theory Basics
A **game** is a structured conflict where each player tries to maximise their own payoff. Key game types:
- **Zero-sum** (one's win = other's loss): chess, checkers, Go.
- **Non-zero-sum**: prisoner's dilemma.
- **Deterministic vs. stochastic**: chess is deterministic; poker is stochastic.
- **Perfect vs. imperfect information**: chess is perfect; poker is imperfect.

### Game Tree
The game is modelled as a tree: root = initial state, nodes = game states, branches = moves. Terminal nodes have **payoff values**. Non-terminal nodes are evaluated by a **heuristic evaluation function**.

### Min-Max Algorithm
- **MAX** player chooses moves maximising the evaluation.
- **MIN** player (opponent) chooses moves minimising it.
- Assumes the opponent plays **optimally**.
- Complexity: O(b^d) - infeasible for large games (e.g., chess: 35^100 nodes).

### Alpha-Beta Pruning
An optimisation that **prunes branches** the Min-Max would never explore:
- **α (alpha):** best value MAX can guarantee so far (lower bound for MAX).
- **β (beta):** best value MIN can guarantee so far (upper bound for MIN).
- A branch is cut if α ≥ β.
- Optimistic complexity: **O(b^(d/2))** - doubles the effective search depth vs. raw Min-Max.
- Worst case: O((b/log b)^d). Node ordering is critical for efficiency.

### Evaluation Function
- Must agree with the **payoff function** at terminal nodes.
- Should estimate win probability for intermediate states.
- Often a **linear combination of features** describing the game state.
- Deep Blue used 8,000 patterns with assigned weights.

### Horizon Problem
The **horizon effect**: the search stops before a board state changes dramatically (e.g., a major capture just beyond the search depth). The evaluation function sees a misleadingly calm state.

**Quiescent positions** are states where the evaluation function is unlikely to change significantly in the next few moves - safe to stop the search there.

### Deep Blue (IBM, 1997)
- Defeated world champion Kasparov using α-β Min-Max with extensive extensions.
- Two-level architecture: software search near the root + hardware search near the leaves.
- Used an **opening book** (4,000 manually described positions) and a **700,000-game database**.
- Evaluation function with slow (conceptual chess features) and fast (square-based) components.

---

## 3. Constraint Satisfaction Problems (CSP)

### Definition
A CSP is defined by:
- **Variables:** X = {X₁, X₂, …, Xₙ}
- **Domains:** each variable Xᵢ has a domain Dᵢ of possible values.
- **Constraints:** relations restricting combinations of variable values.

A **solution** is a complete, consistent assignment (all variables assigned, all constraints satisfied).

Example: Australia map colouring - variables are regions, domain is {red, green, blue}, constraints say adjacent regions must differ.

### Types of Constraints
- **Absolute:** must be satisfied (part of the goal).
- **Preferred:** introduce a partial order of solutions (optimisation problems).
- **Unary, Binary, N-ary:** depending on how many variables they involve. N-ary constraints can be reduced to binary with auxiliary variables.

### CSP as a Graph
- **Nodes** = variables, **Arcs** = binary constraints.

### Blind Search for CSP
**Backtracking search:** assigns values one variable at a time, backtracks when a constraint is violated.

```
BACKTRACKING-SEARCH:
  SELECT unassigned variable
  FOR each value in its domain:
    IF consistent with assignment:
      add assignment
      result ← RECURSIVE-BACKTRACKING
      IF result ≠ failure: return result
    REMOVE assignment
  RETURN failure
```

### Constraint Propagation
**Forward checking:** after assigning X, remove from other variables' domains the values inconsistent with X's value.

**Arc Consistency (AC-3):** for every arc (Xᵢ, Xⱼ), every value in Dᵢ must have at least one compatible value in Dⱼ. If a value is deleted from Dᵢ, all arcs pointing to Xᵢ must be re-checked.

**MAC (Maintaining Arc Consistency):** runs AC-3 after each variable assignment during search.

Arc consistency **dynamically reduces the effective size of variable domains** - making it key to CSP efficiency.

### Heuristics for CSP
- **MRV (Minimum Remaining Values) / Most Constrained Variable:** choose the variable with the fewest legal values left.
- **Most Constraining Variable (Degree Heuristic):** choose the variable involved in the most constraints on remaining variables.
- **Least Constraining Value:** choose the value that rules out the fewest values in neighbouring domains.

### k-Consistency
A CSP is **k-consistent** if for any consistent assignment to k-1 variables, a consistent value can always be found for the k-th variable. Arc consistency = 2-consistency; path consistency = 3-consistency.

### Problem Structure
- **Tree-structured CSPs** can be solved in O(nd²) - linear in number of variables.
- General graphs can be reduced to trees by removing or collapsing nodes.

---

## 4. Planning & STRIPS

### Planning Concept
Planning = searching for a sequence of actions to transition from an **initial state** to a **goal state**.

### STRIPS Representation
**State:** a conjunction of ground literals (closed-world assumption - unlisted literals are false).

**Action (Operator)** consists of:
- **Name/description**
- **Preconditions:** conjunction of literals that must be true before the action.
- **Effects:**
  - **ADD list** - literals made true.
  - **DELETE list** - literals made false.

Example - Fly(p, from, to):
- PRECOND: At(p, from) ∧ Plane(p) ∧ Airport(from) ∧ Airport(to)
- EFFECT: ¬At(p, from) ∧ At(p, to)

### STRIPS vs ADL
| Feature | STRIPS | ADL |
|---|---|---|
| States | Positive literals only | Positive and negative literals |
| World Assumption | Closed (unlisted = false) | Open (unlisted = unknown) |
| Goals | Ground literals, conjunctions | Quantified variables, disjunctions |
| Effects | Conjunctions only | Conditional effects allowed |
| Types | No | Yes |

### Partial Order Planning (POP)
Uses the **least commitment principle** - only order steps when necessary.

A **partial order plan** has:
- Set of plan steps.
- Ordering constraints (only where needed).
- Variable binding constraints.
- Causal links: Sᵢ → Sⱼ means Sᵢ achieves condition c needed by Sⱼ.

**Threats** (clobbering): an action C that deletes a condition c needed by a causal link. Resolved by:
- **Demotion:** place C before the achieving step.
- **Promotion:** place C after the consuming step.

### PDDL (Planning Domain Definition Language)
Standard language for planning systems. Defines domains (predicates, actions) and problems (objects, initial state, goal).

Notable planning systems: **FF** (forward hill-climbing, satisficing), **LAMA** (landmark + FF heuristics), **Fast Downward** (A\*, optimal).

### Heuristics for Planning
- **Delete relaxation:** ignore delete effects → compute a relaxed plan → use its length as a heuristic.
- **Landmarks:** facts/actions that must occur in every solution.
- **Abstraction:** merge states to simplify the problem.

### Key Exam Point
Planning algorithms **utilise knowledge from the symbolic representation of operators** - this is what distinguishes them from pure heuristic search. The Partial Order Plan uses **only necessary ordering constraints**.

---

## 5. Logical Inference & Knowledge Representation

### Inference Types
- **Deduction:** from general to specific. ((p → q) ∧ p) → q is true. Sound and complete.
- **Induction:** from specific to general. Basis of machine learning.
- **Abduction:** reasoning about probable causes. ((p → q) ∧ q) → p is probable.

### Propositional Logic
**Implication:** p → q ≡ ¬p ∨ q

Truth table: p → q is false only when p is true and q is false.

**Modus Ponens:** If (p → q) and p is true, infer q.

### Forward Chaining
Start with known facts; apply rules to derive new facts until no more can be added or the goal is reached. Data-driven (bottom-up).

### Backward Chaining
Start from the goal; identify which rules could produce it; work backwards to known facts. Goal-driven (top-down).

### First-Order Logic (FOL)
Extends propositional logic with:
- **Constants, Variables, Functions**
- **Predicates** (parameterised propositions): e.g., `IsOpen(CircuitBreaker, Line4)`
- **Quantifiers:** ∀ (for all), ∃ (there exists)

### Resolution
A proof method: to prove q, add ¬q, convert everything to CNF (Conjunctive Normal Form), and resolve until a contradiction (empty clause) is found.

### Semantic Networks
A **labelled digraph** representing knowledge:
- Nodes = objects, concepts, attributes.
- Edges = relations (is_a, has, has_part, instance).
- Key relations for **inheritance**: `is_a` (taxonomic) and `instance`.

Definition: G = (V, S, u) where V = nodes, S ⊆ V×V edges, u: S → W×N assigning properties/weights.

### Knowledge Representation Formats
- **<Object, Attribute, Value> triples** - basic unit of semantic representation.
- **Binary relations, N-ary relations** (reducible to nested binary).
- **Ontologies** - formal, shared conceptualisations of a domain.
- **RDF graphs** - e.g., DBpedia, Freebase.

### Non-monotonic and Extended Logic
- **Classical logic is monotonic** - new facts never retract old conclusions.
- **Non-monotonic logic** allows revision of beliefs.
- Extensions: **Temporal logic**, **Fuzzy logic**, **Probabilistic logic**.

---

## 6. Introduction to Machine Learning & Decision Trees

### Learning Definition
A system **learns** from experience E with respect to tasks T and performance measure P, if performance on T improves with E. (Mitchell, 1997)

Learning = autonomous change on the basis of experience that causes better system functionality.

### ML Paradigms
- **Supervised learning:** labelled training data → classification or regression.
- **Unsupervised learning:** no labels → clustering, dimensionality reduction.
- **Reinforcement learning:** learning from rewards via interaction.

### Deduction vs Induction
- **Deduction:** general → specific (top-down).
- **Induction:** specific → general (bottom-up, basis of most ML).

### Inductive Learning Hypothesis
Any hypothesis that approximates the target function well on a large training set will also approximate it on unseen examples.

**Bias** of an inductive algorithm = factors determining which hypothesis is preferred among all consistent ones.

### Evaluation
- **Training set / Development (tuning) set / Test set** - kept hidden during training.
- **k-fold Cross-Validation:** data split into k folds; train on k-1, test on 1; repeat k times; average results.

### Decision Tree Induction
A tree where:
- Non-leaf nodes = attribute tests.
- Branches = attribute values.
- Leaf nodes = class labels.

**ID3 Algorithm** - greedy, top-down induction. Selects attribute with highest **Information Gain**:
- **Entropy:** H(S) = -Σ pᵢ log₂(pᵢ)
- **Information Gain:** IG(S, A) = H(S) − Σ (|Sᵥ|/|S|) H(Sᵥ)

Prefers attributes with more values → **Gain Ratio** (C4.5) corrects this:
- GainRatio(S, A) = IG(S, A) / SplitInfo(S, A)

### Overfitting
A hypothesis h overfits if there exists h' with worse training error but better test error. As tree depth grows, training performance increases monotonically, but test performance eventually drops.

**Prevention:**
- **Early stopping** - stop before perfect training fit.
- **Post-pruning** - build full tree, then prune (reduced-error pruning: prune a node if performance doesn't worsen).
- **Chi-square test** - stop expanding if further splitting only helps training.
- **MDL (Minimum Description Length)** - stop when encoding is minimal.

### Continuous Attributes
Find a threshold tᵢ maximising Information Gain by testing splits (48+60)/2, etc. Continuous attributes can appear multiple times in a tree with different thresholds.

### C4.5 Improvements over ID3
- Gain Ratio instead of Information Gain.
- Handles continuous attributes.
- Handles missing attribute values.
- Post-pruning.
- Different attribute costs.

### Decision Trees: Key Properties
- Hypothesis space = all finite discrete-valued functions (complete).
- Greedy search → **local optimum** (no backtracking).
- **Self-explainable** - rare in ML.

---

## 7. Case-Based Reasoning & Unsupervised Learning

### Case-Based Reasoning (CBR) / Instance-Based Learning
Also called: Memory-based learning, k-NN.

Core idea: "Similar objects often belong to the same class." To classify x, find the most similar training examples and label x accordingly.

### k-Nearest Neighbour (k-NN)
1. Find k nearest neighbours of x in the training set.
2. Assign the most frequent class among those k neighbours.

k should be **odd** to avoid ties. Common distance measures:
- **Euclidean distance:** d(x, y) = √Σ(xᵢ − yᵢ)²
- **Hamming distance:** for binary attributes.
- **Minkowski, Mahalanobis** - generalisations.

Distance must satisfy: non-negativity, symmetry, d(x,x)=0, triangle inequality. Not every similarity measure is a distance.

### Problems with k-NN
- **Irrelevant attributes** distort distances → attribute selection needed.
- **Scale differences** - larger-range attributes dominate → **normalise** to [0,1].
- **Curse of Dimensionality:** as attribute count grows, needed training data grows exponentially.

### Weighted k-NN
Closer neighbours get higher weight: wᵢ = 1/dᵢ (normalised). Weighted voting across classes.

### Unsupervised Learning - Clustering
Goal: discover natural groups (clusters) in unlabelled data.

Key questions: how to measure similarity, how to find groups, how to represent them.

**Cluster properties:**
- Non-overlapping (strict) vs fuzzy.
- Internal density and consistency.
- Number and balance of clusters.

**Centroid** = average attribute vector of all cluster members.

### k-Means Algorithm
1. Initialise k centroids.
2. Assign each example to the nearest centroid.
3. Recalculate centroids.
4. Repeat until stable (no example moves cluster).

Problems: sensitive to initialisation, normalisation needed, choice of k.

**Evaluation:**
- **External (supervised):** compare to known labels - purity, entropy.
- **Internal (unsupervised):** SD (summed distances to centroids), Dunn index, Silhouette coefficient.

### Hierarchical Aggregation
1. Start: each example is its own cluster (N clusters).
2. Merge the two closest clusters.
3. Repeat until stopping criterion.

Result: a **dendrogram** - a tree showing the merge hierarchy.

### ML Frameworks
- **WEKA:** Java-based, GUI, many built-in algorithms.
- **scikit-learn:** Python library, pipelines, 100+ classifiers.
- **TiMBL:** memory-based learner.

---

## 8. Naïve Bayes & Statistical Classification

### Bayes' Theorem
P(h|D) = P(D|h) · P(h) / P(D)

- **Prior P(h):** probability of hypothesis h before seeing data.
- **Likelihood P(D|h):** probability of data given h.
- **Posterior P(h|D):** probability of h given data.

**MAP (Maximum A Posteriori):** argmax_h P(h|D) = argmax_h P(D|h)·P(h)

**ML (Maximum Likelihood):** if all h equally likely, argmax_h P(D|h)

### Naïve Bayes Classifier
Classify document D into class cⱼ by:

P(cⱼ|D) ∝ P(cⱼ) · Π P(xᵢ|cⱼ)

**Naïve Bayes Assumption:** features are **conditionally independent** given the class.

Two models:
- **Multivariate Binomial:** each word either present or absent.
- **Multinomial:** uses word frequencies. Generally better.

### Smoothing (Laplace/Add-one)
To avoid zero probabilities:

P(xᵢ|cⱼ) = (count(xᵢ, cⱼ) + 1) / (count(cⱼ) + |Vocabulary|)

### Language Models
**Unigram model:** P(string) = Π P(word). Simple and effective for classification.

**Bigram/n-gram:** P(wᵢ | wᵢ₋₁, …, wᵢ₋ₙ₊₁) - captures word order.

### Feature Selection
**Mutual Information (MI):** measures extent of association between term and category.
**Chi-square (χ²):** measures confidence in association (statistical significance).

In practice, even just using the most common terms performs ~90% as well.

**Overfitting risk:** performing feature selection on the whole dataset (including test data) leaks information.

### When NB Works Well
Even with violated independence assumptions, NB classification is often correct - because classification only needs to compare P(A,c₁) vs P(A,c₂), not estimate probabilities accurately. The posterior probabilities themselves are unreliable (very close to 0 or 1).

---

## 9. Neural Networks & Deep Learning

### Biological vs. Artificial Neuron
**Biological:** many inputs, one output; fires when activation reaches threshold; non-linear.

**Artificial neuron:**
- Computes weighted sum: z = Σ wᵢxᵢ + b
- Applies **activation function** f(z)
- Common activations: sigmoid (σ), tanh, **ReLU** (max(0,z)), Leaky ReLU, softmax (for output layer probabilities).

### Multilayer Perceptron (MLP)
Architecture: input layer → one or more hidden layers → output layer.

**Forward propagation:** for each hidden neuron j: f(Σ wₖⱼ xₖ + bⱼ). Output: yᵢ = f(Σ wⱼᵢ · hiddenⱼ + bᵢ).

**Training - Backpropagation:**
1. Forward pass: compute output.
2. Compute loss (e.g., MSE or cross-entropy).
3. Backward pass: compute gradients via **chain rule** through the computational graph.
4. Update weights: w ← w − η∇E (gradient descent, η = learning rate).

### Overfitting in NNs
Solutions:
- **More training data / data augmentation.**
- **Reduce model complexity.**
- **Early stopping** (monitor dev set error).
- **Dropout / Dropconnect:** randomly disable neurons/connections during training.
- **Regularisation (L1/L2).**
- **Trade-off breadth vs. depth** (deeper nets need fewer neurons per layer).

### Deep Neural Networks
**CNNs (Convolutional Neural Networks):** shared spatial weights → detect local patterns. Hierarchy of features (edges → shapes → objects). Best for images.

**RNNs / LSTMs:** process sequences; LSTM avoids vanishing gradient with gating mechanisms.

**Word Embeddings (Word2Vec, GloVe):** dense vector representations of words in a semantic space.

### Transformers
Introduced in "Attention Is All You Need" (Vaswani, 2017). Replaced recurrent architectures.

**Self-Attention mechanism:** for each element in a sequence, compute attention to all other elements using Query (Q), Key (K), Value (V) projections:
- Attention(Q,K,V) = softmax(QKᵀ/√dₖ)·V

**Multi-Head Attention:** M independent projections capturing different types of relationships.

**BERT (Bidirectional Encoder Representations from Transformers):**
- Encoder-only, bidirectional.
- Pre-trained with Masked Language Modelling (MLM) and Next Sentence Prediction (NSP).
- Fine-tuned for downstream tasks.

**GPT (Generative Pre-trained Transformer):**
- Decoder-only, unidirectional (causal masking - can't look at future tokens).
- Autoregressive: generates one token at a time.
- Uses trained positional vectors.

### Decoding Strategies
- **Greedy:** always pick the highest-probability token.
- **Sampling (Top-k, Top-p/nucleus):** sample from restricted probability distribution.
- **Beam search:** keep top B partial sequences at each step.

---

## 10. Reinforcement Learning

### Core Idea
An **agent** learns to maximise cumulative reward by interacting with an **environment**. No explicit teacher - learning via trial-and-error and delayed rewards.

Distinguishing features:
- **Trial-and-error search**
- **Delayed reward** (actions affect future states)

### Key Differences from Supervised ML
- No supervisor, only a reward signal.
- Feedback is delayed, not instantaneous.
- Sequential, non-i.i.d. data.
- Agent's actions affect future data it receives.

### RL Elements
- **Policy π:** mapping from states to actions. Deterministic: a = π(s). Stochastic: π(a|s) = P[Aₜ=a|Sₜ=s].
- **Reward function:** maps state (or state-action pair) → scalar reward. Property of the environment, not the agent.
- **Value function V(s):** expected cumulative future reward from state s. Long-term desirability.
- **Model (optional):** agent's internal representation of the environment.

### Discounted Return
Agent maximises expected **discounted return**:
Gₜ = rₜ₊₁ + γrₜ₊₂ + γ²rₜ₊₃ + …

- γ = 0: only immediate reward matters.
- γ = 1: fully far-sighted.
- 0 < γ < 1: balances immediate and future rewards.

### Temporal-Difference (TD) Learning
Update rule for state value:
V(s) ← V(s) + α[V(s') − V(s)]

where α is the learning rate (step-size parameter) and s' is the next state. Changes are based on the **difference between estimates at two time steps**.

### Q-Learning
Learns the **action-value function Q(s, a)** - expected return when taking action a in state s. Off-policy algorithm. Converges to optimal policy if:
- Each state-action pair visited infinitely often.
- Learning rate decreases appropriately.

**ε-greedy exploration:** select greedy action with probability 1-ε; random action with probability ε.

### Tic-Tac-Toe Example
- Assign values to all states (probability of winning).
- Play greedily most of the time; occasionally explore.
- After each greedy move, back up the value: update earlier state toward later state's value.
- This is TD learning - no explicit opponent model needed.

### RL vs. Dynamic Programming
DP requires a complete model (all transition probabilities). RL learns from experience when the model is unknown.

---

## 11. Large Language Models & Prompt Engineering

### What is an LLM?
A **Large Language Model** is a very large generative neural language model:
- From 1B to hundreds of billions of parameters.
- Mostly **decoder-only** (autoregressive).
- Pre-trained on massive text corpora.

### LLM Training Pipeline

**1. Pre-training (Unsupervised)**
- Task: **next-token prediction** (autoregressive).
- Loss: negative log-likelihood of correct tokens.
- More data → more general knowledge and capabilities.

**2. Fine-tuning (Supervised, SFT)**
- Input: instruction → model → output R̂.
- Loss: comparison of R̂ with reference answer R.
- Types: text conversion, classification, QA, dialogue, NER, etc.

**3. Alignment (RLHF / DPO)**
- Goal: align model behaviour with human preferences.
- **RLHF (Reinforcement Learning with Human Feedback):** humans evaluate responses → train a reward model → use RL to improve policy.
- **DPO, KTO:** alternative alignment methods.

### Prompt Engineering

**Zero-Shot Prompting:** instruction + data, no examples.

**Few-Shot Prompting:** instruction + examples + data. A few examples improve performance significantly; more don't help much beyond that.

**Chain-of-Thought (CoT) Prompting:** provide step-by-step solutions in examples. Forces the model to reason through intermediate steps. Greatly improves complex multi-step problems.

**Role-Playing:** instruct the model to assume a persona.

**Reflexion / Self-consistency:** model critiques and refines its own outputs.

**Least-to-Most Prompting:** decompose a complex problem into subproblems.

### Tips for Writing Prompts
- Be concrete and direct; avoid wordiness.
- Specify exact output format.
- Avoid ambiguity (e.g., "2-3 sentences" instead of "a few sentences").
- Tell the model what to do, not what to avoid.
- Context length matters - keep prompts efficient.

### In-Context Learning
Beyond fine-tuning tasks - the model generalises to new tasks from examples in the prompt. Maximising semantic similarity between demonstration examples and the test input improves results.

### LLM Parameters (API)
- **Temperature:** lower → more deterministic/repeatable output.
- **Top-p (nucleus sampling):** limits token selection to top cumulative probability mass.
- **Max length:** maximum tokens generated.
- **Stop sequence:** stops generation when pattern occurs.
- **Frequency penalty / Presence penalty:** reduce word repetition.

### RAG (Retrieval-Augmented Generation)
Combines an LLM with a retrieval system:
1. Query → retrieve relevant document chunks.
2. Chunks + query → LLM → answer.

Key aspects: document segmentation, semantic retrieval (embeddings), re-ranking.

---

## 12. Semantic Retrieval, RAG & LLM-Based Agents

### Semantic Retrieval
**Goal:** produce a ranked list of documents from a corpus in response to a query — a query-document matching problem.

Three core challenges:
- **Representation:** how to encode query vs. document.
- **Matching method:** how to compare them.
- **Process efficiency:** scaling to very large collections.

#### Retrieval Pipeline
1. **Lexical retrieval** — keyword matching via an inverted index (e.g. BM25).
2. **Re-ranking** — ML-based refinement of the top-k candidates.
3. **Answer extraction** — passage retrieval and answer span detection.

#### BM25 (Lexical Baseline)
BM25 scores a query q against document d by summing term weights that account for **term frequency** (tf), **inverse document frequency** (idf), and **document length normalisation**. Parameters k₁ and b control term-frequency saturation and length penalty.

#### Evaluation Metrics
- **Precision@k / Recall@k** — accuracy within the top k results.
- **MRR (Mean Reciprocal Rank)** — average of 1/rank of the first relevant result across queries.
- **nDCG (Normalised Discounted Cumulative Gain)** — rewards high-relevance documents appearing early in the ranking; normalised by the ideal ranking (IDCG).

### Query-Document Interaction Models
Four architectural families:

| Architecture | Idea | Example |
|---|---|---|
| Representation-based | Encode query & doc separately; compare vectors | DSSM, SNRM |
| Interaction-based | Explicit token-level match matrix | DRMM, KNRM |
| All-to-all (Cross-encoder) | Full joint attention over all tokens | monoBERT |
| Late Interaction | Separate encoders + MaxSim at query time | ColBERT |

**monoBERT:** input is `[CLS] query [SEP] document [SEP]`; the `[CLS]` vector predicts relevance. Cross-encoders achieve the highest scores because attention models every query-document token interaction — but are slow (must re-encode every (q, d) pair).

**ColBERT:** keeps fast separate encoders, then matches each query token to its most similar document token (MaxSim). Balances quality and efficiency.

### Retrieval-Augmented Generation (RAG)

#### Core Idea
Augment an LLM with a retrieval step so answers are **grounded in retrieved documents** rather than only in parametric memory.

**Pipeline:** User query → document index (chunks/vectors) → semantic retrieval → retrieved chunks + query → LLM prompt → answer.

**Advantages over pure LLM:**
- Delivers up-to-date information beyond training cutoff.
- Reduces hallucinations by anchoring responses in real documents.
- Supports domain-specific corpora (internal company docs, recent events).
- Enables citation of the source passage.

#### RAG Optimisation Levels
- **Naive RAG:** fixed query → retrieval → generation.
- **Advanced RAG** adds:
  - *Pre-retrieval:* query routing, query rewriting, query expansion.
  - *Post-retrieval:* re-ranking, summarisation, fusion of multiple retrieved chunks.
- **Document chunking** strategy affects retrieval quality.
- **Response analysis and regeneration** when the generated answer is insufficient.

#### RAG Retrieval Strategies
- **Iterative:** retrieve → generate → judge → repeat (provides more context incrementally).
- **Recursive:** query decomposition between retrieve-generate cycles (breaks down complex problems).
- **Adaptive:** judge whether retrieval is needed before each step; uses special tokens or thresholds to control the cycle dynamically.

#### Multiagent RAG (MMOA-RAG)
Each RAG component (query rewriter, retriever, selector, generator) is treated as a **separate trainable agent** with its own reward function, optimised with RL against a shared end reward (correct answer).

---

### LLM-Based Agents
An **LLM-based agent** is a modular architecture where an LLM autonomously analyses a problem, decides on actions, and executes them.

#### Four Core Components

**(1) Environment** — the decision-making space the agent operates in (computer, code interpreter, simulation, real world, etc.).

**(2) Memory**

| Type | Description |
|---|---|
| Short-term | Prompt context, recent dialogue history, context compression via summarisation |
| Long-term | Knowledge graphs, vector stores, relational databases, API calls — persists across sessions |
| Memory retrieval | Classifier-based sourcing; strategies for remembering (preservation) and forgetting (pruning) |

Analogy with human memory: sensory memory → input embeddings; short-term → task context; long-term (episodic + semantic) → external storage; training memory → model parameters.

**(3) Tools (Function Calling)**

Allows the agent to call external functions, APIs, databases, and programs — enabling procedural action beyond text generation.

**Mechanism:**
1. Agent receives a JSON schema describing available tools.
2. LLM selects the appropriate function and arguments.
3. The environment executes the call and returns a result.
4. The agent analyses the result and decides on the next action.

The LLM is fine-tuned (SFT) on examples of tool use to learn when and how to call tools correctly. Key challenges: recognising when a tool is needed, generating correct parameters.

**(4) Planning and Reasoning**

**ReAct ("Think and Do"):** the agent alternates between a *Thought* (internal reasoning), an *Action* (tool call / search), and an *Observation* (result) — cycling until the answer is found.

**Reflexion ("Learn from Mistakes"):** generate an initial answer → self-critique ("does this make sense?") → refine based on the critique. Implemented as a prompt cycle.

**Chain-of-Thought with Reflection (CoT+):** uses structured tags — `<thinking>` for reasoning, `<reflection>` for error checking, `<adjustment>` for corrections, `<output>` for the final answer.

**Training methods for planning:**
- *Supervised (Process Supervision, Hinting):* provide correct intermediate steps as ground truth.
- *Reinforcement (Dialogue Shaping, REX):* reward correct strategies from environment feedback.
- *Multimodule / multiagent:* separate planning, memory, and execution modules (planner–executor architectures).

---

### ToRA — Tool-Integrated Reasoning Agent
(Gou et al., 2024)

Combines **Chain of Thought** (natural language reasoning) with **code-based tool use** (PAL — Program-Aided Language Models) for mathematical problem solving.

**ToRA format** for a single problem:
1. **r₁** — natural language rationale (e.g. "I'll use SymPy to solve this").
2. **a₁** — Python code calling a symbolic library.
3. **o₁** — output from code execution.
4. **r₂** — final natural language answer from the output.

**Two-stage training:**
1. *Imitation Learning:* a strong LLM generates tool-integrated reasoning trajectories → valid ones collected into a ToRA-Corpus → student model fine-tuned on corpus.
2. *Output Space Shaping (weak supervision):* student model samples multiple trajectories; erroneous ones are corrected by a teacher model; corrected trajectories used for further fine-tuning.

**Tool ecosystem:** SymPy (symbolic maths) dominates across nearly all topics; `solvers` and `rational` are heavily used in PreCalc and Geometry; `algorithm` achieves near-perfect accuracy in Combinatorics and Algebra.

---

## Quick Reference: Key Algorithms

| Algorithm | Type | Key Property |
|---|---|---|
| BFS | Uninformed search | Complete, optimal (uniform cost), high memory |
| DFS | Uninformed search | Low memory, not optimal, not complete |
| A\* | Informed search | Optimal if h admissible, complete |
| IDA\* | Informed search | A\* with low memory, re-expands states |
| SMA\* | Informed search | Uses bounded memory, forgets highest-cost leaves |
| Min-Max | Game search | Optimal vs perfect opponent |
| α-β Pruning | Game search | Prunes Min-Max, O(b^(d/2)) optimistic |
| Backtracking | CSP | Systematic, complete |
| AC-3 | CSP propagation | Maintains arc consistency, prunes domains |
| STRIPS | Planning | Closed-world, add/delete lists |
| ID3/C4.5 | Supervised ML | Decision tree by information gain |
| k-NN | Supervised ML | Instance-based, no explicit model |
| k-Means | Unsupervised ML | Clustering via centroid iteration |
| Naïve Bayes | Statistical ML | Conditional independence assumption |
| MLP + Backprop | Neural Network | Gradient descent via chain rule |
| Q-Learning | Reinforcement RL | Off-policy, learns action-value function |
| Transformer | Deep Learning | Self-attention, parallel sequence processing |
| BM25 | Lexical retrieval | TF-IDF-style scoring with length normalisation |
| monoBERT | Neural re-ranking | Cross-encoder; joint query-document attention via [CLS] |
| ColBERT | Late interaction retrieval | Separate encoders + MaxSim; fast and accurate |
| Naive RAG | Retrieval-augmented LLM | Query → retrieve → generate; no pre/post processing |
| Advanced RAG | Retrieval-augmented LLM | Adds query rewriting, re-ranking, response analysis |
| ReAct | LLM agent reasoning | Thought → Action → Observation loop |
| Reflexion | LLM agent reasoning | Generate → self-critique → refine cycle |
| ToRA | Tool-integrated reasoning | CoT + code execution for maths; two-stage training |

---

## Key Distinctions to Remember for the Exam

**Admissible heuristic** - never overestimates; required for A\* optimality.

**Arc consistency** - for each constrained pair (Xᵢ, Xⱼ), every value in Dᵢ has a compatible value in Dⱼ. Dynamically reduces domain sizes.

**Horizon problem** - stopping the game tree search before dramatic board changes occur; the evaluation function sees a misleadingly stable state.

**Quiescent positions** - positions where the evaluation function won't change significantly in the next few moves; safe to stop search.

**Partial Order Planning** - uses only necessary ordering constraints (least commitment principle).

**Overfitting** - model fits training data too well; generalises poorly. Prevented by pruning, early stopping, regularisation, dropout.

**Deductive AI still relevant** - deductive methods encode verified knowledge, can be integrated with modern LLMs (e.g., LINC - neurosymbolic theorem proving).

**k-NN** - allows making assumptions about unknown objects' properties based on a similarity measure; not for unsupervised discovery of the number of classes (that's k-Means).

**Naïve Bayes posterior probabilities** - numerically unreliable (close to 0 or 1) due to violated independence, but classification decisions are usually correct.

**CNN** - spatially shared weights allow hierarchical feature extraction; ideal for image/shape recognition.

**Planning vs. heuristic search** - planning exploits the symbolic structure of operators; pure heuristic search does not.

**BM25 vs. semantic retrieval** - BM25 matches exact terms (lexical); semantic retrieval uses dense vectors/embeddings to match meaning even when vocabulary differs.

**Cross-encoder vs. bi-encoder** - a cross-encoder (monoBERT) jointly encodes query+document for highest accuracy but is slow; a bi-encoder encodes them separately for fast retrieval at slight accuracy cost.

**Naive RAG vs. Advanced RAG** - naive RAG retrieves once and generates; advanced RAG adds query rewriting before retrieval and re-ranking/summarisation after, reducing noise and improving answer quality.

**ReAct vs. Reflexion** - ReAct interleaves reasoning with external actions (search, tools) in a single pass; Reflexion generates an answer first, then critiques and refines it without necessarily taking new actions.

**Short-term vs. long-term agent memory** - short-term lives in the prompt context (limited, ephemeral); long-term is stored externally (vector stores, databases) and persists across sessions.

**ToRA vs. pure CoT** - CoT reasons in natural language only and can make symbolic errors; ToRA delegates exact computation to executable code (SymPy, solvers), combining reasoning with verifiable tool output.
