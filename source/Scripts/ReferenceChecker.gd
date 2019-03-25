extends Node

# From https://github.com/bitwes/Gut/issues/28
static func is_previously_freed(obj):
	var weak_reference = weakref(obj)
	return weak_reference.get_ref() == null