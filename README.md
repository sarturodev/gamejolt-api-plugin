# GameJoltAPI Plugin V 1.0

This plugin for Godot 3.2 allows you to easily implement the [**Game Jolt API**](https://gamejolt.com/game-api) into your games.

 - Quick installation and configuration (see the Get Started section).
 - Use the API by calling simple GD functions (see the Documentation page).
 - Make custom API requests.
 - Create and handle simultaneous Game Jolt API requests. 

# Get started
## Instalation

 1. Copy and paste the folder `gamejolt_api` in the `res://addons/` path from your project.
 
 2. To activate/deactivate the plugin, go to `Project>Project Settings>Plugins`, and change its status.
 
Once installed, the plugin will automatically configure and load the **GameJoltAPI** scene as an Singleton Object.  To use the API just call the GameJoltAPI's functions.

## Configuration

Use the following function to set up the Game API settings:
``` GDscript
  GameJoltAPI.set_game_credentials({
  "game_id": "YOUR GAME ID",
  "private_key": "YOUR PRIVATE KEY"
  })
``` 
You can find this information in Game Jolt, by going to `Game Page > Manage Game > Game API > API Settings`.

**You must call this function before making a request.**

## Getting the player's credentials

If your project will be exported as an **HTML5 game**, you can use the following function:

```GDscript
  GameJoltAPI.get_user_credentials()
 ```
You can manually gather the credentials of the player within the game and assign the following variables:
```GDscript
  GameJoltAPI.username = "GAMEJOLT USERNAME"
  GameJoltAPI.user_token = "PLAYER'S GAME TOKEN"
 ```

## Make your first GAME JOLT API request
Once you have set up de API, you are ready to make  API requests.

### Let's create a trophy!

You can add a new trophy by going to `Game Page > Manage Game > Game API > Trophies` . Click on `NEW TROPHY`, fill the `Title` and add an `Image` (1500x1500 px is a good resolution). A `TROPHY ID` wil be generated, we will use it in our API request.

### Let's make a request to the API

Let's make the player achieve the trophy in the game by calling the following function:

```GDscript
	var trophy_request = GameJoltAPI.add_achieved({
		"username": GameJoltAPI.username,
		"user_token": GameJoltAPI.user_token,
		"trophy_id": "YOUR TROPHY ID"
	})
 ```
 Note that we are using all the required parameters (except the `game_id`) to make the API request: `Add Achieved` (for more information, go to the official [Game Jolt API documentation](https://gamejolt.com/game-api/doc/trophies/add-achieved)).

### Handle the API response:
The Game Jolt API request can emit the folllowing signals:

 - `api_request_completed`: This signal will be emitted when the request was successfully processed by the Game Jolt Server. This signal will return an Array containing the server response.
 - `api_request_failed`: This signal will be emitted if an error occurs during the sending or processing stage of the request. This signal will return an `error` message.
 
These signals can be connected via GDScript: 

```GDscript

	trophy_request.connect("api_request_completed", 
	self, "_on_request_completed")
	
	trophy_request.connect("api_request_failed", 
	self, "_on_request_completed")
	
 ```
 The following functions will be executed when the signals are emitted:
 ```GDscript
		function _on_request_completed(data: Array) -> void:
			#Do something
			pass
		function _on_request_failed(error: String) -> void:
			#Do something
			pass
  ```
  For more information about the GamejoltAPI' functions, check the Documentation page.
  
## Make a custom request
In addition to the available functions, you can make your own custom requests:
 ```GDscript
		var custom_request = GameJoltAPI.create_request(
		"/trophies/",
		{
        "username": GameJoltAPI.username, 
        "user_token": GameJoltAPI.user_token
		})
		#Connect to the signals:
		custom_request.connect("api_request_completed", self, "_on_custom_request_completed")
  ```
Remember, you must introduce all the required API parameters (except the "game_id").

## Handle multiple API requests
 The `handle_requests` function allows you to trigger an action when all requests have been successfully completed. If one of the requests fails, you can execute another action instead (this is optional).
 
Imagine that you want to show a message to the player once his score has been registered and he has obtained a trophy:

 ```GDscript
	  #request 1
	  var score_request = GameJoltAPI.add_score({
	  "username": GameJoltAPI.username,
	  "user_token": GameJoltAPI.user_token,
	  "score": player_score
	  "sort": player_score
	  })
	  #request 2
	  var trophy_request = GameJoltAPI.add_achieved({
	  "username": GameJoltAPI.username,
	  "user_token": GameJoltAPI.user_token,
	  "trophy_id": "124565"
	  })

	#Handle the API requests
	GameJoltAPI.handle_requests(
	[score_request, trophy_request],
	self,
	"_on_requests_completed",
	"_on_requests_failed"
	)
  ```
If both requests were successful, the function `_on_requests_completed` will be called, returning as a parameter an Array with the responses given by the API.  

Otherwise, if an error occurs in one of the requests, the function `_on_requests_failed` will be called, returning the error message as a parameter.

 ```GDscript
	func _on_requests_completed(responses: Array) -> void:
		#Do an action
		pass
		
	func _on_requests_failed(error: String) -> void:
    #Do another action
    pass
  ```
And that's it! If you want more information about the available functions, check out the Documentation page.
If you want to know more about the Game Jolt API, check the [**Official Documentation**](https://gamejolt.com/game-api).
