"""
transit_graph.py
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
================
Builds a directed, time-dependent transit graph from the loaded GTFS data.

GRAPH STRUCTURE
---------------
  Nodes  ->  stop_id strings (one node per platform / stop in stops.txt)
  Edges  ->  stored as a dict:  edges[stop_id] = List[Edge]

TWO TYPES OF EDGES
------------------
  1. Trip edge  -  a train runs from stop A to stop B on trip T,
                   departing at time D and arriving at time R.
     {type:"trip", to, departure, arrival, line, trip_id}

  2. Transfer edge  -  a passenger walks between two platforms of the
                       same physical station (same parent_station).
                       Costs a fixed minimum transfer time (default 3 min).
     {type:"transfer", to, transfer_time, line:"TRANSFER", trip_id:None}

HEURISTIC SUPPORT
-----------------
  The graph stores stop coordinates so A* can compute geographical
  distance estimates via the Haversine formula.
"""

from typing import Dict, List
import math
from collections import defaultdict
from gtfs_loader import GTFSLoader

# Minimum time to walk between two platforms of the same station [seconds]
DEFAULT_TRANSFER_TIME = 3 * 60   # 3 minutes

# Assumed maximum train speed for the A* heuristic [m/s]
# 160 km/h is a safe upper bound for regional rail (Koleje Dolnośląskie tops ~120)
MAX_TRAIN_SPEED_MS = 160_000 / 3600   # ≈ 44.4 m/s


class TransitGraph:
    """
    Container for the time-dependent transit graph.

    Build steps:
        graph = TransitGraph(loader)
        graph.build()          # constructs all edges

    Then pass `graph` to the pathfinding functions.
    """

    def __init__(self, loader: GTFSLoader):
        self.loader = loader
        self.stops = loader.stops          # convenient alias

        # edges[stop_id] -> list of edge-dicts (see module docstring)
        # After build() each list is sorted by departure time for fast lookup.
        self.edges: Dict[str, list] = defaultdict(list)

    # ------------------------------------------------------------------
    # Build
    # ------------------------------------------------------------------

    def build(self):
        """Construct trip edges then transfer edges."""
        self._build_trip_edges()
        self._build_transfer_edges()
        self._sort_edges()

    def _build_trip_edges(self):
        """
        For each consecutive pair of stops within a trip, create one directed
        trip edge:  stop_i  ->  stop_{i+1}

        We only add the edge if:
          - The trip's service_id is active on the requested date.
          - The boarding stop allows pickup (pickup_type != 1).
        """
        active = self.loader.active_services

        for trip_id, stop_seq in self.loader.stop_times.items():
            trip = self.loader.trips[trip_id]

            # Skip trips not running today
            if trip["service_id"] not in active:
                continue

            route  = self.loader.routes[trip["route_id"]]
            line   = route["name"]

            for i in range(len(stop_seq) - 1):
                curr = stop_seq[i]
                nxt  = stop_seq[i + 1]

                # Skip: no pickup possible at this stop
                if curr["pickup_type"] == 1:
                    continue

                self.edges[curr["stop_id"]].append({
                    "type":      "trip",
                    "to":        nxt["stop_id"],
                    "departure": curr["departure"],   # when we leave curr
                    "arrival":   nxt["arrival"],      # when we arrive at nxt
                    "line":      line,
                    "trip_id":   trip_id,
                })

    def _build_transfer_edges(self):
        """
        Group all platforms by their parent station, then create bidirectional
        transfer edges between every pair of platforms within the same station.

        Stops without a parent_station are treated as their own parent (so a
        single-platform station gets no transfer edges, which is correct).
        """
        # Map  parent_id -> [child_stop_ids]
        station_platforms: Dict[str, List[str]] = defaultdict(list)
        for stop_id, stop in self.stops.items():
            parent = stop["parent_station"] or stop_id
            station_platforms[parent].append(stop_id)

        for _parent, platforms in station_platforms.items():
            if len(platforms) < 2:
                continue   # nothing to connect
            for s1 in platforms:
                for s2 in platforms:
                    if s1 == s2:
                        continue
                    self.edges[s1].append({
                        "type":          "transfer",
                        "to":            s2,
                        "transfer_time": DEFAULT_TRANSFER_TIME,
                        "line":          "TRANSFER",
                        "trip_id":       None,
                    })

    def _sort_edges(self):
        """
        Sort trip edges by departure time for each stop.

        Benefit: during pathfinding we can binary-search for the first
        departure >= current_arrival_time, skipping all earlier ones efficiently.
        Transfer edges are appended at the end (they have no departure time).
        """
        for stop_id in self.edges:
            trip_edges     = [e for e in self.edges[stop_id] if e["type"] == "trip"]
            transfer_edges = [e for e in self.edges[stop_id] if e["type"] == "transfer"]
            trip_edges.sort(key=lambda e: e["departure"])
            self.edges[stop_id] = trip_edges + transfer_edges

    # ------------------------------------------------------------------
    # Heuristic helpers for A*
    # ------------------------------------------------------------------

    def haversine(self, stop_a: str, stop_b: str) -> float:
        """
        Great-circle distance in metres between two stops.

        Used by A* as h(n): the straight-line distance divided by the maximum
        possible train speed gives a lower bound on remaining travel time,
        making the heuristic admissible (it never overestimates).
        """
        sa = self.stops[stop_a]
        sb = self.stops[stop_b]
        return _haversine_m(sa["lat"], sa["lon"], sb["lat"], sb["lon"])

    def heuristic_time(self, stop_id: str, goal_id: str) -> float:
        """Lower-bound estimate of travel time [seconds] from stop_id to goal."""
        return self.haversine(stop_id, goal_id) / MAX_TRAIN_SPEED_MS


