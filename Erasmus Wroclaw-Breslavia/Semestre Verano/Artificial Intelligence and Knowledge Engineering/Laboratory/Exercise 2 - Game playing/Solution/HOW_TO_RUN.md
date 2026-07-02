# 🧠 Breakthrough AI – How to Run

---

# ▶️ Basic Command

```bash
python breakthrough.py [OPTIONS]
```

You must provide **either**:

* `--default-board` → use built-in board
* or `--board board.txt` → use custom board

---

# ⚙️ All Parameters (Quick Explanation)

## 🧩 Board

| Option            | Meaning                         |
| ----------------- | ------------------------------- |
| `--default-board` | Use built-in 8×8 starting board |
| `--board FILE`    | Load board from a file          |

---

## 🧠 AI Strength (meant to be combined)

| Option | Example      | Meaning                              |
| ------ | ------------ | ------------------------------------ |
| `-d`   | `-d 3`       | Depth (higher = stronger but slower) |
| `-H`   | `-H advance` | Heuristic used by AI                 |

Heuristics:

```
piece | advance | threat | central | combined
```
Default: 'combined'

---

## 🤖 Second Player (optional)

| Option | Example       | Meaning         |
| ------ | ------------- | --------------- |
| `-d2`  | `-d2 2`       | Depth for W     |
| `-H2`  | `-H2 central` | Heuristic for W |

👉 If not set → W uses same as B

---

## 🧑 Human Mode

| Option      | Example    | Meaning     |
| ----------- | ---------- | ----------- |
| `--human W` | you play W | Human vs AI |
| `--human B` | you play B | AI vs Human |

---

## 👁️ Visual Mode

| Option     | Example       | Meaning                  |
| ---------- | ------------- | ------------------------ |
| `--visual` |               | Show moves               |
| `--delay`  | `--delay 0.5` | Auto pause between moves |
| `--step`   |               | Press Enter each move    |

---

## 🔁 Agent Mode

| Option      | Example | Meaning            |
| ----------- | ------- | ------------------ |
| `--agent B` |         | Run ONE move for B |
| `--agent W` |         | Run ONE move for W |

---

# 🔗 How to Combine Parameters

Think in blocks:

```
[BOARD] + [MODE] + [AI SETTINGS] + [EXTRAS]
```

---

# 🚀 Most Common Commands

## 🤖 AI vs AI

```bash
python3 breakthrough.py --default-board -d 3 -H combined
```

---

## 🤖 AI vs AI (different strategies)

```bash
python3 breakthrough.py --default-board -d 4 -H combined -d2 3 -H2 advance
```

---

## 🧑 Human vs AI

```bash
python3 breakthrough.py --default-board --human W -d 3 -H combined
```

---

## 👁️ Watch AI play

```bash
python3 breakthrough.py --default-board -d 3 -H combined --visual --delay 0.5
```

---

## 👁️ Step-by-step visualization

```bash
python3 breakthrough.py --default-board -d 3 -H combined --visual --step
```

---

## 📄 Use custom board

```bash
python3 breakthrough.py -d 3 -H combined --board board.txt
```

---

## 🔁 Agent (one move)

```bash
python3 breakthrough.py --agent B -d 4 -H combined --board board.txt
```

---

# 🎮 Human Input Format

Moves are like chess:

```
b2 b3
b2 c3
```

You will always see:

* board with coordinates
* list of legal moves

---

# ⚡ Performance Guide

| Depth | Use case         |
| ----- | ---------------- |
| 2     | fast / testing   |
| 3     | best for playing |
| 4     | strong but slow  |
| 5+    | very slow        |

---

# ✅ Minimal Examples

### Play vs AI

```bash
python3 breakthrough.py --default-board --human W -d 3 -H combined
```

### Watch a game

```bash
python3 breakthrough.py --default-board -d 3 -H combined --visual
```

### Strong AI battle

```bash
python3 breakthrough.py --default-board -d 4 -H combined
```

---

# 🧠 Rule of Thumb

* Want to **play** → add `--human`
* Want to **see moves** → add `--visual`
* Want it **faster** → lower `-d`
* Want different AIs → use `-d2` and `-H2`

---

That’s it—everything reduces to combining a few flags.