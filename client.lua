local ESX = exports["es_extended"]:getSharedObject()

-- F7 Taste registrieren
RegisterKeyMapping('openadminmenu', 'Admin Menü öffnen', 'keyboard', 'F7')

RegisterCommand('openadminmenu', function()
    ESX.TriggerServerCallback('esx_adminmenu:isAdmin', function(isAdmin)
        if isAdmin then
            OpenAdminMenu()
        else
            ESX.ShowNotification('~r~Du hast keine Rechte, um dieses Menü zu öffnen.')
        end
    end)
end, false)

-- Hauptmenü
function OpenAdminMenu()
    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'admin_main_menu', {
        title    = 'Admin Menü',
        align    = 'top-left',
        elements = {
            {label = 'Spielerliste', value = 'player_list'},
            {label = 'Heilen', value = 'heal'},
            {label = 'Rüstung geben', value = 'armor'},
            {label = 'Auto spawnen', value = 'spawn_car'},
            {label = 'Auto reparieren', value = 'repair'},
            {label = 'Auto Max-Tuning', value = 'tune_car'}, -- Neu hinzugefügt
        }
    }, function(data, menu)
        local action = data.current.value
        local playerPed = PlayerPedId()

        if action == 'player_list' then
            OpenPlayerListMenu() -- Öffnet die neue Spielerliste

        elseif action == 'heal' then
            SetEntityHealth(playerPed, GetEntityMaxHealth(playerPed))
            ESX.ShowNotification('~g~Du hast dich geheilt.')
            
        elseif action == 'armor' then
            SetPedArmour(playerPed, 200)
            ESX.ShowNotification('~g~Rüstung aufgefüllt.')
            
        elseif action == 'spawn_car' then
            menu.close()
            ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'spawn_car_dialog', {
                title = 'Fahrzeugname eingeben'
            }, function(data2, menu2)
                local vehicleName = data2.value
                if vehicleName then
                    ESX.Game.SpawnVehicle(vehicleName, GetEntityCoords(playerPed), GetEntityHeading(playerPed), function(vehicle)
                        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)
                    end)
                end
                menu2.close()
                OpenAdminMenu()
            end, function(data2, menu2)
                menu2.close()
                OpenAdminMenu()
            end)

        elseif action == 'repair' then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle ~= 0 then
                SetVehicleFixed(vehicle)
                SetVehicleDirtLevel(vehicle, 0.0)
                ESX.ShowNotification('~g~Fahrzeug repariert.')
            else
                ESX.ShowNotification('~r~Du sitzt in keinem Fahrzeug!')
            end

        elseif action == 'tune_car' then -- Auto-Tuning Funktion
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            if vehicle ~= 0 then
                -- Schaltet alle Performance-Upgrades auf das Maximum
                SetVehicleModKit(vehicle, 0)
                ToggleVehicleMod(vehicle, 18, true) -- Turbo
                SetVehicleMod(vehicle, 11, GetNumVehicleMods(vehicle, 11) - 1, false) -- Motor
                SetVehicleMod(vehicle, 12, GetNumVehicleMods(vehicle, 12) - 1, false) -- Bremsen
                SetVehicleMod(vehicle, 13, GetNumVehicleMods(vehicle, 13) - 1, false) -- Getriebe
                SetVehicleMod(vehicle, 15, GetNumVehicleMods(vehicle, 15) - 1, false) -- Federung
                
                SetVehicleWindowTint(vehicle, 1) -- Dunkle Scheiben
                ESX.ShowNotification('~g~Fahrzeug wurde auf das Maximum getunt!')
            else
                ESX.ShowNotification('~r~Du sitzt in keinem Fahrzeug!')
            end
        end

    end, function(data, menu)
        menu.close()
    end)
end

-- Neues Untermenü für die Spielerliste
function OpenPlayerListMenu()
    -- Holt die Spielerliste live vom Server
    ESX.TriggerServerCallback('esx_adminmenu:getPlayers', function(players)
        local elements = {}

        for _, player in ipairs(players) do
            local displayName = player.name
            
            -- Wenn der Spieler Admin/Staff ist, füge das Präfix hinzu
            if player.isStaff then
                displayName = '~r~[STAFF] ~s~' .. player.name
            end

            table.insert(elements, {
                label = ('[%d] %s'):format(player.id, displayName),
                value = player.id
            })
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'admin_player_list', {
            title    = 'Online Spieler',
            align    = 'top-left',
            elements = elements
        }, function(data, menu)
            -- Hier könnte man später Spieler-Aktionen einbauen (z.B. Kicken, Teleportieren)
            local targetId = data.current.value
            ESX.ShowNotification('Spieler ID ausgewählt: ' .. targetId)
        end, function(data, menu)
            menu.close()
            OpenAdminMenu() -- Zurück zum Hauptmenü
        end)
    end)
end