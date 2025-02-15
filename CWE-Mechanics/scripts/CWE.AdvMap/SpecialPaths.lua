----------------------------------------------------------------------------
-- Skill's Modifications ---------------------------------------------------
SpecialPaths = {} --> MODULE

-- TODO: maybe all perks inside a Special Path sector should also transfer stats?
STAT_SWAP_MAP = {
    {   -- Path of Nature --
        skills  = { SKILL_SUMMONING_MAGIC },     races = { TOWN_HEAVEN, TOWN_PRESERVE },     
        from    = STAT_DEFENCE,
        to      = STAT_SPELL_POWER    
    }, 
    
    {   -- Path of Sorcerer -- 
        skills  = { SKILL_SORCERY },            races = { TOWN_INFERNO, TOWN_HEAVEN },
        from    = STAT_ATTACK,  
        to      = STAT_SPELL_POWER    
    },

    {   -- Chaotic Madness --
        skills  = { SKILL_DESTRUCTIVE_MAGIC },  races = { TOWN_HEAVEN },
        from    = STAT_DEFENCE,  
        to      = STAT_SPELL_POWER    
    },

    {   -- Dark Knowledge + Corrupted Light --
        skills  = { SKILL_DARK_MAGIC, SKILL_LIGHT_MAGIC },  races = { TOWN_INFERNO, TOWN_DUNGEON },
        from    = STAT_SPELL_POWER,  
        to      = STAT_KNOWLEDGE    
    },

    {   -- Corrupted Light --
        skills  = { SKILL_LIGHT_MAGIC },         races = { TOWN_INFERNO, TOWN_DUNGEON },
        from    = STAT_SPELL_POWER,  
        to      = STAT_KNOWLEDGE    
    },

    {   -- Sagacious Lord --
        skills  = { SKILL_LEARNING },           races = { TOWN_INFERNO },
        from    = STAT_SPELL_POWER,  
        to      = STAT_DEFENCE  
    },

    {   -- Mystic Protector --
        skills  = { SKILL_LEADERSHIP },         races = { TOWN_INFERNO, TOWN_DUNGEON, TOWN_ACADEMY },
        from    = STAT_SPELL_POWER,  
        to      = STAT_DEFENCE  
    },

    {   -- Battle Mage / Lord --
        skills  = { SKILL_OFFENCE },            races = { TOWN_ACADEMY, TOWN_DUNGEON, TOWN_NECROMANCY },
        from    = STAT_SPELL_POWER,  
        to      = STAT_ATTACK  
    },

    {   -- Path of Enlightment --
        skills  = { SKILL_LEARNING },           races = { TOWN_STRONGHOLD },
        from    = STAT_ATTACK,  
        to      = STAT_KNOWLEDGE  
    },

    {   -- Path of Shaman --
        skills  = { 
            HERO_SKILL_SHATTER_DESTRUCTIVE_MAGIC,   HERO_SKILL_SHATTER_DARK_MAGIC,
            HERO_SKILL_SHATTER_LIGHT_MAGIC, HERO_SKILL_SHATTER_SUMMONING_MAGIC
        },            
        races = { TOWN_STRONGHOLD },
        from    = STAT_ATTACK,  
        to      = STAT_SPELL_POWER  
    }
}

-- public:

function SpecialPaths.Init()
    for _, sHeroName in GetObjectNamesByType('HERO') do
        SpecialPaths.OnAddHero(sHeroName)
    end
end

function SpecialPaths.OnAddHero(sHeroName)
    local race = GetHeroRace(sHeroName)
    for _, tSwapRule in STAT_SWAP_MAP do
        if contains(tSwapRule.races, race) then
            for _, nSkill in tSwapRule.skills do
                local nMastery = GetHeroSkillMastery(sHeroName, nSkill)
                while nMastery > 0 do
                    SpecialPaths._StatSwapApply(sHeroName, tSwapRule)
                    nMastery = nMastery - 1
                    sleep(2)
                end
            end
        end
    end
end

function SpecialPaths.OnAddSkill(sHeroName, nSkill, nMastery)
    for _, tSwapRule in STAT_SWAP_MAP do
        if contains(tSwapRule.skills, nSkill) and
           contains(tSwapRule.races, GetHeroRace(sHeroName))
        then
            startThread(SpecialPaths._StatSwapApply, sHeroName, tSwapRule)
            break
        end
    end
end

function SpecialPaths.OnRemoveSkill(sHeroName, nSkill, nMastery)
    for _, tSwapRule in STAT_SWAP_MAP do
        if contains(tSwapRule.skills, nSkill) and
           contains(tSwapRule.races, GetHeroRace(sHeroName))
        then
            startThread(SpecialPaths._StatSwapRollback, sHeroName, tSwapRule)
            break
        end
    end
end

-- private:

function SpecialPaths._StatSwapApply(sHeroName, tMap)
    tMap.take = tMap.take or 1
    tMap.add = tMap.add or 1
    if GetHeroStat(sHeroName, tMap.from) >= StatMinimum(tMap.from) + tMap.take
    then
        ChangeHeroStat(sHeroName, tMap.from, -tMap.take)
        ChangeHeroStat(sHeroName, tMap.to, tMap.add)

        startThread(SpecialPaths._Show, sHeroName, tMap.from, tMap.to, tMap.take, tMap.add)
    end
end

function SpecialPaths._StatSwapRollback(sHeroName, tMap)
    tMap.take = tMap.take or 1
    tMap.add = tMap.add or 1
    if GetHeroStat(sHeroName, tMap.to) >= StatMinimum(tMap.to) + tMap.add
    then
        ChangeHeroStat(sHeroName, tMap.to, -tMap.add)
        ChangeHeroStat(sHeroName, tMap.from, tMap.take)
        
        startThread(SpecialPaths._Show, sHeroName, tMap.to, tMap.from, tMap.add, tMap.take)
    end
end

function SpecialPaths._Show(sHeroName, srcStat, dstStat, srcAmount, dstAmount)
    ShowFlyingSign('txt/special-path.txt', sHeroName, GetHeroOwner(sHeroName), 2)
    sleep(4)
    ShowChangeStat(sHeroName, srcStat, -srcAmount)
    sleep(4)
    ShowChangeStat(sHeroName, dstStat, dstAmount)
end

-------------------------------------------------

function ShowChangeStat(sHeroName, nStat, nDiff)
    local pref = ''
    if      nDiff > 0 then pref = 'plus'
    elseif  nDiff < 0 then pref = 'minus' end

    local suff = ''
    if     nStat == STAT_SPELL_POWER then suff = '-sp'
    elseif nStat == STAT_KNOWLEDGE   then suff = '-knowledge' 
    elseif nStat == STAT_ATTACK      then suff = '-attack'
    elseif nStat == STAT_DEFENCE     then suff = '-defence' end

    ShowFlyingSign({ 'txt/'..pref..suff..'.txt'; val = nDiff },
        sHeroName, GetHeroOwner(sHeroName), 2)
end