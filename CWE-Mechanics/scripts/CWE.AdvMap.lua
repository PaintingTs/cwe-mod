doFile('/scripts/CWE.version.lua')
doFile('/scripts/game.lib.lua')
doFile('/scripts/clans.lua')
doFile(GetMapDataPath()..'clans.lua') -- Try to load overwritten 'clans.lua'

--------------------------------------------------------------------------
-- MODULES ---------------------------------------------------------------
doFile('/scripts/CWE.AdvMap/SpecialPaths.lua')
doFile('/scripts/CWE.AdvMap/ClanFeud.lua')
doFile('/scripts/CWE.AdvMap/MapSpellsExt.lua')
doFile('/scripts/CWE.AdvMap/CustomSpells.lua')

doFile('/scripts/CWE.AdvMap/RuneLimiter.lua')
doFile('/scripts/CWE.AdvMap/InfernoPitExt.lua')
doFile('/scripts/CWE.AdvMap/DungeonPitExt.lua')

doFile('/scripts/CWE.AdvMap/DeathWeeksNerf.lua')
doFile('/scripts/CWE.AdvMap/LearnTownSpells.lua')
--doFile('/scripts/CWE.AdvMap/AvengerHunt.lua')
--doFile('/scripts/CWE.AdvMap/SlaveryBonus.lua')

--------------------------------------------------------------------------
-- Common Storages -------------------------------------------------------
tMonsterStorage = {}
tEntranceStorage = {}

----------------------------------------------------------------------------
-- All global code is here -------------------------------------------------
function _MAIN_()
    sleep(2)
    print("Clan Wars Edition. Version "..CWE_VERSION)
    
    local names = GetAllNames(FILTER_HEROES)
    print_debug___ (names)

    -------------------------------
    ShowMyClan()

    BuildWallsForNeutralTowns()

    UpdateMonsterStorage()

    SetCommonTriggers()
    
    -- Map Spells addons
    MapSpellsExt.Init(tEntranceStorage)

    -- Init Inferno Pit Bonus addons
    InfernoPitExt.Init()

    -- Heroes' Special Paths (Stat Swappers)
    SpecialPaths.Init()

    DailyRoutine()

    -- Custom Spells - Checking availability --
    startThread(CustomSpells.AvailabilityThread)
    
    -- Main loop
    while MainCancelationToken == 0 do
        sleep(2)
        ContinousRoutine()
    end
end


----------------------------------------------------------------------------
-- Triggers ----------------------------------------------------------------
function SetCommonTriggers()
    SetTrigger(NEW_DAY_TRIGGER, 'DailyRoutine')
    SetTrigger(COMBAT_RESULTS_TRIGGER, 'CombatEnded')
    SetTrigger(CUSTOM_ABILITY_TRIGGER, 'CustomAbilityCasted')

    for i = 1, 8 do
        SetTrigger(PLAYER_ADD_HERO_TRIGGER, PLAYERS_ENUM[i], 'PlayerAddHero')
        SetTrigger(PLAYER_REMOVE_HERO_TRIGGER, PLAYERS_ENUM[i], 'PlayerRemoveHero')
    end

    for _, sMonsterName in GetObjectNamesByType('CREATURE') do
        SetTrigger(OBJECT_TOUCH_TRIGGER, sMonsterName, 'HeroEngageMonster')
    end
    
    for _, sObjectName in GetObjectNamesByType('BUILDING') do
        SetTrigger(OBJECT_TOUCH_TRIGGER, sObjectName, 'HeroEngageBuilding')
    end
    
    for _, sHeroName in GetObjectNamesByType('HERO') do
        SetTrigger(HERO_ADD_SKILL_TRIGGER,    sHeroName, 'HeroGotSkill')
        SetTrigger(HERO_REMOVE_SKILL_TRIGGER, sHeroName, 'HeroRemoveSkill')
        
        SetTrigger(HERO_TOUCH_TRIGGER, sHeroName, 'HeroEngageHero')
    --    SetTrigger(HERO_LEVELUP_TRIGGER, sHeroName, 'HeroLevelUp')
    end

    for _, sTownName in GetObjectNamesByType('TOWN') do
        local nX, nY, nFloor = GetObjectPosition(sTownName)
        --TODO: IsTilePassable()
        tEntranceStorage[sTownName] = { x = nX, y = nY - 5, floorID = nFloor }

        SetTrigger(OBJECT_CAPTURE_TRIGGER, sTownName, 'HeroCapturedTown')
        SetTrigger(OBJECT_TOUCH_TRIGGER, sTownName, 'HeroEnterTown')
        SetTrigger(TOWN_HERO_DEPLOY_TRIGGER, sTownName, 'HeroDeployTown')
    end
