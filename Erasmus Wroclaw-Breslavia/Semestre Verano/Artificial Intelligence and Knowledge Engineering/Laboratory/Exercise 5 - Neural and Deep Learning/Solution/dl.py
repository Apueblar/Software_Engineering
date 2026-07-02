"""
Exercise 5 - Text Classification with Encoder-only and Decoder-only Models
Artificial Intelligence and Knowledge Engineering
"""
from google.colab import files

import os
import warnings
import transformers
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import torch

from datasets import load_dataset
from sklearn.metrics import (
    accuracy_score,
    f1_score,
    classification_report,
    confusion_matrix,
    ConfusionMatrixDisplay,
)
from transformers import (
    pipeline,
    AutoModelForCausalLM,
    AutoTokenizer,
    BitsAndBytesConfig,
)
from langchain_huggingface import HuggingFacePipeline
from langchain_core.prompts import PromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from pydantic import BaseModel, Field

warnings.filterwarnings("ignore")
transformers.logging.set_verbosity_error()
DEVICE = 0 if torch.cuda.is_available() else -1
print(f"Using device: {'CUDA' if DEVICE == 0 else 'CPU'}")


# -----------------------------------------------------------------------------
# TASK 1 - Dataset Loading and Basic Statistics
# -----------------------------------------------------------------------------

print("\n" + "=" * 70)
print("TASK 1 - Dataset Loading and Basic Statistics")
print("=" * 70)

# Load the PolEmo2.0-IN dataset (test split only, as required)
dataset = load_dataset("allegro/klej-polemo2-in", split="test")

print(f"\nTotal samples in test split: {len(dataset)}")
print(f"\nExample record:")
print(f"  sentence : {dataset[0]['sentence'][:80]}...")
print(f"  target   : {dataset[0]['target']}")

# -- Label mapping --
# The dataset uses long internal labels; we map them to short human-readable ones
LABEL_MAP_FULL = {
    "__label__meta_plus_m":  "plus",
    "__label__meta_minus_m": "minus",
    "__label__meta_zero":    "neutral",
    "__label__meta_amb":     "amb",
}

df_full = pd.DataFrame(dataset)
df_full["label"] = df_full["target"].map(LABEL_MAP_FULL)

# -- Class distribution --
print("\nClass distribution (full test split):")
dist_full = df_full["label"].value_counts()
print(dist_full.to_string())

# -- Filter out the ambiguous class (as instructed) --
df = df_full[df_full["label"] != "amb"].copy().reset_index(drop=True)
print(f"\nSamples after removing 'amb' class: {len(df)}")

print("\nClass distribution (working split, no 'amb'):")
dist = df["label"].value_counts()
for cls, cnt in dist.items():
    print(f"  {cls:>8s}: {cnt:4d}  ({100 * cnt / len(df):.1f}%)")

# -- Text-length statistics --
df["text_len"] = df["sentence"].str.len()

print("\nText length statistics (characters):")
print(df.groupby("label")["text_len"].describe()[["count", "mean", "min", "max"]].to_string())

# -- Visualise class balance and text lengths --
fig, axes = plt.subplots(1, 2, figsize=(12, 4))

dist.plot(kind="bar", ax=axes[0], color=["#4C72B0", "#DD8452", "#55A868"], edgecolor="black")
axes[0].set_title("Class Distribution (no 'amb')")
axes[0].set_xlabel("Sentiment")
axes[0].set_ylabel("Count")
axes[0].tick_params(axis="x", rotation=0)
for p in axes[0].patches:
    axes[0].annotate(f"{int(p.get_height())}", (p.get_x() + p.get_width() / 2, p.get_height()),
                     ha="center", va="bottom", fontsize=9)

for cls, grp in df.groupby("label"):
    grp["text_len"].plot(kind="hist", bins=30, ax=axes[1], alpha=0.55, label=cls)
axes[1].set_title("Text Length Distribution by Class")
axes[1].set_xlabel("Characters")
axes[1].set_ylabel("Frequency")
axes[1].legend()

plt.tight_layout()
plt.savefig("fig_task1_stats.pdf", bbox_inches="tight")
plt.show()
files.download("fig_task1_stats.pdf")
print("[Saved] fig_task1_stats.pdf")


# -----------------------------------------------------------------------------
# TASK 2 - Encoder-only Model: Voicelab/herbert-base-cased-sentiment
# -----------------------------------------------------------------------------

print("\n" + "=" * 70)
print("TASK 2 - Encoder-only: herbert-base-cased-sentiment")
print("=" * 70)

ENCODER_MODEL = "Voicelab/herbert-base-cased-sentiment"

