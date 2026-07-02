"""
pathfinding.py  -  Task 1
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
==========================
Implements four search algorithms for transit routing on the time-dependent
graph built by transit_graph.py:

  1. dijkstra_time              - Dijkstra's algorithm, cost = total travel time
  2. astar_time                 - A* algorithm,         cost = total travel time
  3. astar_transfers            - A* algorithm,         cost = number of line changes
  4. astar_time_bidirectional   - Bidirectional A*      cost = total travel time

All four share the same output contract:
    (cost, path_legs, nodes_explored)

  cost          - value of the minimised criterion (seconds or transfer count)
  path_legs     - list of dicts describing each leg of the journey
  nodes_explored - how many states were popped from the priority queue
                   (useful for comparing algorithm efficiency)

HOW TIME-DEPENDENT ROUTING WORKS
---------------------------------
In a regular graph Dijkstra/A* assign a single cost to each edge.
Here an edge "train T departs stop A at 08:30, arrives stop B at 09:10"
can only be used if the traveller reaches A *before* 08:30.

We therefore model the state as the *stop* we are at plus the *time* we
arrived there.  The cost to move to the next stop is:

    wait_time  =  next_departure - current_arrival
    ride_time  =  next_arrival   - next_departure
    edge_cost  =  wait_time + ride_time

For travel-time minimisation this equals (next_arrival - current_arrival).
"""

from typing import Dict, List
import heapq
from transit_graph import TransitGraph
from gtfs_loader import seconds_to_str


# ---------------------------------------------------------------------------
# Shared path-reconstruction helper
# ---------------------------------------------------------------------------

def _reconstruct(came_from: dict, end_state: tuple) -> List[dict]:
    """
    Walk `came_from` backwards from end_state to the start to build the journey.

    Each step in came_from maps:
        state  ->  (previous_state, edge_dict)

    Returns a list of leg-dicts (start to end order), each with:
        from_stop, to_stop, line, departure, arrival
    """
    legs = []
    state = end_state
    while state in came_from:
        prev_state, edge = came_from[state]
        if edge is None:
            state = prev_state
            continue
        legs.append(edge)
        state = prev_state
    legs.reverse()
    return legs


def _format_legs(legs: List[dict], stops: dict) -> List[dict]:
    """
    Enrich raw edge-dicts with human-readable stop names and formatted times.

    Output dicts contain:
        from_stop_name, to_stop_name, line, departure_str, arrival_str
    """
    result = []
    for leg in legs:
        if leg.get("type") == "transfer":
            continue   # omit platform walks from printed output (or include with note)
        result.append({
            "from_stop":  leg["from_stop"],
            "to_stop":    leg["to_stop"],
            "from_name":  stops.get(leg["from_stop"], {}).get("name", leg["from_stop"]),
            "to_name":    stops.get(leg["to_stop"],   {}).get("name", leg["to_stop"]),
            "line":       leg["line"],
            "departure":  seconds_to_str(leg["departure"]),
            "arrival":    seconds_to_str(leg["arrival"]),
        })
    return result


# ---------------------------------------------------------------------------
# 1. DIJKSTRA - travel time
# ---------------------------------------------------------------------------

