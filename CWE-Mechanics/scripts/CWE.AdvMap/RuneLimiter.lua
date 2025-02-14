--------------------------------------------------------------------------
-- Rune Magic Resorces Limiter -------------------------------------------
RUNE_RESOURCE_LIMIT = 10

RuneLimiter = {} --> MODULE

tRuneResourceStorage = {}
tObjectOwners = {}
tDwarfXp = {}

RuneLimiter.IsSet = nil
RuneLimiter.CancelationToken = 0

function RuneLimiter.CheckSetReset()
    local hasRuneCasters = AnyRuneCaster_NotAI()
    
    if RuneLimiter.IsSet ~= hasRuneCasters then
        RuneLimiter.IsSet = hasRuneCasters
        RuneLimiter._BattleObjectsEnableSwitcher(not hasRuneCasters)
    end
end


function RuneLimiter.OnNewDay()
    RuneLimiter.CancelationToken = 1
    -- TODO: Check with Dwarf hidding in the Town
    RuneLimiter.CheckSetReset()
end


function RuneLimiter.OnAddHero(sHeroName)
    if not GetHeroTown(sHeroName) and HasHeroSkill(sHeroName, HERO_SKILL_RUNELORE) then
        RuneLimiter.CheckSetReset()
    end
end


function RuneLimiter.OnRemoveHero(sHeroName, sFoeName)
    if tObjectOwners[sHeroName] then
        RuneLimiter._TryGetResourcesBack(tObjectOwners[sHeroName])
    end
    
    if sFoeName and tObjectOwners[sFoeName] then
        RuneLimiter._TryGetResourcesBack(tObjectOwners[sFoeName])
    end
end


function RuneLimiter.OnHeroTouchObject(sHeroName, sObjectName, sTriggerName)
    if not IsObjectExists(sObjectName) or IsObjectEnabled(sObjectName) then
        return
    end
    print_debug___("Custom Hero-Object Interaction")
    
    SetObjectEnabled(sObjectName, not nil)
    
    if RuneLimiter._CheckStoreResources(sHeroName, sObjectName) then
        SetTrigger(OBJECT_TOUCH_TRIGGER, sObjectName, 'AwaitRuneBattleEnd')
    else
        SetTrigger(OBJECT_TOUCH_TRIGGER, sObjectName, nil)
    end
    
    MakeHeroInteractWithObject(sHeroName, sObjectName)
    sleep(1)
    
    if IsObjectExists(sObjectName) then
        SetObjectEnabled(sObjectName, nil)
        SetTrigger(OBJECT_TOUCH_TRIGGER, sObjectName, sTriggerName)
    end
end


function RuneLimiter.OnHeroTouchHero(sHero1Name, sHero2Name, sTriggerName)
    if not IsObjectExists(sHero2Name) or IsObjectEnabled(sHero2Name) then
        return
    end

    RuneLimiter._CheckStoreResources(sHero1Name, sHero2Name, 'Hero-vs-Hero')

    SetObjectEnabled(sHero1Name, not nil)
    SetObjectEnabled(sHero2Name, not nil)
    -- SetTrigger(HERO_TOUCH_TRIGGER, sHero2Name, 'AwaitRuneBattleEnd')
    -- This trigger does not work
    -- PLAYER_REMOVE_HERO_TRIGGER used instead to get resources back

    MakeHeroInteractWithObject(sHero1Name, sHero2Name)
    sleep(1)

    if IsHeroAlive(sHero1Name) then
        SetObjectEnabled(sHero1Name, nil)
    end
    
    if IsHeroAlive(sHero2Name) then
        SetObjectEnabled(sHero2Name, nil)
        SetTrigger(HERO_TOUCH_TRIGGER, sHero2Name, sTriggerName)
    end
end


