"""
Exercise 4 - Cirrhosis Patient Survival Prediction
Artificial Intelligence and Knowledge Engineering
"""

import warnings
warnings.filterwarnings("ignore")

import pandas as pd
import numpy as np
import matplotlib
matplotlib.use("Agg") # plots are saved to files, not shown interactively
import matplotlib.pyplot as plt

from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, Normalizer, LabelEncoder, OrdinalEncoder
from sklearn.decomposition import PCA
from sklearn.impute import SimpleImputer
from sklearn.naive_bayes import GaussianNB
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import (accuracy_score, precision_score, recall_score,
                              f1_score, confusion_matrix, classification_report)

import json, os

np.random.seed(42)

# -----------------------------------------------------------------------------
# SECTION 1 - DATA LOADING & MINING
# -----------------------------------------------------------------------------
print("-" * 70)
print("SECTION 1 - DATA MINING")
print("-" * 70)

# Load cirrhosis.csv from the same folder as this script
_csv_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "cirrhosis.csv")
df = pd.read_csv(_csv_path)

# Keep only relevant columns
FEATURES = ["Drug","Age","Sex","Ascites","Hepatomegaly","Spiders","Edema",
            "Bilirubin","Cholesterol","Albumin","Copper","Alk_Phos","SGOT",
            "Tryglicerides","Platelets","Prothrombin","Stage"]
TARGET = "Status"
df = df[FEATURES + [TARGET]].copy() # only keep these columns

print(f"\nDataset shape: {df.shape}")
print(f"\nTarget distribution:")
print(df[TARGET].value_counts()) # D=death, C=transplant, CL=liver survival
print(f"\nMissing values per feature:")
print(df.isnull().sum()[df.isnull().sum() > 0]) # only show features with missing values

print(f"\nNumerical feature statistics:")
num_cols = df.select_dtypes(include=[np.number]).columns.tolist() # automatically detect numeric columns
print(df[num_cols].describe().round(2).to_string()) # show stats (count, mean, std, min, max, quartiles)

# Save stats for report
stats_missing = df.isnull().sum()
stats_target  = df[TARGET].value_counts()

# -----------------------------------------------------------------------------
# SECTION 2 - DATA PREPARATION
# -----------------------------------------------------------------------------
print("\n" + "-" * 70)
print("SECTION 2 - DATA PREPARATION")
print("-" * 70)

# -- 2.1 Encode categoricals (text categories -> numbers)--
df_encoded = df.copy()

# Ordinal / binary categoricals
ordinal_map = {"Edema": {"N": 0, "S": 1, "Y": 2}} # (None - Slight - Yes)
binary_map  = {"Sex": {"F": 0, "M": 1},
               "Ascites": {"N": 0, "Y": 1},
               "Hepatomegaly": {"N": 0, "Y": 1},
               "Spiders": {"N": 0, "Y": 1},
               "Drug": {"D-penicillamine": 0, "Placebo": 1}}

for col, mapping in {**ordinal_map, **binary_map}.items():
    df_encoded[col] = df_encoded[col].map(mapping)

le = LabelEncoder()
df_encoded[TARGET] = le.fit_transform(df_encoded[TARGET]) # encode target (D=0, CL=1, C=2)
CLASS_NAMES = list(le.classes_) # CLASS_NAMES stores the original string labels for later use in reports
print(f"\nClass encoding: {dict(zip(range(len(CLASS_NAMES)), CLASS_NAMES))}")

# -- 2.2 Handle missing values (imputation with median/mode) --
X_raw = df_encoded[FEATURES].copy()
y = df_encoded[TARGET].values

num_feats = X_raw.select_dtypes(include=[np.number]).columns.tolist()
cat_feats = [c for c in FEATURES if c not in num_feats]

num_imputer  = SimpleImputer(strategy="median")
X_imputed_num = pd.DataFrame(num_imputer.fit_transform(X_raw[num_feats]),
                              columns=num_feats)

