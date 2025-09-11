extends Node2D

@onready var player: CharacterBody2D = $CharacterBody2D

func _ready() -> void:
	$AnimationPlayer.play("plank")
	$AnimationPlayer2.play("planet")


func _on_character_body_2d_parent_found(area: Area2D) -> void:
	if area is GravityArea:
		var planet = area.get_master()
		player.reparent(planet)


func _on_character_body_2d_parent_lost() -> void:
	player.reparent(self)
