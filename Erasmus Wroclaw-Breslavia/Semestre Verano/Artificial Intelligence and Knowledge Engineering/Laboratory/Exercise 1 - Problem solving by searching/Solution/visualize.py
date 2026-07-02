"""
visualize.py
SOME COMMENTS OF THE CODE MADE BY AI and corrections by Alvaro
============
Reads the GTFS data and generates a self-contained interactive HTML map
(Leaflet.js) showing all stops and rail lines.

No extra Python packages required - only the standard library.
The output is a single HTML file you can open in any browser.

USAGE
-----
    python visualize.py                        # reads ./gtfs, writes map.html
    python visualize.py --gtfs ./gtfs --out map.html
    python visualize.py --date 20260303        # filter to a specific service day

HOW IT WORKS
------------
  1. Load stops -> Leaflet circle markers (coloured by location_type).
  2. Load routes -> each route gets the color from routes.txt (or a fallback).
  3. For each trip on the chosen date, extract the ordered stop sequence
     and collect the (lat, lon) pairs.
  4. Per route, deduplicate the set of stop-sequences and draw polylines.
  5. Write everything into a single HTML file with embedded JS/CSS.
"""

from typing import Dict, List, Optional, Set, Tuple
import argparse
import csv
import json
import os
from collections import defaultdict


# ---------------------------------------------------------------------------
# CSV helper
# ---------------------------------------------------------------------------

def read_csv(path: str) -> List[dict]:
    with open(path, encoding="utf-8-sig") as fh:
        return list(csv.DictReader(fh))


# ---------------------------------------------------------------------------
# Color utilities ¡Done by AI as I don't want to spend hours tweaking a palette by hand!
# ---------------------------------------------------------------------------

def _generate_distinct_colors(n: int) -> List[str]:
    """
    Generate n visually distinct colors using golden-ratio hue stepping
    combined with lightness cycling across 3 tiers.

    Strategy:
      - Hues are stepped using the golden-ratio conjugate (0.618...) for
        maximum angular separation across the color wheel.
      - Lightness alternates across 3 values (0.62, 0.48, 0.72) so that
        even when two routes end up with similar hues, they differ in
        brightness and remain visually distinguishable on both dark and
        light map tiles.
      - Saturation stays high (0.85) to keep all colors vivid.
      - The yellow band (hue 0.11-0.20 ≈ 40-72 deg) is skipped to avoid
        clashing with the KD brand yellow stop markers.
    """
    import colorsys
    # Three lightness tiers cycled in order: medium, dark, bright
    lightness_tiers = [0.62, 0.48, 0.72]
    colors = []
    hue = 0.0
    golden = 0.618033988749895
    tier_idx = 0
    while len(colors) < n:
        hue = (hue + golden) % 1.0
        # Skip yellow band
        if 0.11 < hue < 0.20:
            hue = (hue + golden) % 1.0
        lum = lightness_tiers[tier_idx % 3]
        tier_idx += 1
        r, g, b = colorsys.hls_to_rgb(hue, lum, 0.85)
        colors.append("#{:02X}{:02X}{:02X}".format(int(r*255), int(g*255), int(b*255)))
    return colors

# Pre-generate enough colors for any realistic number of routes
_FALLBACK_PALETTE: List[str] = _generate_distinct_colors(120)


def _hex_to_rgb(hex_color: str) -> Tuple[int, int, int]:
    """Parse '#RRGGBB' or 'RRGGBB' into (r, g, b) ints."""
    h = hex_color.lstrip("#")
    if len(h) != 6:
        raise ValueError(f"Bad hex color: {hex_color!r}")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


def _relative_luminance(r: int, g: int, b: int) -> float:
    """
    WCAG relative luminance of an sRGB colour (0 = black, 1 = white).
    Used to detect colours that are too dark to see on a dark map.
    """
    def linearise(c: int) -> float:
        v = c / 255.0
        return v / 12.92 if v <= 0.04045 else ((v + 0.055) / 1.055) ** 2.4
    return 0.2126 * linearise(r) + 0.7152 * linearise(g) + 0.0722 * linearise(b)


