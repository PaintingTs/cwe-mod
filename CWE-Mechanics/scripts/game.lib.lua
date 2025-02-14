RACE_NEUTRAL = -1   -- for compatibility with TOWN_<X> constants

TOWN_HERO_DEPLOY_TRIGGER = 10


CLAN_1    = 1
CLAN_2    = 2
CLAN_NONE = 0

PLAYERS_ENUM = {
    PLAYER_1, PLAYER_2, PLAYER_3, PLAYER_4,
    PLAYER_5, PLAYER_6, PLAYER_7, PLAYER_8
}

ALIGNMENT_NEUTRAL = 0
ALIGNMENT_GOOD = 1
ALIGNMENT_EVIL = 2

RESOURCES = { ORE, WOOD, CRYSTAL, GEM, SULFUR, MERCURY, GOLD }

PRIMARY_STATS = { STAT_ATTACK, STAT_DEFENCE, STAT_KNOWLEDGE, STAT_SPELL_POWER }


--------------------------------------------------------------------------
-- CREATURES TODO: COMPLETE THIS TABLES ----------------------------------

STRONGHOLD_CLAN_1 = {
    CREATURE_GOBLIN_TRAPPER,       CREATURE_CENTAUR_NOMAD,
    CREATURE_ORC_SLAYER,           CREATURE_SHAMAN_WITCH,
    CREATURE_ORCCHIEF_EXECUTIONER, CREATURE_CYCLOP_UNTAMED
}

STRONGHOLD_CLAN_2 = {
    CREATURE_GOBLIN_DEFILER,     CREATURE_CENTAUR_MARADEUR,
    CREATURE_ORC_WARMONGER,      CREATURE_SHAMAN_HAG,
    CREATURE_ORCCHIEF_CHIEFTAIN, CREATURE_CYCLOP_BLOODEYED
}

HEAVEN_CLAN_2 = {
    CREATURE_LANDLORD,        CREATURE_LONGBOWMAN,  CREATURE_VINDICATOR,
    CREATURE_BATTLE_GRIFFIN,  CREATURE_ZEALOT,      CREATURE_CHAMPION,
    CREATURE_SERAPH
}

WEEKLY_GROWTH = {
    [ CREATURE_GOBLIN ]         = 25,        [ CREATURE_CENTAUR ]          = 14,
    [ CREATURE_GOBLIN_TRAPPER ] = 25,        [ CREATURE_CENTAUR_NOMAD ]    = 14,
    [ CREATURE_GOBLIN_DEFILER ] = 25,        [ CREATURE_CENTAUR_MARADEUR ] = 14,

    [ CREATURE_ORC_WARRIOR ]   = 11,         [ CREATURE_SHAMAN ]       = 5,
    [ CREATURE_ORC_SLAYER ]    = 11,         [ CREATURE_SHAMAN_WITCH ] = 5,
    [ CREATURE_ORC_WARMONGER ] = 11,         [ CREATURE_SHAMAN_HAG ]   = 5,

    [ CREATURE_ORCCHIEF_BUTCHER ]     = 5,
    [ CREATURE_ORCCHIEF_EXECUTIONER ] = 5,
    [ CREATURE_ORCCHIEF_CHIEFTAIN ]   = 5,

    [ CREATURE_WITCH ] = 5,
    [ CREATURE_MINOTAUR ] = 6
}

--
CREATURE_RACE = {}

