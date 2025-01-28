extends AnimatedSprite2D

class_name Spell

@export var NAME: String = "Spell"
@export var description: String = "text"
@export var treasure_cost: int = 1
@export var texture_normal: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_pressed: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_hover: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_disabled: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_focused: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
@export var texture_click_mask: CompressedTexture2D = preload("res://png/spells/spell_tile.png")
# spell values
@export var mana_cost: int = 1
@export var spell_piercing: float
@export var attack_range: int = 1
@export var min_damage: int = 1
@export var max_damage: int = 2
@export var crit_multiplier: float = 1
@export var crit_modifier: float = 0
@export var missile: bool = false

var rng = RandomNumberGenerator.new()
const t = preload("res://ui/fading_text.tscn")

func effect(_target: Actor, _crit: bool):
	pass # No Effect, override this method

func hit_chance(attacker: Actor, target: Actor) -> float:		## Chance to hit this actor, given attacker node.
	# Armor Piercing only shreds armor, can't shred armor that isn't there ¯\_(ツ)_/¯
	var armor_total = max(target.magic_resist - attacker.spell_piercing  - spell_piercing, 0)
	var vantage = (int(target.map.is_vantage(attacker.position)) - int(target.map.is_vantage(target.position))) * Actor.VANTAGE_BONUS
	var cover = target.map.get_cover(attacker.position, target.position)
	return clamp(Actor.BASE_HIT_CHANCE + attacker.spell_skill - armor_total + ((vantage - cover) * int(missile)), Actor.MIN_HIT_CHANCE, Actor.MAX_HIT_CHANCE)

func get_damage(crit: bool = false) -> int:						## Retrieves a random damage value within this actors range.
	return rng.randi_range(min_damage, max_damage) * max(1, (int(crit) * crit_multiplier))

func attack(attacker: Actor, target: Actor) -> int:				## Attack vs. this player.
	var damage_text = t.instantiate()
	var damage: int = 0
	if rng.randf() < hit_chance(attacker, target):
		var text_type = damage_text.TEXT_TYPE_NEGATIVE
		if rng.randf() < attacker.BASE_CRIT_CHANCE + attacker.crit_modifier:
			damage = attacker.get_damage(true)
			effect(target, true)
			text_type = damage_text.TEXT_TYPE_CRITICAL
			damage_text.scale = Vector2.ONE * attacker.crit_multiplier
		else:
			damage = attacker.get_damage()
			effect(target, false)
		damage_text.set_text(str(damage), text_type)
		target.anim_player.play("damage")
		target.hp -= damage
	else:
		target.anim.play("block " + target.facing)
		damage_text.set_text("RESIST", damage_text.TEXT_TYPE_BLOCK)
		target.anim_player.play("block")
	# Die if below 0 HP
	if target.hp <= 0:
		target.die()
	target.add_child(self)
	play("hit")
	target.add_child(damage_text)
	if !target.is_sig and target.target == null and target.hp > 0:
		target.aggro(attacker)
	return damage


# Engine
func _on_animation_finished() -> void:
	if animation.contains("hit") and get_parent():
		get_parent().remove_child(self)