def _ensure_visible(hex_color: str, min_luminance: float = 0.06) -> str:
    """
    If the colour is too dark to see on the dark CartoDB basemap, lighten it
    by blending with white until it meets the minimum luminance threshold.

    min_luminance=0.06 corresponds roughly to a medium-dark grey - anything
    below that is almost invisible against the near-black (#0a0e1a) map tiles.
    """
    try:
        r, g, b = _hex_to_rgb(hex_color)
    except ValueError:
        return hex_color  # malformed - return as-is

    lum = _relative_luminance(r, g, b)
    if lum >= min_luminance:
        return hex_color  # already bright enough

    # Blend towards white iteratively (up to 10 steps of +20 per channel)
    for _ in range(10):
        r = min(255, r + 20)
        g = min(255, g + 20)
        b = min(255, b + 20)
        if _relative_luminance(r, g, b) >= min_luminance:
            break

    return "#{:02X}{:02X}{:02X}".format(r, g, b)


def _parse_route_color(raw: str, fallback: str) -> str:
    """
    Robustly parse a route_color field value from routes.txt.

    Handles:
      - Empty string / whitespace-only  -> use fallback
      - Already has '#' prefix          -> strip then re-add
      - Wrong length (not 6 hex chars)  -> use fallback
      - Too dark for the dark basemap   -> lighten automatically
    """
    cleaned = raw.strip().lstrip("#").upper()
    if len(cleaned) != 6 or not all(c in "0123456789ABCDEF" for c in cleaned):
        return fallback  # malformed or empty
    color = "#" + cleaned
    return _ensure_visible(color)


# ---------------------------------------------------------------------------
# Data loading
# ---------------------------------------------------------------------------

