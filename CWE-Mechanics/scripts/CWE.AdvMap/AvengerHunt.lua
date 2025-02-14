--------------------------------------------------------------------------
-- Sylvan Avenger bonuses  -----------------------------------------------
RANGER_TRACK_DOWN_RADIUS = 24
RANGER_EYE_RADIUS = 2
RANGER_GUILD_BOOST = 1.5

AvengerHunt = {} --> MODULE
tRangerHuntStorage = {}


function AvengerHunt.TryStart(sHeroName, tMonsterTypes)
    if not HasHeroSkill(sHeroName, SKILL_AVENGER) then return end
    
    local mastery = GetHeroSkillMastery(sHeroName, SKILL_AVENGER)

    for _, nCreatureID in tMonsterTypes do
        if nCreatureID ~= CREATURE_UNKNOWN and
           ceil(CREATURE_TIER[nCreatureID] / 2) <= mastery  -- do we need this?
        then
            tRangerHuntStorage[sHeroName] = tRangerHuntStorage[sHeroName] or {}

            tRangerHuntStorage[sHeroName][BaseCreatureOf(nCreatureID)] = not nil

            print_debug___ ("Hunt started")
            ShowFlyingSign('txt/hunt-started.txt', sHeroName, GetObjectOwner(sHeroName), 2.0)
        end
    end
end


function AvengerHunt.RevealEnemies()
    local monsters = GetObjectNamesByType('CREATURE')
    if length(monsters) == 0 then return end
    
    local rangers = GetObjectNamesByType('HERO_CLASS_RANGER')
    
    for _, sHeroName in rangers do
        local nRndReveals = 0
        
        local nPlayerID = GetObjectOwner(sHeroName)
        local avengerGuildLevel = AvengerHunt._GuildMaxLevel(nPlayerID)
        
        local nRadius = RANGER_TRACK_DOWN_RADIUS
        if avengerGuildLevel == 2 then
            nRadius = nRadius * RANGER_GUILD_BOOST
        end
        
        if avengerGuildLevel > 0 then
            local mastery = GetHeroSkillMastery(sHeroName, SKILL_AVENGER)

            local revealsLeft = pow_int(2, mastery - 2)
            if mastery == 1 then revealsLeft = 1 end
            
            local index = random(length(monsters))
            
            for _, _ in monsters do
                if index >= length(monsters) then index = 0 end
                
                local sMonsterName = monsters[index]
                index = index + 1
                
                if not IsObjectVisible(nPlayerID, sMonsterName) and
                   AvengerHunt._TryReveal(sHeroName, sMonsterName, nRadius)
                then
                    revealsLeft = revealsLeft - 1
                end
                
                if revealsLeft == 0 then break end
            end
        end
    end
end


function AvengerHunt._TryReveal(sHeroName, sMonsterName, nRadius)

    local result = nil
    local nPlayerID = GetObjectOwner(sHeroName)
    
    local nHX, nHY, nHFloor = GetObjectPosition(sHeroName)
    local nMX, nMY, nMFloor = GetObjectPosition(sMonsterName)

    if nHFloor == nMFloor then
        local distance = (nHX - nMX)*(nHX - nMX) + (nHY - nMY)*(nHY - nMY)
        local tAvengList = tRangerHuntStorage[sHeroName]

        if distance < nRadius * nRadius then
            for _, nCreatureID in GetObjectCreaturesTypes_t(sMonsterName) do
            
                if tAvengList and tAvengList[BaseCreatureOf(nCreatureID)] then
                    result = not nil
                        
                    OpenCircleFog(nMX, nMY, nMFloor, RANGER_EYE_RADIUS, nPlayerID)
                    break
                end
            end
        end
    end
    
    return result
end


function AvengerHunt._GuildMaxLevel(nPlayerID)
    local avengerGuildID = TOWN_BUILDING_PRESERVE_AVENGERS_BROTHERHOOD
    local maxLevel = 0
    
    for _, sTown in GetObjectNamesByType('TOWN_PRESERVE') do
        if GetObjectOwner(sTown) == nPlayerID then
            local level = GetTownBuildingLevel(sTown, avengerGuildID)
            
            if level == 1 then maxLevel = level end
            
            if level == 2 then return level end
        end
    end
    
    return maxLevel
end
