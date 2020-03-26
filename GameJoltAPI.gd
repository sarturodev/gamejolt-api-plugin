extends Node
#-- API Settings
const GAME_API: String =  "https://api.gamejolt.com/api/game/v1_2/"
const GAME_ID : String = "478958"
const SECURE_KEY: String = "f9e9a1077e7d5d77727bd9e81f0c4192"
enum {NONE, ADD_SCORE, GET_RANK, FETCH_SCORE, ADD_ACHIEVED}
var GameJoltAPIRequest = preload("res://utils/gamejolt_api/gamejolt_api_request/GameJoltAPIRequest.tscn")

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

func add_achieved(params: Dictionary) -> GameJoltAPIRequest:
	var request_template: String = ""
	var parsed_params: String = parse_parameters(params)
	request_template = "%strophies/add-achieved/?game_id=%s&%s" % [GAME_API, GAME_ID, parsed_params]
	return send_request(request_template, ADD_SCORE)


#-- REQUEST CONSTRUCTION 

func parse_parameters(params: Dictionary) -> String:
	var parse_result: String  = ""
	var params_parsed: PoolStringArray = []
	var params_name: PoolStringArray = params.keys()
	for param_name in params_name:
		 params_parsed.append("%s=%s" % [param_name, params[param_name]])
	parse_result = params_parsed.join("&") 
	return parse_result

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