def load_data(gtfs_dir: str, date_str: Optional[str] = None) -> dict:
    """Return a dict with stops, routes, active_trips, stop_times."""

    # --- stops ---
    stops = {}
    for row in read_csv(os.path.join(gtfs_dir, "stops.txt")):
        stops[row["stop_id"]] = {
            "name": row["stop_name"].strip(),
            "lat":  float(row["stop_lat"]),
            "lon":  float(row["stop_lon"]),
            "type": int(row.get("location_type") or 0),
            "parent": row.get("parent_station", "").strip(),
        }

    # --- routes ---
    # Strategy: read all routes first, collect their CSV colors, then decide
    # whether those colors are actually useful for differentiation.
    #
    # The provided data uses a single brand color (F6C32F) for every route,
    # so the CSV color gives zero visual information on the map.  We detect
    # this by checking whether ALL valid CSV colors are identical.
    #
    # - If every route shares the same color -> ignore CSV colors entirely and
    #   assign each route a distinct color from the palette.
    # - If routes genuinely differ -> use the CSV color (boosted for visibility)
    #   with the palette only as a fallback for missing/invalid entries.
    #
    # In both cases the original CSV color is stored as `brand_color` so the
    # sidebar can display it as a small brand badge next to the line name.

    raw_rows = read_csv(os.path.join(gtfs_dir, "routes.txt"))

    # Collect all valid CSS colors from the CSV
    valid_csv_colors = set()
    for row in raw_rows:
        raw = row.get("route_color", "").strip().lstrip("#").upper()
        if len(raw) == 6 and all(c in "0123456789ABCDEF" for c in raw):
            valid_csv_colors.add(raw)

    all_same_color = len(valid_csv_colors) == 1   # e.g. all routes = F6C32F

    if all_same_color:
        shared = next(iter(valid_csv_colors))
        print(f"  NOTE: All routes share the same CSV color #{shared}. "
              f"Assigning distinct palette colors for map visibility.")
    else:
        print(f"  Found {len(valid_csv_colors)} distinct route colors in CSV.")

    routes = {}
    palette_idx = 0
    for row in raw_rows:
        name = (row.get("route_short_name") or "").strip() \
            or (row.get("route_long_name") or "").strip()

        raw_color = row.get("route_color", "").strip()
        brand_color = _parse_route_color(raw_color, "#888888") if raw_color else "#888888"

        if all_same_color:
            # Ignore the shared CSV color - every route gets a unique palette color
            map_color = _FALLBACK_PALETTE[palette_idx % len(_FALLBACK_PALETTE)]
        else:
            # Use the CSV color if valid, otherwise pick from palette
            if raw_color:
                map_color = _parse_route_color(
                    raw_color,
                    _FALLBACK_PALETTE[palette_idx % len(_FALLBACK_PALETTE)]
                )
            else:
                map_color = _FALLBACK_PALETTE[palette_idx % len(_FALLBACK_PALETTE)]

        palette_idx += 1
        routes[row["route_id"]] = {
            "name":        name,
            "color":       map_color,    # color used for the map polyline
            "brand_color": brand_color,  # original CSV color shown as badge
        }
        print(f"  Route {name:<30}  CSV: {raw_color or '(none)':>8}  "
              f"-> map color: {map_color}")

    # --- active services ---
    from datetime import datetime
    active_services: Set[str] = set()

    if date_str:
        date = datetime.strptime(date_str, "%Y%m%d")
        weekday_col = ["monday","tuesday","wednesday","thursday",
                       "friday","saturday","sunday"][date.weekday()]

        cal_path = os.path.join(gtfs_dir, "calendar.txt")
        if os.path.exists(cal_path):
            for row in read_csv(cal_path):
                s = datetime.strptime(row["start_date"], "%Y%m%d")
                e = datetime.strptime(row["end_date"],   "%Y%m%d")
                if s <= date <= e and row.get(weekday_col) == "1":
                    active_services.add(row["service_id"])

        dates_path = os.path.join(gtfs_dir, "calendar_dates.txt")
        if os.path.exists(dates_path):
            for row in read_csv(dates_path):
                if row["date"] == date_str:
                    if row["exception_type"] == "1":
                        active_services.add(row["service_id"])
                    else:
                        active_services.discard(row["service_id"])
    else:
        # treat all service_ids as active when no date filter
        active_services = None   # sentinel = all

    # --- trips ---
    trips = {}
    for row in read_csv(os.path.join(gtfs_dir, "trips.txt")):
        sid = row["service_id"]
        if active_services is None or sid in active_services:
            trips[row["trip_id"]] = row["route_id"]

    # --- stop_times: group by trip, keep ordered sequences ---
    # route_id -> list of [stop_id, ...] sequences
    route_sequences: Dict[str, List[List[str]]] = defaultdict(list)

    raw: Dict[str, list] = defaultdict(list)
    for row in read_csv(os.path.join(gtfs_dir, "stop_times.txt")):
        tid = row["trip_id"]
        if tid not in trips:
            continue
        raw[tid].append((int(row["stop_sequence"]), row["stop_id"]))

    for tid, pairs in raw.items():
        pairs.sort()
        seq = [sid for _, sid in pairs]
        rid = trips[tid]
        route_sequences[rid].append(seq)

    # Deduplicate sequences per route (keep unique shapes only)
    for rid in route_sequences:
        seen = set()
        unique = []
        for seq in route_sequences[rid]:
            key = tuple(seq)
            if key not in seen:
                seen.add(key)
                unique.append(seq)
        route_sequences[rid] = unique

    return {
        "stops":           stops,
        "routes":          routes,
        "route_sequences": route_sequences,
    }


# ---------------------------------------------------------------------------
# HTML / Leaflet generation
# ---------------------------------------------------------------------------