# The HerBERT-based sentiment model outputs labels: "positive", "negative", "neutral"
# Map them to the dataset's three-class scheme (plus / minus / neutral)
ENCODER_LABEL_MAP = {
    "positive": "plus",
    "negative": "minus",
    "neutral":  "neutral",
}

sentiment_pipe = pipeline(
    "text-classification",
    model=ENCODER_MODEL,
    device=DEVICE,
    truncation=True,
    max_length=512,
)

def run_encoder(texts, pipe, label_map):
    """Run encoder pipeline; return list of mapped labels."""
    raw = pipe(list(texts), batch_size=32)
    return [label_map.get(r["label"].lower(), "neutral") for r in raw]

print(f"\nRunning inference on {len(df)} samples …")
y_true = df["label"].tolist()
y_pred_enc_default = run_encoder(df["sentence"], sentiment_pipe, ENCODER_LABEL_MAP)

acc_enc = accuracy_score(y_true, y_pred_enc_default)
f1_enc  = f1_score(y_true, y_pred_enc_default, average="macro")
print(f"\nHerBERT (default) → Accuracy: {acc_enc:.4f}  |  Macro-F1: {f1_enc:.4f}")
print("\nDetailed report:")
print(classification_report(y_true, y_pred_enc_default, target_names=["minus", "neutral", "plus"]))


# -----------------------------------------------------------------------------
# TASK 3 - Encoder-only: Parameter Exploration
# -----------------------------------------------------------------------------

print("\n" + "=" * 70)
print("TASK 3 - Encoder-only: Exploring Alternative Models")
print("=" * 70)

# -- Alternative model 1: distilbert-based sentiment (multilingual) ---------
ALT_ENCODER_1 = "lxyuan/distilbert-base-multilingual-cased-sentiments-student"
ALT_LABEL_MAP_1 = {"positive": "plus", "negative": "minus", "neutral": "neutral"}

print(f"\n[1] Loading {ALT_ENCODER_1} …")
pipe_alt1 = pipeline(
    "text-classification",
    model=ALT_ENCODER_1,
    device=DEVICE,
    truncation=True,
    max_length=512,
)
y_pred_alt1 = run_encoder(df["sentence"], pipe_alt1, ALT_LABEL_MAP_1)
acc_alt1 = accuracy_score(y_true, y_pred_alt1)
f1_alt1  = f1_score(y_true, y_pred_alt1, average="macro")
print(f"{ALT_ENCODER_1.split('/')[-1]} → Accuracy: {acc_alt1:.4f}  |  Macro-F1: {f1_alt1:.4f}")
print(classification_report(y_true, y_pred_alt1, target_names=["minus", "neutral", "plus"]))

# -- Alternative model 2: Polish-specific BERT (allegro/herbert-large) --
# Note: this model needs a classification head; use a general HF zero-shot variant
# We use textattack/bert-base-uncased-SST-2 with Polish text to show impact of
# language mismatch, which is a meaningful pedagogical comparison
ALT_ENCODER_2 = "cardiffnlp/twitter-xlm-roberta-base-sentiment"
ALT_LABEL_MAP_2 = {
    "positive": "plus",
    "negative": "minus",
    "neutral":  "neutral",
}

print(f"\n[2] Loading {ALT_ENCODER_2} …")
pipe_alt2 = pipeline(
    "text-classification",
    model=ALT_ENCODER_2,
    device=DEVICE,
    truncation=True,
    max_length=512,
)
y_pred_alt2 = run_encoder(df["sentence"], pipe_alt2, ALT_LABEL_MAP_2)
acc_alt2 = accuracy_score(y_true, y_pred_alt2)
f1_alt2  = f1_score(y_true, y_pred_alt2, average="macro")
print(f"{ALT_ENCODER_2.split('/')[-1]} → Accuracy: {acc_alt2:.4f}  |  Macro-F1: {f1_alt2:.4f}")
print(classification_report(y_true, y_pred_alt2, target_names=["minus", "neutral", "plus"]))

# -- Summary table: encoder comparison --
encoder_results = {
    "HerBERT-base (Task 2)":         (acc_enc,  f1_enc),
    "DistilBERT-multilingual":        (acc_alt1, f1_alt1),
    "XLM-RoBERTa-twitter":           (acc_alt2, f1_alt2),
}

print("\nEncoder Comparison Summary:")
print(f"{'Model':<40} {'Accuracy':>10} {'Macro-F1':>10}")
print("-" * 62)
for model_name, (acc, f1) in encoder_results.items():
    print(f"{model_name:<40} {acc:>10.4f} {f1:>10.4f}")