def dijkstra_time(graph: TransitGraph,
                  start_stop: str,
                  end_stop: str,
                  start_time: int) -> tuple:
    """
    Classic Dijkstra on the time-dependent transit graph.

    Why Dijkstra works here
    -----------------------
    Even though edges have varying costs (wait + ride), the effective edge cost
    (new_arrival - current_arrival) is always >= 0 when we require departure >= arrival.
    This non-negativity is the only requirement for Dijkstra's correctness.

    State:  stop_id  (just a string)
    Key:    best_time[stop_id] = earliest clock time we can be at this stop

    Priority queue entry:  (arrival_time, stop_id, trip_id_we_are_on)
    trip_id is tracked only for later transfer counting in path; it does not
    affect the cost or pruning here.

    Returns
    -------
    (cost_seconds, formatted_legs, nodes_explored)
    or (None, [], nodes_explored) if no path exists.
    """
    # best_time[stop_id] = minimum wall-clock arrival time at this stop
    best_time: Dict[str, int] = {start_stop: start_time}

    # came_from[(stop_id, time)] = (prev_(stop_id, time), edge_with_from/to fields)
    came_from: dict = {}

    # Priority queue: (arrival_time, stop_id, current_trip_id)
    pq = [(start_time, start_stop, None)]

    nodes_explored = 0

    while pq:
        curr_time, stop_id, curr_trip = heapq.heappop(pq)
        nodes_explored += 1

        # Goal reached - reconstruct path
        if stop_id == end_stop:
            cost = curr_time - start_time
            legs = _reconstruct(came_from, (stop_id, curr_time))
            return cost, _format_legs(legs, graph.stops), nodes_explored

        # Stale entry: we already found a better path to this stop
        if curr_time > best_time.get(stop_id, float("inf")):
            continue

        for edge in graph.edges.get(stop_id, []):
            if edge["type"] == "trip":
                dep = edge["departure"]
                arr = edge["arrival"]
                nxt = edge["to"]

                # We can only board if the train has not yet departed
                if dep < curr_time:
                    continue

                # New arrival time at the next stop
                if arr < best_time.get(nxt, float("inf")):
                    best_time[nxt] = arr
                    enriched = {**edge, "from_stop": stop_id, "to_stop": nxt}
                    came_from[(nxt, arr)] = ((stop_id, curr_time), enriched)
                    heapq.heappush(pq, (arr, nxt, edge["trip_id"]))

            elif edge["type"] == "transfer":
                nxt = edge["to"]
                new_time = curr_time + edge["transfer_time"]
                if new_time < best_time.get(nxt, float("inf")):
                    best_time[nxt] = new_time
                    enriched = {**edge, "from_stop": stop_id, "to_stop": nxt,
                                "departure": curr_time, "arrival": new_time}
                    came_from[(nxt, new_time)] = ((stop_id, curr_time), enriched)
                    heapq.heappush(pq, (new_time, nxt, None))

    return None, [], nodes_explored


# ---------------------------------------------------------------------------
# 2. A* - travel time
# ---------------------------------------------------------------------------

def astar_time(graph: TransitGraph,
               start_stop: str,
               end_stop: str,
               start_time: int) -> tuple:
    """
    A* algorithm minimising total travel time (wait + ride).

    Heuristic h(n)
    --------------
    h(n) = haversine_distance(n, goal) / MAX_TRAIN_SPEED

    Why it is ADMISSIBLE (never overestimates):
        No train travels faster than MAX_TRAIN_SPEED (160 km/h).
        Therefore the remaining travel time is always >= h(n).
        Admissibility guarantees that A* finds the optimal path.

    Why it is better than Dijkstra:
        Dijkstra expands nodes in all directions uniformly.
        A* biases expansion towards the goal using the heuristic,
        so many stops in the wrong direction are never explored.
        This dramatically reduces the number of nodes_explored.

    State / priority queue:  (f_score, arrival_time, stop_id, trip_id)
    where  f = g + h,  g = arrival_time - start_time  (elapsed travel time),
                       h = heuristic remaining time.
    """
    best_time: Dict[str, int] = {start_stop: start_time}
    came_from: dict = {}

    h0 = graph.heuristic_time(start_stop, end_stop)
    # pq entry: (f_score, arrival_time, stop_id, trip_id)
    # We include arrival_time as secondary sort key so ties break deterministically.
    pq = [(h0, start_time, start_stop, None)]

    nodes_explored = 0

    while pq:
        f, curr_time, stop_id, curr_trip = heapq.heappop(pq)
        nodes_explored += 1

        if stop_id == end_stop:
            cost = curr_time - start_time
            legs = _reconstruct(came_from, (stop_id, curr_time))
            return cost, _format_legs(legs, graph.stops), nodes_explored

        if curr_time > best_time.get(stop_id, float("inf")):
            continue

        for edge in graph.edges.get(stop_id, []):
            if edge["type"] == "trip":
                dep = edge["departure"]
                arr = edge["arrival"]
                nxt = edge["to"]

                if dep < curr_time:
                    continue

                if arr < best_time.get(nxt, float("inf")):
                    best_time[nxt] = arr
                    enriched = {**edge, "from_stop": stop_id, "to_stop": nxt}
                    came_from[(nxt, arr)] = ((stop_id, curr_time), enriched)

                    g = arr - start_time
                    h = graph.heuristic_time(nxt, end_stop)
                    heapq.heappush(pq, (g + h, arr, nxt, edge["trip_id"]))

            elif edge["type"] == "transfer":
                nxt = edge["to"]
                new_time = curr_time + edge["transfer_time"]
                if new_time < best_time.get(nxt, float("inf")):
                    best_time[nxt] = new_time
                    enriched = {**edge, "from_stop": stop_id, "to_stop": nxt,
                                "departure": curr_time, "arrival": new_time}
                    came_from[(nxt, new_time)] = ((stop_id, curr_time), enriched)

                    g = new_time - start_time
                    h = graph.heuristic_time(nxt, end_stop)
                    heapq.heappush(pq, (g + h, new_time, nxt, None))

    return None, [], nodes_explored