# For already-encoded categoricals that have NaN, use most_frequent
if cat_feats:
    cat_imputer = SimpleImputer(strategy="most_frequent")
    X_imputed_cat = pd.DataFrame(cat_imputer.fit_transform(X_raw[cat_feats]),
                                  columns=cat_feats)
    X_imputed = pd.concat([X_imputed_num, X_imputed_cat], axis=1)[FEATURES]
else:
    X_imputed = X_imputed_num[FEATURES]

print(f"\nMissing values after imputation: {X_imputed.isnull().sum().sum()}")

# -- 2.3 Train / validation / test split (60 / 20 / 20) ----------------------
X_arr = X_imputed.values

X_trainval, X_test, y_trainval, y_test = train_test_split(
    X_arr, y, test_size=0.20, random_state=42, stratify=y)

X_train, X_val, y_train, y_val = train_test_split(
    X_trainval, y_trainval, test_size=0.25, random_state=42, stratify=y_trainval)

print(f"\nSplit sizes - train:{len(X_train)}  val:{len(X_val)}  test:{len(X_test)}")

# -- 2.4 Preprocessing variants -----------------------------------------------
# (a) No preprocessing
X_tr_none, X_v_none = X_train.copy(), X_val.copy()

# (b) Standardization
scaler = StandardScaler()
X_tr_std = scaler.fit_transform(X_train)
X_v_std  = scaler.transform(X_val)

# (c) Normalization (L2)
normalizer = Normalizer()
X_tr_norm = normalizer.fit_transform(X_train)
X_v_norm  = normalizer.transform(X_val)

# (d) PCA (retain 95% variance)
pca = PCA(n_components=0.95, random_state=42) # n_components=0.95 means "choose the minimum number of principal components such that 95% of the variance is retained"
X_tr_pca  = pca.fit_transform(X_tr_std)
X_v_pca   = pca.transform(X_v_std)
print(f"\nPCA components retained (95% var): {pca.n_components_}")

# -----------------------------------------------------------------------------
# SECTION 3 - CLASSIFICATION
# -----------------------------------------------------------------------------
print("\n" + "-" * 70)
print("SECTION 3 - CLASSIFICATION")
print("-" * 70)

def evaluate(y_true, y_pred, prefix=""):
    acc  = accuracy_score(y_true, y_pred)
    prec = precision_score(y_true, y_pred, average="macro", zero_division=0)
    rec  = recall_score(y_true, y_pred, average="macro", zero_division=0)
    f1   = f1_score(y_true, y_pred, average="macro", zero_division=0)
    return {"acc": acc, "prec": prec, "rec": rec, "f1": f1}

# Container for all results
results = []   # list of dicts

# --- 3.1 Naive Bayes ---------------------------------------------------------
print("\n--- Naive Bayes ---")

nb_configs = [
    ("NB-default",         GaussianNB()),
    ("NB-vs=1e-9",         GaussianNB(var_smoothing=1e-9)),
    ("NB-vs=1e-5",         GaussianNB(var_smoothing=1e-5)),
    ("NB-vs=1e-2",         GaussianNB(var_smoothing=0.01)),
]

preprocessing_sets = {
    "None":          (X_tr_none, X_v_none),
    "Standardized":  (X_tr_std,  X_v_std),
    "Normalized":    (X_tr_norm, X_v_norm),
    "PCA":           (X_tr_pca,  X_v_pca),
}

for pp_name, (Xtr, Xv) in preprocessing_sets.items():
    for cfg_name, clf in nb_configs:
        clf.fit(Xtr, y_train)
        pred_train = clf.predict(Xtr)
        pred_val   = clf.predict(Xv)
        m_tr = evaluate(y_train, pred_train)
        m_v  = evaluate(y_val,   pred_val)
        row = {"Classifier": cfg_name, "Preprocessing": pp_name,
               "Train_Acc": m_tr["acc"], "Val_Acc": m_v["acc"],
               "Val_Prec": m_v["prec"], "Val_Rec": m_v["rec"], "Val_F1": m_v["f1"]}
        results.append(row)
        print(f"  {cfg_name:20s} | pp={pp_name:14s} | "
              f"train_acc={m_tr['acc']:.3f}  val_acc={m_v['acc']:.3f}  "
              f"f1={m_v['f1']:.3f}")