def build_html(data: dict) -> str:
    stops           = data["stops"]
    routes          = data["routes"]
    route_sequences = data["route_sequences"]

    # --- Build JS data blobs ---

    # Stops JSON (only platforms - location_type 0 - to avoid duplicate markers)
    js_stops = []
    for sid, s in stops.items():
        if s["type"] == 0:
            js_stops.append({
                "id":   sid,
                "name": s["name"],
                "lat":  s["lat"],
                "lon":  s["lon"],
            })

    # Routes + polylines JSON
    # Also build stop_routes: stop_id -> [{name, color}] for popup enrichment
    from collections import defaultdict as _dd
    stop_routes_map: dict = _dd(list)

    js_routes = []
    for rid, route in routes.items():
        seqs = route_sequences.get(rid, [])
        polylines = []
        seen_stops_this_route: set = set()
        for seq in seqs:
            coords = []
            for sid in seq:
                s = stops.get(sid)
                if s:
                    coords.append([s["lat"], s["lon"]])
                    # Register that this route passes through this stop (once per route)
                    if sid not in seen_stops_this_route:
                        seen_stops_this_route.add(sid)
                        stop_routes_map[sid].append({
                            "name":  route["name"],
                            "color": route["color"],
                        })
            if len(coords) >= 2:
                polylines.append(coords)
        if polylines:
            js_routes.append({
                "name":        route["name"],
                "color":       route["color"],
                "brand_color": route.get("brand_color", route["color"]),
                "polylines":   polylines,
            })

    # Inject stop routes into the stops JS array
    for entry in js_stops:
        entry["routes"] = stop_routes_map.get(entry["id"], [])

    stops_json  = json.dumps(js_stops,  ensure_ascii=False)
    routes_json = json.dumps(js_routes, ensure_ascii=False)

    n_stops  = len(js_stops)
    n_routes = len(js_routes)

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>Koleje Dolnośląskie - Network Map</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css"/>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Space+Mono:wght@400;700&family=DM+Sans:wght@300;400;600&display=swap');

  /* CSS DONE BY AI */
  /* -- CSS theme variables -- */
  :root {{
    --bg:           #0a0e1a;
    --header-bg:    #0d1220;
    --header-bg2:   #111827;
    --border:       #1e2740;
    --text:         #e8eaf0;
    --text-muted:   #6b7a99;
    --text-dim:     #4a556e;
    --sidebar-bg:   rgba(10,14,26,0.92);
    --input-bg:     #111827;
    --input-text:   #c8ccda;
    --item-hover:   rgba(255,255,255,0.04);
    --item-active:  rgba(255,255,255,0.07);
    --toggle-off:   #1e2740;
    --popup-bg:     #0d1220;
    --popup-border: #1e2740;
    --popup-text:   #e8eaf0;
    --accent:       #f6c32f;
    --stop-color:   #f6c32f;
    --scrollbar:    #1e2740;
  }}
  body.light {{
    --bg:           #f0f2f8;
    --header-bg:    #ffffff;
    --header-bg2:   #f5f7fc;
    --border:       #d0d6e8;
    --text:         #1a1f2e;
    --text-muted:   #5a6480;
    --text-dim:     #8892aa;
    --sidebar-bg:   rgba(255,255,255,0.95);
    --input-bg:     #f5f7fc;
    --input-text:   #2a3040;
    --item-hover:   rgba(0,0,0,0.04);
    --item-active:  rgba(0,0,0,0.07);
    --toggle-off:   #c8d0e0;
    --popup-bg:     #ffffff;
    --popup-border: #d0d6e8;
    --popup-text:   #1a1f2e;
    --accent:       #c89a00;
    --stop-color:   #d4920a;
    --scrollbar:    #c8d0e0;
  }}

  * {{ box-sizing: border-box; margin: 0; padding: 0; }}

  body {{
    font-family: 'DM Sans', sans-serif;
    background: var(--bg);
    color: var(--text);
    height: 100vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    transition: background 0.3s, color 0.3s;
  }}

  /* -- Header -- */
  header {{
    display: flex;
    align-items: center;
    gap: 18px;
    padding: 12px 24px;
    background: linear-gradient(135deg, var(--header-bg) 0%, var(--header-bg2) 100%);
    border-bottom: 1px solid var(--border);
    z-index: 1000;
    flex-shrink: 0;
    transition: background 0.3s, border-color 0.3s;
  }}
  .header-badge {{
    font-family: 'Space Mono', monospace;
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    color: var(--accent);
    background: rgba(246,195,47,0.12);
    border: 1px solid rgba(246,195,47,0.3);
    padding: 4px 10px;
    border-radius: 4px;
  }}
  header h1 {{
    font-family: 'Space Mono', monospace;
    font-size: 15px;
    font-weight: 700;
    letter-spacing: 0.04em;
    color: var(--text);
  }}
  .stats {{
    display: flex;
    gap: 20px;
    margin-left: auto;
    align-items: center;
  }}
  .stat {{
    text-align: right;
  }}
  .stat-val {{
    font-family: 'Space Mono', monospace;
    font-size: 16px;
    font-weight: 700;
    color: var(--accent);
    line-height: 1;
  }}
  .stat-lbl {{
    font-size: 10px;
    color: var(--text-dim);
    text-transform: uppercase;
    letter-spacing: 0.08em;
  }}

  /* -- Theme toggle button -- */
  #theme-btn {{
    display: flex;
    align-items: center;
    gap: 7px;
    font-family: 'Space Mono', monospace;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--text-muted);
    background: var(--input-bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 6px 12px;
    cursor: pointer;
    transition: all 0.2s;
    user-select: none;
    white-space: nowrap;
  }}
  #theme-btn:hover {{
    border-color: var(--accent);
    color: var(--accent);
  }}
  #theme-btn .icon {{ font-size: 14px; line-height: 1; }}

  /* -- Map container -- */
  #map {{
    flex: 1;
    width: 100%;
  }}

  /* -- Sidebar / legend -- */
  #sidebar {{
    position: absolute;
    top: 74px;
    right: 12px;
    width: 240px;
    max-height: calc(100vh - 110px);
    background: var(--sidebar-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    backdrop-filter: blur(12px);
    z-index: 900;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    transition: background 0.3s, border-color 0.3s;
  }}
  #sidebar-header {{
    padding: 12px 14px 10px;
    border-bottom: 1px solid var(--border);
    font-family: 'Space Mono', monospace;
    font-size: 10px;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    color: var(--text-dim);
    display: flex;
    justify-content: space-between;
    align-items: center;
    flex-shrink: 0;
  }}
  #filter-input {{
    background: var(--input-bg);
    border: 1px solid var(--border);
    border-radius: 4px;
    color: var(--input-text);
    font-family: 'DM Sans', sans-serif;
    font-size: 12px;
    padding: 6px 10px;
    outline: none;
    margin: 8px 14px 0;
    width: calc(100% - 28px);
    transition: background 0.3s, border-color 0.3s;
  }}
  #filter-input:focus {{ border-color: #3b5bdb; }}
  #route-list {{
    overflow-y: auto;
    padding: 8px 0 12px;
    flex: 1;
  }}
  .route-item {{
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 7px 14px;
    cursor: pointer;
    transition: background 0.15s;
    user-select: none;
  }}
  .route-item:hover {{ background: var(--item-hover); }}
  .route-item.active {{ background: var(--item-active); }}
  .route-toggle {{
    margin-left: auto;
    width: 28px;
    height: 14px;
    background: var(--toggle-off);
    border-radius: 7px;
    position: relative;
    flex-shrink: 0;
    transition: background 0.2s;
  }}
  .route-toggle.on {{ background: #3b5bdb; }}
  .route-toggle::after {{
    content: '';
    position: absolute;
    width: 10px; height: 10px;
    border-radius: 50%;
    background: #fff;
    top: 2px; left: 2px;
    transition: left 0.2s;
  }}
  .route-toggle.on::after {{ left: 16px; }}

  /* -- Popup theming -- */
  .leaflet-popup-content-wrapper {{
    background: var(--popup-bg);
    color: var(--popup-text);
    border: 1px solid var(--popup-border);
    border-radius: 6px;
    font-family: 'DM Sans', sans-serif;
    transition: background 0.3s;
  }}
  .leaflet-popup-tip {{ background: var(--popup-bg); }}
  .popup-stop-name {{
    font-family: 'Space Mono', monospace;
    font-size: 12px;
    font-weight: 700;
    color: var(--accent);
  }}
  .popup-stop-id {{
    font-size: 11px;
    color: var(--text-dim);
    margin-top: 2px;
  }}

  /* -- Leaflet attribution - keep it legal but unobtrusive -- */
  .leaflet-control-attribution {{
    font-size: 9px !important;
    opacity: 0.45;
    transition: opacity 0.2s;
  }}
  .leaflet-control-attribution:hover {{
    opacity: 1;
  }}

  /* -- Brand color badge in sidebar -- */
  .route-line-swatch {{
    width: 18px;
    height: 3px;
    border-radius: 2px;
    flex-shrink: 0;
  }}
  .brand-badge {{
    font-family: 'Space Mono', monospace;
    font-size: 9px;
    font-weight: 700;
    padding: 1px 5px;
    border-radius: 3px;
    opacity: 0.75;
    flex-shrink: 0;
    letter-spacing: 0.05em;
  }}

  /* -- Stop popup route chips -- */
  .popup-routes {{
    margin-top: 8px;
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
  }}
  .route-chip {{
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-family: 'Space Mono', monospace;
    font-size: 10px;
    font-weight: 700;
    padding: 3px 7px;
    border-radius: 4px;
    border: 1.5px solid;
    white-space: nowrap;
  }}
  .route-chip-dot {{
    width: 6px;
    height: 6px;
    border-radius: 50%;
    flex-shrink: 0;
  }}
  /* -- Line click popup -- */
  .line-popup-name {{
    font-family: 'Space Mono', monospace;
    font-size: 13px;
    font-weight: 700;
    display: flex;
    align-items: center;
    gap: 8px;
  }}
  .line-popup-swatch {{
    display: inline-block;
    width: 28px;
    height: 4px;
    border-radius: 2px;
    flex-shrink: 0;
  }}
  .line-popup-label {{
    font-size: 10px;
    color: var(--text-dim);
    margin-top: 3px;
    font-family: 'DM Sans', sans-serif;
  }}

  /* Custom scrollbar */
  #route-list::-webkit-scrollbar {{ width: 4px; }}
  #route-list::-webkit-scrollbar-track {{ background: transparent; }}
  #route-list::-webkit-scrollbar-thumb {{ background: var(--scrollbar); border-radius: 2px; }}
</style>
</head>
<body>

<header>
  <div class="header-badge">KD</div>
  <h1>Koleje Dolnośląskie — Network Map</h1>
  <div class="stats">
    <div class="stat">
      <div class="stat-val">{n_stops}</div>
      <div class="stat-lbl">Stops</div>
    </div>
    <div class="stat">
      <div class="stat-val">{n_routes}</div>
      <div class="stat-lbl">Routes</div>
    </div>
    <button id="theme-btn" title="Toggle light/dark map">
      <span class="icon">🌙</span><span id="theme-label">Dark</span>
    </button>
  </div>
</header>

<div id="map"></div>

<div id="sidebar">
  <div id="sidebar-header">
    <span>Lines</span>
    <span id="visible-count" style="color:#3b5bdb">{n_routes} visible</span>
  </div>
  <input id="filter-input" type="text" placeholder="Filter lines…" autocomplete="off"/>
  <div id="route-list"></div>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<script>
// -- Raw data injected by Python ------------------------------------------
const STOPS  = {stops_json};
const ROUTES = {routes_json};

// -- Map setup ------------------------------------------------------------
const map = L.map('map', {{
  center: [51.1, 16.9],
  zoom: 9,
  preferCanvas: true,
}});

// -- Tile layers (dark + light) ------------------------------------------
// Attribution is required by CARTO's terms of service and cannot be removed.
// It is styled to be small and fades unless hovered (see CSS above).
const TILES = {{
  dark: L.tileLayer(
    'https://{{s}}.basemaps.cartocdn.com/dark_all/{{z}}/{{x}}/{{y}}{{r}}.png',
    {{ attribution: '&copy; <a href="https://carto.com/">CARTO</a> &copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>', subdomains:'abcd', maxZoom:18 }}
  ),
  light: L.tileLayer(
    'https://{{s}}.basemaps.cartocdn.com/light_all/{{z}}/{{x}}/{{y}}{{r}}.png',
    {{ attribution: '&copy; <a href="https://carto.com/">CARTO</a> &copy; <a href="https://www.openstreetmap.org/copyright">OSM</a>', subdomains:'abcd', maxZoom:18 }}
  ),
}};
TILES.dark.addTo(map);
let isDark = true;

// -- Theme switch --------------------------------------------------------─
function applyTheme(dark) {{
  isDark = dark;
  document.body.classList.toggle('light', !dark);
  // Swap tile layers
  if (dark) {{
    map.removeLayer(TILES.light);
    TILES.dark.addTo(map);
    TILES.dark.bringToBack();
  }} else {{
    map.removeLayer(TILES.dark);
    TILES.light.addTo(map);
    TILES.light.bringToBack();
  }}
  // Update stop marker color for contrast
  const stopCol = dark ? '#f6c32f' : '#d4920a';
  stopGroup.eachLayer(l => {{
    l.setStyle({{ color: stopCol, fillColor: stopCol }});
  }});
  // Update button label
  document.getElementById('theme-label').textContent = dark ? 'Dark' : 'Light';
  document.querySelector('#theme-btn .icon').textContent = dark ? '🌙' : '☀️';
}}

document.getElementById('theme-btn').addEventListener('click', () => applyTheme(!isDark));

// -- Draw routes ----------------------------------------------------------─
const routeLayers = [];

ROUTES.forEach(route => {{
  const layerGroup = L.layerGroup();
  route.polylines.forEach(coords => {{
    const pl = L.polyline(coords, {{
      color:   route.color,
      weight:  3,
      opacity: 0.85,
    }});
    // Thicken on hover so the line is easier to click
    pl.on('mouseover', function() {{ this.setStyle({{ weight: 5, opacity: 1 }}); }});
    pl.on('mouseout',  function() {{ this.setStyle({{ weight: 3, opacity: 0.85 }}); }});
    // Click: show a popup with the line name + color swatch
    pl.on('click', function(e) {{
      const hex = route.color;
      // Readable text color for the swatch label
      const r2 = parseInt(hex.slice(1,3),16), g2 = parseInt(hex.slice(3,5),16), b2 = parseInt(hex.slice(5,7),16);
      const lum = 0.2126*(r2/255)+0.7152*(g2/255)+0.0722*(b2/255);
      const txt = lum > 0.4 ? '#1a1a1a' : '#ffffff';
      L.popup({{ className: 'line-click-popup' }})
        .setLatLng(e.latlng)
        .setContent(
          `<div class="line-popup-name">
             <span class="line-popup-swatch" style="background:${{route.color}}"></span>
             <span style="color:${{route.color}}">${{route.name}}</span>
           </div>
           <div class="line-popup-label">Railway line</div>`
        )
        .openOn(map);
    }});
    pl.addTo(layerGroup);
  }});
  layerGroup.addTo(map);
  routeLayers.push({{ name: route.name, color: route.color, brandColor: route.brand_color, layer: layerGroup, visible: true }});
}});

// -- Draw stops ------------------------------------------------------------
const stopGroup = L.layerGroup().addTo(map);
const stopRadius = 3;

STOPS.forEach(stop => {{
  const marker = L.circleMarker([stop.lat, stop.lon], {{
    radius:      stopRadius,
    color:       '#f6c32f',
    fillColor:   '#f6c32f',
    fillOpacity: 0.8,
    weight:      0,
  }});

  // Build route chips HTML
  // Text is always the route's own color - it's always readable against the
  // semi-transparent dark/light chip background, and keeps every chip distinct.
  let chipsHtml = '';
  if (stop.routes && stop.routes.length > 0) {{
    const chips = stop.routes.map(rt => {{
      const bgCol = rt.color + '22';   // 13% opacity tint of the route color
      return `<span class="route-chip" style="color:${{rt.color}};border-color:${{rt.color}};background:${{bgCol}}">
                <span class="route-chip-dot" style="background:${{rt.color}}"></span>
                ${{rt.name}}
              </span>`;
    }}).join('');
    chipsHtml = `<div class="popup-routes">${{chips}}</div>`;
  }} else {{
    chipsHtml = `<div class="popup-stop-id" style="margin-top:5px">No active routes on this date</div>`;
  }}

  marker.bindPopup(
    `<div class="popup-stop-name">${{stop.name}}</div>
     <div class="popup-stop-id">Stop ID: ${{stop.id}}</div>
     ${{chipsHtml}}`
  );
  marker.addTo(stopGroup);
}});

// Scale markers with zoom
map.on('zoomend', () => {{
  const z = map.getZoom();
  const r = z < 10 ? 2 : z < 12 ? 3 : 5;
  stopGroup.eachLayer(l => l.setRadius(r));
}});

// -- Sidebar route list ----------------------------------------------------─
const routeList = document.getElementById('route-list');
const visibleCount = document.getElementById('visible-count');

function updateVisibleCount() {{
  const n = routeLayers.filter(r => r.visible).length;
  visibleCount.textContent = n + ' visible';
}}

function buildList(filter = '') {{
  routeList.innerHTML = '';
  routeLayers.forEach((r, i) => {{
    if (filter && !r.name.toLowerCase().includes(filter.toLowerCase())) return;
    const item = document.createElement('div');
    item.className = 'route-item' + (r.visible ? ' active' : '');
    // Determine contrasting text color for the brand badge
    const bc = r.brandColor || r.color;
    const hex = bc.replace('#','');
    const rr = parseInt(hex.substr(0,2),16), gg = parseInt(hex.substr(2,2),16), bb2 = parseInt(hex.substr(4,2),16);
    const lum = 0.2126*(rr/255) + 0.7152*(gg/255) + 0.0722*(bb2/255);
    const textCol = lum > 0.4 ? '#1a1a1a' : '#ffffff';
    item.innerHTML = `
      <span class="route-line-swatch" style="background:${{r.color}};box-shadow:0 0 5px ${{r.color}}88"></span>
      <span class="route-name" style="color:${{r.color}}">${{r.name}}</span>
      <span class="brand-badge" style="background:${{bc}};color:${{textCol}}">${{bc}}</span>
      <span class="route-toggle ${{r.visible ? 'on' : ''}}"></span>`;
    item.addEventListener('click', () => {{
      r.visible = !r.visible;
      if (r.visible) {{ map.addLayer(r.layer); }}
      else           {{ map.removeLayer(r.layer); }}
      item.className = 'route-item' + (r.visible ? ' active' : '');
      item.querySelector('.route-toggle').className = 'route-toggle' + (r.visible ? ' on' : '');
      updateVisibleCount();
    }});
    routeList.appendChild(item);
  }});
}}

buildList();

document.getElementById('filter-input').addEventListener('input', e => {{
  buildList(e.target.value);
}});
</script>
</body>
</html>"""
    return html


# ---------------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------------

def main():
    # Options parsing if user wants to specify a different GTFS directory, output file, or service date.
    parser = argparse.ArgumentParser(description="Generate interactive map of KD network")
    parser.add_argument("--gtfs",  default="./gtfs", help="GTFS directory [./gtfs]")
    parser.add_argument("--out",   default="map.html", help="Output HTML file [map.html]")
    parser.add_argument("--date",  default="20260303", help="Service date YYYYMMDD")
    args = parser.parse_args()

    print(f"Loading GTFS from '{args.gtfs}' (date: {args.date}) ...")
    print("Route colours (from routes.txt route_color field):")
    data = load_data(args.gtfs, date_str=args.date)

    # Print summary stats to console - also shown in the header of the generated map
    n_stops  = sum(1 for s in data["stops"].values() if s["type"] == 0)
    n_routes = sum(1 for r in data["route_sequences"] if data["route_sequences"][r])
    print(f"\n  Stops: {n_stops}  |  Routes with geometry: {n_routes}")

    # Generate HTML and write to output file
    print(f"Generating '{args.out}' ...")
    html = build_html(data)
    with open(args.out, "w", encoding="utf-8") as fh:
        fh.write(html)

    print(f"Done. Open '{args.out}' in your browser.")

if __name__ == "__main__":
    main()