# -----------------------------------------------------------------------------
# TASK 4 - Decoder-only LLM: Qwen/Qwen2.5-1.5B-Instruct
# -----------------------------------------------------------------------------

print("\n" + "=" * 70)
print("TASK 4 - Decoder-only LLM: Qwen2.5-1.5B-Instruct")
print("=" * 70)

LLM_MODEL = "Qwen/Qwen2.5-1.5B-Instruct"

print(f"Loading {LLM_MODEL} …")
tokenizer_llm = AutoTokenizer.from_pretrained(LLM_MODEL)
model_llm = AutoModelForCausalLM.from_pretrained(
    LLM_MODEL,
    torch_dtype=torch.float16,
    device_map="auto",
)

# -- Baseline prompt (English instructions, zero-shot) --
BASIC_TEMPLATE = """\
Classify the sentiment of the following Polish review into exactly one of \
these three classes: plus (positive), minus (negative), neutral.
Respond with ONLY the class name and nothing else.

Review: {text}
Class:"""

# Build the LangChain pipeline
hf_pipeline_base = pipeline(
    "text-generation",
    model=model_llm,
    tokenizer=tokenizer_llm,
    max_new_tokens=8,
    temperature=0.1,
    do_sample=True,
    pad_token_id=tokenizer_llm.eos_token_id,
    return_full_text=False,
)
llm_base = HuggingFacePipeline(pipeline=hf_pipeline_base)

basic_prompt = PromptTemplate.from_template(BASIC_TEMPLATE)
basic_chain  = basic_prompt | llm_base


def parse_llm_label(raw: str) -> str:
    """
    Robustly extract a label from a raw LLM output string.
    Handles minor whitespace / casing / punctuation artefacts.
    """
    raw = raw.strip().lower()
    if "plus" in raw or "positive" in raw:
        return "plus"
    if "minus" in raw or "negative" in raw:
        return "minus"
    if "neutral" in raw or "zero" in raw:
        return "neutral"
    return "neutral"   # fallback


# Run on a representative subset (first 200 samples) to save inference time
SUBSET_SIZE = 200
df_sub = df.iloc[:SUBSET_SIZE].copy()
y_true_sub = df_sub["label"].tolist()

print(f"\nRunning LLM inference on {SUBSET_SIZE} samples (baseline prompt) …")
raw_preds_base = [basic_chain.invoke({"text": row}) for row in df_sub["sentence"]]
y_pred_llm_base = [parse_llm_label(r) for r in raw_preds_base]

acc_llm_base = accuracy_score(y_true_sub, y_pred_llm_base)
f1_llm_base  = f1_score(y_true_sub, y_pred_llm_base, average="macro", zero_division=0)
print(f"Qwen2.5-1.5B (baseline) → Accuracy: {acc_llm_base:.4f}  |  Macro-F1: {f1_llm_base:.4f}")
print(classification_report(y_true_sub, y_pred_llm_base,
                             target_names=["minus", "neutral", "plus"], zero_division=0))


# -----------------------------------------------------------------------------
# TASK 5 - LLM Parameter Exploration
# -----------------------------------------------------------------------------

print("\n" + "=" * 70)
print("TASK 5 - LLM Parameter Exploration")
print("=" * 70)

# -----------------------------------------------------------------------------
# 5.A  Effect of generation TEMPERATURE
# -----------------------------------------------------------------------------

print("\n[5.A] Temperature sweep: 0.0 (greedy), 0.1, 0.5, 1.0")

TEMPERATURES = [0.0, 0.1, 0.5, 1.0]
temp_results  = {}

for temp in TEMPERATURES:
    do_sample = temp > 0
    pipe_t = pipeline(
        "text-generation",
        model=model_llm,
        tokenizer=tokenizer_llm,
        max_new_tokens=8,
        temperature=temp if do_sample else 1.0,  # temperature ignored if do_sample=False
        do_sample=do_sample,
        pad_token_id=tokenizer_llm.eos_token_id,
        return_full_text=False,
    )
    llm_t = HuggingFacePipeline(pipeline=pipe_t)
    chain_t = basic_prompt | llm_t

    preds_raw = [chain_t.invoke({"text": row}) for row in df_sub["sentence"]]
    preds     = [parse_llm_label(r) for r in preds_raw]
    acc_t = accuracy_score(y_true_sub, preds)
    f1_t  = f1_score(y_true_sub, preds, average="macro", zero_division=0)
    temp_results[temp] = (acc_t, f1_t)
    label = "greedy" if temp == 0 else f"T={temp}"
    print(f"  {label:>12} → Accuracy: {acc_t:.4f}  |  Macro-F1: {f1_t:.4f}")