# --- 3.2 Decision Tree -------------------------------------------------------
print("\n--- Decision Tree ---")

dt_configs = [
    ("DT-depth=None", DecisionTreeClassifier(max_depth=None,  random_state=42)),
    ("DT-depth=3",    DecisionTreeClassifier(max_depth=3,     random_state=42)),
    ("DT-depth=5",    DecisionTreeClassifier(max_depth=5,     random_state=42)),
    ("DT-depth=10",   DecisionTreeClassifier(max_depth=10,    random_state=42)),
    ("DT-min10",      DecisionTreeClassifier(max_depth=5, min_samples_leaf=10, random_state=42)),
]

for pp_name, (Xtr, Xv) in preprocessing_sets.items():
    for cfg_name, clf in dt_configs:
        clf.fit(Xtr, y_train)
        pred_train = clf.predict(Xtr)
        pred_val   = clf.predict(Xv)
        m_tr = evaluate(y_train, pred_train)
        m_v  = evaluate(y_val,   pred_val)
        row = {"Classifier": cfg_name, "Preprocessing": pp_name,
               "Train_Acc": m_tr["acc"], "Val_Acc": m_v["acc"],
               "Val_Prec": m_v["prec"], "Val_Rec": m_v["rec"], "Val_F1": m_v["f1"]}
        results.append(row)
        print(f"  {cfg_name:20s} | pp={pp_name:14s} | "
              f"train_acc={m_tr['acc']:.3f}  val_acc={m_v['acc']:.3f}  "
              f"f1={m_v['f1']:.3f}")

# --- BONUS: Random Forest ----------------------------------------------------
print("\n--- BONUS: Random Forest ---")

rf_configs = [
    ("RF-100",      RandomForestClassifier(n_estimators=100, random_state=42)), # n_estimators = how many trees to build
    ("RF-200-d5",   RandomForestClassifier(n_estimators=200, max_depth=5, random_state=42)), # max_depth = maximum depth of each tree (to prevent overfitting)
    ("RF-50-d10",   RandomForestClassifier(n_estimators=50,  max_depth=10, random_state=42)),
]

for pp_name, (Xtr, Xv) in list(preprocessing_sets.items())[:2]:  # just None & Std for bonus
    for cfg_name, clf in rf_configs:
        clf.fit(Xtr, y_train)
        pred_train = clf.predict(Xtr)
        pred_val   = clf.predict(Xv)
        m_tr = evaluate(y_train, pred_train)
        m_v  = evaluate(y_val,   pred_val)
        row = {"Classifier": cfg_name, "Preprocessing": pp_name,
               "Train_Acc": m_tr["acc"], "Val_Acc": m_v["acc"],
               "Val_Prec": m_v["prec"], "Val_Rec": m_v["rec"], "Val_F1": m_v["f1"]}
        results.append(row)
        print(f"  {cfg_name:20s} | pp={pp_name:14s} | "
              f"train_acc={m_tr['acc']:.3f}  val_acc={m_v['acc']:.3f}  "
              f"f1={m_v['f1']:.3f}")

# --- BONUS: Overfitting mitigation (DT pruning via ccp_alpha) ----------------
print("\n--- BONUS: Overfitting mitigation via cost-complexity pruning ---")

# Step 1: grow a full unlimited tree
clf_full = DecisionTreeClassifier(max_depth=None, random_state=42)
clf_full.fit(X_tr_std, y_train)

# Step 2: ask sklearn "what alpha values are interesting?"
path = clf_full.cost_complexity_pruning_path(X_tr_std, y_train)
ccp_alphas = path.ccp_alphas[::5][:8] # pick 8 sample values. ccp_alpha (α) controls how aggressively to prune: higher α → more pruning → simpler tree

