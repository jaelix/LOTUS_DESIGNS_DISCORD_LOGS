local discordWebhook = 'https://discord.com/api/webhooks/1391942584271896596/3V9iVRhp_NmliN8BQpbVo5WemKsfELmuo3tMQTTXbZ5zipb8ifYV3EvcWhQzRuWQE1rX' -- Replace with your actual webhook URL

-- Utility: Get a specific identifier (e.g., license, steam)
local function getIdentifier(source, idType)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if string.find(id, idType) then
            return id
        end
    end
    return "Unavailable"
end

-- Player joined
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local src = source
    local license = getIdentifier(src, "license")
    local steam = getIdentifier(src, "steam")
    local msg = ("🔔 %s is joining. [Steam: %s]"):format(playerName, steam ~= "Unavailable" and steam or "N/A")

    -- In-game chat
    for _, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { '[Join Notice]', msg },
            color = { 0, 255, 100 }
        })
    end

    -- Discord
    PerformHttpRequest(discordWebhook, function() end, 'POST', json.encode({
        username = "Server Logger",
        embeds = {{
            title = "🔔 Player Joined",
            description = ("**%s** is joining the server.\n**Steam:** `%s`\n**License:** `%s`"):format(playerName, steam, license),
            color = 3066993,
            footer = { text = "FiveM Server Log" },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end)

-- Player left
AddEventHandler('playerDropped', function(reason)
    local src = source
    local name = GetPlayerName(src) or "Unknown"
    local license = getIdentifier(src, "license")
    local steam = getIdentifier(src, "steam")
    local msg = ("❌ %s left the server. [Reason: %s]"):format(name, reason)

    -- In-game chat
    for _, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent('chat:addMessage', playerId, {
            args = { '[Leave Notice]', msg },
            color = { 255, 60, 60 }
        })
    end

    -- Discord
    PerformHttpRequest(discordWebhook, function() end, 'POST', json.encode({
        username = "Server Logger",
        embeds = {{
            title = "❌ Player Left",
            description = ("**%s** left the server.\n**Steam:** `%s`\n**License:** `%s`\n**Reason:** %s"):format(name, steam, license, reason),
            color = 15158332,
            footer = { text = "FiveM Server Log" },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end)