# -----------------------------------------------------------------------------
# 5.B  Improved PROMPT (chain-of-thought + JSON output parser)
# -----------------------------------------------------------------------------

print("\n[5.B] Improved prompt with JSON output via JsonOutputParser")

IMPROVED_TEMPLATE = """\
You are a sentiment analysis expert. Read the Polish review and respond ONLY \
with a JSON object containing a single key "sentiment" whose value is one of: \
"plus", "minus", or "neutral".

Examples:
Review: "Jestem bardzo zadowolony z obsługi." → {{"sentiment": "plus"}}
Review: "Tragiczna obsługa, nie polecam."     → {{"sentiment": "minus"}}
Review: "Byłem tam w środę."                  → {{"sentiment": "neutral"}}

Review: {text}
Response:"""

class SentimentOutput(BaseModel):
    sentiment: str = Field(description="Sentiment class: plus, minus, or neutral")

json_parser   = JsonOutputParser(pydantic_object=SentimentOutput)
improved_prompt = PromptTemplate.from_template(IMPROVED_TEMPLATE)

hf_pipeline_imp = pipeline(
    "text-generation",
    model=model_llm,
    tokenizer=tokenizer_llm,
    max_new_tokens=30,
    temperature=0.1,
    do_sample=True,
    pad_token_id=tokenizer_llm.eos_token_id,
    return_full_text=False,
)
llm_imp = HuggingFacePipeline(pipeline=hf_pipeline_imp)
improved_chain = improved_prompt | llm_imp

print(f"Running improved prompt on {SUBSET_SIZE} samples …")

def parse_json_label(raw: str) -> str:
    """
    Try to parse JSON from LLM output; fall back to string matching.
    """
    import json, re
    raw = raw.strip()
    # Try to extract JSON object
    match = re.search(r'\{[^}]+\}', raw)
    if match:
        try:
            obj = json.loads(match.group())
            val = obj.get("sentiment", "").lower()
            if val in ("plus", "minus", "neutral"):
                return val
        except json.JSONDecodeError:
            pass
    return parse_llm_label(raw)


raw_preds_imp  = [improved_chain.invoke({"text": row}) for row in df_sub["sentence"]]
y_pred_llm_imp = [parse_json_label(r) for r in raw_preds_imp]

acc_llm_imp = accuracy_score(y_true_sub, y_pred_llm_imp)
f1_llm_imp  = f1_score(y_true_sub, y_pred_llm_imp, average="macro", zero_division=0)
print(f"Qwen2.5-1.5B (improved prompt) → Accuracy: {acc_llm_imp:.4f}  |  Macro-F1: {f1_llm_imp:.4f}")
print(classification_report(y_true_sub, y_pred_llm_imp,
                             target_names=["minus", "neutral", "plus"], zero_division=0))

# -----------------------------------------------------------------------------
# 5.C  Alternative LLM: Qwen/Qwen2.5-3B-Instruct  (larger model comparison)
# -----------------------------------------------------------------------------

print("\n[5.C] Alternative LLM: Qwen/Qwen2.5-3B-Instruct")

LLM_MODEL_LARGE = "Qwen/Qwen2.5-3B-Instruct"
print(f"Loading {LLM_MODEL_LARGE} (4-bit quantised) …")

bnb_config = BitsAndBytesConfig(
    load_in_4bit=True,
    bnb_4bit_compute_dtype=torch.float16,
    bnb_4bit_quant_type="nf4",
)
model_large = AutoModelForCausalLM.from_pretrained(
    LLM_MODEL_LARGE,
    quantization_config=bnb_config,
    device_map="auto",
)
tokenizer_large = AutoTokenizer.from_pretrained(LLM_MODEL_LARGE)

hf_pipeline_large = pipeline(
    "text-generation",
    model=model_large,
    tokenizer=tokenizer_large,
    max_new_tokens=30,
    temperature=0.1,
    do_sample=True,
    pad_token_id=tokenizer_large.eos_token_id,
    return_full_text=False,
)
llm_large = HuggingFacePipeline(pipeline=hf_pipeline_large)

# Reuse the improved (JSON) prompt with the larger model
improved_prompt_large = PromptTemplate.from_template(IMPROVED_TEMPLATE)
chain_large = improved_prompt_large | llm_large

print(f"Running Qwen-3B on {SUBSET_SIZE} samples …")
raw_preds_large  = [chain_large.invoke({"text": row}) for row in df_sub["sentence"]]
y_pred_llm_large = [parse_json_label(r) for r in raw_preds_large]

