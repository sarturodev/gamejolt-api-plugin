extends Node
#-- API Settings
const GAME_API: String =  "api.gamejolt.com/api/game/v1_2"
var GAME_ID : String = ""
var PRIVATE_KEY: String = ""
var username: String = ""
var user_token: String = ""

var GameJoltAPIRequestNode = preload("res://addons/gamejolt_api/gamejolt_api_request/GameJoltAPIRequest.tscn")
var GameJoltAPIPromiseNode = preload("res://addons/gamejolt_api/gamejolt_api_promise/GameJoltAPIPromise.tscn")

# Get username and game token (only available for HTML5 games)
func get_user_credentials() -> void:
	if OS.has_feature('JavaScript'):
		username = JavaScript.eval("new URLSearchParams(window.location.search).get('gjapi_username') || ''")  
		user_token = JavaScript.eval("new URLSearchParams(window.location.search).get('gjapi_token') || ''")
		if username != "" and user_token != "":
			print_debug("Error: Cannot get the user credentials")
	else:
		print_debug("Error: JavaScript is not supported")

func set_game_credentials(params: Dictionary) -> void:
	if params["game_id"] && params["private_key"]:
		if params["game_id"] is String and params["private_key"] is String:
			GAME_ID = params["game_id"]
			PRIVATE_KEY = params["private_key"]
	else:
		print_debug("Error: Game credentials cannot be set up")
	pass

#--- SCORES

func add_score(params: Dictionary, options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/add/", params, options)
	return send_request(request, GameJoltAPIRequest.ADD_SCORE)

func get_rank(params: Dictionary, options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/get-rank/", params, options)
	return send_request(request, GameJoltAPIRequest.GET_RANK)

func fetch_score(params: Dictionary, options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/", params, options)
	return send_request(request, GameJoltAPIRequest.FETCH_SCORE)

func tables(options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/scores/tables", {}, options)
	return send_request(request, GameJoltAPIRequest.TABLES)

#--- TROPHIES

func fetch_trophy(params: Dictionary, options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/trophies/", params, options)
	return send_request(request, GameJoltAPIRequest.FETCH_TROPHIES)

func add_achieved(params: Dictionary, options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/trophies/add-achieved/", params, options)
	return send_request(request, GameJoltAPIRequest.ADD_ACHIEVED)

func remove_achieved(params: Dictionary, options: Dictionary = {"ssl": true}) -> GameJoltAPIRequest:
	var request: String = construct_request("/trophies/remove-achieved/", params, options)
	return send_request(request, GameJoltAPIRequest.REMOVE_ACHIEVED)

#Custom request
func create_request(endpoint:String, params: Dictionary, options: Dictionary = {"ssl": true})-> GameJoltAPIRequest:
	var request: String = construct_request(endpoint, params, options)
	return send_request(request, GameJoltAPIRequest.CUSTOM_REQUEST)
	
#-- REQUEST CONSTRUCTION 
func construct_request(endpoint:String, params: Dictionary, options: Dictionary) -> String:
	#Check if the API is set up
	if GAME_ID == "" and PRIVATE_KEY == "":
		print_debug("The API is not set up");
		return ""
	var request_url: String = ""
	var protocol: String = "https://" if (options.has("ssl") and options["ssl"] == true) else "http://"
	var parsed_params: String = parse_parameters(params)
	if parsed_params == "":
		request_url = "%s%s%s?game_id=%s" % [protocol, GAME_API, endpoint, GAME_ID]
	else:
		request_url = "%s%s%s?game_id=%s&%s" % [protocol, GAME_API, endpoint, GAME_ID, parsed_params]
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
	var signature: String = (request_url + PRIVATE_KEY).md5_text()
	signed_request = "%s&signature=%s" % [request_url, signature]
	return signed_request

func send_request(request: String, action: int ) -> GameJoltAPIRequest:
	var signed_request: String = sign_request(request)
	var api_request: GameJoltAPIRequest = GameJoltAPIRequestNode.instance()
	add_child(api_request)
	api_request.send(signed_request, action)
	return api_request
	
func handle_requests(requests:Array, target: Node, resolve_action: String, reject_action: String = "") -> void:
	var promise: GameJoltAPIPromise = GameJoltAPIPromiseNode.instance()
	add_child(promise)
	promise.initialize(requests, target, "api_request_completed", resolve_action, "api_request_failed", reject_action)
