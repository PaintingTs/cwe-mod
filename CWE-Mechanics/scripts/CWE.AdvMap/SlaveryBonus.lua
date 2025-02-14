--------------------------------------------------------------------------
-- Stronghold Slavery bonuses --------------------------------------------
SLAVARY_GUARD_TIERS = { 1, 2, 3, 4, 5 }
SLAVARY_GUARD_COEFF = 0.5

SlaveryBonus = {} --> MODULE

function SlaveryBonus.CheckApply()
    local nSlaveMarketID = TOWN_BUILDING_STRONGHOLD_SLAVE_MARKET
    local tSlaveOwners = {}
    
    for _, sTownName in GetObjectNamesByType('TOWN_STRONGHOLD') do
        if GetTownBuildingLevel(sTownName, nSlaveMarketID) > 0 then
            local nPlayerID = GetObjectOwner(sTownName)
            
            if nPlayerID ~= PLAYER_NONE then
                tSlaveOwners[nPlayerID] = not nil
            end
        end
        local nOwnerID = GetObjectOwner(sTownName)
    end
    
    for _, nResID in RESOURCES do
        for _, sMineName in GetObjectNamesByType(MINE_TYPES[nResID]) do
            local nOwnerID = GetObjectOwner(sMineName)

            if tSlaveOwners[nOwnerID] then
                local nGuard = 0
                for _, nCreatureID in GetObjectCreaturesTypes_t(sMineName) do

                    if GetCreatureRace(nCreatureID) == TOWN_STRONGHOLD and
                       contains(SLAVARY_GUARD_TIERS, CREATURE_TIER[nCreatureID])
                    then
                        local nCount = GetObjectCreatures(sMineName, nCreatureID)

                        nGuard = nGuard + nCount / WEEKLY_GROWTH[nCreatureID]
                    end
                end

                if nGuard > SLAVARY_GUARD_COEFF then
                    -- Total creatures more then 'coeff' of weekly growth
                    ChangePlayerResource(nOwnerID, nResID, MINE_INCOME[nResID])
                    
                    ShowFlyingSign('txt/slave-work.txt', sMineName, nOwnerID, 30.0)
                        
                    print_debug___ ("Slavery works on resource: "..nResID)
                end
            end
        end
    end
    
end
