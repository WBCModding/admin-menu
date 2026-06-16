local ESX = exports["es_extended"]:getSharedObject()

-- Prüft, ob der ausführende Spieler Admin-Rechte besitzt
ESX.RegisterServerCallback('esx_adminmenu:isAdmin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        local playerGroup = xPlayer.getGroup()
        if playerGroup == 'admin' or playerGroup == 'superadmin' then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

-- Callback, das alle Spieler sammelt und deren Gruppen überprüft
ESX.RegisterServerCallback('esx_adminmenu:getPlayers', function(source, cb)
    local players = {}
    local xPlayers = ESX.GetExtendedPlayers() -- Kompatibel mit modernen ESX-Versionen

    for _, xPlayer in pairs(xPlayers) do
        local playerGroup = xPlayer.getGroup()
        local isStaff = false

        -- Definiere, welche Gruppen das STAFF-Tag erhalten
        if playerGroup == 'admin' or playerGroup == 'superadmin' then
            isStaff = true
        end

        table.insert(players, {
            id = xPlayer.source,
            name = xPlayer.getName(), -- Holt den RP-Namen (oder Steam-Namen je nach ESX Config)
            isStaff = isStaff
        })
    end

    cb(players)
end)