----------------------------------------------------------------------------
-- Adv Map Spells Extentions -----------------------------------------------

-- TODO:
-- Check blocked tiles teleport!!!
MapSpellsExt = {} --> MODULE

MapSpellsExt.tStatsStorage = {}
MapSpellsExt.tMaxMovePoints = {}
MapSpellsExt.tEntranceStorage = {}

function MapSpellsExt.Init(entranceStorage)
    MapSpellsExt.tEntranceStorage = entranceStorage

    for _, sHeroName in GetObjectNamesByType('HERO') do
        MapSpellsExt.tStatsStorage[sHeroName] = GetCurrentStats(sHeroName)
    end
end

function MapSpellsExt.OnDayStarted()
    for _, sHeroName in GetObjectNamesByType('HERO') do      
        MapSpellsExt.tMaxMovePoints[sHeroName] = GetHeroStat(sHeroName, STAT_MOVE_POINTS)
    end
end

function MapSpellsExt.CheckCasts()
    for sHeroName, tStored in MapSpellsExt.tStatsStorage do
        if IsHeroAlive(sHeroName) and not GetHeroTown(sHeroName) then
            tNewStats = GetCurrentStats(sHeroName)

            -- CheckTpCast(sHeroName, tStored, tNewStats) -- obsolete --
            DarkRitualExt.CheckCast(sHeroName, tStored, tNewStats)
            SummonCreaturesExt.CheckCast(sHeroName, tStored, tNewStats)

            MapSpellsExt.tStatsStorage[sHeroName] = tNewStats
        end
    end
end

function GetCurrentStats(sHeroName)
    local x, y, floor = GetObjectPosition(sHeroName)
    local tStats = {
        mana = GetHeroStat(sHeroName, STAT_MANA_POINTS),
        xp = GetHeroStat(sHeroName, STAT_EXPERIENCE),
        movePoints = GetHeroStat(sHeroName, STAT_MOVE_POINTS),
        x = x, y = y, floor = floor
    }
    return tStats
end

---------------------------------------
DARK_RITUAL_BONUS_DAYS = { 1, 7 }
DARK_RITUAL_BONUS = 0.75

DarkRitualExt = {} --> MODULE

function DarkRitualExt.CheckCast(sHeroName, tStored, tNewStats)
    if HasHeroSkill(sHeroName, PERK_DARK_RITUAL) then
        local maxMP = MapSpellsExt.tMaxMovePoints[sHeroName]
        
        if maxMP and maxMP == tStored.movePoints 
            and tNewStats.movePoints == 0 
            and tNewStats.mana > tStored.mana
            ------------------------
            and tNewStats.x == tStored.x 
            and tNewStats.y == tStored.y
            and tNewStats.floor == tStored.floor
        then
            print_debug___ (sHeroName.." casts Dark Ritual")
            if contains(DARK_RITUAL_BONUS_DAYS, GetDate(DAY_OF_WEEK)) then
                ChangeHeroStat(sHeroName, STAT_MOVE_POINTS, floor(maxMP * DARK_RITUAL_BONUS))
            end
        end
    end
end

---------------------------------------
SUMMON_CREATURES_MP_COST = 500

SummonCreaturesExt = {} --> MODULE

function SummonCreaturesExt.CheckCast(sHeroName, tStored, tNewStats)
    if KnowHeroSpell(sHeroName, SPELL_SUMMON_CREATURES) then
        local maxMP = MapSpellsExt.tMaxMovePoints[sHeroName]
        local deltaMP = tStored.movePoints - tNewStats.movePoints
        local is75 = deltaMP >= floor(0.75 * maxMP - 1) and deltaMP <= ceil(0.75 * maxMP + 1)
        -- +-1 is needed becuase of the strange way game calculates: 0.75 * 2500 => 1874 instead of 1875
        
        if is75 and tNewStats.mana < tStored.mana 
            and tNewStats.x == tStored.x 
            and tNewStats.y == tStored.y
            and tNewStats.floor == tStored.floor
        then
            print_debug___ (sHeroName.." casts Summon Creatures")
            ChangeHeroStat(sHeroName, STAT_MOVE_POINTS, deltaMP - SUMMON_CREATURES_MP_COST)
        end
    end