# Step 3: for each alpha, retrain and score
pruning_results = []
for alpha in ccp_alphas:
    clf_p = DecisionTreeClassifier(ccp_alpha=alpha, random_state=42)
    clf_p.fit(X_tr_std, y_train)
    tr_acc = accuracy_score(y_train, clf_p.predict(X_tr_std))
    v_acc  = accuracy_score(y_val,   clf_p.predict(X_v_std))
    pruning_results.append((alpha, tr_acc, v_acc))
    print(f"  alpha={alpha:.5f}  train_acc={tr_acc:.3f}  val_acc={v_acc:.3f}")

# -----------------------------------------------------------------------------
# SECTION 4 - EVALUATION
# -----------------------------------------------------------------------------
print("\n" + "-" * 70)
print("SECTION 4 - EVALUATION")
print("-" * 70)

df_results = pd.DataFrame(results)

# Best per classifier family on validation accuracy
best = (df_results.sort_values("Val_Acc", ascending=False)
        .drop_duplicates(subset=["Classifier"]))

# Final test-set evaluation for the best model of each family
print("\n--- Best configurations (validation set) ---")
print(df_results.sort_values(["Classifier","Val_Acc"], ascending=[True,False])
      .drop_duplicates("Classifier")[["Classifier","Preprocessing","Val_Acc","Val_F1"]]
      .to_string(index=False))

# Pick one best NB and one best DT for test evaluation
def best_config(family):
    sub = df_results[df_results["Classifier"].str.startswith(family)]
    row = sub.loc[sub["Val_F1"].idxmax()]
    return row

best_nb_row = best_config("NB")
best_dt_row = best_config("DT")
best_rf_row = best_config("RF")

def rebuild_and_test(clf, pp_name, Xtest):
    pp_map_tr = {"None": X_tr_none, "Standardized": X_tr_std,
                 "Normalized": X_tr_norm, "PCA": X_tr_pca}
    pp_map_te = {"None": X_test,
                 "Standardized": StandardScaler().fit(X_train).transform(X_test),
                 "Normalized":   Normalizer().fit(X_train).transform(X_test),
                 "PCA":          pca.transform(StandardScaler().fit(X_train).transform(X_test))}
    Xtr = pp_map_tr[pp_name]
    Xte = pp_map_te[pp_name]
    clf.fit(Xtr, y_train)
    return clf.predict(Xte)

# -- NB best ------------------------------------------------------------------
nb_best_clf = GaussianNB(var_smoothing=float(best_nb_row["Classifier"].split("=")[-1])
                         if "vs=" in best_nb_row["Classifier"] else 1e-9)
pred_nb = rebuild_and_test(nb_best_clf, best_nb_row["Preprocessing"], X_test)
print(f"\n--- Test Results: Best NB ({best_nb_row['Classifier']}, {best_nb_row['Preprocessing']}) ---")
print(classification_report(y_test, pred_nb, target_names=CLASS_NAMES))
cm_nb = confusion_matrix(y_test, pred_nb)

# -- DT best ------------------------------------------------------------------
depth_str = best_dt_row["Classifier"].split("=")[-1]
max_depth = None if depth_str == "None" else int(depth_str)
min_sl = 10 if "min" in best_dt_row["Classifier"] else 1
dt_best_clf = DecisionTreeClassifier(max_depth=max_depth, min_samples_leaf=min_sl, random_state=42)
pred_dt = rebuild_and_test(dt_best_clf, best_dt_row["Preprocessing"], X_test)
print(f"\n--- Test Results: Best DT ({best_dt_row['Classifier']}, {best_dt_row['Preprocessing']}) ---")
print(classification_report(y_test, pred_dt, target_names=CLASS_NAMES))
cm_dt = confusion_matrix(y_test, pred_dt)

