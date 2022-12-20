require("mock")
require("utils")

local current_lang = arg[1]
local output_dir = arg[2].."/"..current_lang.."/"
os.execute("mkdir -p "..output_dir)

local supported_languages = {
  "en", "zh-CN", "zh-TW", "fr",
  "de", "it", "ja", "ko", "pl",
  "pt", "ru", "es", "es-MX"
}

local function get_file_name(lang)
  if lang == "zh-CN" then
    return "chinese_s.po"
  end
  if lang == "zh-TW" then
    return "chinese_t.po"
  end
  if lang == "fr" then
    return "french.po"
  end
  if lang == "de" then
    return "german.po"
  end
  if lang == "it" then
    return "italian.po"
  end
  if lang == "ja" then
    return "japanese.po"
  end
  if lang == "ko" then
    return "korean.po"
  end
  if lang == "pl" then
    return "polish.po"
  end
  if lang == "pt" then
    return "portuguese_br.po"
  end
  if lang == "ru" then
    return "russian.po"
  end
  if lang == "es" then
    return "spanish.po"
  end
  if lang == "es-MX" then
    return "spanish_mex.po"
  end
  return "unsupported_lang.po"
end

if Indexof(supported_languages, current_lang) == -1 then
  print("Unsupported language: "..current_lang)
  os.exit(1)
end

-- ---------- ---------- ---------- ---------- ---------- ---------- --
-- Load global variable STRINGS
require("strings")

-- ---------- ---------- ---------- ---------- ---------- ---------- --
-- Update global variable STRINGS

local function get_value_from_strings(key)
  local list = Split(key, ".")
  local v = STRINGS
  for i = 2, #list, 1 do
    v = v[list[i]]
  end
  return v
end

local function set_value_to_strings(key, value)
  local list = Split(key, ".")
  local k = ""
  local index = nil
  local v = STRINGS

  for i = 2, #list-1, 1 do
    k = list[i]
    index = tonumber(list[i])
    if index then
      v = v[index]
    else
      v = v[k]
    end
  end

  k = list[#list]
  index = tonumber(k)
  if index then
    v[index] = value
  else
    v[k] = value
  end
end

-- copy from scripts/translator.lua
local function join_po_file_multiline_strings(fname)
	local lines = {}
	local workline = ""
	local started = false
	for i in io.lines(fname) do
		if i:sub(1,1) == "#" then
			started = true
		end
		if started and workline:sub(-1) == '"' and i:sub(1,1)=='"' then
			workline = workline:sub(1,-2)..i:sub(2)
		else
			lines[#lines+1] = workline
			workline = i
		end
	end
	lines[#lines+1] = workline
	return lines
end

-- copy from scripts/translator.lua
local function join_po_file_multiline(fname)
	local i = 0
	local lines = join_po_file_multiline_strings(fname)
	return function()
	      i = i + 1
	      if i > #lines then return nil
	      else return lines[i] end
	end
end

local function parse_po_file_and_update_strings()
  if current_lang == "en" then
    return
  end
  local file_path = "./languages/"..get_file_name(current_lang)

	local current_id = ""
	local localized_en = ""

  for line in join_po_file_multiline(file_path) do

    if current_id == "" then
			local _, _, id = string.find(line, "^msgctxt%s*\"(%S*)\"")
      if id then current_id = id end
    elseif localized_en == "" then
			local _, _, en = string.find(line, "^msgid%s*\"(.+)\"")
      if en then localized_en = en end
    else
			local _, _, other = string.find(line, "^msgstr%s*\"(.+)\"")
      if other then
        set_value_to_strings(current_id, other)
        current_id = ""
        localized_en = ""
      end
    end

  end
end

parse_po_file_and_update_strings()

-- ---------- ---------- ---------- ---------- ---------- ---------- --

local C = require("customize")

local function repack_setting_options(options)
  local table = {
    data = {},
    display = {},
  }
  for index, option in ipairs(options) do
    table.data[index] = option.data
    table.display[index] = option.text
  end
  return table
end

local key_prefix = "STRINGS.UI.CUSTOMIZATIONSCREEN."
local json_prefix_lv1 = "  "
local json_prefix_lv2 = "    "
local json_prefix_lv3 = "      "
local json_prefix_lv4 = "        "

local gen_order_list = {}
for key, data in pairs(C.WORLDGEN_GROUP) do
  gen_order_list[data.order] = key
end
local set_order_list = {}
for key, data in pairs(C.WORLDSETTINGS_GROUP) do
  -- order of "global" is 0 but lua index start from 1
  set_order_list[data.order + 1] = key
end

local function output_json(is_gen, world_type)
  local file_name = world_type
  local order_list = {}
  if is_gen then
    file_name = file_name..".gen."
    order_list = gen_order_list
  else
    file_name = file_name..".set."
    order_list = set_order_list
  end
  file_name = output_dir..file_name..current_lang..".json"
  print("New JSON File: "..file_name)
  local output = io.open(file_name, "w")

  output:write("[\n")
  for order, group_key in ipairs(order_list) do
    local group_data = nil
    if is_gen then
      group_data = C.WORLDGEN_GROUP[group_key]
    else
      group_data = C.WORLDSETTINGS_GROUP[group_key]
    end

    output:write(json_prefix_lv1.."{\n")
    output:write(json_prefix_lv2.."\"name\": \""..group_key.."\",\n")
    output:write(json_prefix_lv2.."\"display\": \""..group_data.text.."\",\n")
    output:write(json_prefix_lv2.."\"options\": [\n")
  
    local items_size = 0
    for _, data in pairs(group_data.items) do
      local a = not is_gen
      local b = data.world and Indexof(data.world, world_type) ~= -1
      if a or b then
        items_size = items_size + 1
      end
    end
    local count = 0

    local sortedOptionsList = GetSortedKeyArray(group_data.items)
    for _, setting_key in ipairs(sortedOptionsList) do
      local setting_data = group_data.items[setting_key]
      if is_gen and setting_data.world then
        local is_target_world = Indexof(setting_data.world, world_type)
        if is_target_world == -1 then
          goto continue
        end
      end
      count = count + 1

      local id = setting_key
      local display_name = get_value_from_strings(key_prefix..string.upper(setting_key))
      local default_value = setting_data.value
      local options = nil
      if setting_data.desc then
        options = setting_data.desc
      else
        options = group_data.desc
      end
      if type(options) == "function" then
        options = options(setting_data.world[1])
      end
  
      local setting_table = repack_setting_options(options)
      output:write(json_prefix_lv3.."{\n")

      output:write(json_prefix_lv4.."\"key\": \""..id.."\",\n")
      output:write(json_prefix_lv4.."\"display\": \""..display_name.."\",\n")
      output:write(json_prefix_lv4.."\"value\": \""..default_value.."\",\n")
      output:write(json_prefix_lv4.."\"options\": [\""..table.concat(setting_table.data, "\", \"").."\"],\n")
      output:write(json_prefix_lv4.."\"opts-display\": [\""..table.concat(setting_table.display, "\", \"").."\"]\n")
  
      if count < items_size then
        output:write(json_prefix_lv3.."},\n")
      else
        output:write(json_prefix_lv3.."}\n")
      end
      ::continue::
    end
  
    output:write(json_prefix_lv2.."]\n")
    if order < #order_list then
      output:write(json_prefix_lv1.."},\n")
    else
      output:write(json_prefix_lv1.."}\n")
    end
  end
  output:write("]\n")
  output:close()
end

output_json(true, "forest")
output_json(false, "forest")
output_json(true, "cave")
output_json(false, "cave")
