--------------------------------------------------------------------------
-- Inferno pit bonuses ---------------------------------------------------
INFERNO_PIT_XP_BONUS = 1666

InfernoPitExt = {} --> MODULE

InfernoPitExt.tHeroStorage = {}
InfernoPitExt.tBonusGained = {}

tJustWinBattleFlag = {}

function InfernoPitExt.Init()
    for _, sHeroName in GetObjectNamesByType('HERO') do
        InfernoPitExt.tHeroStorage[sHeroName] = {
            xp = GetHeroStat(sHeroName, STAT_EXPERIENCE)
        }
    end
end

function InfernoPitExt.OnAddHero(sHeroName)
    if not InfernoPitExt.tHeroStorage[sHeroName] then  -- New hero from tavern
        -- This script will execute after first exit of town screen
        -- At that time new hero could have > 0 XP due to sacrifice
        -- So we set it to 0 manually to do not miss this first sacrifice
        InfernoPitExt.tHeroStorage[sHeroName] = {
            xp = 0
        }
    end
    
    local sTownName = GetHeroTown_GateOrGarrison(sHeroName)
    
    if sTownName then
        InfernoPitExt.StartSacrificeCheck(sHeroName, sTownName)
    end
end

function InfernoPitExt.OnHeroWinBattle(sHeroName)
    local sTownName = GetHeroTown_GateOrGarrison(sHeroName)
    if sTownName then
        tJustWinBattleFlag[sHeroName] = not nil
    end
end

function InfernoPitExt.HeroXpUpdater()
    for sHeroName, vHeroInfo in InfernoPitExt.tHeroStorage do
        if IsHeroAlive(sHeroName) and not GetHeroTown_GateOrGarrison(sHeroName)
        then
            local newXP = GetHeroStat(sHeroName, STAT_EXPERIENCE)
            if newXP > vHeroInfo.xp then
                InfernoPitExt.tHeroStorage[sHeroName].xp = newXP
                
                print_debug___ ("XP updated")
                -- BUG: Do not work if hero gets level when sacrifice ???
            end
        end
    end
end

function InfernoPitExt.StartSacrificeCheck(sHeroName, sTownName)
    if GetTownRace(sTownName) == TOWN_INFERNO and InfernoPitExt.tHeroStorage[sHeroName]
    then
        startThread(InfernoPitSacrificeAwait, sHeroName, sTownName)
    end
end

function InfernoPitSacrificeAwait(sHeroName, sTownName)
    while IsHeroAlive(sHeroName) and IsHeroInTown(sHeroName, sTownName, 1, 1) do
        local oldXP = InfernoPitExt.tHeroStorage[sHeroName].xp

        if not GetHeroTown(sHeroName) and
           GetHeroStat(sHeroName, STAT_EXPERIENCE) > oldXP -- Can't call GetHeroStat() while Hero is in Town's Garrison
        then
            local newXP = GetHeroStat(sHeroName, STAT_EXPERIENCE)
            print_debug___ ("New XP: "..newXP)
            print_debug___ ("Old XP: "..oldXP)

            sleep(4)
            if tJustWinBattleFlag[sHeroName] then -- todo test it
                tJustWinBattleFlag[sHeroName] = nil
            else
                local deltaXp = newXP - oldXP  -- NOTE: delta XP == Sacrificed HP

                print_debug___ (sHeroName.." gained "..(deltaXp * 2).." XP")
 
                ChangeHeroStat(sHeroName, STAT_EXPERIENCE, deltaXp)
                sleep(2)
                ChangeHeroStat(sHeroName, STAT_EXPERIENCE, deltaXp)

                if not InfernoPitExt.tBonusGained[sHeroName] then
                    InfernoPitExt.tBonusGained[sHeroName] = not nil
                    sleep(2)
                    ChangeHeroStat(sHeroName, STAT_EXPERIENCE, INFERNO_PIT_XP_BONUS)
                    print_debug___ (sHeroName.." gained "..INFERNO_PIT_XP_BONUS.." XP")
                end
            end

            sleep(4)
            InfernoPitExt.tHeroStorage[sHeroName].xp = GetHeroStat(sHeroName, STAT_EXPERIENCE)
        else
            sleep(2)
        end
    end
end
