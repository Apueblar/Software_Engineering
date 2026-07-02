"""
tabu_search.py  -  Task 2
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
==========================
Solves the Transit TSP: starting from stop A, visit every stop in list L,
and return to A, minimising either total travel time or total transfers.

PROBLEM REDUCTION
-----------------
The full problem is NP-hard (it is a generalisation of TSP).  We tackle it in
two stages:

  Stage 1 - Shortest-path precomputation
    For every ordered pair (i, j) of stops in {A} U L, we run A* to find
    the minimum cost and actual journey (legs) from i to j.
    This gives us a cost matrix C[i][j] and a path matrix P[i][j].
    Complexity: O(n^2 * cost_of_A*),  n = |L| + 1.

  Stage 2 - Tabu Search on the permutation space
    We treat the precomputed costs as static edge weights and search for the
    best ordering (permutation) of L to visit.
    The tour is always: A -> pi[0] -> pi[1] -> ... -> pi[n-1] -> A.

TABU SEARCH DETAILS
-------------------
  Initial solution   Nearest-neighbour greedy heuristic
                     (repeatedly visit the cheapest unvisited stop).
                     A good start reduces convergence time.

  Neighbourhood      2-opt: select two positions i < j in the tour and
                     reverse the sub-sequence pi[i..j].
                     Each 2-opt move is identified by (i, j).

  Tabu list T        Stores recently made (i, j) swap pairs.
                     Task 2a: plain set, unbounded (moves never evicted).
                     Task 2b: fixed-size FIFO deque of size max(7, N).

  Aspiration         A tabu move is accepted anyway if the resulting tour is
                     better than the globally best known tour s*.
                     This prevents the tabu list from blocking genuine improvements.

  Stop condition     Run for STEP_LIMIT outer iterations.  Inner loop tries
                     all neighbour pairs (sampling option).
"""

from typing import Dict, List, Optional, Tuple
import random
from collections import deque
from pathfinding import astar_time, astar_transfers
from transit_graph import TransitGraph
from gtfs_loader import seconds_to_str


# ---------------------------------------------------------------------------
# Stage 1 - Pairwise shortest paths
# ---------------------------------------------------------------------------

def compute_pairwise_costs(graph: TransitGraph,
                            stops_list: List[str],
                            start_time: int,
                            criterion: str) -> Tuple[dict, dict]:
    """
    For every ordered pair (A, B) in stops_list x stops_list (A != B),
    compute the minimum cost path using the chosen algorithm.

    Args:
        graph       - the built TransitGraph
        stops_list  - all stops we need to connect (includes the start depot)
        start_time  - departure time in seconds (used for the first leg)
        criterion   - 't' = travel time, 'p' = transfers

    Returns:
        cost_matrix[i][j] - minimum cost from stops_list[i] to stops_list[j]
        path_matrix[i][j] - list of leg-dicts for that journey

    Note on time-dependence
    -----------------------
    In a fully time-dependent model the cost from i to j depends on *when*
    we depart i, which changes dynamically during the tour.  Computing all
    (i,j) costs from a fixed start_time is an approximation that is standard
    practice in the literature for TSP on public transport.
    For higher accuracy one could re-run A* at each step of the Tabu Search
    with the actual departure time, at the cost of much longer runtime.
    """
    cost_matrix: Dict[tuple, float] = {}
    path_matrix: Dict[tuple, list] = {}

    algo = astar_time if criterion == "t" else astar_transfers

    for i, src in enumerate(stops_list):
        for j, dst in enumerate(stops_list):
            if i == j:
                cost_matrix[(i, j)] = 0
                path_matrix[(i, j)] = []
                continue

            cost, legs, _ = algo(graph, src, dst, start_time)

            if cost is None:
                # No connection found - assign a very high penalty
                cost_matrix[(i, j)] = float("inf")
                path_matrix[(i, j)] = []
            else:
                cost_matrix[(i, j)] = cost
                path_matrix[(i, j)] = legs

    return cost_matrix, path_matrix


# ---------------------------------------------------------------------------
# Stage 2 - Tabu Search core
# ---------------------------------------------------------------------------

def _tour_cost(perm: List[int], cost_matrix: dict) -> float:
    """
    Evaluate the total cost of a tour given a permutation of stop indices.

    Tour: depot(0) -> perm[0] -> perm[1] -> ... -> perm[-1] -> depot(0)
    Cost: sum of cost_matrix[(from, to)] for each consecutive pair.
    """
    n = len(perm)
    total = cost_matrix[(0, perm[0])]           # depot -> first stop
    for k in range(n - 1):
        total += cost_matrix[(perm[k], perm[k + 1])]
    total += cost_matrix[(perm[-1], 0)]         # last stop -> depot
    return total


