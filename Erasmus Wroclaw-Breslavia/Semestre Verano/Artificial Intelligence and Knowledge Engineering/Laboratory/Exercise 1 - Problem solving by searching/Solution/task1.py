"""
task1.py  -  Task 1 entry point
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
================================
Implement an algorithm searching for shortest paths between given 
stops A and B. As a cost function use (depending on the user's decision)
travel time from A to B or the number of transfers needed.

USAGE
-----
    python task1.py <start_stop> <end_stop> <criterion> <start_time> [options]

ARGUMENTS
---------
    start_stop   Name (or partial name) of the departure stop.
    end_stop     Name (or partial name) of the destination stop.
    criterion    't'  ->  minimise total travel time
                 'p'  ->  minimise number of line transfers
    start_time   Departure time in HH:MM format (e.g. 08:30).

OPTIONS
-------
    --algo dijkstra    Use Dijkstra's algorithm (only for criterion 't').
    --algo astar       Use A* algorithm [default].
    --gtfs DIR         Path to the directory containing GTFS .txt files
                       [default: ./gtfs].
    --date YYYYMMDD    Service date [default: 20260303].

OUTPUT
------
    stdout:  One line per journey leg:
             <from_stop>  <to_stop>  <line>  <departure>  <arrival>
    stderr:  Minimised criterion value and computation time.

EXAMPLES
--------
    python task1.py "Wrocław Główny" "Jelenia Góra" t 08:00
    python task1.py "Wrocław" 1475088 p 07:30 --algo astar
"""

from typing import List
import sys
import time
import argparse

from gtfs_loader import GTFSLoader, seconds_to_str
from transit_graph import TransitGraph, build_reverse_graph
from pathfinding import dijkstra_time, astar_time, astar_transfers, astar_time_bidirectional


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def parse_time(time_str: str) -> int:
    """Convert 'HH:MM' or 'HH:MM:SS' to seconds-from-midnight."""
    parts = time_str.strip().split(":")
    h, m = int(parts[0]), int(parts[1])
    s = int(parts[2]) if len(parts) > 2 else 0
    return h * 3600 + m * 60 + s

def is_integer(s):
    try:
        int(s)
        return True
    except ValueError:
        return False

def find_stop(stops: dict, query: str) -> List[tuple]:
    """
    Case-insensitive partial-match search for a stop by name.

    Returns a list of (stop_id, stop_dict) pairs.
    We prefer stops with location_type == 0 (platforms) since those have
    actual timetable connections.  Parent stations (type 1) are included as
    fallback because the user may type the station name rather than a platform.
    """
    q = query.lower().strip()
    if is_integer(q):
        # If the query is a number, try to match stop_id directly
        sid = str(q)
        if sid in stops:
            return [(sid, stops[sid])]
        else:
            return []
    matches = [(sid, s) for sid, s in stops.items()
               if q in s["name"].lower()]
    # Prefer platforms over parent stations
    platforms   = [(sid, s) for sid, s in matches if s["location_type"] == 0]
    parents     = [(sid, s) for sid, s in matches if s["location_type"] == 1]
    return platforms if platforms else parents


def pick_stop(stops: dict, query: str, label: str) -> str:
    """
    Interactive stop selection: if the query matches multiple stops, let the
    user choose.  Raises SystemExit if nothing is found.
    """
    candidates = find_stop(stops, query)
    if not candidates:
        print(f"ERROR: No stop found matching '{query}'.", file=sys.stderr)
        sys.exit(1)
    if len(candidates) == 1:
        return candidates[0][0]

    # Multiple matches - ask the user
    print(f"\nMultiple stops match '{query}' for {label}:")
    for idx, (sid, s) in enumerate(candidates[:20]):
        print(f"  [{idx}] {s['name']}  (id: {sid})")
    while True:
        choice = input("Enter number: ").strip()
        if choice.isdigit() and 0 <= int(choice) < len(candidates):
            break
        print("Invalid choice. Please try again.")
    return candidates[int(choice)][0]


def print_path(legs: List[dict]):
    """Print journey legs to stdout in the required format."""
    if not legs:
        print("(no legs - already at destination)")
        return
    # Header
    print(f"{'FROM':<35} {'TO':<35} {'LINE':<12} {'DEP':>8} {'ARR':>8}")
    print("-" * 105)
    for leg in legs:
        print(f"{leg['from_name']:<35} {leg['to_name']:<35} "
              f"{leg['line']:<12} {leg['departure']:>8} {leg['arrival']:>8}")