function AwaitRuneBattleEnd(sHeroName, sObjectName)
    local nWasHeroOwner = tObjectOwners[sHeroName]
    local nWasObjectOwner = tObjectOwners[sObjectName]
    
    if nWasHeroOwner == nWasObjectOwner then return end
    
    RuneLimiter.CancelationToken = 0
    while RuneLimiter.CancelationToken == 0 do
        if not IsHeroAlive(sHeroName) or
           not IsObjectExists(sObjectName) or
           GetObjectOwner(sHeroName) == GetObjectOwner(sObjectName) or
           tDwarfXp[sHeroName] < GetHeroStat(sHeroName, STAT_EXPERIENCE)
        then
            RuneLimiter._TryGetResourcesBack(nWasHeroOwner)
            RuneLimiter._TryGetResourcesBack(nWasObjectOwner)
            return
        else
            sleep(2)
        end
    end
    
    RuneLimiter._TryGetResourcesBack(nWasHeroOwner)
    RuneLimiter._TryGetResourcesBack(nWasObjectOwner)
end


function RuneLimiter._CheckStoreResources(sHeroName, sObjectName, bothHeroes)
    tObjectOwners[sHeroName]   = GetHeroOwner(sHeroName)
    tObjectOwners[sObjectName] = GetObjectOwner(sObjectName)
    
    if tObjectOwners[sHeroName] == tObjectOwners[sObjectName] then
        return nil
    end
    
    local stored = nil
    
    if HasHeroSkill(sHeroName, HERO_SKILL_RUNELORE) and
       GetHeroLevel(sHeroName) < 40
    then
        tDwarfXp[sHeroName] = GetHeroStat(sHeroName, STAT_EXPERIENCE)
        RuneLimiter._StoreResources(tObjectOwners[sHeroName])
        stored = not nil
    end
    
    local sFoeHeroName = nil
    
    if     bothHeroes          then  sFoeHeroName = sObjectName
    elseif IsTown(sObjectName) then  sFoeHeroName = GetTownHero(sObjectName) end
    
    if sFoeHeroName and HasHeroSkill(sFoeHeroName, HERO_SKILL_RUNELORE) and
       GetHeroLevel(sFoeHeroName) < 40
    then
        tDwarfXp[sFoeHeroName] = GetHeroStat(sFoeHeroName, STAT_EXPERIENCE)
        RuneLimiter._StoreResources(tObjectOwners[sObjectName])
        stored = not nil
    end
    
    return stored
end


function RuneLimiter._StoreResources(nPlayerID)
    -- TODO: Enemy building OR monster
    local limit = RUNE_RESOURCE_LIMIT
    tRuneResourceStorage[nPlayerID] = { }

    for _, nResID in RESOURCES do
        local nResCount = GetPlayerResource(nPlayerID, nResID)

        if nResID ~= GOLD and nResCount > limit then
            tRuneResourceStorage[nPlayerID][nResID] = nResCount - limit
            SetPlayerResource(nPlayerID, nResID, limit)
        end
    end
     
    return nPlayerID
end


function RuneLimiter._TryGetResourcesBack(nPlayerID)
    if not tRuneResourceStorage[nPlayerID] then
        print_debug___ ("Nothing to return for Player "..nPlayerID)
        return
    end
    
    for _, nResID in RESOURCES do
       local nStoredResCount = tRuneResourceStorage[nPlayerID][nResID]

       if nResID ~= GOLD and nStoredResCount then
           ChangePlayerResource(nPlayerID, nResID, nStoredResCount)
       end
   end
   
   tRuneResourceStorage[nPlayerID] = nil
   print_debug___ ("All resources return for Player "..nPlayerID)
end


function RuneLimiter._BattleObjectsEnableSwitcher(enable)
    for _, sObjectName in GetObjectNamesByType('HERO') do
        SetObjectEnabled(sObjectName, enable)
    end
    for _, sObjectName in GetObjectNamesByType('TOWN') do
        SetObjectEnabled(sObjectName, enable)
    end
    for _, sObjectName in GetObjectNamesByType('CREATURE') do
        SetObjectEnabled(sObjectName, enable)
    end
    for _, sObjectName in GetCombatableBuildings() do
        SetObjectEnabled(sObjectName, enable)
    end
end


function AnyRuneCaster_NotAI()
    for _, sHeroName in GetObjectNamesByType('HERO_CLASS_RUNEMAGE') do
        if KnowHeroAnyRune(sHeroName) and IsAIPlayer(GetHeroOwner(sHeroName)) == 0 then
            return not nil
        end
    end
    
    return nil
end