def _two_opt_swap(perm: List[int], i: int, j: int) -> List[int]:
    """
    Produce a new permutation by reversing the sub-sequence perm[i..j].

    This is the standard 2-opt neighbourhood move for TSP.  It effectively
    removes two edges of the tour and reconnects them in the only other way
    possible, which may yield a shorter total path.
    """
    new_perm = perm[:i] + perm[i:j + 1][::-1] + perm[j + 1:]
    return new_perm


def _nearest_neighbour_init(n_stops: int, cost_matrix: dict) -> List[int]:
    """
    Greedy nearest-neighbour heuristic to build an initial tour.

    Starting from the depot (index 0), repeatedly move to the cheapest
    unvisited stop. The result is usually a reasonably good starting point
    for Tabu Search, reducing the number of iterations needed.
    """
    unvisited = list(range(1, n_stops)) # indices 1..n (depot = 0)
    current = 0
    tour = []
    while unvisited:
        best_next = min(unvisited, key=lambda j: cost_matrix.get((current, j), float("inf")))
        tour.append(best_next)
        unvisited.remove(best_next)
        current = best_next
    return tour


def tabu_search(cost_matrix: dict,
                n_stops: int,
                tabu_size: Optional[int] = None,
                step_limit: int = 200,
                use_aspiration: bool = True,
                sampling: bool = False,
                sample_size: int = 20) -> Tuple[List[int], float, list]:
    """
    Knox-style Tabu Search for the transit TSP.

    TASK MAPPING
    ------------
    2a  tabu_size=None  -> T is an UNBOUNDED set. Moves are added but never
                           evicted. This is the base implementation. Every
                           accepted move is permanently forbidden, guaranteeing
                           the algorithm never revisits the exact same solution.
                           Memory grows by 1 entry per iteration.

    2b  tabu_size=N     -> T is a bounded FIFO deque of size max(7, N).
                           Older moves are evicted so the search can revisit
                           areas explored long ago (more exploration freedom).

    2c  use_aspiration  -> Even if (i,j) in T, accept the move if its neighbour
                           solution beats the global best s*. Prevents the tabu
                           list from blocking genuine improvements.

    2d  sampling=True   -> Draw a random subset of sample_size 2-opt pairs per
                           iteration instead of evaluating all O(n^2) pairs.
                           Trades quality-per-step for speed.

    Parameters
    ----------
    cost_matrix    - precomputed pairwise costs (from compute_pairwise_costs)
    n_stops        - total stops including depot (= len(stops_list))
    tabu_size      - None -> Task 2a: unbounded T (plain set, never clears)
                    int N -> Task 2b: bounded FIFO deque of size max(7, N)
    step_limit     - outer iteration budget
    use_aspiration - Task 2c: accept tabu moves that beat global best
    sampling       - Task 2d: randomly sample neighbours instead of all
    sample_size    - number of neighbours to sample when sampling=True

    Returns
    -------
    (best_perm, best_cost, history)
    """
    n_cities = n_stops - 1 # number of stops to visit (excluding depot)

    # Step 1: initial solution (nearest-neighbour greedy)
    s = _nearest_neighbour_init(n_stops, cost_matrix)
    best_s = s[:]
    best_cost = _tour_cost(s, cost_matrix)
    current_cost = best_cost

    # Step 2: initialise tabu list T
    #
    # TASK 2a (tabu_size=None): UNBOUNDED T
    # --------------------------------------
    # T is a plain Python set. Every accepted move (i,j) is added permanently.
    # No move is ever evicted. This means:
    #   - The algorithm can never revisit a previously-visited solution.
    #   - T grows by one entry per iteration.
    #   - The search becomes increasingly constrained; eventually most moves
    #     are forbidden and only aspiration overrides or skipped iterations occur.
    # This is the correct base behaviour specified in Task 2a.
    #
    # TASK 2b (tabu_size=int): BOUNDED FIFO DEQUE
    # ---------------------------------------------
    # T is a deque(maxlen=max(7, tabu_size)).
    # Python automatically evicts the oldest entry when the deque is full.
    # This allows moves made more than tabu_size steps ago to become legal again,
    # giving the algorithm more freedom to escape local optima over long runs.

    if tabu_size is None:
        # Task 2a: unbounded - use a set for O(1) lookup
        T_set: set = set()
        T_deque: Optional[deque] = None

        def _in_tabu(move: tuple) -> bool:
            i, j = move
            return move in T_set or (j, i) in T_set # order-independent check

        def _add_tabu(move: tuple) -> None:
            T_set.add(move)

    else:
        # Task 2b: bounded FIFO deque -> max(7, L) to ensure some minimum memory even for small L values
        effective_size = max(7, tabu_size) # WHY 7? -> Long enough to escape local cycles, short enough that most of the neighbourhood remains explorable
        T_deque = deque(maxlen=effective_size)

        def _in_tabu(move: tuple) -> bool:
            i, j = move
            return move in T_deque or (j, i) in T_deque

        def _add_tabu(move: tuple) -> None:
            T_deque.append(move)

    history = [(0, best_cost)]

    # Step 3: main Tabu Search loop
    for k in range(step_limit):

        # Step 3a: generate neighbourhood N(s) as all 2-opt swap pairs
        all_pairs = [(i, j) for i in range(n_cities - 1)
                             for j in range(i + 1, n_cities)]

        # Task 2d - sampling: evaluate a random subset instead of all O(n^2)
        if sampling and len(all_pairs) > sample_size:
            pairs_to_try = random.sample(all_pairs, sample_size)
        else: # Normal case: evaluate all pairs
            pairs_to_try = all_pairs

        best_candidate = None
        best_candidate_cost = float("inf")
        best_move = None

        for (i, j) in pairs_to_try:
            candidate = _two_opt_swap(s, i, j)
            c_cost = _tour_cost(candidate, cost_matrix)
            move = (i, j)

            if _in_tabu(move):
                # Task 2c - aspiration: override tabu if this beats global best
                if use_aspiration and c_cost < best_cost:
                    if c_cost < best_candidate_cost:
                        best_candidate = candidate
                        best_candidate_cost = c_cost
                        best_move = move
            else:
                # Non-tabu: valid candidate
                if c_cost < best_candidate_cost:
                    best_candidate = candidate
                    best_candidate_cost = c_cost
                    best_move = move

        # Step 3b: no valid candidate - all moves tabu, aspiration did not fire
        if best_candidate is None:
            history.append((k + 1, current_cost))
            continue

        # Step 3d: move to best candidate
        s = best_candidate
        current_cost = best_candidate_cost

        # Step 3c: record the move as tabu
        if best_move is not None:
            _add_tabu(best_move)

        # Step 3e: update global best
        if current_cost < best_cost:
            best_cost = current_cost
            best_s = s[:]

        history.append((k + 1, current_cost))

    return best_s, best_cost, history


