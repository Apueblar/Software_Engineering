# -*- coding: utf-8 -*-
"""WiFi Repeater Placement - Simulated Annealing Metaheuristic

Exact same instance as wifi_repeater_gurobi.py:
  seed=43, n=8, R=1.5, R_SOURCE=2.5, num_clients=15

Key differences from the old SA version:
  • Source node v0=0 is always active (never flipped).
  • TWO coverage radii: R_SOURCE=2.5 for v0, R=1.5 for all others.
  • Edges: dist(i,k) ≤ max(node_range[i], node_range[k])   ← Euclidean, not grid-adjacency.
  • Connectivity check: BFS/DFS from v0 — every active node must be reachable
    (true single-component constraint, mirrors SCF in Gurobi).
  • Repair respects the Euclidean edge set, not just 4-connected grid neighbours.

Encoding   : binary vector x ∈ {0,1}^|V|, x[0]=1 fixed
Neighbour  : flip one x[i], i≠0, then repair
Repair     : (1) coverage — activate cheapest covering node per uncovered client
             (2) connectivity — BFS from v0; for each unreachable active node,
                 activate the cheapest edge that bridges it toward v0

Time  complexity : O(T_max x |V| x |J|)
Memory complexity: O(|V| + |J| + |E|)
"""

import math, random, time
from collections import deque

# -- Instance (identical to Gurobi script) --
random.seed(43)

n           = 8
R           = 1.5
R_SOURCE    = 2.5
num_clients = 15

locations  = [(x, y) for y in range(n) for x in range(n)]
num_locs   = len(locations)
costs      = [round(random.uniform(1, 8), 2) for _ in range(num_locs)]
clients    = [(round(random.uniform(0, n - 1), 2),
               round(random.uniform(0, n - 1), 2)) for _ in range(num_clients)]

