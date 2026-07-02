# How to Run - Step-by-Step Guide

## 1. Folder Structure

```
ex1/
├── gtfs/
│   ├── agency.txt
│   ├── stops.txt
│   ├── routes.txt
│   ├── trips.txt
│   ├── stop_times.txt
│   ├── calendar.txt
│   ├── calendar_dates.txt
│   └── feed_info.txt
│
├── gtfs_loader.py           <- GTFS parser
├── transit_graph.py         <- graph builder
├── pathfinding.py           <- Dijkstra + A* algorithms
├── tabu_search.py           <- Tabu Search TSP
├── task1.py                 <- Task 1 entry point
├── task2.py                 <- Task 2 entry point
└── visualize.py             <- Map generator
```

---

## 2. Generate the Interactive Map

```bash
python visualize.py
```

This reads `./gtfs`, generates **`map.html`**, and prints:
```
Loading GTFS from './gtfs' (date: 20260303) …
Route colours (from routes.txt route_color field):
  NOTE: All routes share the same CSV color #F6C32F. Assigning distinct palette colors for map visibility.
  Route D1                              CSV:   F6C32F  -> map color: #
  ...

  Stops: 843  |  Routes with geometry: 57
Generating 'map.html' …
Done. Open 'map.html' in your browser.
```

Then open `map.html` in your browser. You will see:
- 🟡 **Yellow dots** = all stops/platforms
- **Coloured lines** = each train route (colour from routes.txt)
- **Sidebar** = toggle individual lines on/off, filter by name
- Click any stop dot to see its name and ID

Custom options:
```bash
python visualize.py --gtfs ./gtfs --out network_map.html --date 20260310
```

---

## 3. Task 1 – Find Shortest Path Between Two Stops

### 3a. Dijkstra, travel time
```bash
python task1.py 1474651 1474981 t 08:00 --algo dijkstra --date 20260310
```

### 3b. A*, travel time (default)
```bash
python task1.py 1474651 1474981 t 08:00 --date 20260310
```

### 3c. A*, fewest transfers
```bash
python task1.py 1474651 1474981 p 08:00 --date 20260310
```

### 3d. A*, modification with bidirectional
```bash
python task1.py 1474651 1474981 t 08:00 --algo bidir
```

### If you see "Multiple stops match…"
The script asks you to choose:
```
Multiple stops match 'Wrocław' for START:
  [0] Wrocław Główny  (id: 5100021)
  [1] Wrocław Mikołajów  (id: 5100034)
  ...
Enter number: 0
```

---

## 4. Task 2 – Round-Trip TSP with Tabu Search

### 4a. Basic Tabu Search (no limits on T)
```bash
python task2.py "1474651" "1474843;1475162;1475133" t 08:00 --no-aspiration
```

### 4b. Variable tabu list size --tabu-size N
```bash
python task2.py "1474651" "1474843;1475162;1475133" t 08:00 --no-aspiration --tabu-size 5
```
> T becomes a FIFO deque of size max(7, N). Once full, the oldest move is evicted,
allowing the search to revisit areas of the solution space explored long ago.

### 4c. With aspiration criterion (ON by default)
```bash
# Aspiration is ON by default – no flag needed:
python task2.py "1474651" "1474843;1475162;1475133" t 08:00

# Turn it OFF to compare: (Done in 4a)
python task2.py "1474651" "1474843;1475162;1475133" t 08:00 --no-aspiration
```

### 4d. Neighbour sampling (faster for large lists)
```bash
python task2.py "1474651" "1474843;1475162;1475133;1475015;1475245" t 08:00 --sampling --sample-size 15 --steps 500
```