for i = CREATURE_PEASANT,          CREATURE_ARCHANGEL        do CREATURE_RACE[i] = TOWN_HEAVEN     end -- [1..14]
for i = CREATURE_FAMILIAR,         CREATURE_ARCHDEVIL        do CREATURE_RACE[i] = TOWN_INFERNO    end -- [15..28]
for i = CREATURE_SKELETON,         CREATURE_SHADOW_DRAGON    do CREATURE_RACE[i] = TOWN_NECROMANCY end -- [29..42]
for i = CREATURE_PIXIE,            CREATURE_GOLD_DRAGON      do CREATURE_RACE[i] = TOWN_PRESERVE   end -- [43..56]
for i = CREATURE_GREMLIN,          CREATURE_TITAN            do CREATURE_RACE[i] = TOWN_ACADEMY    end -- [57..70]
for i = CREATURE_SCOUT,            CREATURE_BLACK_DRAGON     do CREATURE_RACE[i] = TOWN_DUNGEON    end -- [71..84]
for i = CREATURE_FIRE_ELEMENTAL,   CREATURE_PHOENIX          do CREATURE_RACE[i] = RACE_NEUTRAL    end -- [85..91]
for i = CREATURE_DEFENDER,         CREATURE_MAGMA_DRAGON     do CREATURE_RACE[i] = TOWN_FORTRESS   end -- [92..105]
for i = CREATURE_LANDLORD,         CREATURE_SERAPH           do CREATURE_RACE[i] = TOWN_HEAVEN     end -- [106..112]
for i = CREATURE_WOLF,             CREATURE_MUMMY            do CREATURE_RACE[i] = RACE_NEUTRAL    end -- [113..116]
for i = CREATURE_GOBLIN,           CREATURE_CYCLOP_UNTAMED   do CREATURE_RACE[i] = TOWN_STRONGHOLD end -- [117..130]
for i = CREATURE_QUASIT,           CREATURE_ARCH_DEMON       do CREATURE_RACE[i] = TOWN_INFERNO    end -- [131..137]
for i = CREATURE_STALKER,          CREATURE_RED_DRAGON       do CREATURE_RACE[i] = TOWN_DUNGEON    end -- [138..144]
for i = CREATURE_DRYAD,            CREATURE_RAINBOW_DRAGON   do CREATURE_RACE[i] = TOWN_PRESERVE   end -- [145..151]
for i = CREATURE_SKELETON_WARRIOR, CREATURE_HORROR_DRAGON    do CREATURE_RACE[i] = TOWN_NECROMANCY end -- [152..158]
for i = CREATURE_GREMLIN_SABOTEUR, CREATURE_STORM_LORD       do CREATURE_RACE[i] = TOWN_ACADEMY    end -- [159..165]
for i = CREATURE_STONE_DEFENDER,   CREATURE_LAVA_DRAGON      do CREATURE_RACE[i] = TOWN_FORTRESS   end -- [166..172]
for i = CREATURE_GOBLIN_DEFILER,   CREATURE_CYCLOP_BLOODEYED do CREATURE_RACE[i] = TOWN_STRONGHOLD end -- [173..179]

function GetCreatureRace(nCreatureID)
    local race = CREATURE_RACE[nCreatureID] or RACE_NEUTRAL
    return race
end


CREATURE_ALIGNMENT = {}

