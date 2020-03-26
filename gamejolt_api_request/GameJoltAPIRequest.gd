extends HTTPRequest
class_name GameJoltAPIRequest
var action: int 
var error_message : String 
signal API_request_completed(data)
signal API_request_failed(error_message)


func _ready():
	connect("request_completed", self, "_on_request_completed")

func send(request_url: String, action_requested: int) -> void:
	action = action_requested
	request(request_url)

func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var response: Dictionary = JSON.parse(body.get_string_from_utf8()).result.response
		var data: Array
		if response.success and not response.has("message"):
			match action:
				GameJoltAPI.ADD_SCORE:
					data = []
				GameJoltAPI.GET_RANK:
					data = [response.rank]
				GameJoltAPI.FETCH_SCORE:
					data = response.scores
				GameJoltAPI.FETCH_TROPHIES:
					data = response.trophies
				GameJoltAPI.ADD_ACHIEVED:
					data = []
				GameJoltAPI.REMOVE_ACHIEVED:
					data = []
			emit_signal("API_request_completed", data)
		else:
			error_message = response.message
			print_debug("Errror: ", error_message)
			emit_signal("API_request_failed", error_message)
	else:
		error_message = "response code " + result as String
		print_debug("Error: ", error_message)
		emit_signal("API_request_failed", error_message)
	queue_free() #Delete the node
