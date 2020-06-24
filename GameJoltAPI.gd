extends Node
#-- API Settings
const GAME_API: String =  "https://api.gamejolt.com/api/game/v1_2/"
const GAME_ID : String = "478958"
const SECURE_KEY: String = "f9e9a1077e7d5d77727bd9e81f0c4192"
var username: String = ""
var game_token: String = ""
enum {NONE, ADD_SCORE, GET_RANK, FETCH_SCORE, FETCH_TROPHIES, ADD_ACHIEVED, REMOVE_ACHIEVED}
var GameJoltAPIRequest = preload("res://utils/gamejolt_api/gamejolt_api_request/GameJoltAPIRequest.tscn")


# Get username and game token (only avaliable for HTML5 games)
func get_web_user_credentials() -> void:
	if OS.has_feature('JavaScript'):
		username = JavaScript.eval("new URLSearchParams(window.location.search).get('gjapi_username') || ''")  
		game_token = JavaScript.eval("new URLSearchParams(window.location.search).get('gjapi_token') || ''")
		if username != "" and game_token != "":
			print_debug("Error: Cannot get the user credentials")
	else:
		print_debug("Error: JavaScript is not soported")

#--- SCORES

func add_score(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%sscores/add/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, ADD_SCORE)

func get_rank(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%sscores/get-rank/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, GET_RANK)

func fetch_score(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%sscores/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, FETCH_SCORE)

#--- TROPHIES

func fetch_trophies(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%strophies/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, FETCH_TROPHIES)

func add_achieved(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%strophies/add-achieved/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, ADD_ACHIEVED)

func remove_achieved(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%strophies/remove-achieved/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, REMOVE_ACHIEVED)

#-- REQUEST CONSTRUCTION 

func parse_parameters(params: Dictionary) -> String:
	var parse_result: String  = ""
	var params_parsed: PoolStringArray = []
	var params_name: PoolStringArray = params.keys()
	for param_name in params_name:
		var param_value = parse_boolean(params[param_name]) if typeof(params[param_name]) == TYPE_BOOL else params[param_name]
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

func send_request(request_template: String, action: int ) -> GameJoltAPIRequest:
	var signed_request: String = sign_request(request_template)
	var api_request: GameJoltAPIRequest = GameJoltAPIRequest.instance()
	add_child(api_request)
	api_request.send(signed_request, action)
	return api_request