def build_reverse_graph(graph: "TransitGraph") -> Dict[str, List[dict]]:
    """
    Build a time-agnostic reverse adjacency list for the backward A* pass.

    WHY WE NEED A REVERSE GRAPH
    ----------------------------
    The backward A* searches *from the goal towards the start*, so it needs
    to traverse edges in the opposite direction.

    Original forward edge:  A --[dep d, arr a]--> B
    Reversed edge:          B --[travel_time = a-d]--> A

    WHY TIME-AGNOSTIC?
    ------------------
    A fully time-dependent backward search would require working with
    "latest departure time" rather than "earliest arrival time".  That is
    significantly more complex and the benefit is marginal for the small
    Koleje Dolnośląskie network (A* already explores very few nodes).

    Instead we use the *static travel time* of each edge (arrival - departure)
    as the cost.  This gives an optimistic estimate of how long the backward
    portion takes, which is acceptable for demonstrating the algorithm.

    EDGE STRUCTURE
    --------------
    Each reversed edge stores:
      - "to":          the stop we move to (the original edge's source)
      - "travel_time": static cost = original (arrival - departure) in seconds
      - "orig":        a copy of the original forward edge enriched with
                       from_stop and to_stop so it can be used directly in
                       path reconstruction without further lookups

    Returns
    -------
    A plain dict  stop_id -> list[reversed_edge_dict]
    (not a TransitGraph object, since we only need the adjacency list)
    """
    rev: Dict[str, List[dict]] = defaultdict(list)

    for stop_id, edges in graph.edges.items():
        for edge in edges:
            if edge["type"] == "trip":
                # Static travel time = scheduled ride time (no waiting component)
                travel_time = max(1, edge["arrival"] - edge["departure"])
                rev[edge["to"]].append({
                    "type":        "trip_rev",
                    "to":          stop_id,          # reversed direction
                    "travel_time": travel_time,
                    # Full original edge for path reconstruction
                    "orig": {
                        **edge,
                        "from_stop": stop_id,
                        "to_stop":   edge["to"],
                    },
                })

            elif edge["type"] == "transfer":
                rev[edge["to"]].append({
                    "type":        "transfer_rev",
                    "to":          stop_id,
                    "travel_time": edge["transfer_time"],
                    "orig": {
                        **edge,
                        "from_stop": stop_id,
                        "to_stop":   edge["to"],
                        # departure/arrival are dynamic; placeholders used here
                        "departure": 0,
                        "arrival":   edge["transfer_time"],
                    },
                })

    return dict(rev)


def _haversine_m(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Haversine formula - returns distance in metres between two WGS84 points.

    The Haversine formula accounts for the Earth's curvature without needing
    complex map projections. Accuracy is sufficient for distances up to ~500 km.

    Formula:
        a = sin²(Δlat/2) + cos(lat1)·cos(lat2)·sin²(Δlon/2)
        d = 2·R·arcsin(√a)
    where R = 6 371 000 m (mean Earth radius).
    """
    R = 6_371_000.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))