# -- RF best ------------------------------------------------------------------
rf_best_clf = RandomForestClassifier(n_estimators=100, random_state=42)
pred_rf = rebuild_and_test(rf_best_clf, best_rf_row["Preprocessing"], X_test)
print(f"\n--- Test Results: Best RF ({best_rf_row['Classifier']}, {best_rf_row['Preprocessing']}) ---")
print(classification_report(y_test, pred_rf, target_names=CLASS_NAMES))
cm_rf = confusion_matrix(y_test, pred_rf)

# -----------------------------------------------------------------------------
# SAVE FIGURES
# -----------------------------------------------------------------------------
import os
fig_dir = ".\\figures"
os.makedirs(fig_dir, exist_ok=True)

# Figure 1: Target distribution
fig, ax = plt.subplots(figsize=(5, 3.5))
vc = df[TARGET].value_counts()
bars = ax.bar(vc.index, vc.values, color=["#4C72B0","#55A868","#C44E52"], edgecolor="white", linewidth=0.8)
for b in bars:
    ax.text(b.get_x()+b.get_width()/2, b.get_height()+2, str(int(b.get_height())),
            ha="center", va="bottom", fontsize=10)
ax.set_xlabel("Status", fontsize=11)
ax.set_ylabel("Count", fontsize=11)
ax.set_title("Target Class Distribution", fontsize=12)
ax.spines[["top","right"]].set_visible(False)
plt.tight_layout()
plt.savefig(f"{fig_dir}/fig_target_dist.pdf", bbox_inches="tight")
plt.close()

# Figure 2: Missing values heatmap
fig, ax = plt.subplots(figsize=(10, 2.5))
miss = df[FEATURES].isnull().astype(int)
cmap = matplotlib.colors.ListedColormap(["#eaf0fb", "#C44E52"])
ax.imshow(miss.T, aspect="auto", cmap=cmap, interpolation="nearest")
ax.set_yticks(range(len(FEATURES)))
ax.set_yticklabels(FEATURES, fontsize=7)
ax.set_xlabel("Sample index")
ax.set_title("Missing values (red = missing)")
plt.tight_layout()
plt.savefig(f"{fig_dir}/fig_missing.pdf", bbox_inches="tight")
plt.close()

# Figure 3: Confusion matrices (NB and DT side-by-side)
fig, axes = plt.subplots(1, 3, figsize=(12, 3.5))
for ax, cm, title in zip(axes, [cm_nb, cm_dt, cm_rf],
                          ["Naive Bayes (test)", "Decision Tree (test)", "Random Forest (test)"]):
    im = ax.imshow(cm, cmap="Blues")
    ax.set_xticks(range(len(CLASS_NAMES))); ax.set_xticklabels(CLASS_NAMES)
    ax.set_yticks(range(len(CLASS_NAMES))); ax.set_yticklabels(CLASS_NAMES)
    ax.set_xlabel("Predicted"); ax.set_ylabel("True")
    ax.set_title(title, fontsize=10)
    for i in range(len(CLASS_NAMES)):
        for j in range(len(CLASS_NAMES)):
            ax.text(j, i, str(cm[i,j]), ha="center", va="center",
                    color="white" if cm[i,j] > cm.max()/2 else "black", fontsize=11)
plt.tight_layout()
plt.savefig(f"{fig_dir}/fig_conf_matrices.pdf", bbox_inches="tight")
plt.close()

# Figure 4: Validation accuracy across preprocessing methods (NB and DT)
fig, axes = plt.subplots(1, 2, figsize=(11, 4))
for ax, fam, title in zip(axes, ["NB", "DT"], ["Naive Bayes", "Decision Tree"]):
    sub = df_results[df_results["Classifier"].str.startswith(fam)]
    pivot = sub.pivot(index="Classifier", columns="Preprocessing", values="Val_Acc")
    pivot.plot(kind="bar", ax=ax, edgecolor="white", linewidth=0.5)
    ax.set_title(f"{title}: Val Accuracy by Preprocessing", fontsize=10)
    ax.set_ylabel("Accuracy")
    ax.set_xticklabels(pivot.index, rotation=30, ha="right", fontsize=8)
    ax.legend(fontsize=8, title="Preprocessing")
    ax.set_ylim(0, 1)
    ax.spines[["top","right"]].set_visible(False)