for i = CREATURE_PEASANT,          CREATURE_ARCHANGEL        do CREATURE_ALIGNMENT[i] = ALIGNMENT_GOOD end -- [1..14]
for i = CREATURE_FAMILIAR,         CREATURE_SHADOW_DRAGON    do CREATURE_ALIGNMENT[i] = ALIGNMENT_EVIL end -- [15..42]
for i = CREATURE_PIXIE,            CREATURE_TITAN            do CREATURE_ALIGNMENT[i] = ALIGNMENT_GOOD end -- [43..70]
for i = CREATURE_SCOUT,            CREATURE_BLACK_DRAGON     do CREATURE_ALIGNMENT[i] = ALIGNMENT_EVIL end -- [71..84]
for i = CREATURE_FIRE_ELEMENTAL,   CREATURE_PHOENIX          do CREATURE_ALIGNMENT[i] = ALIGNMENT_NEUTRAL end -- [85..91]
for i = CREATURE_DEFENDER,         CREATURE_SERAPH           do CREATURE_ALIGNMENT[i] = ALIGNMENT_GOOD end -- [92..112]
for i = CREATURE_WOLF,             CREATURE_MUMMY            do CREATURE_ALIGNMENT[i] = ALIGNMENT_NEUTRAL end -- [113..116]
for i = CREATURE_GOBLIN,           CREATURE_CYCLOP_UNTAMED   do CREATURE_ALIGNMENT[i] = ALIGNMENT_EVIL end -- [117..130]
for i = CREATURE_QUASIT,           CREATURE_RED_DRAGON       do CREATURE_ALIGNMENT[i] = ALIGNMENT_EVIL end -- [131..144]
for i = CREATURE_DRYAD,            CREATURE_RAINBOW_DRAGON   do CREATURE_ALIGNMENT[i] = ALIGNMENT_GOOD end -- [145..151]
for i = CREATURE_SKELETON_WARRIOR, CREATURE_HORROR_DRAGON    do CREATURE_ALIGNMENT[i] = ALIGNMENT_EVIL end -- [152..158]
for i = CREATURE_GREMLIN_SABOTEUR, CREATURE_LAVA_DRAGON      do CREATURE_ALIGNMENT[i] = ALIGNMENT_GOOD end -- [159..172]
for i = CREATURE_GOBLIN_DEFILER,   CREATURE_CYCLOP_BLOODEYED do CREATURE_ALIGNMENT[i] = ALIGNMENT_EVIL end -- [173..179]

function GetCreatureAlignment(nCreatureID)
    local align = CREATURE_ALIGNMENT[nCreatureID] or ALIGNMENT_NEUTRAL
    return align
end


CREATURE_TIER = {
    [ CREATURE_WOLF ] = 4,              [ CREATURE_MUMMY ] = 5,

    [ CREATURE_FIRE_ELEMENTAL ] = 4,    [ CREATURE_WATER_ELEMENTAL ] = 4,
    [ CREATURE_AIR_ELEMENTAL ]  = 4,    [ CREATURE_EARTH_ELEMENTAL ] = 4,

    [ CREATURE_MANTICORE ]    = 6,      [ CREATURE_PHOENIX ] = 7,
    [ CREATURE_DEATH_KNIGHT ] = 6

}

for i = CREATURE_PEASANT, CREATURE_BLACK_DRAGON do -- [1..84]
    CREATURE_TIER[i] = mod(ceil(i / 2) - 1, 7) + 1
end
for i = CREATURE_DEFENDER, CREATURE_MAGMA_DRAGON do -- [92..105]
    CREATURE_TIER[i] = mod(ceil((i - 91) / 2) - 1, 7) + 1
end
for i = CREATURE_LANDLORD, CREATURE_SERAPH do -- [106..112]
    CREATURE_TIER[i] = i - 105
end
for i = CREATURE_GOBLIN, CREATURE_CYCLOP_UNTAMED do -- [117..130]
    CREATURE_TIER[i] = mod(ceil((i - 116) / 2) - 1, 7) + 1
end
for i = CREATURE_QUASIT, CREATURE_CYCLOP_BLOODEYED do -- [131..179]
    CREATURE_TIER[i] = mod(i - 131, 7) + 1
end


function GetCreatureClan(nCreatureID)
    local n = nCreatureID
    -- exceptions --
    if n == CREATURE_IMP or n == CREATURE_QUASIT then return CLAN_NONE end
    -- common table
    if n >= CREATURE_PEASANT  and n <= CREATURE_BLACK_DRAGON and mod(n, 2) == 0 then return CLAN_1 end
    if n >= CREATURE_DEFENDER and n <= CREATURE_MAGMA_DRAGON and mod(n, 2) == 1 then return CLAN_1 end
    if n >= CREATURE_LANDLORD and n <= CREATURE_SERAPH then return CLAN_2 end
    if n >= CREATURE_GOBLIN   and n <= CREATURE_CYCLOP_UNTAMED and mod(n, 2) == 0 then return CLAN_1 end
    if n >= CREATURE_QUASIT   and n <= CREATURE_CYCLOP_BLOODEYED then return CLAN_2 end
    return CLAN_NONE