end


----------------------------------------------------------------------------
-- This function contains checks for events that happen at the new day start
function DailyRoutine()

    cur_day     = GetDate(DAY_OF_WEEK)
    abs_day     = GetDate(DAY)

    cur_week    = GetDate(WEEK)
    cur_month   = GetDate(MONTH)
    abs_week    = 4 * (cur_month - 1) + cur_week
    
    MapSpellsExt.OnDayStarted()
    CustomSpells.OnNewDay()
    
    -- Barbarian Slave Market Bonus --
    -- SlaveryBonus.CheckApply()
    
    -- Avenger night track down --
    -- AvengerHunt.RevealEnemies()
    
    -- Rune Magic Resource Limiter
    RuneLimiter.OnNewDay()
    
    if cur_day == 1 and abs_week > 1 then
        WeeklyRoutine()
    end
end


function WeeklyRoutine()

    UpdateMonsterStorage()

    -- Dungeon Pit Bonus --
    DungeonPitExt.CalcBonus()
    DungeonPitExt.ApplyBonus()
    
    DeathWeeksNerf.RecoverDwellingCreatures()
end


----------------------------------------------------------------------------
-- This function contains checks for events that can happen anytime --------
function ContinousRoutine()

    -- Clan Feud modifiers check --
    ClanFeud.CheckToggleModifiers()
    
    -- Built-in spells check --
    MapSpellsExt.CheckCasts()

    -- Demon Lords XP check --
    InfernoPitExt.HeroXpUpdater()
    
    -- Set\Reset Resources Limiter for Runes
    RuneLimiter.CheckSetReset()

    -- Stats for moddifiing summon spells in combat --
    TrackStatsForCombatScript()

    -- Dungeon dwelling checker (for pit bonus detection)
    if GetDate(DAY_OF_WEEK) == 7 then
        DeathWeeksNerf.SaveDwellingCount()
        DungeonPitExt.SaveDwellingCount()
    end

end


----------------------------------------------------------------------------
-- Add Hero Handler --------------------------------------------------------
function PlayerAddHero(sHeroName, nPlayerID)

    InfernoPitExt.OnAddHero(sHeroName)
    
    RuneLimiter.OnAddHero(sHeroName)
    
    LearnTownSpells.OnAddHero(sHeroName)

    SpecialPaths.OnAddHero(sHeroName)
end


----------------------------------------------------------------------------
-- Remove Hero Handler -----------------------------------------------------
function PlayerRemoveHero(sHeroName, sFoeName)
    RuneLimiter.OnRemoveHero(sHeroName, sFoeName)
end


----------------------------------------------------------------------------
-- Hero Engage Monster Handler ---------------------------------------------
function HeroEngageMonster(sHeroName, sMonsterName)

    -- AvengerHunt.TryStart(sHeroName, tMonsterStorage[sMonsterName])
    
    RuneLimiter.OnHeroTouchObject(sHeroName, sMonsterName, 'HeroEngageMonster')
end

function HeroEngageBuilding(sHeroName, sObjectName)
    print_debug___ ("Hero Engage Building: "..sObjectName)
    
    RuneLimiter.OnHeroTouchObject(sHeroName, sObjectName, 'HeroEngageBuilding')
end

function UpdateMonsterStorage()
    local monsters = GetObjectNamesByType('CREATURE')
    
    for _, sMonsterName in monsters do
        tMonsterStorage[sMonsterName] = GetObjectCreaturesTypes_t(sMonsterName)
    end
end

----------------------------------------------------------------------------
-- Hero <-> Town Interactions ----------------------------------------------
function HeroEnterTown(sHeroName, sTownName)
    if not GetHeroTown(sHeroName) then
        local nX, nY, nFloor = GetObjectPosition(sHeroName)
        tEntranceStorage[sTownName] = { x = nX, y = nY, floorID = nFloor }
    end
    
    RuneLimiter.CheckSetReset()
    RuneLimiter.OnHeroTouchObject(sHeroName, sTownName, 'HeroEnterTown')

    if GetHeroTown(sHeroName) or
       GetObjectOwner(sHeroName) == GetObjectOwner(sTownName)
    then
        LearnTownSpells.StartCheckAwait(sHeroName, sTownName)
        InfernoPitExt.StartSacrificeCheck(sHeroName, sTownName)
    end
end


function HeroDeployTown(sHeroName, sTownName)
    local nX, nY, nFloor = GetObjectPosition(sHeroName)
    tEntranceStorage[sTownName] = { x = nX, y = nY, floorID = nFloor }
