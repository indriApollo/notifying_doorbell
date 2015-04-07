
notifying_doorbell = {}

local formspec_context = {}

notifying_doorbell.edit = function(pos,name)
	formspec_context[name] = {pos = pos}
	local meta = minetest.get_meta(pos)
	local doorbell_id = meta:get_string("doorbell_id") or ""
	meta:set_string("doorbell_owner",name)
	minetest.show_formspec(name, "notifying_doorbell:edit",
				"size[4,3]" ..
				"field[1,1;3,1;doorbell_id;Bell Name;"..doorbell_id.."]" ..
				"button_exit[1,2;2,1;exit;Save]")
end

minetest.register_node("notifying_doorbell:doorbell", {
	tiles = { "notifying_doorbell.png" },
	inventory_image = "notifying_doorbell_inv.png",
	description = "Notifying Doorbell",
	drawtype = "nodebox",
	paramtype = "light",
    paramtype2 = "facedir",
    groups = {snappy=3},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.0625, 0, 0.46875, 0.0625, 0.1875, 0.5}, -- NodeBox1
			{-0.03125, 0.0625, 0.45, 0.03125, 0.125, 0.4675}, -- NodeBox2
		}
	},
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		local name = player:get_player_name()
		local owner = minetest.get_meta(pos):get_string("doorbell_owner")
		if name == owner then
			notifying_doorbell.edit(pos,name)
		else
			local doorbell_id = minetest.get_meta(pos):get_string("doorbell_id")
			minetest.sound_play("notifying_doorbell", {
				to_player = name,
				gain = 1.5,
			})
			minetest.sound_play("notifying_doorbell", {
				to_player = owner,
				gain = 1.5,
			})
			minetest.chat_send_player(owner,"* "..name.." rang the door bell at "..doorbell_id)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local name = placer:get_player_name()
		notifying_doorbell.edit(pos,name)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "notifying_doorbell:edit" then
		return false -- not our form
	end
	local name = player:get_player_name()
	if formspec_context[name].pos then
		local pos = formspec_context[name].pos
		formspec_context[name] = nil -- we free the context
		if not fields.doorbell_id then
			minetest.get_meta(pos):set_string("doorbell_id","noname")
		else
			minetest.get_meta(pos):set_string("doorbell_id",fields.doorbell_id)
		end
		minetest.chat_send_player(name,"* Doorbell updated")
	else
		minetest.chat_send_player(name,"* Something went wrong, please try again")
	end
	return true
end)


minetest.register_craft( {
        output = "notifying_doorbell:doorbell",
        recipe = {
			{ "default:steel_ingot", "default:steelblock", "default:steel_ingot" }
        },
})
