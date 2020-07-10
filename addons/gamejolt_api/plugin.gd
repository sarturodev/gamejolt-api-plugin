tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("GameJoltAPI", "res://addons/gamejolt_api/GameJoltAPI.tscn")
	if ProjectSettings.get_setting("network/ssl/certificates") == "":
		ProjectSettings.set_setting("network/ssl/certificates", "res://addons/gamejolt_api/ssl/ca-certificates.crt")


func _exit_tree():
	remove_autoload_singleton("GameJoltAPI")