end

----------------------------------------------------------------------------
-- Hero Engage Hero Handler ------------------------------------------------
function HeroEngageHero(sHero1Name, sHero2Name)
    RuneLimiter.OnHeroTouchHero(sHero1Name, sHero2Name, 'HeroEngageHero')
end


----------------------------------------------------------------------------
-- Hero Skills Handlers ----------------------------------------------------
function HeroGotSkill(sHeroName, nSkill, nMastery)
    SpecialPaths.OnAddSkill(sHeroName, nSkill, nMastery)
end

function HeroRemoveSkill(sHeroName, nSkill, nMastery)
    SpecialPaths.OnRemoveSkill(sHeroName, nSkill, nMastery)
end


----------------------------------------------------------------------------
-- Combat Ends Handlers ----------------------------------------------------
function CombatEnded(combatIndex)
    local sHeroWinner = GetSavedCombatArmyHero(combatIndex, 1)
    local sHeroLoser = GetSavedCombatArmyHero(combatIndex, 0)

    ClanFeud.AfterBattle(sHeroWinner, sHeroLoser)
    InfernoPitExt.OnHeroWinBattle(sHeroWinner)
end


----------------------------------------------------------------------------
-- Custom Abilities Handlers -----------------------------------------------
function CustomAbilityCasted(sHeroName, nCustomAbilityID)
    CustomSpells.CastHandler(sHeroName, nCustomAbilityID)
end


----------------------------------------------------------------------------
-- Show Clan Info For Player -----------------------------------------------
function ShowMyClan()
    for _, nPlayerID in PLAYERS_ENUM do
        if CLAN_OF_PLAYER[nPlayerID] == CLAN_1 then
            MessageBox2(nPlayerID, 'txt/clan-one.txt')
        elseif CLAN_OF_PLAYER[nPlayerID] == CLAN_2 then
            MessageBox2(nPlayerID, 'txt/clan-two.txt')
        end
    end
end


----------------------------------------------------------------------------
-- Build Walls for Neutral Towns -------------------------------------------
function BuildWallsForNeutralTowns()
    for _, sTownName in GetObjectNamesByType('TOWN') do
        if GetObjectOwner(sTownName) == PLAYER_NONE then
            local nWallsLevel = GetTownBuildingLevel(sTownName, TOWN_BUILDING_FORT)
            while nWallsLevel < 2 do
                UpgradeTownBuilding(sTownName, TOWN_BUILDING_FORT)
                sleep(1)
                nWallsLevel = nWallsLevel + 1
            end
        end
    end
end


function HeroCapturedTown(nPrevOwnerID, nNewOwnerID, sHeroName, sTownName)
    if nPrevOwnerID == PLAYER_NONE then
        DestroyTownBuildingToLevel(sTownName, TOWN_BUILDING_FORT, 0)
        sleep(1)
    end
end


----------------------------------------------------------------------------
-- Track Stats for CombatScript --------------------------------------------
function TrackStatsForCombatScript()
    for _, sHeroName in GetObjectNamesByType('HERO_CLASS_NECROMANCER') do
        local hasElems = KnowHeroSpell(sHeroName, SPELL_SUMMON_ELEMENTALS)
        local hasPhoenix = KnowHeroSpell(sHeroName, SPELL_CONJURE_PHOENIX)

        if hasElems or hasPhoenix then
            local spellPower = GetHeroStat(sHeroName, STAT_SPELL_POWER)
            if HasHeroSkill(sHeroName, PERK_MASTER_OF_CREATURES) then
                spellPower = spellPower + 4
            end
            
            SetGameVar( sHeroName..'|SP', spellPower )

            SetGameVar( sHeroName..'|SKILL',
                GetHeroSkillMastery(sHeroName, SKILL_SUMMONING_MAGIC) )

            SetGameVar( sHeroName..'|CLASS', 'HERO_CLASS_NECROMANCER')
        end

    end
end


---- Logging ------------------
function print_debug___ (sMsg)
    if CWE_DEBUG > 0 then print(sMsg) end
end

---- ERRORS HANDLING ----------
MainCancelationToken = 0

function onError()
    MainCancelationToken = 1
    sleep(2)
    print("CWE: Error occured. Waiting all threads to stop")
    sleep(2)
    print("CWE: Trying to restart Main Thread")
    MainCancelationToken = 0
    startThread(MainLoop)
end

function MainLoop()
    while MainCancelationToken == 0 do
        sleep(2)
        ContinousRoutine()
    end
end

errorHook(onError)

---- EXECUTE MAIN FUNCTION ----
startThread(_MAIN_)