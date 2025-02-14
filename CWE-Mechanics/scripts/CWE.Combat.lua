doFile('scripts/lang.lib.lua')

HERO_CLASS_NECROMANCER = 'HERO_CLASS_NECROMANCER'
HERO_CLASS_WARLOCK     = 'HERO_CLASS_WARLOCK'

-- SetUnitManaPoints( sUnitName, nPoints )  can be used for goblins --

-- SKILL_SUMMONING_MAGIC = 12

function GetHeroNameBySide(nSideID)
    local sHero = GetHero(nSideID)
    
    if not sHero then return "" end
    
    local sHeroName = GetHeroName(sHero)
    return sHeroName
end

--------------------------------------------------------------------

function ElementalToMummy(sCreatureName, nSideID)
    local isElementalAppeared = nil
    local nSummonedNumber = 0
    local nSummonedType = CREATURE_MUMMY

    local nCreatureType = GetCreatureType(sCreatureName)

    if nCreatureType == CREATURE_EARTH_ELEMENTAL or nCreatureType == CREATURE_WATER_ELEMENTAL or
       nCreatureType == CREATURE_AIR_ELEMENTAL or nCreatureType == CREATURE_FIRE_ELEMENTAL
    then
        isElementalAppeared = not nil
        
        local nElementalNumber = GetCreatureNumber(sCreatureName)

        nSummonedNumber = 1 + nElementalNumber / 2 + nElementalNumber / 9
    end

    return isElementalAppeared, nSummonedNumber, nSummonedType
end

--------------------------------------------------------------------

function PhoenixToDeathKnight(sCreatureName, nSideID)
    local isPhoenixAppeared = nil
    local nIntCount = 0
    local nSummonedType = CREATURE_DEATH_KNIGHT

    if GetCreatureType(sCreatureName) == CREATURE_PHOENIX then
        isPhoenixAppeared = not nil

        local sHero = GetHero(nSideID)
        local sHeroName = GetHeroName(sHero)
        
        local nMastery = GetGameVar( sHeroName..'|SKILL', 0 ) + 0
        local nSP = GetGameVar( sHeroName..'|SP', 0 ) + 0
        
        if nMastery == 0 then
            nSP = 0.25 * nSP
        elseif nMastery == 1 then
            nSP = 0.33 * nSP
        elseif nMastery == 2 then
            nSP = 0.5 * nSP
        end
        
        local nFloatCount = 1 + nSP / 4
        nIntCount = floor(nFloatCount + 0.5)
        
        local nManaRestore = floor(35 * (1 - nIntCount / nFloatCount))
        
        local nMana = GetUnitManaPoints(sHero) + nManaRestore
        SetUnitManaPoints(sHero, nMana)
    end

    return isPhoenixAppeared, nIntCount, nSummonedType
end

--------------------------------------------------------------------

function CheckSummon(nSideID, fConvertion)

    local sSummonedCreatureName = nil
    local tPrevCreatures = GetCreatures(nSideID)

    while (not nil) do
        sleep(3)
        local tCurrentCreatures = GetCreatures(nSideID)

        for _, sCreatureName in tCurrentCreatures do
            local wasPrevious = contains(tPrevCreatures, sCreatureName)

            if not wasPrevious then
                local needConvert, nSummonedNumber, nSummonedType = fConvertion(sCreatureName, nSideID)

                if needConvert then
                    local nx, ny = GetUnitPosition(sCreatureName)

                    removeUnit(sCreatureName)

                    if (tCurrentCreatures, sSummonedCreatureName) then
                        removeUnit(sSummonedCreatureName)
                    end

					sleep(1)
                    SummonCreature(nSideID, nSummonedType, nSummonedNumber, nx, ny)
                    sleep(3)

                end

                if GetCreatureType(sCreatureName) == nSummonedType then
                    -- converted summoned creature finally appeares in creatures table --
                    sSummonedCreatureName = sCreatureName
                end
            end
        end

        tPrevCreatures = tCurrentCreatures
    end
end

--------------------------------------------------------------------

function CheckStartThreads(nSideID)
    local sHeroName = GetHeroNameBySide(nSideID)
    local sHeroClass = GetGameVar( sHeroName..'|CLASS', "")
    
    if sHeroName ~= "" and sHeroClass == 'HERO_CLASS_NECROMANCER' then
        startThread(CheckSummon, nSideID, ElementalToMummy)
        startThread(CheckSummon, nSideID, PhoenixToDeathKnight)
    end
end

--------------------------------------------------------------------
function Start()
    CheckStartThreads(ATTACKER)
    CheckStartThreads(DEFENDER)
end