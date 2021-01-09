extends Object

class_name ConnectTo

static func orDie(src :Object, signal_name :String, target :Object, method_name :String, binds = [], flags = 0 ):
	if not src.connect(signal_name, target, method_name, binds, flags):
		var src_node = src as Node
		var src_path = src_node.get_path().get_concatenated_subnames() + " " if src_node else ""
		printerr("FATAL: Cannot connect to " + src_path + "\"" + signal_name + "\"")
		var tree = src_node.get_tree() if src_node else (target.get_tree() if target is Node else null)
		tree.quit(1)
	
