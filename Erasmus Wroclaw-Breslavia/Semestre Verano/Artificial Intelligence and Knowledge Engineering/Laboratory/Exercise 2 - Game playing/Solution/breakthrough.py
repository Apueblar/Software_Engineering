#!/usr/bin/env python3
"""
Breakthrough Game - Minimax with Alpha-Beta Pruning
====================================================
Assignment 2: Artificial Intelligence and Knowledge Engineering

Board symbols
-------------
  B  - first player's piece  (advances toward row m-1, i.e. downward)
  W  - second player's piece (advances toward row 0,   i.e. upward)
  _  - empty cell
  o  - cell from which the last move was made

Input format (stdin)
--------------------
  m lines, each with n space-separated symbols.

Usage
-----
  python breakthrough.py --default-board -d 4 -H combined
  python breakthrough.py --default-board --human W -d 3 -H combined
  python breakthrough.py --default-board --human B -d 3 -H combined
  python breakthrough.py -d 4 -H combined -d2 3 -H2 advance < board.txt
  python breakthrough.py --agent B -d 4 -H combined < board.txt
"""

import sys
import time
import argparse

# -----------------------------------------------------------------------------
# Constants
# -----------------------------------------------------------------------------

B = 'B'
W = 'W'
EMPTY = '_'
LAST = 'o'

WIN = 1_000_000
LOSS = -1_000_000

OPP = {B: W, W: B}


# -----------------------------------------------------------------------------
# Board utilities
# -----------------------------------------------------------------------------

def parse_board(lines):
    return [line.strip().split() for line in lines if line.strip()]

def board_copy(board):
    return [row[:] for row in board]

def is_free(cell):
    return cell == EMPTY or cell == LAST

def default_board(rows=8, cols=8):
    board = [[EMPTY] * cols for _ in range(rows)]
    for r in range(2):
        for c in range(cols):
            board[r][c] = B
    for r in range(rows - 2, rows):
        for c in range(cols):
            board[r][c] = W
    return board

def print_board(board, file=sys.stdout, coords=False):
    """
    Print the board. When coords=True, show chess-like labels:

        a b c d e f g h
      8 B B B B B B B B
      7 B B B B B B B B
      ...
      1 W W W W W W W W

    Row 0 of internal board -> label m (top), row m-1 -> label 1 (bottom).
    Col 0 -> 'a', col n-1 -> chr('a'+n-1).
    """
    m = len(board)
    n = len(board[0]) if board else 0
    if coords:
        col_labels = ' '.join(chr(ord('a') + c) for c in range(n))
        print(f"   {col_labels}", file=file)
        for r, row in enumerate(board):
            label = m - r
            print(f"{label:2d} {' '.join(row)}", file=file)
    else:
        for row in board:
            print(' '.join(row), file=file)


# -----------------------------------------------------------------------------
# Coordinate helpers
# -----------------------------------------------------------------------------

def coord_to_index(coord, m):
    """
    'b2' -> (row, col) for board with m rows.

    Mapping: col letter 'a'=0,'b'=1,...  |  row digit '1'->m-1, str(m)->0
    Returns None if the string is malformed.
    """
    coord = coord.strip().lower()
    if len(coord) < 2:
        return None
    col_char = coord[0]
    row_str = coord[1:]
    if not col_char.isalpha() or not row_str.isdigit():
        return None
    col = ord(col_char) - ord('a')
    row = m - int(row_str)
    return (row, col)

def index_to_coord(row, col, m):
    """(6, 1) -> 'b2'  for m=8."""
    return f"{chr(ord('a') + col)}{m - row}"

def format_move(move, m):
    """((6,1),(5,1)) -> 'b2 -> b3'  for m=8."""
    (r1, c1), (r2, c2) = move
    return f"{index_to_coord(r1, c1, m)} -> {index_to_coord(r2, c2, m)}"


# -----------------------------------------------------------------------------
# Game rules
# -----------------------------------------------------------------------------

def get_moves(board, player):
    m, n = len(board), len(board[0])
    dr = 1 if player == B else -1
    opponent = OPP[player]
    moves = []
    for r in range(m):
        for c in range(n):
            if board[r][c] != player:
                continue
            nr = r + dr
            if not (0 <= nr < m):
                continue
            if is_free(board[nr][c]):
                moves.append(((r, c), (nr, c)))
            for dc in (-1, 1):
                nc = c + dc
                if 0 <= nc < n:
                    target = board[nr][nc]
                    if is_free(target) or target == opponent:
                        moves.append(((r, c), (nr, nc)))
    return moves