def print_summary(criterion: str, cost, calc_time: float, nodes: int):
    """Print minimised criterion and timing info to stderr."""
    if criterion == "t":
        h = cost // 3600
        m = (cost % 3600) // 60
        s = cost % 60
        val_str = f"{h}h {m}m {s}s  ({cost} seconds)"
        label = "Travel time"
    else:
        val_str = f"{cost} transfer(s)"
        label = "Transfers"
    print(f"{label}: {val_str}", file=sys.stderr)
    print(f"Calculation time: {calc_time:.3f} s  |  Nodes explored: {nodes}",
          file=sys.stderr)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Transit shortest-path finder (Task 1)")
    parser.add_argument("start_stop",   help="Name of the departure stop")
    parser.add_argument("end_stop",     help="Name of the destination stop")
    parser.add_argument("criterion",    choices=["t", "p"],
                        help="'t' = travel time, 'p' = transfers")
    parser.add_argument("start_time",   help="Departure time HH:MM or HH:MM:SS")
    parser.add_argument("--algo",       choices=["dijkstra", "astar", "bidir"],
                        default="astar",
                        help="Search algorithm (default: astar)")
    parser.add_argument("--gtfs",       default="./gtfs",
                        help="Path to GTFS directory (default: ./gtfs)")
    parser.add_argument("--date",       default="20260303",
                        help="Service date YYYYMMDD (default: 20260303)")
    args = parser.parse_args()

    # ------------------------------------------------------------------
    # Step 1: Load GTFS data
    # ------------------------------------------------------------------
    print(f"Loading GTFS data from '{args.gtfs}' for date {args.date} …",
          file=sys.stderr)
    loader = GTFSLoader(args.gtfs)
    loader.load(date_str=args.date)
    print(f"  Stops: {len(loader.stops)}  |  Active trips: "
          f"{sum(1 for t in loader.trips.values() if t['service_id'] in loader.active_services)}",
          file=sys.stderr)

    # ------------------------------------------------------------------
    # Step 2: Build transit graph
    # ------------------------------------------------------------------
    print("Building transit graph …", file=sys.stderr)
    graph = TransitGraph(loader)
    graph.build()
    total_edges = sum(len(v) for v in graph.edges.values())
    print(f"  Edges: {total_edges}", file=sys.stderr)

    # ------------------------------------------------------------------
    # Step 3: Resolve stop names
    # ------------------------------------------------------------------
    start_id = pick_stop(loader.stops, args.start_stop, "START")
    end_id   = pick_stop(loader.stops, args.end_stop,   "END")
    start_sec = parse_time(args.start_time)

    print(f"\nRouting: {loader.stops[start_id]['name']}  ->  "
          f"{loader.stops[end_id]['name']}", file=sys.stderr)
    print(f"Depart after: {seconds_to_str(start_sec)}  |  "
          f"Criterion: {'travel time' if args.criterion=='t' else 'transfers'}  |  "
          f"Algorithm: {args.algo}", file=sys.stderr)

    # ------------------------------------------------------------------
    # Step 4: Run the chosen algorithm
    # ------------------------------------------------------------------
    t0 = time.perf_counter()

    if args.criterion == "t":
        if args.algo == "dijkstra":
            # Task 1a: Dijkstra minimising travel time
            cost, legs, nodes = dijkstra_time(graph, start_id, end_id, start_sec)
        elif args.algo == "bidir":
            # Task 1d: Bidirectional A* minimising travel time
            # Build the reverse graph once and pass it in.
            print("Building reverse graph for bidirectional search ...",
                  file=sys.stderr)
            rev_graph = build_reverse_graph(graph)
            cost, legs, nodes = astar_time_bidirectional(
                graph, rev_graph, start_id, end_id, start_sec
            )
        else:
            # Task 1b: A* minimising travel time
            cost, legs, nodes = astar_time(graph, start_id, end_id, start_sec)
    else:
        # Task 1c: A* minimising transfers (criterion 'p')
        # Dijkstra is not requested for this criterion in the spec, so we
        # always use A* (with h=0, equivalent to Dijkstra on (transfers, time)).
        cost, legs, nodes = astar_transfers(graph, start_id, end_id, start_sec)

    calc_time = time.perf_counter() - t0

    # ------------------------------------------------------------------
    # Step 5: Output results
    # ------------------------------------------------------------------
    if cost is None:
        print("No path found between the given stops on this date.", file=sys.stderr)
        sys.exit(1)

    print_path(legs)
    print_summary(args.criterion, cost, calc_time, nodes)


if __name__ == "__main__":
    main()
