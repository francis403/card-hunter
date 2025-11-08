extends Node

func debug_log(_log: String, _condition: bool = true):
	if _condition:
		print("DEBUG: " + _log)
