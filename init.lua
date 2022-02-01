colored_eggs = {}
local MP = minetest.get_modpath("colored_eggs").."/"

dofile(MP.."colors.lua")


-- particles

local spawn_particles = function(pos, palette_index)
	local s = 1

	minetest.add_particlespawner({
		amount = 10,
		time = 0.01, -- seconds to spawn all particles
		minpos = {x=pos.x, y=pos.y, z=pos.z},
		maxpos = {x=pos.x, y=pos.y, z=pos.z},
		minvel = {x=-s, y=-s, z=-s},
		maxvel = {x=s, y=s, z=s},
		minacc = {x=0, y=-2, z=0},
		maxacc = {x=0, y=-2, z=0},
		minexptime = 1.0,
		maxexptime = 1.0,
		minsize = 0.5,
		maxsize = 0.5,
		collisiondetection = false,
		vertical = false,
		texture = "egg.png^[multiply:#"..colored_eggs.colors[palette_index+1],
		glow = 0
	})
end


-- entity

mobs:register_arrow("colored_eggs:entity", {
	visual = "sprite",
	visual_size = {x=.5, y=.5},
	textures = {"egg.png"},
	velocity = 6,

	hit_player = function(self, player)
		player:punch(minetest.get_player_by_name(self.playername) or self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
		spawn_particles(player:get_pos(), self.palette_index)
	end,

	hit_mob = function(self, mob)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 1},
		}, nil)
		spawn_particles(mob:get_pos(), self.palette_index)
	end,

	hit_node = function(self, pos, node)
		spawn_particles(pos, self.palette_index)
	end
})


-- throwing item

local egg_GRAVITY = 9
local egg_VELOCITY = 19

-- shoot egg
local shoot_egg = function (item, player, pointed_thing)
	local playerpos = player:get_pos()

	minetest.sound_play("default_place_node_hard", {
		pos = playerpos,
		gain = 1.0,
		max_hear_distance = 5,
	})

	local obj = minetest.add_entity({
		x = playerpos.x,
		y = playerpos.y +1.5,
		z = playerpos.z
	}, "colored_eggs:entity")

	local palette_index = item:get_meta():get_int("palette_index")
	obj:set_properties({textures = {"egg.png^[multiply:#"..colored_eggs.colors[palette_index+1]}})

	local ent = obj:get_luaentity()
	local dir = player:get_look_dir()

	ent.palette_index = palette_index
	ent.playername = player:get_player_name()
	ent.velocity = egg_VELOCITY -- needed for api internal timing
	ent.switch = 1 -- needed so that egg doesn't despawn straight away
	ent._is_arrow = true -- tell advanced mob protection this is an arrow

	obj:set_velocity({
		x = dir.x * egg_VELOCITY,
		y = dir.y * egg_VELOCITY,
		z = dir.z * egg_VELOCITY
	})

	obj:set_acceleration({
		x = dir.x * -3,
		y = -egg_GRAVITY,
		z = dir.z * -3
	})

	-- don't consume item if player has the 'give' privilege or has creative
	local playername = player.get_player_name and player:get_player_name() or ""
	if not (minetest.get_player_privs(playername).give or minetest.is_creative_enabled(playername)) then
		item:take_item(1)
	end

	return item
end


-- node
minetest.register_node("colored_eggs:node", {
	description = "Colored Egg",
	tiles = {"egg.png"},
	inventory_image = "egg.png",
	visual_scale = 0.7,
	drawtype = "plantlike",
	wield_image = "egg.png",
	paramtype = "light",
	paramtype2 = "color",
	palette = "unifieddyes_palette_extended.png",
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = true,
	selection_box = {
		type = "fixed",
		fixed = {-0.2, -0.5, -0.2, 0.2, 0, 0.2}
	},
	groups = {food_egg = 1, snappy = 2, dig_immediate = 3, not_in_creative_inventory=1, ud_param2_colorable = 1},
	on_use = shoot_egg,
	on_dig = unifieddyes.on_dig,
})

unifieddyes.register_color_craft({
	output = "colored_eggs:node",
	palette = "extended",
	type = "shapeless",
	neutral_node = "mobs:egg",
	recipe = {
		"NEUTRAL_NODE",
		"MAIN_DYE"
	}
})



print("[MOD] Colored Eggs loaded")
