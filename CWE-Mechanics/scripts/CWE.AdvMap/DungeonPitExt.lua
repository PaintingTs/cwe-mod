--------------------------------------------------------------------------
-- Dungeon Pit bonuses ---------------------------------------------------

-- 1 pit point = 150 hp of sacrificed creatures
-- At the begining of the week after pit levels up,
-- half of the pit points wil be spent to spawn additional creatures
-- You can roll per pit point:
---- 10% -> 0.5 Dragon = 100 hp
---- 20% -> 3 Dark Riders = 120 hp
---- 30% -> 2 Hydra = 160 hp
---- 40% -> 5 Minotaurs = 155 hp
DungeonPitExt = {} --> MODULE

tDungeonPitStorage = {}
tDungeonBonusCreatures = {}

function DungeonPitExt.SaveDwellingCount()
    local pitID = TOWN_BUILDING_DUNGEON_RITUAL_PIT
    
    for _, sTownName in GetObjectNamesByType('TOWN_DUNGEON') do
        if GetTownBuildingLevel(sTownName, pitID) > 0 then
            if not tDungeonPitStorage[sTownName] then
                tDungeonPitStorage[sTownName] = {
                    pointsGained = 0,
                    pointsSpent  = 0
                }
            end
            
            tDungeonPitStorage[sTownName].witches =
                GetObjectDwellingCreatures(sTownName, CREATURE_WITCH)
        end
    end
end


function DungeonPitExt.CalcBonus()
    for sTown, vInfo in tDungeonPitStorage do
        local actualGrowth =
            GetObjectDwellingCreatures(sTown, CREATURE_WITCH) - vInfo.witches

        local calcGrowth = WEEKLY_GROWTH[ CREATURE_WITCH ]

        local fortLevel = GetTownBuildingLevel(sTown, TOWN_BUILDING_FORT)
        local moonWeek = GetCurrentMoonWeek()
        -- TODO: bonus weeks and death weeks may apply to base growth or full growth - check it!
        local moonWeekMultiplier = 1
        if moonWeek == WEEK_OF_FEVER then moonWeekMultiplier = 0.5
        elseif moonWeek == WEEK_OF_DISEASE then moonWeekMultiplier = 1.0 / 3 
        elseif moonWeek == WEEK_OF_PLAGUE then moonWeekMultiplier = 0
        elseif moonWeek == WEEK_OF_LIFE then moonWeekMultiplier = 2
        elseif moonWeek == WEEK_OF_WITCH then moonWeekMultiplier = 2
        elseif moonWeek == WEEK_OF_CONJUNCTION then moonWeekMultiplier = 3 end

        -- TODO: bug: what about Asha Tier???
        
        if fortLevel > 1 then
            calcGrowth = floor(0.5 * (fortLevel + 1) * calcGrowth)
        end
        if TOWN_TIER_SPEC[sTown] and TOWN_TIER_SPEC[sTown] == 2 then
            calcGrowth = calcGrowth + 1
        end

        calcGrowth = ceil(calcGrowth * moonWeekMultiplier)
        
        local bonus = actualGrowth - calcGrowth
        
        print_debug___ ("bonus: "..bonus)

        if bonus > 0 and bonus < 10  -- and (bonus < 5 or fortLevel > 1) and (bonus < 7 or fortLevel > 2)
        then
            tDungeonPitStorage[sTown].pointsGained = pow_int(2, bonus)
            print_debug___ ("Points gained: "..tDungeonPitStorage[sTown].pointsGained)
        end
        
    end
end


function DungeonPitExt.ApplyBonus()
    for sTown, vInfo in tDungeonPitStorage do
        local pointsToSpend = vInfo.pointsGained - vInfo.pointsSpent
        print_debug___ ("Point to spend: "..pointsToSpend)
        
        if pointsToSpend > 0 then
            -- roll bonus creatures --
            for nSpent = 1, pointsToSpend do
                local dice = random(10)

                tDungeonBonusCreatures[sTown] = tDungeonBonusCreatures[sTown] or {}
                local tCreatures = tDungeonBonusCreatures[sTown]

                if     dice == 0 then
                    tCreatures[CREATURE_DEEP_DRAGON] = (tCreatures[CREATURE_DEEP_DRAGON] or 0) + 1
                    nSpent = nSpent + 1 -- requires 2 points for 1 dragon
                elseif dice <= 2 then
                    tCreatures[CREATURE_RIDER] = (tCreatures[CREATURE_RIDER] or 0) + 3
                elseif dice <= 5 then
                    tCreatures[CREATURE_HYDRA] = (tCreatures[CREATURE_HYDRA] or 0) + 2
                else
                    tCreatures[CREATURE_MINOTAUR] = (tCreatures[CREATURE_MINOTAUR] or 0) + 5
                end
            end

            tDungeonPitStorage[sTown].pointsSpent = vInfo.pointsSpent + pointsToSpend

            local tSpawned = {}

            -- try to spawn them if dwelling is present --
            for nCreatureID, nAdded in tCreatures do
                local nCurrentCount = GetObjectDwellingCreatures(sTown, nCreatureID) 
                if nCurrentCount > -1 then -- Dwelling is built
                    SetObjectDwellingCreatures(sTown, nCreatureID, nCurrentCount + nAdded)

                    ShowFlyingSign({'txt/dungeon-pit-'..nCreatureID..'.txt'; val = nAdded}, sTown,
                        GetObjectOwner(sTown), 6.0)
                    tCreatures[nCreatureID] = nil
                    sleep(3) -- todo thread??
                end
            end
        end
        
    end
end
