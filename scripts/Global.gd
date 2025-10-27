extends Node

# Global singleton (autoload) that holds cross-scene game state.
#
# State machine (simple string-based):
#   MENU -> INTRO -> RUNNING -> DEAD -> (click) -> MENU
#
# Notes
# - main.gd is responsible for switching to RUNNING and restoring the
#   boost value decided in the Intro scene.
# - All moving nodes (background, enemies, collectibles, player) check
#   `Global.state == "RUNNING"` before updating, so setting state to
#   DEAD effectively freezes the world without pausing the tree.

var score:int = 0         # Distance in meters (displayed by UI)
var mars_bars:int = 0     # Run-local currency (resets on new run)
var boost:float = 1.0     # 1.0..2.0 multiplier set by Intro mini-game
var alive:bool = true     # Convenience flag used by some scripts
var state:String = "MENU" # Current state label

func reset():
	# Resets the per-run values. The caller decides what the next state is
	# (we do not set `state` here to keep transitions explicit in code).
	score = 0
	mars_bars = 0
	boost = 1.0
	alive = true
