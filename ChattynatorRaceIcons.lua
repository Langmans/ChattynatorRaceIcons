local addonName = ...

local lower = string.lower
local format = string.format
local gsub = string.gsub
local CreateAtlasMarkup = CreateAtlasMarkup
local CreateSimpleTextureMarkup = CreateSimpleTextureMarkup
--local setmetatable = setmetatable

local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local ElvUI_EltreumUI = ElvUI_EltreumUI
local DLAPI = DLAPI

---@type function(any, ...): void
local function Debug(...)
    if DLAPI then
        DLAPI.DebugLog(addonName, ...)
    end
end

local atlasMarkup = setmetatable({}, {
	__mode = "kv",
	__index = function(self, key)
		local markup = CreateAtlasMarkup(key)
		self[key] = markup
		Debug('atlasMarkup[%q] = %q', key, markup)
		return self[key]
	end
})
local eltreumRaceIcons = setmetatable({}, {
	__mode = "kv",
	__index = function(self, key)
		local markup = CreateSimpleTextureMarkup(format([[Interface\Addons\ElvUI_EltreumUI\Media\Textures\Races\%s\%s.tga]],
				isRetail and 'Retail' or 'Classic', key
		), 0, 0)
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

		local icon = ElvUI_EltreumUI
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
		data.text = gsub(data.text, "(|Hplayer:[^|]+|h)(%[?)", "%1%2" .. icon)

		--Debug("race = %q, sex = %q, icon = %q", race, sex, icon)
	end
end)