end


TOWN_CREATURE_DWELLINGS = {
    [ TOWN_HEAVEN ] = { CREATURE_PEASANT, CREATURE_ARCHER, CREATURE_MARKSMAN, CREATURE_GRIFFIN, 
                        CREATURE_PRIEST, CREATURE_CAVALIER, CREATURE_ANGEL },

    [ TOWN_PRESERVE ] = { CREATURE_PIXIE, CREATURE_BLADE_JUGGLER, CREATURE_WOOD_ELF, CREATURE_DRUID,
                            CREATURE_UNICORN, CREATURE_TREANT, CREATURE_GREEN_DRAGON }, 

    [ TOWN_ACADEMY ] = { CREATURE_GREMLIN, CREATURE_STONE_GARGOYLE, CREATURE_IRON_GOLEM, CREATURE_MAGI,
                            CREATURE_GENIE, CREATURE_RAKSHASA, CREATURE_GIANT }, 

    [ TOWN_DUNGEON ] = { CREATURE_SCOUT, CREATURE_WITCH, CREATURE_MINOTAUR, CREATURE_RIDER,
                            CREATURE_HYDRA, CREATURE_MATRON, CREATURE_DEEP_DRAGON }, 

    [ TOWN_NECROMANCY ] = { CREATURE_SKELETON, CREATURE_WALKING_DEAD, CREATURE_MANES, CREATURE_VAMPIRE,
                            CREATURE_LICH, CREATURE_WIGHT, CREATURE_BONE_DRAGON }, 

    [ TOWN_INFERNO ] = { CREATURE_FAMILIAR, CREATURE_DEMON, CREATURE_HELL_HOUND, CREATURE_SUCCUBUS, 
                            CREATURE_NIGHTMARE, CREATURE_PIT_FIEND, CREATURE_DEVIL },

    [ TOWN_FORTRESS ] = { CREATURE_DEFENDER, CREATURE_AXE_FIGHTER, CREATURE_BEAR_RIDER, CREATURE_BROWLER,
                            CREATURE_RUNE_MAGE, CREATURE_THANE, CREATURE_FIRE_DRAGON},

    [ TOWN_STRONGHOLD ] = { CREATURE_GOBLIN, CREATURE_CENTAUR, CREATURE_ORC_WARRIOR, CREATURE_SHAMAN,
                            CREATURE_ORCCHIEF_BUTCHER, CREATURE_WYVERN, CREATURE_CYCLOP }
}

--------------------------------------------------------------------------
-- BUILDINGS -------------------------------------------------------------

MINE_TYPES = {
    [ ORE ]     = 'ORE_PIT',        [ WOOD ]    = 'SAWMILL',
    [ CRYSTAL ] = 'CRYSTAL_CAVERN', [ GEM ]     = 'GEM_POND',
    [ SULFUR ]  = 'SULFUR_DUNE',    [ MERCURY ] = 'ALCHEMIST_LAB',
    [ GOLD ]    = 'GOLD_MINE'
}

MINE_INCOME = {
    [ ORE ]     = 2,        [ WOOD ]    = 2,
    [ CRYSTAL ] = 1,        [ GEM ]     = 1,
    [ SULFUR ]  = 1,        [ MERCURY ] = 1,
    [ GOLD ]    = 1000
}

BATTLE_SITE_TYPES = {
    'ABANDONED_MINE',      'BUILDING_CRYPT', 'CYCLOPS_STOCKPILE',
    'CYCLOPS_STOCKPILE',   'NAGA_BANK',      'BUILDING_PYRAMID',
    'DRAGON_UTOPIA',       'MILITARY_POST',  'BUILDING_SHIP_GALEON',
    'DWARVEN_TREASURE',    'BLOOD_TEMPLE',   'TREANT_THICKET',
    'GARGOYLE_STONEVAULT', 'SUNKEN_TEMPLE',  'NAGA_TEMPLE'
}

