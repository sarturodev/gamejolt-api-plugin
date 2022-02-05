# GameJoltAPI Plugin V 1.3

 
This plugin for Godot 3.x allows you to easily integrate the [**Game Jolt API**](https://gamejolt.com/game-api) into your games.

- **Quick installation and configuration** (see the Get Started section).

- Use the API by **calling simple GD functions** (see the [Documentation](https://github.com/sarturodev/gamejolt-api-plugin/wiki) page).
- **Automatically get player credentials** through the **Game Jolt Desktop App** and **Web builds**. 

- Make **custom GJ API requests**.

- Create and handle **simultaneous GJ API requests**.

[**Download**](https://gamejolt.com/games/ambush_fish/512872) the sample Godot project!

# Get started

## Installation

1. Copy and paste the folder `addons` in the `res://` path of your game project.

2. To activate/deactivate the plugin, go to `Project>Project Settings>Plugins`, and change its status.

Once installed, the plugin will automatically configure and load the **GameJoltAPI** singleton.
To use the API just call the GameJoltAPI's functions.
  

## Configuration

 Use the following function to set up the Game API settings:

``` GDscript

GameJoltAPI.set_game_credentials({

"game_id": "YOUR GAME ID",

"private_key": "YOUR PRIVATE KEY"

})

```
You can find the  **game credentials** in Game Jolt, by going to the `Game Page > Manage Game > Game API > API Settings`.
  
 This function only needs to be called once, it is recommended to place it in the main scene of your game.
 
**You must call this function before making a GJ API equest.**

## Getting the player's credentials

In order to automatically get the player's credentials in your game, you need to call the following function: 

```GDscript

GameJoltAPI.get_user_credentials()

```

This function is only available when running the game in the Game Jolt Desktop App and Web builds.

You can manually set the player's in-game credentials (useful for debugging and testing):

```GDscript

GameJoltAPI.username = "GAMEJOLT USERNAME WITHOUT @"

GameJoltAPI.user_token = "PLAYER'S GAME TOKEN"

```

## Make your first Game Jolt API request

Once you have set up the API, you are ready to make API requests.
  
### Let's create a trophy!

You can add a new trophy by going to `Game Page > Manage Game > Game API > Trophies` . Click on `NEW TROPHY`, fill the `Title` and add an `Image`.  A **`TROPHY ID`** wil be generated, we will use it in our API request.

### Let's make a request to the Game Jolt API
 
Let's make the player achieve the trophy within the game by calling the following function:

```GDscript

var trophy_request = GameJoltAPI.add_achieved({

"username": GameJoltAPI.username,

"user_token": GameJoltAPI.user_token,

"trophy_id": "YOUR TROPHY ID"

})

```

Note that we are using all the required parameters (except the **`game_id`**) to make the API request: **`Add Achieved`** (for more information, go to the official [Game Jolt API documentation](https://gamejolt.com/game-api/doc/trophies/add-achieved)).

### Handle the API response:

A **GameJoltAPI** request have the following signals:

-  **`api_request_completed`**: This signal will be emitted when the request is successfully processed by the Game Jolt Server. This signal will return an Array containing the server response.

-  **`api_request_failed`**: This signal will be emitted if an error occurs during the sending or processing stage of the request. This signal will return an `error` message.

These signals can be connected though GDScript:

  

```GDscript

trophy_request.connect("api_request_completed",

self, "_on_request_completed")

trophy_request.connect("api_request_failed",

self, "_on_request_failed")

```

The following functions will be executed when the signals are triggered:

```GDscript

func _on_request_completed(data: Array):

#Do something

pass


func _on_request_failed(error: String):

#Do something

pass

```

For more information about the GameJoltAPI' functions, check the [**Documentation**](https://github.com/sarturodev/gamejolt-api-plugin/wiki).

  

## Make a custom request

In addition to the available GamejoltAPI functions, you can make your own custom requests:

```GDscript

var custom_request = GameJoltAPI.create_request("/trophies/",
{
"username": GameJoltAPI.username,
"user_token": GameJoltAPI.user_token
})

  
#Connect to the signals:

custom_request.connect("api_request_completed", self, "_on_custom_request_completed")

```

**You must introduce all the required Game Jolt API parameters (except the "game_id")**.


## Handle multiple API requests

The **`handle_requests`** function allows you to trigger an action when all requests have been successfully completed. If one of the requests fails, you can trigger another action instead (this is optional).

In the following example, we want to display a message to the player once his score has been registered and he has won a trophy:
 

```GDscript

#request 1 (Saving the Player Score)

var score_request = GameJoltAPI.add_score({

"username": GameJoltAPI.username,

"user_token": GameJoltAPI.user_token,

"score": player_score,

"sort": player_score

})

  

#request 2 (Give a trophy to the player)

var trophy_request = GameJoltAPI.add_achieved({

"username": GameJoltAPI.username,

"user_token": GameJoltAPI.user_token

})

  

#Handle the API requests

GameJoltAPI.handle_requests( [score_request, trophy_request],
self, "_on_requests_completed", "_on_requests_failed")

```

If both requests were successful, the function **`_on_requests_completed`**  will be called, returning as a parameter an Array with the responses given by the API.

Otherwise, if an error occurs in one of the requests, the function **`_on_requests_failed`**  will be called, returning the error message as a parameter.
  

```GDscript

func _on_requests_completed(responses: Array):

#Do an action

pass

func _on_requests_failed(error: String):

#Do another action

pass

```

## Exporting your game

In order to perform Game Jolt API requests through the HTTPS protocol, it is necessary to use an **SSL certificate**. The plugin has the file **ca-certificates.crt** which is automatically included in your project when you install the plugin.

Remember to add **.crt** into the filters so the exporter recognizes this when exporting your project.

![including .crt as filter](https://docs.godotengine.org/en/latest/_images/add_crt.png)

  

And that's it! If you want more information about the available functions, check out the [**GameJoltAPI Plugin Documentation**](https://github.com/sarturodev/gamejolt-api-plugin/wiki).

If you want to know more about the Game Jolt API, check the [**Official Documentation**](https://gamejolt.com/game-api).

[**Download**](https://gamejolt.com/games/ambush_fish/512872) the sample Godot project.