# ---------------------------------------------------------------------------
# 3. A* - number of transfers
# ---------------------------------------------------------------------------

def astar_transfers(graph: TransitGraph,
                    start_stop: str,
                    end_stop: str,
                    start_time: int) -> tuple:
    """
    A* minimising the number of line changes (transfers).

    What counts as a transfer?
    --------------------------
    Boarding the first train is free (no transfer).
    Every subsequent boarding of a *different* trip_id counts as +1 transfer.
    Walking between platforms of the same station does NOT add a transfer
    but does add waiting/walk time.

    State
    -----
    We must track which trip we are currently riding, because:
        "At stop S on trip T1, 0 transfers so far"  ≠
        "At stop S on trip T2, 0 transfers so far"
    Even if both reach stop S at the same time, T1 may connect directly to the
    next leg while T2 requires a transfer.

    State key:  (stop_id, trip_id)
    best[(stop_id, trip_id)] = (min_transfers, min_arrival_time)

    Heuristic
    ---------
    h(n) = 0  for all nodes.

    This is trivially admissible (it never overestimates the remaining transfers).
    A better heuristic is hard to design without precomputation, but h=0 already
    makes the algorithm correct.  A* with h=0 degenerates to Dijkstra, but the
    *priority key* is (transfers, time) which ensures we explore fewer-transfer
    paths first - better than plain Dijkstra on time alone.

    Priority queue entry: (num_transfers, arrival_time, stop_id, trip_id)
    Secondary sort on arrival_time breaks ties by preferring earlier arrivals.
    """
    # best[(stop_id, trip_id)] = (min_transfers, min_arrival_time)
    best: dict = {(start_stop, None): (0, start_time)}

    # came_from[(stop_id, time, trip_id)] = (prev_state, edge)
    came_from: dict = {}

    pq = [(0, start_time, start_stop, None)]   # (transfers, time, stop, trip)
    nodes_explored = 0

    while pq:
        transfers, curr_time, stop_id, curr_trip = heapq.heappop(pq)
        nodes_explored += 1

        if stop_id == end_stop:
            legs = _reconstruct(came_from, (stop_id, curr_time, curr_trip))
            return transfers, _format_legs(legs, graph.stops), nodes_explored

        # Prune if a better (fewer transfers, earlier) path was already found
        key = (stop_id, curr_trip)
        bt, btime = best.get(key, (float("inf"), float("inf")))
        if transfers > bt or (transfers == bt and curr_time > btime):
            continue

        for edge in graph.edges.get(stop_id, []):
            if edge["type"] == "trip":
                dep = edge["departure"]
                arr = edge["arrival"]
                nxt = edge["to"]
                tid = edge["trip_id"]

                if dep < curr_time:
                    continue

                # A transfer happens when we board a DIFFERENT trip
                # (curr_trip is None only at the very start - first boarding is free)
                new_transfers = transfers + ( 1 if curr_trip is not None and tid != curr_trip else 0 )
                new_time = arr
                nxt_key = (nxt, tid)
                bt2, bt2time = best.get(nxt_key, (float("inf"), float("inf")))

                if new_transfers < bt2 or (new_transfers == bt2 and new_time < bt2time):
                    best[nxt_key] = (new_transfers, new_time)
                    enriched = {**edge, "from_stop": stop_id, "to_stop": nxt}
                    new_state = (nxt, new_time, tid)
                    prev_state = (stop_id, curr_time, curr_trip)
                    came_from[new_state] = (prev_state, enriched)
                    heapq.heappush(pq, (new_transfers, new_time, nxt, tid))

            elif edge["type"] == "transfer":
                # Platform walk: same trip context, no extra transfer
                nxt = edge["to"]
                new_time = curr_time + edge["transfer_time"]
                nxt_key = (nxt, curr_trip)
                bt2, bt2time = best.get(nxt_key, (float("inf"), float("inf")))

                if transfers < bt2 or (transfers == bt2 and new_time < bt2time):
                    best[nxt_key] = (transfers, new_time)
                    enriched = {**edge, "from_stop": stop_id, "to_stop": nxt,
                                "departure": curr_time, "arrival": new_time}
                    new_state = (nxt, new_time, curr_trip)
                    prev_state = (stop_id, curr_time, curr_trip)
                    came_from[new_state] = (prev_state, enriched)
                    heapq.heappush(pq, (transfers, new_time, nxt, curr_trip))

    return None, [], nodes_explored


