extends HTTPRequest
class_name GameJoltAPIRequest
var action: int 
signal API_request_completed(data)
signal API_request_failed

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("request_completed", self, "_on_request_completed")

func send(request_url: String, action_requested: int) -> void:
	action = action_requested
	request(request_url)

func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var response: Dictionary = JSON.parse(body.get_string_from_utf8()).result.response
		var data: Array
		if response.success:
			match action:
				GameJoltAPI.ADD_SCORE:
					data = []
				GameJoltAPI.GET_RANK:
					data = [response.rank]
				GameJoltAPI.FETCH_SCORE:
					data = response.scores
				GameJoltAPI.ADD_ACHIEVED:
					data = []
			emit_signal("API_request_completed", data)
			print(response.message)
		else:
			print_debug("Error: ")
			print_debug("Message: " + response.message)
			emit_signal("API_request_failed")
	else:
		print_debug("Error: ")
		print_debug("Result: " + result as String)
		emit_signal("API_request_failed")
	queue_free() #Delete the node