# ---------------------------------------------------------------------------
# High-level runner called by task2.py
# ---------------------------------------------------------------------------

def solve_tsp(graph: TransitGraph,
              depot: str,
              waypoints: List[str],
              start_time: int,
              criterion: str,
              tabu_size: Optional[int] = None,
              step_limit: int = 300,
              use_aspiration: bool = True,
              sampling: bool = False) -> tuple:
    """
    End-to-end solver for Task 2.

    tabu_size=None  -> Task 2a: unbounded T (plain set, moves never evicted)
    tabu_size=N     -> Task 2b: bounded FIFO deque of size max(7, N)

    Stage 1: precompute all n*(n-1) pairwise A* paths (fixed start_time).
             Used by Tabu Search as a static cost matrix for ordering decisions.
    Stage 2: Tabu Search finds the best ordering (permutation) of waypoints.
    Stage 3: Re-route each leg sequentially using the real clock time,
             so all displayed departure/arrival times are causally correct.
    """
    all_stops = [depot] + waypoints
    n = len(all_stops)

    if tabu_size is None:
        tabu_label = "unbounded (Task 2a)"
    else:
        tabu_label = f"max(7,{tabu_size})={max(7,tabu_size)} (Task 2b)"

    # -- Stage 1: precompute all pairwise shortest paths -----------------------
    print(f"  [TSP] Stage 1: precomputing {n*(n-1)} pairwise paths ...", flush=True)
    cost_matrix, path_matrix = compute_pairwise_costs(
        graph, all_stops, start_time, criterion
    )

    # Warn about stops that have no rail connection on this date
    unreachable = []
    for idx, sid in enumerate(all_stops):
        outbound = any(cost_matrix.get((idx, j), float("inf")) < float("inf")
                       for j in range(n) if j != idx)
        inbound  = any(cost_matrix.get((i, idx), float("inf")) < float("inf")
                       for i in range(n) if i != idx)
        if not outbound or not inbound:
            name = graph.stops.get(sid, {}).get("name", sid)
            reason = "no outbound rail" if not outbound else "no inbound rail"
            unreachable.append((idx, sid, name, reason))

    if unreachable:
        print(f"\n  [TSP] WARNING: {len(unreachable)} stop(s) have no rail connection "
              f"in the graph on this date:", flush=True)
        for idx, sid, name, reason in unreachable:
            print(f"    [{idx}] {name}  (id: {sid})  <- {reason}", flush=True)
        print(f"  [TSP] These stops will produce an inf tour cost. "
              f"Check the stop ID or try a different date.\n", flush=True)

    # -- Stage 2: Tabu Search over waypoint permutations ----------------------
    print(f"  [TSP] Stage 2: Tabu Search  steps={step_limit}  "
          f"|T|={tabu_label}  aspiration={use_aspiration}  "
          f"sampling={sampling} ...", flush=True)
    best_perm, _, _ = tabu_search(
        cost_matrix,
        n_stops=n,
        tabu_size=tabu_size,
        step_limit=step_limit,
        use_aspiration=use_aspiration,
        sampling=sampling,
    )

    # -- Stage 3: Sequential re-routing with real departure times -------------
    #
    # WHY THE PRECOMPUTED paths ARE WRONG FOR DISPLAY
    # ------------------------------------------------
    # compute_pairwise_costs runs every A* query from the same fixed start_time.
    # That gives correct *costs* for the Tabu Search cost matrix (standard TSP
    # approximation), but the *legs* would show departures like 08:10 for a stop
    # you only reach at 11:55 — causally impossible.
    #
    # THE FIX: re-run A* for each leg in sequence using the actual clock time
    # at which the previous leg finishes. This gives correct departure/arrival
    # times throughout the displayed journey.

    DAY = 86400   # seconds in one day

    algo = astar_time if criterion == "t" else astar_transfers

    ordered_indices = [0] + best_perm + [0]
    ordered_stops   = [all_stops[i] for i in ordered_indices]

    full_legs:  list  = []
    true_cost:  float = 0.0
    curr_time:  int   = start_time   # real clock time advances as we travel

    print(f"  [TSP] Stage 3: re-routing {len(ordered_indices)-1} legs with real times ...",
          flush=True)

    for step, (a_idx, b_idx) in enumerate(zip(ordered_indices[:-1], ordered_indices[1:])):
        src_stop  = all_stops[a_idx]
        dst_stop  = all_stops[b_idx]
        day_offset = (curr_time // DAY) * DAY   # 0, 86400, 172800, …

        # First try from the actual curr_time (handles GTFS times > 24:00)
        cost, legs, _ = algo(graph, src_stop, dst_stop, curr_time)

        # If no connection found and we are past midnight, wrap to time-of-day
        # and search again.  The cost arithmetic is unchanged (see note above).
        if (cost is None or cost == float("inf")) and curr_time >= DAY:
            time_of_day = curr_time % DAY
            cost, legs, _ = algo(graph, src_stop, dst_stop, time_of_day)
            if cost is not None and cost != float("inf"):
                # Adjust day_offset: the leg now belongs to the next logical day
                day_offset += DAY
                stop_name = graph.stops.get(dst_stop, {}).get("name", dst_stop)
                print(f"  [TSP] INFO: leg {step+1} to '{stop_name}' wraps to next day "
                      f"(search from {seconds_to_str(time_of_day)})", flush=True)

        if cost is None or cost == float("inf"):
            stop_name = graph.stops.get(dst_stop, {}).get("name", dst_stop)
            print(f"  [TSP] WARNING: no connection on leg {step+1} to '{stop_name}' "
                  f"departing at {seconds_to_str(curr_time)}", flush=True)
            true_cost = float("inf")
            continue

        full_legs.extend(legs)
        true_cost += cost

        # Advance clock to the real arrival time of the last leg.
        # GTFS legs already use >24:00 notation when crossing midnight, so we
        # can read the arrival time directly and it will be numerically correct.
        if legs:
            arr_str = legs[-1].get("arrival", "")
            if arr_str:
                parts = arr_str.split(":")
                try:
                    arr_secs = int(parts[0])*3600 + int(parts[1])*60 + int(parts[2])
                    # If we wrapped, the arrival is relative to the new day
                    if arr_secs < curr_time % DAY:
                        arr_secs += DAY
                    curr_time = day_offset + arr_secs
                except (ValueError, IndexError):
                    curr_time += int(cost) if criterion == "t" else 0
            else:
                curr_time += int(cost) if criterion == "t" else 0

    return ordered_stops, true_cost, full_legs