GARRISON_TYPES = {
    'GARRISON', 'CITADEL', 'OUTPOST'
}

RED_ANALOGUE = {
    [ 'Christian' ] = 'RedHeavenHero01', [ 'Ving' ]  = 'RedHeavenHero06',
    [ 'Nathaniel' ] = 'Ornella',         [ 'Sarge' ] = 'RedHeavenHero03',
    [ 'Mardigo' ]   = 'RedHeavenHero05', [ 'Maeve' ] = 'Orlando',
    [ 'Brem' ]      = 'RedHeavenHero04', [ 'Orrin' ] = 'RedHeavenHero02'
}

--------------------------------------------------------------------------
-- EXTENTION FUNCTIONS ---------------------------------------------------

function IsRedKnight(sHeroName)
    for i = 1, 6 do
        if sHeroName == "RedHeavenHero0"..i then
            return not nil
        end
    end

    if sHeroName == "Ornella" or sHeroName == "Orlando" then
        return not nil
    end

    return nil
end


function GetPlayerTowns(nPlayerID)
    local t = {}
    for _, sTownName in GetObjectNamesByType('TOWN') do
        if GetObjectOwner(sTownName) == nPlayerID then
            t[length(t) + 1] = sTownName
        end
    end
    
    return t
end

function IsTown(sObjectName)
    local result = contains(GetObjectNamesByType('TOWN'), sObjectName)
    return result
end

function GetTownHero_Gate(sTownName)
    for _, sHeroName in GetObjectNamesByType('HERO') do
        if IsHeroInTown(sHeroName, sTownName, 1, 0) then
            return sHeroName
        end
    end
end

function GetHeroTown_Gate(sHeroName)
    for _, sTownName in GetObjectNamesByType('TOWN') do
        if IsHeroInTown(sHeroName, sTownName, 1, 0) then
            return sTownName
        end
    end

    return nil
end

function GetHeroTown_Garrison(sHeroName)
    return GetHeroTown(sHeroName)
end

function GetHeroTown_GateOrGarrison(sHeroName)
    for _, sTownName in GetObjectNamesByType('TOWN') do
        if IsHeroInTown(sHeroName, sTownName, 1, 1) then
            return sTownName
        end
    end

    return nil
end

function GetHeroOwner(sHeroName)
    return GetObjectOwner(sHeroName)
end

function GetHeroRace(sHeroName)
    if      HasHeroSkill(sHeroName, SKILL_TRAINING)     then return TOWN_HEAVEN
    elseif  HasHeroSkill(sHeroName, SKILL_AVENGER)      then return TOWN_PRESERVE
    elseif  HasHeroSkill(sHeroName, SKILL_INVOCATION)   then return TOWN_DUNGEON
    elseif  HasHeroSkill(sHeroName, SKILL_GATING)       then return TOWN_INFERNO
    elseif  HasHeroSkill(sHeroName, SKILL_ARTIFICIER)   then return TOWN_ACADEMY
    elseif  HasHeroSkill(sHeroName, SKILL_NECROMANCY)   then return TOWN_NECROMANCY
    elseif  HasHeroSkill(sHeroName, HERO_SKILL_RUNELORE) then return TOWN_FORTRESS
    else return TOWN_STRONGHOLD end 
end

function ChangePlayerResource(nPlayerID, nResourceID, nDelta)
    SetPlayerResource(nPlayerID, nResourceID,
        GetPlayerResource(nPlayerID, nResourceID) + nDelta )
end


function GetObjectCreaturesTypes_t(sObjectName)
    local t = {}
    t[1], t[2], t[3], t[4], t[5], t[6], t[7] = GetObjectCreaturesTypes(sObjectName)
    return t
end


function GetHeroCreaturesTypes_t(sHeroName)
    local t = {}
    t[1], t[2], t[3], t[4], t[5], t[6], t[7] = GetHeroCreaturesTypes(sHeroName)
    return t
end


