"""
task2.py  -  Task 2 entry point
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
================================
Find the shortest round-trip from stop A that visits every stop in list L
and returns to A, using Tabu Search.

USAGE
-----
    python task2.py <start_stop> <stops_list> <criterion> <start_time> [options]

ARGUMENTS
---------
    start_stop    Name of the starting (and returning) stop A.
    stops_list    Semicolon-separated list of stops to visit: "B;C;D".
    criterion     't'  ->  minimise total travel time
                  'p'  ->  minimise number of line transfers
    start_time    Departure time HH:MM or HH:MM:SS.

OPTIONS
-------
    --gtfs DIR         GTFS directory [default: ./gtfs].
    --date YYYYMMDD    Service date [default: 20260303].
    --tabu-size N      Fixed tabu list size (Task 2b).  Default: auto (max(7,n)).
    --steps N          Number of Tabu Search iterations [default: 300].
    --no-aspiration    Disable aspiration criterion (Task 2c off).
    --sampling         Enable random neighbour sampling (Task 2d).
    --sample-size N    How many neighbours to sample [default: 20].

OUTPUT
------
    stdout:  Full journey legs for the best tour found.
    stderr:  Minimised criterion, tour order, and computation time.

EXAMPLES
--------
    python task2.py "Wrocław Główny" "Legnica;Jelenia Góra;Zgorzelec" t 08:00
    python task2.py "Wrocław Główny" "Lubin;Polkowice" p 09:00 --steps 500
"""

import sys
import time
import argparse

from gtfs_loader import GTFSLoader, seconds_to_str
from transit_graph import TransitGraph
from tabu_search import solve_tsp
from task1 import parse_time, find_stop, pick_stop, print_path


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Transit TSP solver (Task 2)")
    parser.add_argument("start_stop",  help="Starting and ending stop A")
    parser.add_argument("stops_list",  help="Stops to visit, separated by ';'")
    parser.add_argument("criterion",   choices=["t", "p"],
                        help="'t' = travel time, 'p' = transfers")
    parser.add_argument("start_time",  help="Departure time HH:MM or HH:MM:SS")
    parser.add_argument("--gtfs",          default="./gtfs")
    parser.add_argument("--date",          default="20260303")
    parser.add_argument("--tabu-size",     type=int, default=None,
                        help="Task 2b: bounded tabu list size (uses max(7,N)). "
                             "Default: None = Task 2a unbounded T (set, never clears).")
    parser.add_argument("--steps",         type=int, default=300,
                        help="Tabu Search iterations [default: 300]")
    parser.add_argument("--no-aspiration", action="store_true",
                        help="Disable aspiration criterion (Task 2c disabled).")
    parser.add_argument("--sampling",      action="store_true",
                        help="Enable random neighbour sampling (Task 2d).")
    parser.add_argument("--sample-size",   type=int, default=20)
    args = parser.parse_args()

    # ------------------------------------------------------------------
    # Step 1: Load GTFS
    # ------------------------------------------------------------------
    print(f"Loading GTFS from '{args.gtfs}' for date {args.date} …",
          file=sys.stderr)
    loader = GTFSLoader(args.gtfs)
    loader.load(date_str=args.date)

    # ------------------------------------------------------------------
    # Step 2: Build graph
    # ------------------------------------------------------------------
    print("Building transit graph …", file=sys.stderr)
    graph = TransitGraph(loader)
    graph.build()

    # ------------------------------------------------------------------
    # Step 3: Resolve stop names
    # ------------------------------------------------------------------
    depot_id = pick_stop(loader.stops, args.start_stop, "START (depot)")

    waypoint_ids = []
    for name in args.stops_list.split(";"):
        name = name.strip()
        if name:
            wid = pick_stop(loader.stops, name, f"WAYPOINT '{name}'")
            waypoint_ids.append(wid)

    if not waypoint_ids:
        print("ERROR: stops_list is empty.", file=sys.stderr)
        sys.exit(1)

    start_sec = parse_time(args.start_time)

    depot_name = loader.stops[depot_id]["name"]
    waypoint_names = [loader.stops[w]["name"] for w in waypoint_ids]

    print(f"\nTSP Tour:", file=sys.stderr)
    print(f"  Depot   : {depot_name}", file=sys.stderr)
    print(f"  Waypoints: {' -> '.join(waypoint_names)}", file=sys.stderr)
    print(f"  Criterion: {'travel time' if args.criterion=='t' else 'transfers'}",
          file=sys.stderr)
    print(f"  Start time: {seconds_to_str(start_sec)}", file=sys.stderr)
    tabu_desc = "unbounded/Task 2a" if args.tabu_size is None else f"{args.tabu_size}/Task 2b"
    print(f"  Tabu size: {tabu_desc}  |  Steps: {args.steps}  |  "
          f"Aspiration: {not args.no_aspiration}  |  Sampling: {args.sampling}",
          file=sys.stderr)

    # ------------------------------------------------------------------
    # Step 4: Run Tabu Search
    # ------------------------------------------------------------------
    t0 = time.perf_counter()

    ordered_stops, total_cost, full_legs = solve_tsp(
        graph        = graph,
        depot        = depot_id,
        waypoints    = waypoint_ids,
        start_time   = start_sec,
        criterion    = args.criterion,
        tabu_size    = args.tabu_size,
        step_limit   = args.steps,
        use_aspiration = not args.no_aspiration,
        sampling     = args.sampling,
    )

    calc_time = time.perf_counter() - t0

    # ------------------------------------------------------------------
    # Step 5: Output
    # ------------------------------------------------------------------
    print("\n--- Best tour found ---", file=sys.stderr)
    ordered_names = [loader.stops[s]["name"] for s in ordered_stops]
    print("  " + "  ->  ".join(ordered_names), file=sys.stderr)

    print_path(full_legs)

    # Criterion value to stderr
    if args.criterion == "t":
        if total_cost == float("inf") or total_cost != total_cost:  # inf or nan
            crit_str = ("Total travel time: UNKNOWN (inf) – one or more stops "
                        "in the tour have no rail connection on this date.")
        else:
            tc = int(total_cost)
            h  = tc // 3600
            m  = (tc % 3600) // 60
            s  = tc % 60
            crit_str = f"Total travel time: {h}h {m}m {s}s ({tc} s)"
    else:
        if total_cost == float("inf"):
            crit_str = "Total transfers: UNKNOWN (inf) - unreachable stop in tour."
        else:
            crit_str = f"Total transfers: {int(total_cost)}"

    print(f"\n{crit_str}", file=sys.stderr)
    print(f"Calculation time: {calc_time:.3f} s", file=sys.stderr)


if __name__ == "__main__":
    main()