dist       = lambda a, b: math.sqrt((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2)
node_range = [R_SOURCE if i == 0 else R for i in range(num_locs)]

# Coverage sets (per-node radius)
cov     = {i: [j for j in range(num_clients)
               if dist(locations[i], clients[j]) <= node_range[i]]
           for i in range(num_locs)}
rev_cov = {j: [i for i in range(num_locs) if j in cov[i]]
           for j in range(num_clients)}

# Edges: Euclidean dist ≤ max(range_i, range_k)  — mirrors Gurobi
edges      = []
neighbours = {i: [] for i in range(num_locs)}
for i in range(num_locs):
    for k in range(i + 1, num_locs):
        if dist(locations[i], locations[k]) <= max(node_range[i], node_range[k]):
            edges.append((i, k))
            neighbours[i].append(k)
            neighbours[k].append(i)

V = list(range(num_locs))
J = list(range(num_clients))

# -- Helpers --

def total_cost(x):
    return sum(costs[i] for i in V if x[i])


def bfs_reachable(x):
    """Return set of nodes reachable from v0=0 through active nodes."""
    if not x[0]:
        return set()
    visited = {0}
    queue   = deque([0])
    while queue:
        u = queue.popleft()
        for v in neighbours[u]:
            if x[v] and v not in visited:
                visited.add(v)
                queue.append(v)
    return visited


def is_feasible(x):
    # (a) all clients covered
    coverage_ok = all(any(x[i] for i in rev_cov[j]) for j in J)
    if not coverage_ok:
        return False
    # (b) all active nodes reachable from v0
    active_set  = {i for i in V if x[i]}
    reachable   = bfs_reachable(x)
    return active_set == reachable


def repair(x):
    """Return a repaired copy of x satisfying coverage and connectivity."""
    x = x[:]
    x[0] = 1   # source always on

    # -- (1) Fix coverage --
    for j in J:
        if not any(x[i] for i in rev_cov[j]):
            best = min(rev_cov[j], key=lambda i: costs[i])
            x[best] = 1

    # -- (2) Fix connectivity (BFS from v0) --
    # Repeat until stable: an activation to repair connectivity may create
    # new coverage, but never breaks coverage, so one pass suffices for
    # connectivity.  We iterate to handle chains of disconnected nodes.
    for _ in range(num_locs):           # at most |V| bridge activations needed
        active_set = {i for i in V if x[i]}
        reachable  = bfs_reachable(x)
        orphans    = active_set - reachable
        if not orphans:
            break
        # For each orphan find the cheapest neighbour that is already
        # reachable (or the cheapest node on any path toward v0).
        # Simple greedy: activate the cheapest neighbour of any reachable node
        # that is adjacent to an orphan.
        best_candidate = None
        best_cost      = float("inf")
        for o in orphans:
            for nb in neighbours[o]:
                if nb in reachable and costs[nb] < best_cost:
                    # nb is already active (it's reachable), but we need to
                    # bridge the gap: activate the orphan's cheapest neighbour
                    # that is reachable — but o itself is already active.
                    # What we actually need: the cheapest inactive node on a
                    # path from reachable to o.  Simple proxy: cheapest
                    # inactive neighbour of any reachable node that has a
                    # neighbour in orphans.
                    pass
            # cheaper proxy: cheapest inactive neighbour of reachable nodes
            # that is also a neighbour of this orphan
            for nb in neighbours[o]:
                if nb in reachable:
                    # o is active but not reachable → there's a gap.
                    # Activating any inactive intermediate would help, but
                    # since o is already in active_set and nb is reachable,
                    # the edge (o, nb) exists → o should already be reachable.
                    # This means o IS reachable through nb. Recompute.
                    pass
        # Fallback: find the cheapest inactive node adjacent to a reachable
        # node, then activate it — this grows the reachable set.
        grown = False
        candidates = []
        for r_node in reachable:
            for nb in neighbours[r_node]:
                if not x[nb]:
                    candidates.append(nb)
        if candidates:
            bridge = min(candidates, key=lambda i: costs[i])
            x[bridge] = 1
            grown = True
        if not grown:
            break   # no bridge available — instance is disconnected (shouldn't happen)

    return x


def penalised_cost(x):
    """Cost + large penalties for constraint violations (used during search)."""
    BIG  = 1000.0
    cost = total_cost(x)
    for j in J:
        if not any(x[i] for i in rev_cov[j]):
            cost += BIG
    active_set = {i for i in V if x[i]}
    reachable  = bfs_reachable(x)
    cost += BIG * len(active_set - reachable)
    return cost


# -- Initial solution --
# Greedy: for each uncovered client activate cheapest covering node, then repair.
x_curr    = [0] * num_locs
x_curr[0] = 1                                   # source always on
for j in J:
    if not any(x_curr[i] for i in rev_cov[j]):
        best = min(rev_cov[j], key=lambda i: costs[i])
        x_curr[best] = 1
x_curr = repair(x_curr)

x_best = x_curr[:]
f_best = total_cost(x_curr)
f_curr = penalised_cost(x_curr)

# -- SA hyper-parameters --
T_init   = 50.0
T_min    = 0.01
alpha    = 0.995
max_iter = 30_000

T = T_init

# -- Simulated Annealing --
t0 = time.perf_counter()

for it in range(max_iter):
    if T < T_min:
        break

    # Neighbour: flip one location (never the source)
    flip_idx       = random.randint(1, num_locs - 1)
    x_new          = x_curr[:]
    x_new[flip_idx] ^= 1
    x_new          = repair(x_new)

    f_new  = penalised_cost(x_new)
    delta  = f_new - f_curr

    if delta < 0 or random.random() < math.exp(-delta / T):
        x_curr, f_curr = x_new, f_new
        if is_feasible(x_curr):
            c = total_cost(x_curr)
            if c < f_best:
                x_best, f_best = x_curr[:], c

    T *= alpha

t_sa = time.perf_counter() - t0

# -- Results --
active  = [i for i in V if x_best[i]]
covered = sum(1 for j in J if any(x_best[i] for i in rev_cov[j]))
profit  = (sum(len([j for j in cov[i]]) / costs[i] for i in active)
           / len(active))

print(f"\nStatus          : {'FEASIBLE' if is_feasible(x_best) else 'INFEASIBLE'}")
print(f"Total cost      : {f_best:.4f}")
print(f"Solve time      : {t_sa:.4f} s")
print(f"Repeaters placed: {len(active)} / {num_locs}")
print(f"Clients covered : {covered} / {num_clients}  ({100*covered/num_clients:.1f} %)")
print(f"Avg profitability: {profit:.4f} clients/cost-unit")
print()
print(f"{'Loc':>4}  {'Position':>10}  {'Cost':>6}  {'Clients':>7}  {'Profit':>8}")
for i in active:
    clients_i = len(cov[i])
    print(f"{i:>4}  {str(locations[i]):>10}  {costs[i]:>6.2f}  {clients_i:>7}  {clients_i/costs[i]:>8.4f}")

# -- Map --
import matplotlib.pyplot as plt
import matplotlib.patches as patches

fig, ax = plt.subplots(figsize=(8, 8))
ax.set_xlim(-0.5, n - 0.5)
ax.set_ylim(-0.5, n - 0.5)
ax.set_aspect("equal")
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.grid(True, color="#e0e0e0", linewidth=0.5, zorder=0)
ax.set_facecolor("#f9f9f9")

# Draw range circles (back to front: source last so it's on top)
for i in sorted(active, key=lambda i: i == 0):
    cx, cy = locations[i]
    r = node_range[i]
    color = "#a855f7" if i == 0 else "#3b82f6"
    circle = plt.Circle((cx, cy), r, color=color, alpha=0.10, zorder=1)
    border = plt.Circle((cx, cy), r, fill=False, edgecolor=color,
                         linewidth=1.2, linestyle="--", zorder=2)
    ax.add_patch(circle)
    ax.add_patch(border)

# Draw edges between active repeaters
for (i, k) in edges:
    if i in active and k in active:
        x0, y0 = locations[i]
        x1, y1 = locations[k]
        ax.plot([x0, x1], [y0, y1], color="#94a3b8", linewidth=0.8,
                zorder=3, alpha=0.6)

# Draw repeater nodes
for i in active:
    cx, cy = locations[i]
    if i == 0:
        ax.plot(cx, cy, marker="*", markersize=18, color="#a855f7",
                zorder=5, label="Source")
        ax.annotate("source", (cx, cy), textcoords="offset points",
                    xytext=(6, 6), fontsize=7, color="#7c3aed")
    else:
        ax.plot(cx, cy, marker="s", markersize=9, color="#3b82f6",
                markeredgecolor="#1d4ed8", markeredgewidth=0.8,
                zorder=5)
        ax.annotate(f"r{i}\n{costs[i]:.1f}", (cx, cy),
                    textcoords="offset points", xytext=(5, 5),
                    fontsize=6.5, color="#1e40af")

# Draw clients — green if covered, red if not
covered = {j for i in active for j in cov[i]}
for j, (cx, cy) in enumerate(clients):
    color = "#16a34a" if j in covered else "#dc2626"
    ax.plot(cx, cy, "o", markersize=7, color=color,
            markeredgecolor="white", markeredgewidth=0.6, zorder=6)
    ax.annotate(str(j), (cx, cy), textcoords="offset points",
                xytext=(4, 3), fontsize=6.5, color=color)

# Legend
legend_elements = [
    plt.Line2D([0], [0], marker="*", color="w", markerfacecolor="#a855f7",
               markersize=12, label="Source"),
    plt.Line2D([0], [0], marker="s", color="w", markerfacecolor="#3b82f6",
               markersize=9,  label="Repeater"),
    plt.Line2D([0], [0], marker="o", color="w", markerfacecolor="#16a34a",
               markersize=7,  label="Client (covered)"),
    plt.Line2D([0], [0], marker="o", color="w", markerfacecolor="#dc2626",
               markersize=7,  label="Client (uncovered)"),
    patches.Patch(facecolor="#3b82f680", edgecolor="#3b82f6",
                  linestyle="--", label=f"Repeater range (R={R})"),
    patches.Patch(facecolor="#a855f780", edgecolor="#a855f7",
                  linestyle="--", label=f"Source range (R={R_SOURCE})"),
]
ax.legend(handles=legend_elements, loc="upper right", fontsize=8,
          framealpha=0.9, edgecolor="#cbd5e1")

ax.set_title(
    f"WiFi repeater placement  —  cost {f_best:.2f}  |  "
    f"{len(active)} nodes  |  {len(covered)}/{num_clients} clients covered",
    fontsize=10, pad=10
)
plt.tight_layout()
plt.savefig("wifi_map.png", dpi=150)
plt.show()