end

---------------------------------------
tTownSelectorStorage = {}

--[[ Obsolete ]]--
function CheckTpCast(sHeroName, tStored, tNewStats)
    if KnowHeroSpell(sHeroName, SPELL_TOWN_PORTAL) then
        local newMana = GetHeroStat(sHeroName, STAT_MANA_POINTS)
        local nX, nY, nFloorID = GetObjectPosition(sHeroName)

        if tNewStats.movePoints == 0 
            and tStored.mana - tNewStats.mana > 5 
            and tStored.xp == tNewStats.xp
        then
            MapSpellsExt.StartTpCast(sHeroName)
        end
    end
end


function MapSpellsExt.StartTpCast(sHeroName)
    local sTownName = GetHeroTown_Gate(sHeroName)
    if sTownName then
        print_debug___ ("found in town: "..sTownName)
        local nPlayerID = GetHeroOwner(sHeroName)

        tTownSelectorStorage[nPlayerID] = {
            towns = GetPlayerTowns(nPlayerID),
            currTown = sTownName,
            hero = sHeroName,
            index = 1
        }

        TownSelector(nPlayerID)
    end
end


function TownSelector(nPlayerID)
    local vSelector = tTownSelectorStorage[nPlayerID]
    local sTownName = vSelector.towns[vSelector.index]
    
    local WALKERS_HUT = TOWN_BUILDING_STRONGHOLD_TRAVELLERS_SHELTER
    
    if sTownName ~= vSelector.currTown and ( -- TODO: check IsTilePassable here and skip occupied towns
        GetTownBuildingLevel(sTownName, TOWN_BUILDING_MAGIC_GUILD) >= 1   -- Magic Guild Requirements --
        or (
            GetTownRace(sTownName) == TOWN_STRONGHOLD
            and
            GetTownBuildingLevel(sTownName, WALKERS_HUT) == 1  -- use TOWN_BUILDING_STRONGHOLD_HALL_OF_TRIAL for warcries
        ))
    then
        local nX, nY, nFloorID = GetObjectPosition(sTownName)
        
        MoveCamera(nX, nY, nFloorID, 50, 0, 0, 0, 1)
        
        QuestionBox2(nPlayerID, {'txt/town-portal.txt'; cost=TP_EXT_MANA_COST},
            'TpYes('..nPlayerID..')', 'TpNo('..nPlayerID..')')
    else
        TpNo(nPlayerID)
    end
end

function TpYes(nPlayerID)
    local vSelector = tTownSelectorStorage[nPlayerID]
    local vDest = MapSpellsExt.tEntranceStorage[vSelector.towns[vSelector.index]]
    
    if not IsTilePassable(vDest.x, vDest.y, vDest.floorID) then
        print_debug___ ("WARNING: Can't find town entrance")
        ShowFlyingSign('txt/town-entrance-err.txt', vSelector.hero, nPlayerID, 5)
        return parse('')
    end
    
    if GetHeroStat(vSelector.hero, STAT_MANA_POINTS) >= TP_EXT_MANA_COST then
        ChangeHeroStat(vSelector.hero, STAT_MANA_POINTS, -TP_EXT_MANA_COST)
        SetObjectPosition(vSelector.hero, vDest.x, vDest.y, vDest.floorID)
        tPortalAlreadyUsed[vSelector.hero] = not nil
    else
        ShowFlyingSign('txt/not-enough-mana.txt', vSelector.hero, nPlayerID, 3)
    end
        
    return parse('')
end

function TpNo(nPlayerID)
    local vSelector = tTownSelectorStorage[nPlayerID]
    
    if vSelector.index + 1 <= length(vSelector.towns) then
        tTownSelectorStorage[nPlayerID].index = vSelector.index + 1
        TownSelector(nPlayerID)
    end
    return parse('')
end

