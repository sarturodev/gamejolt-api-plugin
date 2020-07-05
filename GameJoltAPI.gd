extends Node
#-- API Settings
const GAME_API: String =  "https://api.gamejolt.com/api/game/v1_2"
var GAME_ID : String = ""
var SECURE_KEY: String = ""
var username: String = ""
var game_token: String = ""


var GameJoltAPIRequestNode = preload("res://addons/gamejolt_api/gamejolt_api_request/GameJoltAPIRequest.tscn")


# Get username and game token (only available for HTML5 games)
func get_web_user_credentials() -> void:
	if OS.has_feature('JavaScript'):
		username = JavaScript.eval("new URLSearchParams(window.location.search).get('gjapi_username') || ''")  
		game_token = JavaScript.eval("new URLSearchParams(window.location.search).get('gjapi_token') || ''")
		if username != "" and game_token != "":
			print_debug("Error: Cannot get the user credentials")
	else:
		print_debug("Error: JavaScript is not supported")

func set_game_credentials(params: Dictionary) -> void:
	if params["game_id"] && params["secure_key"]:
		if params["game_id"] is String and params["secure_key"] is String:
			GAME_ID = params["game_id"]
			SECURE_KEY = params["secure_key"]
	else:
		print_debug("Error: Game credentials cannot be set up")
	pass

#--- SCORES

func add_score(params: Dictionary) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/add/", params)
	return send_request(request, GameJoltAPIRequest.ADD_SCORE)

func get_rank(params: Dictionary) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/get-rank/", params)
	return send_request(request, GameJoltAPIRequest.GET_RANK)

func fetch_score(params: Dictionary) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/", params)
	return send_request(request, GameJoltAPIRequest.FETCH_SCORE)

#--- TROPHIES

func fetch_trophies(params: Dictionary) -> GameJoltAPIRequest:
	var request: String = construct_request("/trophies/", params)
	return send_request(request, GameJoltAPIRequest.FETCH_TROPHIES)

func add_achieved(params: Dictionary) -> GameJoltAPIRequest:
	var request: String = construct_request("/trophies/add-achieved/", params)
	return send_request(request, GameJoltAPIRequest.ADD_ACHIEVED)

func remove_achieved(params: Dictionary) -> GameJoltAPIRequest:
	var request: String = construct_request("/trophies/remove-achieved/", params)
	return send_request(request, GameJoltAPIRequest.REMOVE_ACHIEVED)

#Custom request
func create_request(endpoint:String, params: Dictionary, options: Dictionary = {})-> GameJoltAPIRequest:
	var request: String = construct_request(endpoint, params)
	return send_request(request, GameJoltAPIRequest.CUSTOM_REQUEST)
	
#-- REQUEST CONSTRUCTION 
func construct_request(endpoint:String, params: Dictionary) -> String:
	#Check if the API is set up
	if GAME_ID == "" and SECURE_KEY == "":
		print_debug("The API is not set up");
		return ""
	var request_url: String = ""
	var parsed_params: String = parse_parameters(params)
	request_url = "%s%s?game_id=%s&%s" % [GAME_API, endpoint, GAME_ID, parsed_params]
	return request_url

func parse_parameters(params: Dictionary) -> String:
	var parse_result: String  = ""
	var params_parsed: PoolStringArray = []
	var params_name: PoolStringArray = params.keys()
	for param_name in params_name:
		var param_value = parse_boolean(params[param_name]) if typeof(params[param_name]) == TYPE_BOOL else str(params[param_name])
		params_parsed.append("%s=%s" % [param_name, parse_blank_spaces(param_value)])
	parse_result = params_parsed.join("&") 
	return parse_result

func parse_boolean(value: bool) -> String:
	return "true" if value else "false"
	
func parse_blank_spaces(value: String) -> String:
	return value.replace(" ", "%20")

func sign_request(request_url: String) -> String:
	var signed_request: String = ""
	var signature: String = (request_url + SECURE_KEY).md5_text()
	signed_request = "%s&signature=%s" % [request_url, signature]
	return signed_request

func send_request(request: String, action: int ) -> GameJoltAPIRequest:
	var signed_request: String = sign_request(request)
	var api_request: GameJoltAPIRequest = GameJoltAPIRequestNode.instance()
	add_child(api_request)
	api_request.send(signed_request, action)
	return api_request


