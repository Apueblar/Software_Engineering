"""
gtfs_loader.py
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
==============
Responsible for reading and parsing all GTFS .txt files from a given directory.

GTFS (General Transit Feed Specification) is a standard format where each .txt file
is a CSV table. Files reference each other by foreign keys (e.g. trip_id, stop_id).

This loader produces simple Python dicts/lists so the rest of the code
never has to touch raw CSV again.
"""

from typing import Dict, List, Optional, Set
import csv
import os
from datetime import datetime

# ---------------------------------------------------------------------------
# Low-level helper
# ---------------------------------------------------------------------------

def _read_csv(path: str) -> List[dict]:
    """Read a CSV file and return a list of row-dicts.

    Uses 'utf-8-sig' to silently strip the BOM that some Windows tools add.
    """
    with open(path, encoding="utf-8-sig") as fh:
        return list(csv.DictReader(fh))


def _time_to_seconds(time_str: str) -> int:
    """Convert a GTFS time string 'HH:MM:SS' to integer seconds.

    GTFS times can exceed 23:59:59 to represent trips that run past midnight
    (e.g. '25:10:00' means 01:10 the next calendar day).
    We keep the raw seconds so comparisons remain correct within a service day.
    """
    h, m, s = map(int, time_str.strip().split(":"))
    return h * 3600 + m * 60 + s


def seconds_to_str(seconds: int) -> str:
    """Inverse of _time_to_seconds - returns 'HH:MM:SS' (hours may exceed 23)."""
    h = seconds // 3600
    m = (seconds % 3600) // 60
    s = seconds % 60
    return f"{h:02d}:{m:02d}:{s:02d}"


# ---------------------------------------------------------------------------
# Main loader class
# ---------------------------------------------------------------------------

class GTFSLoader:
    """
    Loads all relevant GTFS tables into memory and exposes them as clean Python
    data structures.

    Usage:
        loader = GTFSLoader("path/to/gtfs_dir")
        loader.load(date_str="20260303")
    """

    def __init__(self, gtfs_dir: str):
        self.gtfs_dir = gtfs_dir

        # Populated by load():
        self.stops: dict = {}        # stop_id  -> {name, lat, lon, location_type, parent_station}
        self.routes: dict = {}       # route_id -> {name}
        self.trips: dict = {}        # trip_id  -> {route_id, service_id}
        self.stop_times: dict = {}   # trip_id  -> sorted list of stop-time dicts
        self.active_services: set = set()   # service_ids valid on the requested date

    # ------------------------------------------------------------------
    # Public entry point
    # ------------------------------------------------------------------

    def load(self, date_str: Optional[str] = None):
        """
        Parse every relevant GTFS file.

        Args:
            date_str: Date in 'YYYYMMDD' format.  When provided, only trips
                      that run on this date are flagged as active.
        """
        self._load_stops()
        self._load_routes()
        self._load_trips()
        self._load_stop_times()

        if date_str:
            self._determine_active_services(date_str)
        else:
            # If no date given, treat ALL service_ids as active
            self.active_services = set(t["service_id"] for t in self.trips.values())

    # ------------------------------------------------------------------
    # Private parsing methods (one per GTFS file)
    # ------------------------------------------------------------------

    def _load_stops(self):
        """
        stops.txt  -  every physical stop / platform in the network.

        We distinguish:
          location_type == 1  ->  parent station (e.g. "Wrocław Główny")
          location_type == 0  ->  platform / specific boarding point
        A platform may reference its parent via parent_station.
        """
        for row in _read_csv(os.path.join(self.gtfs_dir, "stops.txt")):
            self.stops[row["stop_id"]] = {
                "name": row["stop_name"].strip(),
                "lat": float(row["stop_lat"]),
                "lon": float(row["stop_lon"]),
                "location_type": int(row.get("location_type") or 0),
                "parent_station": row.get("parent_station", "").strip(),
            }

    def _load_routes(self):
        """
        routes.txt  -  named train lines (D1, D10, …).

        The public-facing name is route_short_name if non-empty,
        otherwise route_long_name.
        """
        for row in _read_csv(os.path.join(self.gtfs_dir, "routes.txt")):
            name = (row.get("route_short_name") or "").strip() \
                or (row.get("route_long_name") or "").strip()
            self.routes[row["route_id"]] = {"name": name}

    def _load_trips(self):
        """
        trips.txt  -  individual runs of a vehicle along a route on a given day.

        Each trip belongs to exactly one route and one service calendar entry.
        """
        for row in _read_csv(os.path.join(self.gtfs_dir, "trips.txt")):
            self.trips[row["trip_id"]] = {
                "route_id": row["route_id"],
                "service_id": row["service_id"],
            }

    def _load_stop_times(self):
        """
        stop_times.txt  -  the heart of the timetable.

        For every trip, this file lists arrival / departure times at each stop
        in order.  We group rows by trip_id and sort by stop_sequence so that
        consecutive entries form direct edges in the transit graph.

        We skip stops with pickup_type == 1 (no boarding allowed).
        """
        raw: Dict[str, list] = {}

        for row in _read_csv(os.path.join(self.gtfs_dir, "stop_times.txt")):
            tid = row["trip_id"]
            if tid not in raw:
                raw[tid] = []
            raw[tid].append({
                "stop_id": row["stop_id"],
                "arrival":    _time_to_seconds(row["arrival_time"]),
                "departure":  _time_to_seconds(row["departure_time"]),
                "sequence":   int(row["stop_sequence"]),
                "pickup_type": int(row.get("pickup_type") or 0),
            })

        # Sort each trip by sequence order (ascending stop_sequence)
        for tid, stops in raw.items():
            self.stop_times[tid] = sorted(stops, key=lambda x: x["sequence"])

    def _determine_active_services(self, date_str: str):
        """
        Combine calendar.txt (weekly patterns) and calendar_dates.txt (exceptions)
        to find which service_ids are valid on the given date.

        Steps:
          1. Parse the weekday from date_str (Monday=0 … Sunday=6).
          2. For each row in calendar.txt, check if date falls within [start, end]
             and the corresponding weekday flag is '1'.
          3. Apply exceptions from calendar_dates.txt:
               exception_type 1 -> add service
               exception_type 2 -> remove service
        """
        date = datetime.strptime(date_str, "%Y%m%d")
        weekday_col = ["monday", "tuesday", "wednesday", "thursday",
                       "friday", "saturday", "sunday"][date.weekday()]

        active: Set[str] = set()

        # -- Regular weekly schedule --
        cal_path = os.path.join(self.gtfs_dir, "calendar.txt")
        if os.path.exists(cal_path):
            for row in _read_csv(cal_path):
                start = datetime.strptime(row["start_date"], "%Y%m%d")
                end   = datetime.strptime(row["end_date"],   "%Y%m%d")
                if start <= date <= end and row.get(weekday_col) == "1":
                    active.add(row["service_id"])

        # -- Date-specific exceptions override the weekly pattern --
        cal_dates_path = os.path.join(self.gtfs_dir, "calendar_dates.txt")
        if os.path.exists(cal_dates_path):
            for row in _read_csv(cal_dates_path):
                if row["date"] == date_str:
                    if row["exception_type"] == "1":
                        active.add(row["service_id"])
                    elif row["exception_type"] == "2":
                        active.discard(row["service_id"])

        self.active_services = active