def apply_move(board, move, player):
    board = board_copy(board)
    (r1, c1), (r2, c2) = move
    for r in range(len(board)):
        for c in range(len(board[0])):
            if board[r][c] == LAST:
                board[r][c] = EMPTY
    board[r1][c1] = LAST
    board[r2][c2] = player
    return board

def check_winner(board):
    m, n = len(board), len(board[0])
    if any(board[m - 1][c] == B for c in range(n)):
        return B
    if any(board[0][c] == W for c in range(n)):
        return W
    return None


# -----------------------------------------------------------------------------
# Heuristic evaluation functions
# -----------------------------------------------------------------------------

def h_piece_count(board, player):
    """H1 - Piece-count advantage: (own pieces) - (opponent pieces)."""
    b = sum(row.count(B) for row in board)
    w = sum(row.count(W) for row in board)
    return (b - w) if player == B else (w - b)

def h_advancement(board, player):
    """H2 - Cumulative advancement toward the goal row."""
    m = len(board)
    score = 0
    for r, row in enumerate(board):
        for cell in row:
            if cell == B:
                adv = r
                score += adv if player == B else -adv
            elif cell == W:
                adv = m - 1 - r
                score += adv if player == W else -adv
    return score

def h_threat(board, player):
    """H3 - Bonus for pieces past the board midline (proximity to victory)."""
    m = len(board)
    half = m // 2
    score = 0
    for r, row in enumerate(board):
        for cell in row:
            if cell == B:
                threat = max(0, r - half)
                score += threat if player == B else -threat
            elif cell == W:
                threat = max(0, (m - 1 - r) - half)
                score += threat if player == W else -threat
    return score

def h_centrality(board, player):
    """H4 - Prefer pieces in central columns."""
    n = len(board[0])
    center = (n - 1) / 2.0
    score = 0
    for row in board:
        for c, cell in enumerate(row):
            val = n // 2 - abs(c - center)
            if cell == B:
                score += val if player == B else -val
            elif cell == W:
                score += val if player == W else -val
    return score

def h_combined(board, player):
    """H5 - Weighted combination: 10*piece + 3*advance + 5*threat + 1*central."""
    return (10 * h_piece_count(board, player) +
             3 * h_advancement(board, player) +
             5 * h_threat(board, player) +
             1 * h_centrality(board, player))

HEURISTICS = {
    'piece': h_piece_count,
    'advance': h_advancement,
    'threat': h_threat,
    'central': h_centrality,
    'combined': h_combined,
}


# -----------------------------------------------------------------------------
# Minimax with Alpha-Beta Pruning
# -----------------------------------------------------------------------------

_nodes_visited = 0

def minimax(board, depth, alpha, beta, maximizing, me, opp, hfn):
    global _nodes_visited
    _nodes_visited += 1

    w = check_winner(board)
    if w == me:
        return WIN + depth, None
    if w == opp:
        return LOSS - depth, None

    current = me if maximizing else opp
    moves = get_moves(board, current)

    if depth == 0 or not moves:
        return hfn(board, me), None

    best_move = None

    if maximizing:
        v = float('-inf')
        for mv in moves:
            child = apply_move(board, mv, current)
            score, _ = minimax(child, depth - 1, alpha, beta, False, me, opp, hfn)
            if score > v:
                v, best_move = score, mv
            alpha = max(alpha, v)
            if alpha >= beta:
                break
        return v, best_move
    else:
        v = float('inf')
        for mv in moves:
            child = apply_move(board, mv, current)
            score, _ = minimax(child, depth - 1, alpha, beta, True, me, opp, hfn)
            if score < v:
                v, best_move = score, mv
            beta = min(beta, v)
            if alpha >= beta:
                break
        return v, best_move

def best_move_for(board, player, depth, hfn):
    opp = OPP[player]
    _, mv = minimax(board, depth, float('-inf'), float('inf'), True, player, opp, hfn)
    if mv is None:
        moves = get_moves(board, player)
        mv = moves[0] if moves else None
    return mv


# -----------------------------------------------------------------------------
# Human input helpers
# -----------------------------------------------------------------------------

def show_legal_moves(moves, m):
    """Print all legal moves in chess-like notation."""
    print("Available moves:")
    for mv in moves:
        print(f"  {format_move(mv, m)}")

