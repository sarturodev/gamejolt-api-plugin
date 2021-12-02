extends HTTPRequest
class_name GameJoltAPIRequest
var action: int 
var data
var error_message : String 
var errors_output_enabled: bool = true #Error logs is enabled by default
enum {NONE, CUSTOM_REQUEST, ADD_SCORE, GET_RANK, FETCH_SCORE, TABLES, FETCH_TROPHIES, ADD_ACHIEVED, REMOVE_ACHIEVED}
signal api_request_completed(data)
signal api_request_failed(error_message)


func _ready():
	connect("request_completed", self, "_on_request_completed")

func send(request_url: String, action_requested: int) -> void:
	if request_url != "":
		action = action_requested
		request(request_url)
	else:
		emit_signal("api_request_failed", "An error occurred when trying to make the request (check the API configuration)")

func _on_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS:
		var json: JSONParseResult = JSON.parse(body.get_string_from_utf8())
		if json.error == OK:
			var response: Dictionary = json.result.response
			if response.success and not response.has("message"):
				match action:
					CUSTOM_REQUEST:
						data = [response]
					ADD_SCORE:
						data = []
					GET_RANK:
						data = [response.rank]
					FETCH_SCORE:
						data = response.scores
					TABLES:
						data = [response.tables]
					FETCH_TROPHIES:
						data = response.trophies
					ADD_ACHIEVED:
						data = []
					REMOVE_ACHIEVED:
						data = []
				emit_signal("api_request_completed", data)
			else:
					error_message = response.message
					self.emit_signal("api_request_failed", error_message)
					if (errors_output_enabled):
						print_debug("Error: ", error_message)
				
		else:
			error_message = "Invalid request"
			print_debug("Error: ", error_message)
			emit_signal("api_request_failed", error_message)
	else:
		error_message = "Network error: " + result as String
		print_debug("Error: ", error_message)
		emit_signal("api_request_failed", error_message)
	queue_free() #Delete the node
