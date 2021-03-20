local flib_gui = require("__flib__.gui-beta")
local Event = require("__stdlib__/stdlib/event/event")
local std_string = require("__stdlib__/stdlib/utils/string")

function create_combinator_gui(player_index, unit_number)
	-- Check if it doesn't exist already
	local combinator_gui = get_combinator_gui(player_index, unit_number)
	if combinator_gui then
		debug_log(player_index, "HUD Combinator GUI with unit_number " .. tostring(unit_number) .. " already has a GUI open/created.")
		combinator_gui.destroy()
		return
	end

	-- add the frame
	local player = get_player(player_index)
	local ui_name = HUD_NAMES.combinator_root_frame .. "_" .. tostring(unit_number)
	local refs =
		flib_gui.build(
		player.gui.screen,
		{
			{
				type = "frame",
				name = ui_name,
				ref = {
					HUD_NAMES.combinator_root_frame
				},
				direction = "vertical",
				children = {
					{
						type = "flow",
						ref = {"titlebar_flow"},
						style = "flib_titlebar_flow",
						children = {
							{
								-- add the title label
								type = "label",
								style = "frame_title",
								caption = "HUD Combinator",
								ignored_by_interaction = true
							},
							{
								-- add a pusher (so the close button becomes right-aligned)
								type = "empty-widget",
								style = "flib_titlebar_drag_handle",
								ignored_by_interaction = true
							},
							{
								type = "sprite-button",
								style = "frame_action_button",
								sprite = "utility/close_white",
								actions = {
									on_click = {
										gui = GUI_TYPES.combinator,
										action = GUI_ACTIONS.close,
										unit_number = unit_number
									}
								}
							}
						}
					},
					{
						type = "frame",
						style = "inside_shallow_frame_with_padding",
						direction = "vertical",
						ref = {"inner_frame"},
						children = {
							{
								type = "label",
								caption = "Name",
								style = "heading_2_label"
							},
							{
								type = "textfield",
								ref = {
									"name_field"
								},
								style = "production_gui_search_textfield",
								text = get_hud_combinator_name(unit_number),
								actions = {
									on_text_changed = {
										gui = GUI_TYPES.combinator,
										action = GUI_ACTIONS.name_change,
										unit_number = unit_number
									}
								}
							}
						}
					}
				}
			}
		}
	)

	local root_frame = refs[HUD_NAMES.combinator_root_frame]
	refs.titlebar_flow.drag_target = root_frame
	refs.name_field.select(0, 0)

	player.opened = root_frame
	player.opened.force_auto_center()
end

function get_combinator_gui(player_index, unit_number)
	local player = get_player(player_index)
	if player then
		local gui_windows = player.gui.screen.children
		for _, value in pairs(gui_windows) do
			if std_string.ends_with(value.name, tostring(unit_number)) then
				return value
			end
		end
	end
	return nil
end

function handle_combinator_gui_events(player_index, action)
	local combinator_gui = get_combinator_gui(player_index, action.unit_number)
	if not combinator_gui then
		return
	end

	if action.action == GUI_ACTIONS.close then
		combinator_gui.destroy()
	end

	if "lol" == "test" then
		local unit_number = string.match(event.element.name, "hudcombinatortitle%-%-(%d+)")

		if unit_number then
			-- find the entity
			local hud_combinator = get_hud_combinator(tonumber(unit_number))
			if hud_combinator and hud_combinator.entity.valid then
				-- open the map on the coordinates
				local player = game.players[event.player_index]
				player.zoom_to_world(hud_combinator.entity.position, 2)
			end
		end
	end
end
