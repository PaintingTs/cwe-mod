--------------------------------------------------------------------------
-- Nerf of creature death weeks ------------------------------------------
DeathWeeksNerf = {} --> MODULE

DeathWeeksNerf.tCurrentDwellingStorage = {}

function DeathWeeksNerf.SaveDwellingCount()
    local tDwellingCreatures = DeathWeeksNerf.tCurrentDwellingStorage

    for _, sTownName in GetObjectNamesByType('TOWN') do
        tDwellingCreatures[sTownName] = {}

        for _, nCreatureID in TOWN_CREATURE_DWELLINGS[GetTownRace(sTownName)] do
            tDwellingCreatures[sTownName][nCreatureID] = GetObjectDwellingCreatures(sTownName, nCreatureID)
        end
    end

    -- TODO: same for map dwellings if possible??
end

-- WEEK_OF_FEVER    = no dwelling creatures dies, growth is halfed
-- WEEK_OF_DISEASE  = 1/3 of dwelling creatures dies, 1/3 of growth
-- WEEK_OF_PLAGUE   = 1/2 of dwelling creatures dies, no growth 

function DeathWeeksNerf.RecoverDwellingCreatures()
    local moonWeek = GetCurrentMoonWeek()
    local resurectPortion = 0
    local fRound = floor

    if moonWeek == WEEK_OF_FEVER then resurectPortion = 0.5
    elseif moonWeek == WEEK_OF_DISEASE then resurectPortion = 1.0 / 3 
    elseif moonWeek == WEEK_OF_PLAGUE then resurectPortion = 0.5; fRound = ceil
    else 
        return
    end

    for sTownName, tCounts in DeathWeeksNerf.tCurrentDwellingStorage do
        for nCreatureID, nOldCount in tCounts do
            if nOldCount > 0 then   -- there will be -1 if no dwelling built
                local creaturesToAdd = fRound(nOldCount * resurectPortion)
                AddObjectDwellingCreatures(sTownName, nCreatureID, creaturesToAdd)
                sleep(1)
                print_debug___("Resurected Creatures: "..nCreatureID..", Amount: "..nCount)
            end
        end
    end
end