def parse_human_move(raw, board, player):
    """
    Parse and validate a human input string such as 'b2 b3'.

    Returns
    -------
    - A valid move tuple ((r1,c1),(r2,c2)) on success.
    - 'quit' if the user typed exit/quit/q.
    - None on invalid/illegal input (caller should re-prompt).
    """
    m = len(board)
    tokens = raw.strip().split()

    if len(tokens) == 1 and tokens[0].lower() in ('exit', 'quit', 'q'):
        return 'quit'
    
    if len(tokens) == 1 and tokens[0].lower() in ('h', 'help'):
        show_legal_moves(get_moves(board, player), m)
        return None

    if len(tokens) != 2:
        print("  X Enter two squares separated by a space, e.g. 'b2 b3'.")
        return None

    src = coord_to_index(tokens[0], m)
    dst = coord_to_index(tokens[1], m)

    if src is None or dst is None:
        print("  X Could not parse coordinates. Format: <col-letter><row-number>, e.g. 'b2'.")
        return None

    r1, c1 = src
    r2, c2 = dst
    n = len(board[0])

    if not (0 <= r1 < m and 0 <= c1 < n and 0 <= r2 < m and 0 <= c2 < n):
        print("  X Coordinates are out of board bounds.")
        return None

    move  = ((r1, c1), (r2, c2))
    legal = get_moves(board, player)

    if move not in legal:
        print("  X Illegal move. Please choose from the list above.")
        return None

    return move

def get_human_move(board, player):
    """
    Interactive loop: display the board + legal moves (if 'h' is entered), then read and validate
    the human player's input.  Repeats until a legal move is entered.

    Typing 'exit', 'quit', or 'q' terminates the program cleanly.
    """

    print(f"\n{'='*46}")
    print(f"  Your turn  —  you are playing: {player}")
    print(f"{'='*46}")
    print_board(board, coords=True)
    print()
    
    while True:
        try:
            raw = input("\n  Move (from to), 'h' for help, or 'exit': ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGame interrupted. Goodbye!")
            sys.exit(0)

        if not raw:
            continue

        result = parse_human_move(raw, board, player)

        if result == 'quit':
            print("Thanks for playing! Goodbye.")
            sys.exit(0)

        if result is not None:
            return result
        # loop back on invalid input


# -----------------------------------------------------------------------------
# Game loop
# -----------------------------------------------------------------------------

def play_game(board, depth_b, hfn_b, depth_w, hfn_w,
              visual=False, delay=0.0, step=False, human=None):
    """
    Play a complete game.

    human : 'B', 'W', or None
        None  -> AI vs AI (unchanged behaviour)
        'B'   -> human controls B, AI controls W
        'W'   -> human controls W, AI controls B
    """
    global _nodes_visited
    _nodes_visited = 0

    current = W
    rounds = 0
    start = time.time()

    while True:
        w = check_winner(board)
        if w:
            break

        moves = get_moves(board, current)
        if not moves:
            w = OPP[current]
            break

        if human is not None and current == human:
            # -- Human's turn --------------------------------------------
            mv = get_human_move(board, current)
        else:
            # -- AI's turn -----------------------------------------------
            mv = best_move_for(
                board, current,
                depth_b if current == B else depth_w,
                hfn_b if current == B else hfn_w,
            )

            # Show AI move when playing against a human
            if human is not None:
                m = len(board)
                print(f"\n  AI ({current}) plays: {format_move(mv, m)}")

            # Visualisation for pure AI vs AI mode
            if visual and human is None:
                board_tmp = apply_move(board, mv, current)
                print("\n" + "=" * 40)
                print(f"Player {current} moved: {format_move(mv, len(board))}")
                print_board(board_tmp, coords=True)
                print("=" * 40)
                if step:
                    input("Press Enter to continue...")
                elif delay > 0:
                    time.sleep(delay)

        board = apply_move(board, mv, current)
        current = OPP[current]

        if current == W:
            rounds += 1

    elapsed = time.time() - start
    return board, w, rounds, _nodes_visited, elapsed


# -----------------------------------------------------------------------------
# Agent mode
# -----------------------------------------------------------------------------

def agent_move(board, player, depth, hfn):
    global _nodes_visited
    _nodes_visited = 0
    start = time.time()

    mv = best_move_for(board, player, depth, hfn)
    if mv is None:
        print(f"No legal moves for {player}.", file=sys.stderr)
        sys.exit(1)

    new_board = apply_move(board, mv, player)
    print_board(new_board)

    w = check_winner(new_board)
    if w:
        print(f"Winner: {w}")

    elapsed = time.time() - start
    print(f"Nodes visited : {_nodes_visited}", file=sys.stderr)
    print(f"Execution time: {elapsed:.4f} s", file=sys.stderr)


