-- Add this function to your existing script
RegisterCommand('reports', function(source, args, rawCommand)
    local playerId = source

    -- Check if the player has permission to view reports (you can customize this logic)
    if IsPlayerAdmin(playerId) then
        ShowReportsUI(playerId)
    else
        TriggerClientEvent('chatMessage', playerId, '^1[ERROR]^7 You do not have permission to view reports.')
    end
end, false)

-- Function to display the reports UI
function ShowReportsUI(playerId)
    -- Fetch and format active reports
    local activeReports = GetActiveReports()

    -- Trigger an event to show the UI on the client-side
    TriggerClientEvent('showReportsUI', playerId, activeReports)
end

-- Function to get active reports (you may need to modify this based on how reports are stored)
function GetActiveReports()
    local activeReports = {}

    for _, report in ipairs(reports) do
        -- Check the status of the report (e.g., unresolved)
        if not report.resolved then
            table.insert(activeReports, {
                player = report.player,
                reason = report.reason,
                status = "Unresolved"  -- You can add more status information as needed
            })
        end
    end

    return activeReports
end
