----------------------------------------------------------------------------
-- Adv Map Custom Spells ---------------------------------------------------
CustomSpells = {} --> MODULE

ADV_SPELL_REBUILD = CUSTOM_ABILITY_3
ADV_SPELL_PORTAL = CUSTOM_ABILITY_4

REBUILD_HERO_LVL = 1
REBUILD_COST = { [GOLD] = 25000, [WOOD] = 15, [ORE] = 15, [CRYSTAL] = 5, [MERCURY] = 5, [GEM] = 5, [SULFUR] = 5 } 

TP_EXT_MANA_COST = 15

tRebuildInProgress = {}
tPortalAlreadyUsed = {}


function CustomSpells.OnNewDay()
    tPortalAlreadyUsed = {}
end


function CustomSpells.AvailabilityThread()
    while not nil do
        for _, sHeroName in GetObjectNamesByType('HERO') do
            local sTownName = GetHeroTown_Gate(sHeroName)
            CustomSpells._CheckTpAvailable(sHeroName, sTownName)
            CustomSpells._CheckRebuildAvailable(sHeroName, sTownName)
        end

        sleep(2) -- todo: even 1 is not enough - think of a solution
    end
end


function CustomSpells.CastHandler(sHeroName, nCustomAbilityID)
    if      nCustomAbilityID == ADV_SPELL_PORTAL    then MapSpellsExt.StartTpCast(sHeroName)
    elseif  nCustomAbilityID == ADV_SPELL_REBUILD   then RebuildTown(sHeroName) end
end



function CustomSpells._CheckTpAvailable(sHeroName, sTownName)
    if KnowHeroSpell(sHeroName, SPELL_TOWN_PORTAL) then
        local spellState = CUSTOM_ABILITY_NOT_PRESENT
        if sTownName and (
            GetTownBuildingLevel(sTownName, TOWN_BUILDING_MAGIC_GUILD) >= 1  or 
            GetTownBuildingLevel(sTownName, TOWN_BUILDING_STRONGHOLD_TRAVELLERS_SHELTER) >= 1) 
        then
            if GetHeroStat(sHeroName, STAT_MANA_POINTS) >= TP_EXT_MANA_COST
                and not tPortalAlreadyUsed[sHeroName] 
            then
                spellState = CUSTOM_ABILITY_ENABLED
            else
                spellState = CUSTOM_ABILITY_DISABLED
            end
        end

        ControlHeroCustomAbility(sHeroName, ADV_SPELL_PORTAL, spellState)
    end
end 


function CustomSpells._CheckRebuildAvailable(sHeroName, sTownName)
    if GetHeroLevel(sHeroName) >= REBUILD_HERO_LVL then
        local spellState = CUSTOM_ABILITY_NOT_PRESENT
        if sTownName then
             spellState = CUSTOM_ABILITY_ENABLED 
        end

        ControlHeroCustomAbility(sHeroName, ADV_SPELL_REBUILD, spellState)
    end
end 


function GetResourcesIfCanRebuild(nPlayerID)
    local tResources = {}
    for nResID, nCost in REBUILD_COST do
        local nCurrent = GetPlayerResource(nPlayerID, nResID)
        if nCurrent < nCost then return nil end
        tResources[nResID] = nCurrent
    end
    return tResources
end


function RebuildTown(sHeroName)
    local sTownName = GetHeroTown_Gate(sHeroName)
    if not sTownName then return end

    local nPlayerID = GetHeroOwner(sHeroName)
    local tResources = GetResourcesIfCanRebuild(nPlayerID)
    local errorMessage = nil
    if not tResources                       then errorMessage = 'txt/rebuild-no-resources.txt'
    elseif HasObjectAnyCreatures(sTownName) then errorMessage = 'txt/rebuild-garrison-err.txt'
    elseif tRebuildInProgress[sTownName]    then errorMessage = 'txt/rebuild-in-progress-err.txt' 
    end

    if errorMessage then
        MessageBox2(nPlayerID, errorMessage)
        return
    end

    local nTargetRace = GetHeroRace(sHeroName)
    local nCurrentRace = GetTownRace(sTownName)

    local questionMessage = 'txt/rebuild-question.txt'
    if nTargetRace == nCurrentRace then questionMessage = 'txt/rebuild-question-same-race.txt' end

    QuestionBox2(nPlayerID, questionMessage, 'RebuildYes("'..sHeroName..'","'..sTownName..'")', nil)
end


function RebuildYes(sHeroName, sTownName)
    tRebuildInProgress[sHeroName] = not nil
    local nTargetRace = GetHeroRace(sHeroName)

    local nPlayerID = GetHeroOwner(sHeroName)
    local tResources = GetResourcesIfCanRebuild(nPlayerID)
    
    -- save dwelling creatures when same race --
    local tDwellingStore = {}
    for _, nCreatureID in TOWN_CREATURE_DWELLINGS[nTargetRace] do
        tDwellingStore[nCreatureID] = GetObjectDwellingCreatures(sTownName, nCreatureID)
    end

    -- save common buildings. Magic Guild is rebuilt till level 2 --
    local tBuildings = {}
    for nBuildingID = 0, 13 do -- [TOWN_BUILDING_TOWN_HALL .. TOWN_BUILDING_DWELLING_7]
        tBuildings[nBuildingID] = GetTownBuildingLevel(sTownName, nBuildingID)
    end
    if tBuildings[TOWN_BUILDING_MAGIC_GUILD] > 2 then tBuildings[TOWN_BUILDING_MAGIC_GUILD] = 2 end

    -- transform and take cost
    for nResID, nCost in REBUILD_COST do
        SetPlayerResource(nPlayerID, nResID, tResources[nResID] - nCost)
    end

    ShowRebuildProgress(sTownName, 10)
    TransformTown(sTownName, nTargetRace)
    sleep(6)
    ShowRebuildProgress(sTownName, 20)

    -- rebuild buildings -- 
    for nBuildingID, nBuildingLvl in tBuildings do
        if nBuildingLvl > 0 then
            for i = 1, nBuildingLvl do
                UpgradeTownBuilding(sTownName, nBuildingID)
                sleep(1)
            end 
        end
    end

    ShowRebuildProgress(sTownName, 70)
    sleep(6)
    -- restore dwellings --
    for nCreatureID, nCount in tDwellingStore do
        if nCount ~= -1 then -- when -1 == no such creatures => transform from different race
            SetObjectDwellingCreatures(sTownName, nCreatureID, nCount)
            sleep(1)
        end
    end
    ShowRebuildProgress(sTownName, 100)
    tRebuildInProgress[sHeroName] = nil
    sleep(1)
    MakeHeroInteractWithObject(sHeroName, sTownName)
    return parse('')
end


function ShowRebuildProgress(sTownName, nPercent)
    if nPercent == 100 then
        ShowFlyingSign('txt/rebuild-complete-sign.txt', sTownName, 
            GetObjectOwner(sTownName), 3.0)
    else
        ShowFlyingSign({'txt/rebuild-in-progress-sign.txt'; val = nPercent}, sTownName, 
            GetObjectOwner(sTownName), 3.0)
    end
end

