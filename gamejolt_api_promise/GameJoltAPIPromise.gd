extends Node
class_name GameJoltAPIPromise
var target: Node
var resolve_method: String
var reject_method: String
var tasks: Array = []
var unsolved_tasks:int
var output: Array = []

signal resolved(output)
signal rejected(error)

func initialize(_tasks: Array, _target: Node, resolve_event: String, _resolve_method: String, reject_event: String = "", _reject_method: String = ""):
	#Initial validation
	if _tasks.size() > 0 and _target != null and resolve_event != "" and _resolve_method != "":  
		tasks = _tasks
		unsolved_tasks = tasks.size()
		target = _target
		resolve_method = _resolve_method
		reject_method = _reject_method
		init_output_array()
		connect_to_signals(resolve_event, reject_event)
	else: 
		print_debug("An error occurred when initializing the Promise")


func connect_to_signals(resolve_event: String, reject_event: String) -> void: 
	#Connect the promise to each task's events
	for task_index in range(0, tasks.size()):
		tasks[task_index].connect(resolve_event,  self, "_on_task_resolved", [task_index])
		if reject_event != "":
			tasks[task_index].connect(reject_event, self, "_on_task_rejected") 
	#Connect the promise to the target's methods
	self.connect("resolved", target, resolve_method)
	if reject_method != "":
		self.connect("rejected", target, reject_method)

func init_output_array():
	var number_of_tasks = tasks.size()
	for task_index in range(0, number_of_tasks):
		output.append([])
	pass

func resolve():
	emit_signal("resolved", output)
	queue_free()

func reject(error):
	emit_signal("rejected", error)
	queue_free()

func _on_task_resolved(data, task_index)-> void:
	unsolved_tasks -= 1
	output[task_index] = data
	if unsolved_tasks == 0:
		resolve()

func _on_task_rejected(error_message):
	reject(error_message)

