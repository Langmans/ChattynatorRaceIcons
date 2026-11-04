local addonName = ...

local lower = string.lower
local format = string.format
local gsub = string.gsub
local CreateAtlasMarkup = CreateAtlasMarkup
--local setmetatable = setmetatable

local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local DLAPI = DLAPI

---@type function(any, ...): void
local function Debug(...)
    if DLAPI then
        DLAPI.DebugLog(addonName, ...)
    end
end

local atlasMarkup = setmetatable({}, {
	__index = function(self, key)
		local markup = CreateAtlasMarkup(key)
		self[key] = markup
		Debug('atlasMarkup[%q] = %q', key, markup)
		return self[key]
	end
})
-- Eltruism's race icons, its Retail set on every client: it has every race the Classic set has,
-- in a newer style. Keyed by race file and sex ("NightElf3"). The markup is the one seen to draw in
-- chat: no ".tga" and one size, 0 (the text's height); with ".tga:0:0:0:0" it stayed empty.
local eltreumRaceIcons = setmetatable({}, {
	__index = function(self, key)
		local markup = format([[|TInterface\Addons\ElvUI_EltreumUI\Media\Textures\Races\Retail\%s:0|t]], key)
		self[key] = markup
		Debug('eltreumRaceIcons[%q] = %q', key, markup)
		return self[key]
	end
})

local raceReplacements = {
	Scourge = "Undead",
	HighmountainTauren = "Highmountain",
	LightforgedDraenei = "Lightforged",
	ZandalariTroll = "Zandalari",
}

---A chat text for the log: "|" doubled, so markup shows as text instead of drawing.
---@param text string
---@return string
local function Visible(text)
	return (gsub(text, "|", "||"))
end

Chattynator.API.AddModifier(function(data)
	local seen = data.typeInfo.player
	Debug("line: player=%s race=%s sex=%s", tostring(seen and seen.name), tostring(seen and seen.race),
		tostring(seen and seen.sex))
	if data.typeInfo.player and data.typeInfo.player.race then
		local player = data.typeInfo.player
		local race, sex = player.race, player.sex

		-- if undefined sex or neuter then female is assumed
		if not sex or sex == 1 then
			sex = 3
		end

		-- Looked up per line: Eltruism's global is there once it has loaded, whatever the load order.
		local icon = rawget(_G, "ElvUI_EltreumUI")
			and eltreumRaceIcons[race .. sex]
			or atlasMarkup[(isRetail and "raceicon128-%s-%s" or "raceicon-%s-%s"):format(
				lower(raceReplacements[race] or race),
				sex == 3 and "female" or "male"
			)]

		--[[
		(|Hplayer:[^|]+|h) matches the player link up to |h.
		(%[?) matches an optional [.
		The replacement %1%2 preserves both parts, then adds the icon markup after, regardless of whether [ is present.
		--]]
		local count
		data.text, count = gsub(data.text, "(|Hplayer:[^|]+|h)(%[?)", "%1%2" .. icon)
		Debug("inserted %d: %s", count, Visible(data.text))
	end
end)