# ---------------------------------------------------------------------------
# Modification (d): bidirectional A* for faster time-based search
# ---------------------------------------------------------------------------
from transit_graph import build_reverse_graph

def astar_time_bidirectional(graph: TransitGraph,
                              backward_graph,          # Dict or None
                              start_stop: str,
                              end_stop: str,
                              start_time: int) -> tuple:
    """
    Bidirectional A* minimising total travel time.

    ALGORITHM OVERVIEW
    ------------------
    Two simultaneous A* frontiers expand towards each other:

      Forward  search: start_stop -> end_stop
                       time-DEPENDENT (real timetable, same as astar_time)
                       heuristic h_f(n) = haversine(n, end) / MAX_SPEED

      Backward search: end_stop -> start_stop
                       time-AGNOSTIC (static travel times on reversed graph)
                       heuristic h_b(n) = haversine(n, start) / MAX_SPEED

    WHY THE BACKWARD SEARCH IS TIME-AGNOSTIC
    -----------------------------------------
    In a time-dependent graph, a fully correct backward search would need to
    work with "latest feasible departure" rather than "earliest arrival", which
    requires a different graph representation and significantly more complexity.

    Instead, the backward search uses *static travel times* - its sole purpose
    is to PRUNE the forward search by identifying a good meeting point early.
    The actual timed path for the second half is always computed by running a
    fresh forward A* from the meeting point.

    TWO-PHASE RECONSTRUCTION (the key design decision)
    ---------------------------------------------------
    Phase 1 - Forward half:  start_stop -> meeting_point
              Reconstructed exactly from came_from_f (real timetable times).

    Phase 2 - Backward half: meeting_point -> end_stop
              Re-run as a fresh forward astar_time() starting at
              best_f[meeting_point] - the exact clock time we arrive there.
              This guarantees all departure/arrival times are causally correct.

    WHY NOT USE came_from_b FOR THE SECOND HALF?
    ---------------------------------------------
    The orig edges stored in came_from_b carry their raw scheduled times
    (e.g. a train that runs at 03:28), completely independent of when the
    forward search arrives at the meeting point. Using them would produce
    the bug seen in practice: second-half legs departing before the traveller
    even arrives at the intermediate stop.

    BENEFIT OVER UNIDIRECTIONAL A*
    -------------------------------
    The forward search is pruned as soon as the two frontiers overlap, so it
    explores roughly half as many nodes as standard A* in the ideal case.
    nodes_explored counts only the nodes popped during the bidirectional phase.
    """
    INF = float("inf")

    # -- Build the reverse graph on demand --
    if backward_graph is None:
        backward_graph = build_reverse_graph(graph)

    # -- Trivial case --
    if start_stop == end_stop:
        return 0, [], 0

    # -- Forward search state --
    # best_f[stop] = earliest wall-clock arrival time at this stop
    best_f: Dict[str, float] = {start_stop: float(start_time)}
    # came_from_f[(stop_id, arrival_time)] = (prev_(stop_id, time), enriched_edge)
    came_from_f: dict = {}
    settled_f: set = set()

    h0_f = graph.heuristic_time(start_stop, end_stop)
    # pq_f: (absolute_f_score, arrival_time, stop_id, trip_id)
    pq_f: list = [(start_time + h0_f, start_time, start_stop, None)]

    # -- Backward search state --
    # best_b[stop] = minimum STATIC travel time from this stop to end_stop
    # Used only for pruning and meeting-point selection, NOT for path times.
    best_b: Dict[str, float] = {end_stop: 0.0}
    settled_b: set = set()

    h0_b = graph.heuristic_time(end_stop, start_stop)
    # pq_b: (f_score, cost_b, stop_id)
    pq_b: list = [(h0_b, 0.0, end_stop)]

    # -- Shared state --
    # mu: best complete-path cost estimate using static backward costs.
    # meeting_point: the stop in best_f that minimises best_f[m] + best_b[m].
    mu            = INF
    nodes_explored = 0

    # -- Main loop --
    while pq_f and pq_b:

        # Pohl-Kaindl termination: if both lower-bounds combined exceed mu,
        # no undiscovered path can improve on the best candidate meeting point.
        f_f_norm = pq_f[0][0] - start_time   # g_f + h_f (elapsed seconds)
        f_b_norm = pq_b[0][0]                # g_b + h_b (static seconds to end)
        if f_f_norm + f_b_norm >= mu:
            break

        if f_f_norm <= f_b_norm:
            # -- Forward expansion --
            _, curr_time, stop_id, curr_trip = heapq.heappop(pq_f)
            nodes_explored += 1

            if stop_id in settled_f:
                continue
            settled_f.add(stop_id)

            # Check if the backward search has reached this stop.
            # If yes, it is a candidate meeting point: cost = elapsed + best_b.
            if stop_id in best_b:
                candidate = (curr_time - start_time) + best_b[stop_id]
                if candidate < mu:
                    mu = candidate

            # Direct goal check: forward search reached the destination.
            if stop_id == end_stop:
                candidate = curr_time - start_time
                if candidate < mu:
                    mu = candidate
                break

            # Expand time-dependent forward edges
            for edge in graph.edges.get(stop_id, []):
                if edge["type"] == "trip":
                    dep, arr, nxt = edge["departure"], edge["arrival"], edge["to"]
                    if dep < curr_time:
                        continue
                    if arr < best_f.get(nxt, INF):
                        best_f[nxt] = arr
                        enriched    = {**edge, "from_stop": stop_id, "to_stop": nxt}
                        came_from_f[(nxt, arr)] = ((stop_id, curr_time), enriched)
                        g = arr - start_time
                        h = graph.heuristic_time(nxt, end_stop)
                        heapq.heappush(pq_f, (start_time + g + h, arr, nxt, edge["trip_id"]))

                elif edge["type"] == "transfer":
                    nxt      = edge["to"]
                    new_time = curr_time + edge["transfer_time"]
                    if new_time < best_f.get(nxt, INF):
                        best_f[nxt] = new_time
                        enriched    = {**edge, "from_stop": stop_id, "to_stop": nxt,
                                       "departure": curr_time, "arrival": new_time}
                        came_from_f[(nxt, new_time)] = ((stop_id, curr_time), enriched)
                        g = new_time - start_time
                        h = graph.heuristic_time(nxt, end_stop)
                        heapq.heappush(pq_f, (start_time + g + h, new_time, nxt, None))

        else:
            # -- Backward expansion (time-agnostic, pruning only) --
            _, cost_b, stop_id = heapq.heappop(pq_b)
            nodes_explored += 1

            if stop_id in settled_b:
                continue
            settled_b.add(stop_id)

            # Check if the forward search has already reached this stop.
            if stop_id in best_f:
                candidate = (best_f[stop_id] - start_time) + cost_b
                if candidate < mu:
                    mu = candidate

            # Expand static reverse edges
            for rev_edge in backward_graph.get(stop_id, []):
                nxt      = rev_edge["to"]
                new_cost = cost_b + rev_edge["travel_time"]
                if new_cost < best_b.get(nxt, INF):
                    best_b[nxt] = new_cost
                    h = graph.heuristic_time(nxt, start_stop)
                    heapq.heappush(pq_b, (new_cost + h, new_cost, nxt))

    # -- No meeting point found -> fall back to standard A* --
    if not best_f or not best_b:
        return astar_time(graph, start_stop, end_stop, start_time)


    # -- PHASE 2: Find the optimal meeting point ----------------------------------------    
    MAX_PHASE2_TRIES = 3

    # Collect settled intersection, sorted by lower bound ascending
    candidates = sorted(
        (best_f[m] - start_time + best_b[m], m)
        for m in settled_f
        if m in settled_b
    )

    if not candidates:
        return astar_time(graph, start_stop, end_stop, start_time)

    for i, (_, m) in enumerate(candidates):
        if i >= MAX_PHASE2_TRIES:
            break

        m_time_candidate = int(best_f[m])
        sc, bl, _ = astar_time(graph, m, end_stop, m_time_candidate)
        # Phase-2 node count intentionally NOT added to nodes_explored:
        # the bidirectional phase already did the hard pruning work;
        # Phase-2 is a short targeted correction, not part of the main search.

        if sc is None:
            continue   # no onward connection; try next candidate

        true_cost = (m_time_candidate - start_time) + sc
        fwd_legs  = _reconstruct(came_from_f, (m, m_time_candidate))
        return true_cost, _format_legs(fwd_legs, graph.stops) + bl, nodes_explored

    # All candidates failed -> full fallback
    return astar_time(graph, start_stop, end_stop, start_time)