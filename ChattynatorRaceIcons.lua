local addonName = ...

---@type function(any, ...): void
local function Debug(...)
    if DLAPI then
        DLAPI.DebugLog(addonName, ...)
    end
end

---@type function(any): string
local dump
do
    local type = type
    local tostring = tostring
    local next = next
    local format = string.format

    local function is_list(t)
        if type(t) ~= "table" then
            return false
        end
        local i = 0
        for _ in next, t do
            i = i + 1
            if t[i] == nil then
                return false
            end
        end
        return true
    end

    local dumpers = {
        ["table"] = function(val)
            local s = ""
            if is_list(val) then
                s = "{"
                for _, v in next, val do
                    s = s .. dump(v) .. ', '
                end
                s = s .. "}"
            else
                s = "{"
                for k, v in next, val do
                    s = s .. format("[%q] = %s, ", k, dump(v))
                end
                s = s .. "}"
            end
            return s
        end,
        ["boolean"] = function(val)
            return val and "true" or "false"
        end,
        ["string"] = function(val)
            return format('%q', val)
        end,
        ["nil"] = function()
            return "nil"
        end,
        ["number"] = function(val)
            return tostring(val)
        end,
    }
    dumpers["function"] = dumpers.number

    local defaultDumper = function(val)
        return format("<%s: %s>", type(val), tostring(val))
    end

    function dump(val)
        if not DLAPI then
            return ""
        end
        return (dumpers[type(val)] or defaultDumper)(val)
    end
end

do
    local lower = string.lower
    local format = string.format
    local gsub = string.gsub
    local CreateAtlasMarkup = CreateAtlasMarkup
    local CreateSimpleTextureMarkup = CreateSimpleTextureMarkup
    --local setmetatable = setmetatable

    local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
    local ElvUI_EltreumUI = _G.ElvUI_EltreumUI

    local atlasMarkup = setmetatable({}, {
        __mode = "kv",
        __index = function(self, key)
            self[key] = CreateAtlasMarkup(key)
            Debug('atlasMarkup[%q] = %s', key, dump(self[key]))
            return self[key]
        end
    })
    local eltreumRaceIcons = setmetatable({}, {
        __mode = "kv",
        __index = function(self, key)
            self[key] = CreateSimpleTextureMarkup(format([[Interface\Addons\ElvUI_EltreumUI\Media\Textures\Races\%s\%s.tga]],
                    isRetail and 'Retail' or 'Classic', key
            ), 0, 0)
            Debug('eltreumRaceIcons[%q] = %s', key, dump(self[key]))
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

            -- if undefined sex then male is assumed
            if not sex or sex == 1 then
                sex = 2
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
end