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

Chattynator.API.AddModifier(function(data)
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

		-- The icon goes just before the player link, not inside it: Eltruism's race texture, a file
		-- path, did not draw inside the link's text (after another icon there), while it did outside.
		data.text = gsub(data.text, "|Hplayer:", icon .. "%0", 1)
	end
end)
