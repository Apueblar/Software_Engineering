# Ethics of New Technologies — Report Summary
**W08IST-SM4017S | Alvaro & Quique | 2025/26**

---

## 1. Codes of Ethics

### ACM Code of Ethics (2018)
The most detailed CS-specific framework. Key principles:
- **1.1** Contribute to society and human well-being (all stakeholders count)
- **1.2** Avoid harm
- **1.4** Be fair — do not discriminate (including algorithmically)
- **1.6** Respect privacy and consent
- **2.5** Provide thorough evaluations, including unintended consequences

### IEEE Code of Ethics (2020)
Shorter, covers all engineering disciplines. Key clauses:
- **Clause 1** Public safety and welfare are paramount
- **Clause 7** Accept honest criticism; acknowledge and correct errors
- **Clause 8** Treat all persons fairly regardless of origin or ethnicity

### Similarities vs. Differences
| | ACM | IEEE |
|---|---|---|
| Public welfare first | ✅ | ✅ |
| Non-discrimination | Explicit (algorithmic bias) | General (human relations) |
| Privacy | Dedicated principle | Implicit |
| Scope | Computing only | All engineering |
| Detail | Extensive sub-principles | 10 concise clauses |

---

## 2. Case — "PATROL-AI" (Fictional)

A tech startup deploys a predictive policing algorithm for a city of 500,000.

**Positive outcomes:** Crime drops 18%, response time improves 12%, saves ~€900k/year.

**The problem (discovered by lead engineer Marta):**
- 3 low-income/immigrant neighborhoods (15,000 residents) are flagged at **3.4× disproportionate rates**
- Historical bias in training data → over-policing → more arrests → more data → *feedback loop*
- CCTV data used without GDPR-compliant consent
- Management dismisses Marta's audit: *"the numbers speak for themselves"*

---

## 3. Ethical Analysis

### Under ACM
| Principle | Verdict |
|---|---|
| 1.1 Contribute to well-being | ❌ Ignores 15,000 stakeholders |
| 1.2 Avoid harm | ❌ Documented harm, deliberately continued |
| 1.4 Non-discrimination | ❌ Algorithmic discrimination by race/income |
| 1.6 Privacy | ❌ GDPR non-compliant data use |
| 2.5 Thorough evaluation | ✅ Marta's audit was proper — management failed |

### Under IEEE
| Clause | Verdict |
|---|---|
| 1 — Public welfare paramount | ❌ Minority welfare sacrificed for aggregate stats |
| 7 — Accept honest criticism | ❌ Management rejected documented findings |
| 8 — Fair treatment | ❌ Discriminatory outcomes against minority communities |

---

## 4. Utilitarian Analysis

### Management's argument
> "18% crime reduction for 485,000 people outweighs complaints from 15,000."

This is **simplistic utilitarianism** — and it fails on three grounds:

1. **Long-term calculus** — The feedback loop means harm *compounds*. Over 5 years, concentrated harm to 15,000 likely exceeds marginal benefit to the majority.

2. **Rule utilitarianism (Mill)** — The rule *"sacrifice minority civil liberties for aggregate statistics"* is catastrophic if universally adopted. Good rules must be safe to generalize.

3. **Intensity of harm (Bentham)** — Severe, concentrated harm (harassment, loss of freedom, psychological damage to 15,000) is not offset by diffuse, marginal benefit spread across 485,000 people.

### What Marta should do (utilitarian recommendation)
- Document everything formally with timestamps
- Propose concrete technical fixes: bias correction, fairness constraints, independent auditing
- If internal escalation fails → contact the national data protection authority (GDPR)

> Greatest good for the greatest number **requires Marta to act**, not stay silent.

---

## 5. Conclusions

Both codes and utilitarian philosophy converge on the same verdict:

> **PATROL-AI as deployed is ethically unacceptable** — not because it has no benefits, but because it achieves them by concentrating structural harm on a specific community.

Key lesson: **aggregate benefit does not justify unjust distribution of harm.** Ethical analysis must ask not only *"how much good is produced?"* but *"who bears the cost — and is that fair?"*