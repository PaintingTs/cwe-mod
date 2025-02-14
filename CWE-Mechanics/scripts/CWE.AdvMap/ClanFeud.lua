----------------------------------------------------------------------------
-- Clans Feud --------------------------------------------------------------
ClanFeud = {} --> MODULE
tClanFeudModifiers = {}
tClanFeudMoralFixes = {} -- Compensates same-race moral buff when Clan Feud take place

CLAN_FEUD_MODIFIERS = {
    [TOWN_HEAVEN]       = { [HERO_BATTLE_BONUS_MORALE] = -2,    [HERO_BATTLE_BONUS_DEFENCE] = -2 },
    [TOWN_INFERNO]      = { [HERO_BATTLE_BONUS_ATTACK] = -2,    [HERO_BATTLE_BONUS_SPEED] = -1 },
    [TOWN_ACADEMY]      = { [HERO_BATTLE_BONUS_LUCK] = -2,      [HERO_BATTLE_BONUS_INITIATIVE] = -1 },
    [TOWN_NECROMANCY]   = { [HERO_BATTLE_BONUS_DEFENCE] = -3,   [HERO_BATTLE_BONUS_INITIATIVE] = -1 },
    [TOWN_PRESERVE]     = { [HERO_BATTLE_BONUS_DEFENCE] = -2,   [HERO_BATTLE_BONUS_SPEED] = -1 },
    [TOWN_DUNGEON]      = { [HERO_BATTLE_BONUS_INITIATIVE] = -1,    [HERO_BATTLE_BONUS_SPEED] = -1 },
    [TOWN_FORTRESS]     = { [HERO_BATTLE_BONUS_DEFENCE] = -2,   [HERO_BATTLE_BONUS_LUCK] = -2 },
    [TOWN_STRONGHOLD]   = { [HERO_BATTLE_BONUS_ATTACK] = -3,    [HERO_BATTLE_BONUS_INITIATIVE] = -1 },
    RedKnight           = { [HERO_BATTLE_BONUS_ATTACK] = 2,     [HERO_BATTLE_BONUS_MORALE] = 1 }
}


function ClanFeud.CheckToggleModifiers()
    for _, sHeroName in GetObjectNamesByType('HERO') do
        local tExpectedModifiers, bMoralFix = ClanFeudModifiersPicker(sHeroName)
        local tCurrentModifiers = tClanFeudModifiers[sHeroName]
        local bCurrentMoralFix = tClanFeudMoralFixes[sHeroName]

        -- Compensates same-race moral buff when Clan Feud take place
        if bMoralFix ~= bCurrentMoralFix then
            if bCurrentMoralFix then
                tClanFeudMoralFixes[sHeroName] = nil
                ChangeHeroStat(sHeroName, STAT_MORALE, 1)
            end
            if bMoralFix then
                tClanFeudMoralFixes[sHeroName] = bMoralFix
                ChangeHeroStat(sHeroName, STAT_MORALE, -1)
            end
        end

        if tExpectedModifiers ~= tCurrentModifiers then
            -- restore the stats (if needed) when modifiers have been changed --
            if tCurrentModifiers then
                tClanFeudModifiers[sHeroName] = nil
                startThread(RollbackFeudModifiers, sHeroName, tCurrentModifiers)
            end

            -- apply and store new modifiers --
            if tExpectedModifiers then
                tClanFeudModifiers[sHeroName] = tExpectedModifiers
                startThread(ApplyFeudModifiers, sHeroName, tExpectedModifiers)
            end
        end
    end
end


function ClanFeud.AfterBattle(sHero1Name, sHero2Name)
    if sHero1Name then tClanFeudModifiers[sHero1Name] = nil end
    if sHero2Name then tClanFeudModifiers[sHero2Name] = nil end
end


function ApplyFeudModifiers(sHeroName, tModifiers)
    local isBonus = nil
    for nBonusID, nModifier in tModifiers do
        if nModifier > 0 then isBonus = not nil end
        sleep(3)
        GiveHeroBattleBonus(sHeroName, nBonusID, nModifier)
    end

    local flyingSignText = 'txt/feud-penalty.txt'
    if isBonus then flyingSignText = 'txt/feud-bonus.txt' end
    sleep(3)
    ShowFlyingSign(flyingSignText, sHeroName, GetHeroOwner(sHeroName), 3.0)
end


function RollbackFeudModifiers(sHeroName, tModifiers)
    for nBonusID, nModifier in tModifiers do
        sleep(3)
        GiveHeroBattleBonus(sHeroName, nBonusID, -nModifier)
    end
end


-- TODO: punish White-Knight + red creatures combo as well
function ClanFeudModifiersPicker(sHeroName)
    local tArmyState = GetArmyFeudState(sHeroName)
    local bMoralFix = nil -- Compensates same-race moral buff when Clan Feud take place

    local isRedKnight = IsRedKnight(sHeroName)

    -- Check if it is a Red Knight Bonus --
    if length(tArmyState) == 1 and tArmyState[TOWN_HEAVEN] and isRedKnight
        and length(tArmyState[TOWN_HEAVEN]) == 1 and tArmyState[TOWN_HEAVEN][CLAN_2] 
    then
        return CLAN_FEUD_MODIFIERS.RedKnight, bMoralFix
    end

    -- Red Knight Hero eq. to having CLAN_2 HEAVEN creatures in army --
    if isRedKnight then 
        if not tArmyState[TOWN_HEAVEN] then tArmyState[TOWN_HEAVEN] = {} end
        tArmyState[TOWN_HEAVEN][CLAN_2] = not nil
    end

    local nPlayerRace = GetPlayerRace(GetHeroOwner(sHeroName))
    local nHeroRace = GetHeroRace(sHeroName)

    -- Compensates same-race moral buff when Clan Feud take place --
    if length(tArmyState) == 1 and tArmyState[nHeroRace] then
        bMoralFix = not nil
    end

    -- First try to apply Player Race penalties, then Hero Race penalties --
    for _, nRaceID in { nPlayerRace, nHeroRace } do
        local candidate = tArmyState[nRaceID]
        if candidate and candidate[CLAN_1] and candidate[CLAN_2] then
            return CLAN_FEUD_MODIFIERS[nRaceID], bMoralFix
        end
    end

    -- If no Player/Hero Race penalties, apply first clan feud penalty if any --
    for nRaceID, tClans in tArmyState do
        if tClans[CLAN_1] and tClans[CLAN_2] then
            return CLAN_FEUD_MODIFIERS[nRaceID], bMoralFix
        end
    end

    return nil, nil
end


function GetArmyFeudState(sHeroName)
    local tArmyState = {}

    local nPlayerRace = GetPlayerRace(GetHeroOwner(sHeroName))
    local nHeroRace = GetHeroRace(sHeroName)

    for _, nTypeID in GetHeroCreaturesTypes_t(sHeroName) do
        local nRace = GetCreatureRace(nTypeID)
        local nClan = GetCreatureClan(nTypeID)

        tArmyState[nRace] = tArmyState[nRace] or {}
        tArmyState[nRace][nClan] = not nil
    end

    return tArmyState
end

