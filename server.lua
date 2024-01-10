local reports = {}
local reportCooldowns = {} -- Track report cooldowns per player
local reportCategories = { "Cheating", "Harassment", "Other" } -- Add more categories as needed

RegisterCommand('report', function(source, args, rawCommand)
    local playerId = source
    local playerName = GetPlayerName(playerId)
    local reportReason = table.concat(args, ' ')

    -- Check if the player is on cooldown
    if reportCooldowns[playerId] and (os.time() - reportCooldowns[playerId]) < 120 then
        TriggerClientEvent('chatMessage', playerId, '^1[ERROR]^7 You must wait before submitting another report.')
        return
    end

    -- Check if a valid reason is provided
    if reportReason and #reportReason > 0 then
        local reportCategory = args[1] or "Other"

        -- Check if the report category is valid
        if not table.contains(reportCategories, reportCategory) then
            TriggerClientEvent('chatMessage', playerId, '^1[ERROR]^7 Invalid report category. Available categories: ' .. table.concat(reportCategories, ', '))
            return
        end

        -- Add the report
        table.insert(reports, { player = playerName, reason = reportReason, category = reportCategory })
        TriggerClientEvent('chatMessage', -1, '^1[REPORT]^7 ' .. playerName .. ' has reported: ' .. reportReason)

        -- Send report to webhook with additional information
        SendReportToWebhook(playerId, playerName, reportReason, reportCategory)

        -- Set cooldown for the player
        reportCooldowns[playerId] = os.time()

    else
        TriggerClientEvent('chatMessage', playerId, '^1[ERROR]^7 Invalid report. Usage: /report [category] [reason]')
    end
end, false)

function SendReportToWebhook(playerId, playerName, reportReason, reportCategory)
    local playerIP = GetPlayerEndpoint(playerId)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    
    local webhookData = {
        content = string.format('**New Report:**\nPlayer: %s\nCategory: %s\nReason: %s\nPlayer ID: %s\nPlayer IP: %s\nTimestamp: %s\nAdditional Context: %s', 
                                playerName, reportCategory, reportReason, playerId, playerIP, timestamp, "Additional context here"),
        username = 'Report System',
        avatar_url = 'https://i.imgur.com/AfFp7pu.png' -- Replace with your webhook avatar URL
    }

    PerformHttpRequest('YOUR_WEBHOOK_HERE', function(statusCode, response, headers) end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
end

function table.contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end