acc_llm_large = accuracy_score(y_true_sub, y_pred_llm_large)
f1_llm_large  = f1_score(y_true_sub, y_pred_llm_large, average="macro", zero_division=0)
print(f"Qwen2.5-3B (improved prompt, 4-bit) → Accuracy: {acc_llm_large:.4f}  |  Macro-F1: {f1_llm_large:.4f}")
print(classification_report(y_true_sub, y_pred_llm_large,
                             target_names=["minus", "neutral", "plus"], zero_division=0))


# -----------------------------------------------------------------------------
# FINAL SUMMARY  - all models
# -----------------------------------------------------------------------------

print("\n" + "=" * 70)
print("FINAL SUMMARY")
print("=" * 70)

summary = {
    # Encoder models (full test split)
    "HerBERT-base (Task 2)":                (acc_enc,        f1_enc,        "encoder", "full"),
    "DistilBERT-multilingual (Task 3)":      (acc_alt1,       f1_alt1,       "encoder", "full"),
    "XLM-RoBERTa-twitter (Task 3)":         (acc_alt2,       f1_alt2,       "encoder", "full"),
    # LLM models (200-sample subset)
    "Qwen2.5-1.5B baseline (Task 4)":        (acc_llm_base,   f1_llm_base,   "decoder", "subset"),
    f"Qwen2.5-1.5B T=0 greedy":              (temp_results[0.0][0], temp_results[0.0][1], "decoder", "subset"),
    f"Qwen2.5-1.5B T=0.1":                   (temp_results[0.1][0], temp_results[0.1][1], "decoder", "subset"),
    f"Qwen2.5-1.5B T=0.5":                   (temp_results[0.5][0], temp_results[0.5][1], "decoder", "subset"),
    f"Qwen2.5-1.5B T=1.0":                   (temp_results[1.0][0], temp_results[1.0][1], "decoder", "subset"),
    "Qwen2.5-1.5B improved prompt (Task 5)": (acc_llm_imp,    f1_llm_imp,    "decoder", "subset"),
    "Qwen2.5-3B 4-bit improved (Task 5)":   (acc_llm_large,  f1_llm_large,  "decoder", "subset"),
}

print(f"\n{'Model':<45} {'Type':<10} {'Split':<8} {'Accuracy':>10} {'Macro-F1':>10}")
print("-" * 85)
for model_name, (acc, f1, mtype, split) in summary.items():
    print(f"{model_name:<45} {mtype:<10} {split:<8} {acc:>10.4f} {f1:>10.4f}")

# -- Confusion matrix for best encoder and best LLM ---------------------------
fig, axes = plt.subplots(1, 2, figsize=(12, 5))

labels_order = ["minus", "neutral", "plus"]

cm_enc = confusion_matrix(y_true, y_pred_enc_default, labels=labels_order)
ConfusionMatrixDisplay(cm_enc, display_labels=labels_order).plot(ax=axes[0], colorbar=False)
axes[0].set_title("HerBERT-base (Encoder)")

cm_llm = confusion_matrix(y_true_sub, y_pred_llm_imp, labels=labels_order)
ConfusionMatrixDisplay(cm_llm, display_labels=labels_order).plot(ax=axes[1], colorbar=False)
axes[1].set_title("Qwen2.5-1.5B improved prompt (Decoder)")

plt.suptitle("Confusion Matrices - Best Encoder vs Best LLM", fontsize=13)
plt.tight_layout()
plt.savefig("fig_conf_matrices.pdf", bbox_inches="tight")
plt.show()
files.download("fig_conf_matrices.pdf")
print("[Saved] fig_conf_matrices.pdf")

# -- Temperature sweep chart ---------------------------------------------------
temps    = list(temp_results.keys())
accs_t   = [temp_results[t][0] for t in temps]
f1s_t    = [temp_results[t][1] for t in temps]
x_labels = ["Greedy\n(T=0)", "T=0.1", "T=0.5", "T=1.0"]

fig, ax = plt.subplots(figsize=(7, 4))
ax.plot(x_labels, accs_t, marker="o", label="Accuracy")
ax.plot(x_labels, f1s_t,  marker="s", label="Macro-F1")
ax.set_title("Qwen2.5-1.5B - Temperature vs Performance")
ax.set_xlabel("Temperature")
ax.set_ylabel("Score")
ax.legend()
ax.grid(True, linestyle="--", alpha=0.5)
plt.tight_layout()
plt.savefig("fig_temperature_sweep.pdf", bbox_inches="tight")
plt.show()
files.download("fig_temperature_sweep.pdf")
print("[Saved] fig_temperature_sweep.pdf")

print("\n[DONE] All tasks completed.")