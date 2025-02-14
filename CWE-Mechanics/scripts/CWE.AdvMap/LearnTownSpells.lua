--------------------------------------------------------------------------
-- Town Building Spells --------------------------------------------------
LearnTownSpells = {} --> MODULE

function LearnTownSpells.StartCheckAwait(sHeroName, sTownName)
    ForcesOfNatureCheck(sHeroName, sTownName)
    --DungeonCrystalCheck(sHeroName, sTownName)
end

function LearnTownSpells.OnAddHero(sHeroName)
    local sTownName = GetHeroTown_GateOrGarrison(sHeroName)
    
    if sTownName then
        ForcesOfNatureCheck(sHeroName, sTownName)
        --DungeonCrystalCheck(sHeroName, sTownName)
    end
end


tMysticPondSeed = {}
tMysticPondLearnLevel = {}
MYSTIC_POND = TOWN_BUILDING_PRESERVE_MYSTIC_POND

function ForcesOfNatureCheck(sHeroName, sTownName)
    if GetTownRace(sTownName) == TOWN_PRESERVE then
        startThread(ForcesOfNatureAwait, sHeroName, sTownName)
    end
end

function ForcesOfNatureAwait(sHeroName, sTownName)
    tMysticPondSeed[sTownName] = tMysticPondSeed[sTownName] or random(2)
    
    while IsHeroInTown(sHeroName, sTownName, 1, 1) do
        sleep(2)
        
        if not GetHeroTown(sHeroName) and  -- hero on map
           GetTownBuildingLevel(sTownName, MYSTIC_POND) == 2
        then
            -- HasHeroSkill can't be called for heroes in town garrison
            if not HasHeroSkill(sHeroName, SKILL_AVENGER) then break end
            if tMysticPondLearnLevel[sHeroName] and tMysticPondLearnLevel[sHeroName] == 5 then break end
            
            local gmLvl = GetTownBuildingLevel(sTownName, TOWN_BUILDING_MAGIC_GUILD)
            local summoningMastery = GetHeroSkillMastery(sHeroName, SKILL_SUMMONING_MAGIC)
            
            local learned = nil
            
            if gmLvl >= 2 then
                learned = TeachHeroSpell(sHeroName, SPELL_WASP_SWARM)
                tMysticPondLearnLevel[sHeroName] = 2
            end
            
            if gmLvl >= 3 and summoningMastery >= 1 then
                learned = TeachHeroSpell(sHeroName, SPELL_EARTHQUAKE)
                tMysticPondLearnLevel[sHeroName] = 3
            end
            
            local spell = SPELL_SUMMON_ELEMENTALS
            if tMysticPondSeed[sTownName] == 1 then spell = SPELL_SUMMON_HIVE end
            
            if gmLvl >= 4 and summoningMastery >= 2 then
                learned = TeachHeroSpell(sHeroName, spell)
                tMysticPondLearnLevel[sHeroName] = 4
            end
            
            if gmLvl == 5 and summoningMastery == 3 then
                learned = TeachHeroSpell(sHeroName, SPELL_CONJURE_PHOENIX)
                tMysticPondLearnLevel[sHeroName] = 5
            end

            if learned then
                ShowFlyingSign('Text/Game/TooltipParts/SpellLearned.txt', sHeroName, GetObjectOwner(sHeroName), 4)
            end
        end
    end
end

tAltarOfElementsVisited = {}
ALTAR_OF_ELEMENTS = TOWN_BUILDING_DUNGEON_ALTAR_OF_ELEMENTS

function DungeonCrystalCheck(sHeroName, sTownName)
    if GetTownRace(sTownName) == TOWN_DUNGEON and
       not tAltarOfElementsVisited[sHeroName]
    then
        startThread(DungeonCrystalAwait, sHeroName, sTownName)
    end
end

function DungeonCrystalAwait(sHeroName, sTownName)
    while IsHeroInTown(sHeroName, sTownName, 1, 1) do
        sleep(2)
        
        if GetTownBuildingLevel(sTownName, ALTAR_OF_ELEMENTS) > 1 and
           not GetHeroTown(sHeroName) -- hero on map
        then
            TeachHeroSpell(sHeroName, SPELL_ARCANE_CRYSTAL)
            
            tAltarOfElementsVisited[sHeroName] = not nil
            
            ShowFlyingSign('Text/Game/TooltipParts/SpellLearned.txt', sHeroName,
                GetObjectOwner(sHeroName), 4)
            break
        end
    end
end