plt.tight_layout()
plt.savefig(f"{fig_dir}/fig_val_accuracy.pdf", bbox_inches="tight")
plt.close()

# Figure 5: Pruning effect on DT
fig, ax = plt.subplots(figsize=(6, 3.5))
alphas_, tr_accs_, v_accs_ = zip(*pruning_results)
ax.plot(alphas_, tr_accs_, "o-", label="Train acc", color="#4C72B0")
ax.plot(alphas_, v_accs_,  "s--", label="Val acc",   color="#C44E52")
ax.set_xlabel("ccp_alpha")
ax.set_ylabel("Accuracy")
ax.set_title("Cost-Complexity Pruning: Overfitting Mitigation")
ax.legend()
ax.spines[["top","right"]].set_visible(False)
plt.tight_layout()
plt.savefig(f"{fig_dir}/fig_pruning.pdf", bbox_inches="tight")
plt.close()

# Figure 6: PCA explained variance
fig, ax = plt.subplots(figsize=(5, 3.5))
cum_var = np.cumsum(pca.explained_variance_ratio_) * 100
ax.bar(range(1, len(cum_var)+1), pca.explained_variance_ratio_*100,
       color="#4C72B0", alpha=0.7, label="Individual")
ax.plot(range(1, len(cum_var)+1), cum_var, "ro-", label="Cumulative")
ax.axhline(95, color="gray", linestyle="--", linewidth=0.8)
ax.set_xlabel("Principal Component")
ax.set_ylabel("Explained Variance (%)")
ax.set_title("PCA Explained Variance")
ax.legend(fontsize=9)
ax.spines[["top","right"]].set_visible(False)
plt.tight_layout()
plt.savefig(f"{fig_dir}/fig_pca.pdf", bbox_inches="tight")
plt.close()

# -----------------------------------------------------------------------------
# EXPORT RESULTS JSON (for report)
# -----------------------------------------------------------------------------
def cr_to_dict(y_true, y_pred):
    from sklearn.metrics import classification_report
    r = classification_report(y_true, y_pred, target_names=CLASS_NAMES, output_dict=True)
    return r

export = {
    "dataset_shape":   list(df.shape),
    "target_dist":     stats_target.to_dict(),
    "missing_before":  stats_missing.to_dict(),
    "split_sizes":     {"train": int(len(X_train)), "val": int(len(X_val)), "test": int(len(X_test))},
    "pca_components":  int(pca.n_components_),
    "class_names":     CLASS_NAMES,
    "results_table":   df_results.round(4).to_dict(orient="records"),
    "best_nb":         {"cfg": best_nb_row["Classifier"], "pp": best_nb_row["Preprocessing"],
                        "val_acc": float(best_nb_row["Val_Acc"]), "val_f1": float(best_nb_row["Val_F1"])},
    "best_dt":         {"cfg": best_dt_row["Classifier"], "pp": best_dt_row["Preprocessing"],
                        "val_acc": float(best_dt_row["Val_Acc"]), "val_f1": float(best_dt_row["Val_F1"])},
    "best_rf":         {"cfg": best_rf_row["Classifier"], "pp": best_rf_row["Preprocessing"],
                        "val_acc": float(best_rf_row["Val_Acc"]), "val_f1": float(best_rf_row["Val_F1"])},
    "test_nb":  cr_to_dict(y_test, pred_nb),
    "test_dt":  cr_to_dict(y_test, pred_dt),
    "test_rf":  cr_to_dict(y_test, pred_rf),
    "cm_nb":    cm_nb.tolist(),
    "cm_dt":    cm_dt.tolist(),
    "cm_rf":    cm_rf.tolist(),
    "pruning":  [(float(a), float(tr), float(v)) for a,tr,v in pruning_results],
}

with open("results.json", "w") as f:
    json.dump(export, f, indent=2)

print("\nAll figures and results saved.")
print("Done.")