# -----------------------------------------------------------------------------
# Entry-point
# -----------------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(
        description="Breakthrough - Minimax with Alpha-Beta Pruning",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )

    ap.add_argument('--default-board', action='store_true',
                    help='Use the default 8x8 starting position')
    ap.add_argument('--board', type=str, default=None,
                help='Path to a board file')
    ap.add_argument('--rows', type=int, default=8)
    ap.add_argument('--cols', type=int, default=8)

    ap.add_argument('-d',  '--depth',      type=int, default=4, metavar='D')
    ap.add_argument('-H',  '--heuristic',  default='combined',
                    choices=list(HEURISTICS), metavar='HEUR')
    ap.add_argument('-d2', '--depth-w',    type=int, default=None, metavar='D')
    ap.add_argument('-H2', '--heuristic-w',default=None,
                    choices=list(HEURISTICS), metavar='HEUR')

    ap.add_argument('--agent', choices=[B, W], default=None, metavar='PLAYER',
                    help='Agent mode: compute ONE move for PLAYER and exit')

    ap.add_argument(
        '--human', choices=[B, W], default=None, metavar='PLAYER',
        help=(
            'Human vs AI: specify which colour YOU play (B or W). '
            'The other player is controlled by the AI. '
            'Example: --human W  ->  you play White, AI plays Black.'
        ),
    )

    ap.add_argument('--visual', action='store_true',
                    help='Show board after every move (AI vs AI)')
    ap.add_argument('--delay', type=float, default=0.0,
                    help='Seconds to pause between AI moves in visual mode')
    ap.add_argument('--step', action='store_true',
                    help='Wait for Enter between moves in visual mode')

    args = ap.parse_args()

    # -- Read board ------------------------------------------------------------
    if args.default_board:
        board = default_board(args.rows, args.cols)
    elif args.board:
        with open(args.board) as f:
            lines = [l for l in f if l.strip()]
        board = parse_board(lines)
    else:
        ap.error("You must specify either --default-board or --board")

    # -- Resolve heuristics ----------------------------------------------------
    hfn_b = HEURISTICS[args.heuristic]
    hfn_w = HEURISTICS[args.heuristic_w or args.heuristic]
    depth_b = args.depth
    depth_w = args.depth_w if args.depth_w is not None else args.depth

    # -- Dispatch --------------------------------------------------------------
    if args.agent is not None:
        hfn = hfn_b if args.agent == B else hfn_w
        depth = depth_b if args.agent == B else depth_w
        agent_move(board, args.agent, depth, hfn)

    else:
        if args.human is not None:
            ai = OPP[args.human]
            ai_depth = depth_b if ai == B else depth_w
            ai_heur = args.heuristic if ai == B else (args.heuristic_w or args.heuristic)
            m, n = len(board), len(board[0])
            print("=" * 46)
            print("  Breakthrough  —  Human vs AI")
            print(f"  You  : {args.human}")
            print(f"  AI   : {ai}  (depth={ai_depth}, heuristic={ai_heur})")
            print(f"  Board: {m}x{n}")
            print("=" * 46)
            print("\nCoordinate system:")
            print("  Columns -> a b c ...  (left to right)")
            print(f"  Rows    -> 1 ... {m}   (bottom to top, '1' = bottom row)")
            print(f"  B pieces start at top    and advance downward (toward row 1)")
            print(f"  W pieces start at bottom and advance upward   (toward row {m})")
            print("\nEnter moves as: <from> <to>  e.g.  b2 b3")
            print("Type 'exit' at any time to quit.\n")

        final, w, rounds, visited, elapsed = play_game(
            board, depth_b, hfn_b, depth_w, hfn_w,
            visual=args.visual, delay=args.delay, step=args.step,
            human=args.human,
        )

        print(f"\n{'='*46}")
        print("  GAME OVER")
        print(f"{'='*46}")
        print_board(final, coords=(args.human is not None))
        print(f"\nRounds played: {rounds}  |  Winner: {w}")

        print(f"Nodes visited : {visited}", file=sys.stderr)
        print(f"Execution time: {elapsed:.4f} s", file=sys.stderr)


if __name__ == '__main__':
    main()