function HasObjectAnyCreatures(sObjectName)
    for _, nCreatureID in GetObjectCreaturesTypes_t(sObjectName) do
        if nCreatureID ~= CREATURE_UNKNOWN then return not nil end
    end
    return nil
end


function AddObjectDwellingCreatures(sTownName, nCreatureID, nDelta)
    SetObjectDwellingCreatures(sTownName, nCreatureID,
        GetObjectDwellingCreatures(sTownName, nCreatureID) + nDelta)
end


function BaseCreatureOf(nCreatureID)
    if nCreatureID >= CREATURE_PEASANT and nCreatureID <= CREATURE_BLACK_DRAGON then  -- [1..84]
        return ceil(nCreatureID / 2) * 2 - 1

    elseif nCreatureID <= CREATURE_PHOENIX then  -- [85..91]
        return nCreatureID

    elseif nCreatureID <= CREATURE_MAGMA_DRAGON then -- [92..105]
        return floor(nCreatureID / 2) * 2

    elseif nCreatureID <= CREATURE_SERAPH then -- [106..112]
        return (nCreatureID - CREATURE_LANDLORD) * 2 + CREATURE_PEASANT

    elseif nCreatureID <= CREATURE_MUMMY then -- [113..116]
        return nCreatureID

    elseif nCreatureID <= CREATURE_CYCLOP_UNTAMED then -- [117..130]
        return ceil(nCreatureID / 2) * 2 - 1

    elseif nCreatureID <= CREATURE_CYCLOP_BLOODEYED then  -- [131..179]
        return (nCreatureID - CREATURE_QUASIT) * 2 + CREATURE_FAMILIAR
    end

    return CREATURE_UNKNOWN
end


function KnowHeroAnyRune(sHeroName)
    for spellID = 249, 258 do
        if KnowHeroSpell(sHeroName, spellID) then return not nil end
    end
    
    return nil
    
--    return KnowHeroSpell(sHeroName, SPELL_RUNE_OF_CHARGE)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_BERSERKING)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_MAGIC_CONTROL)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_EXORCISM)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_ELEMENTAL_IMMUNITY)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_ETHEREALNESS)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_STUNNING)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_REVIVE)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_BATTLERAGE)
--        or KnowHeroSpell(sHeroName, SPELL_RUNE_OF_DRAGONFORM)
end


function GetCombatableBuildings()
    local tObjects = {}
    local tCanHaveArmyGroups = { BATTLE_SITE_TYPES, MINE_TYPES, GARRISON_TYPES }
    
    for _, tGroup in tCanHaveArmyGroups do
        for _, sType in tGroup do
            for _, sObjectName in GetObjectNamesByType(sType) do
                AddElem(tObjects, sObjectName)
            end
        end
    end
    return tObjects
end


function StatMinimum(nStat)
    if      nStat == STAT_SPELL_POWER or nStat == STAT_KNOWLEDGE    then return 1
    elseif  nStat == STAT_MORALE or nStat == STAT_LUCK              then return -99
    else    return 0 end
end


function DistanceSqrIfSameFloor(sObjectName1, sObjectName2)
    local nX1, nY1, nFloor1 = GetObjectPosition(sObjectName1)
    local nX2, nY2, nFloor2 = GetObjectPosition(sObjectName2)
    
    if nFloor1 ~= nFloor2 then return nil end
    
    return (nX1 - nX2)*(nX1 - nX2) + (nY1 - nY2)*(nY1 - nY2)
end


function MessageBox2(nPlayerID, messageName, callback)
    if IsAIPlayer(nPlayerID) == 1 then return end
    
    callback = callback or ''
    MessageBoxForPlayers(GetPlayerFilter(nPlayerID), messageName, callback)
end


function QuestionBox2(nPlayerID, messageName, callbackYes, callbackNo)
    if IsAIPlayer(nPlayerID) == 1 then return end
    
    QuestionBoxForPlayers(GetPlayerFilter(nPlayerID), messageName,
        callbackYes, callbackNo)
end