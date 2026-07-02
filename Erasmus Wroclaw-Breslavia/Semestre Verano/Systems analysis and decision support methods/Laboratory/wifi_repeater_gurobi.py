import math, random, time
from gurobipy import Model, GRB, quicksum

random.seed(43)
n = 8
R = 1.5
R_SOURCE = 2.5
num_clients = 15

locations = [(x, y) for y in range(n) for x in range(n)]
num_locs  = len(locations)
costs     = [round(random.uniform(1, 8), 2) for _ in range(num_locs)]
clients   = [(round(random.uniform(0, n-1), 2),
              round(random.uniform(0, n-1), 2)) for _ in range(num_clients)]

dist       = lambda a, b: math.sqrt((a[0]-b[0])**2 + (a[1]-b[1])**2)
node_range = [R_SOURCE if i == 0 else R for i in range(num_locs)]

cov = {i: [j for j in range(num_clients)
           if dist(locations[i], clients[j]) <= node_range[i]]
       for i in range(num_locs)}

# -- edges between any two nodes within mutual signal range --
# New: i and k can relay if dist ≤ max(range_i, range_k)
edges, node_edges = [], {i: [] for i in range(num_locs)}
for i in range(num_locs):
    for k in range(i + 1, num_locs):
        if dist(locations[i], locations[k]) <= max(node_range[i], node_range[k]):
            edges.append((i, k))
            node_edges[i].append((i, k))
            node_edges[k].append((i, k))

# -- Directed arcs --
directed = [(i,k) for (i,k) in edges] + [(k,i) for (i,k) in edges]
out_arcs, in_arcs = {i: [] for i in range(num_locs)}, {i: [] for i in range(num_locs)}
for (i,k) in directed:
    out_arcs[i].append(k)
    in_arcs[k].append(i)
edge_key = {(i,k): (i,k) for (i,k) in edges}
edge_key.update({(k,i): (i,k) for (i,k) in edges})

V, J, BM = range(num_locs), range(num_clients), num_locs - 1

# -- Model --
m  = Model("wifi_repeater")
x  = m.addVars(num_locs, vtype=GRB.BINARY, name="x")
y  = m.addVars([(i,j) for i in V for j in cov[i]], vtype=GRB.BINARY, name="y")
z  = m.addVars(edges, vtype=GRB.BINARY, name="z")
f  = m.addVars(directed, vtype=GRB.CONTINUOUS, lb=0, name="f")
s0 = m.addVar(vtype=GRB.CONTINUOUS, lb=0, ub=BM, name="s0")

m.setObjective(quicksum(costs[i]*x[i] for i in V), GRB.MINIMIZE)

m.addConstr(x[0] == 1)                                   # source always on

for j in J:                                               # C1: full coverage
    m.addConstr(quicksum(y[i,j] for i in V if j in cov[i]) >= 1)
for i in V:                                               # C2: serve from active only
    for j in cov[i]: m.addConstr(y[i,j] <= x[i])
for (i,k) in edges:                                       # C3: edge needs both endpoints
    m.addConstr(z[i,k] <= x[i])
    m.addConstr(z[i,k] <= x[k])
    m.addConstr(z[i,k] >= x[i] + x[k] - 1)              # tighter bound (fixes LP relax)
for (i,k) in directed:                                    # C4: flow on active edges only
    m.addConstr(f[i,k] <= BM * z[edge_key[(i,k)]])

# C5: single-commodity flow → one connected component
m.addConstr(s0 + quicksum(f[k,0] for k in in_arcs[0])
               - quicksum(f[0,k] for k in out_arcs[0]) == x[0])
for i in V:
    if i == 0: continue
    m.addConstr(quicksum(f[k,i] for k in in_arcs[i])
              - quicksum(f[i,k] for k in out_arcs[i]) == x[i])

t0 = time.perf_counter()
m.optimize()
t_gurobi = time.perf_counter() - t0

# -- Results --
active = [i for i in V if x[i].X > 0.5]
profit = sum(sum(y[i,j].X for j in cov[i]) / costs[i] for i in active) / len(active)

print(f"\nStatus          : {'OPTIMAL' if m.status == GRB.OPTIMAL else m.status}")
print(f"Total cost      : {m.objVal:.4f}")
print(f"MIP Gap         : {m.MIPGap*100:.4f} %")
print(f"Solve time      : {t_gurobi:.4f} s")
print(f"Repeaters placed: {len(active)} / {num_locs}")
print(f"Clients covered : {num_clients} / {num_clients} (100.0 %)")
print(f"Avg profitability: {profit:.4f} clients/cost-unit")
print()
print(f"{'Loc':>4}  {'Position':>10}  {'Cost':>6}  {'Clients':>7}  {'Profit':>8}")
for i in active:
    clients_i = sum(y[i,j].X for j in cov[i])
    print(f"{i:>4}  {str(locations[i]):>10}  {costs[i]:>6.2f}  {int(clients_i):>7}  {clients_i/costs[i]:>8.4f}")

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
covered = {j for i in active for j in cov[i] if y[i, j].X > 0.5}
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
    f"WiFi repeater placement  —  cost {m.objVal:.2f}  |  "
    f"{len(active)} nodes  |  {len(covered)}/{num_clients} clients covered",
    fontsize=10, pad=10
)
plt.tight_layout()
plt.savefig("wifi_map.png", dpi=150)
plt.show()