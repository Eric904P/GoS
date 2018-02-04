if GetObjectName(myHero) ~= "Jax" then return end

require('OpenPredict')



local JaxMenu = Menu("JaxNation", "JaxNation")

JaxMenu:Menu("Combo", "Combo")
JaxMenu.Combo:Boolean("useQ", "Use Q", true)
JaxMenu.Combo:Boolean("useW", "Use W", true)
JaxMenu.Combo:Boolean("useE", "Use E", true)
JaxMenu.Combo:Boolean("useR", "Use R", true)
JaxMenu.Combo:Boolean("useTiamat", "Use Tiamat", true)
JaxMenu.Combo:Boolean("useHydra", "Use Ravenous Hydra", true)
JaxMenu.Combo:Boolean("useTitanic", "Use Titanic Hydra", true)
JaxMenu.Combo:Boolean("useBOTRK", "Use BladeOfTheRuinedKing", true)
JaxMenu.Combo:Boolean("useCut", "Use Bilgewater Cutlass", true)  
JaxMenu.Combo:Boolean("useYoum", "Use Youmuu's Ghostblade", true)
JaxMenu.Combo:Boolean("useGun", "Use Hextech Gunblade", true)

--Spells
local JaxQ = { range = 700}

--Start
OnTick(function(myHero)
    if not IsDead(myHero) then
        local target = GetCurrentTarget()

        --Combo
        if IOW:Mode() == "Combo" then
            --E
            if JaxMenu.Combo.useE:Value() and Ready(_E) and ValidTarget(target, GetRange(myHero) + GetHitBox(target)) then
                CastSpell(_E)
            end
            --Q
            if JaxMenu.Combo.useQ:Value() and Ready(_Q) and ValidTarget(target, JaxQ.range) then
                CastTargetSpell(target,_Q)
            end
            --W
            if JaxMenu.Combo.useW:Value() and Ready(_W) and ValidTarget(target, GetRange(myHero)) then
                CastSpell(_W)
            end
            --R
            if JaxMenu.Combo.useR:Value() and Ready(_R) and EnemiesAround(myHero, 600) >= 1 then
                CastSpell(_R)
            end
            if GetItemSlot(myHero, 3142) > 0 and IsReady(GetItemSlot(myHero, 3142)) and JaxMenu.Combo.useYoum:Value() then
                CastSpell(GetItemSlot(myHero, 3142))
            end   
            if GetItemSlot(myHero, 3077) > 0 and IsReady(GetItemSlot(myHero, 3077)) and JaxMenu.Combo.useTiamat:Value() then
                CastSpell(GetItemSlot(myHero, 3077))
            end
            if GetItemSlot(myHero, 3074) > 0 and IsReady(GetItemSlot(myHero, 3074)) and JaxMenu.Combo.useHydra:Value() then
                CastSpell(GetItemSlot(myHero, 3074))
            end
            if GetItemSlot(myHero, 3748) > 0 and IsReady(GetItemSlot(myHero, 3748)) and JaxMenu.Combo.useTitanic:Value() then
                CastSpell(GetItemSlot(myHero, 3748))
            end
            if GetItemSlot(myHero, 3153) > 0 and IsReady(GetItemSlot(myHero, 3153)) and JaxMenu.Combo.useBOTRK:Value() then
                CastTargetSpell(target, GetItemSlot(myHero, 3153))
            end            
            if GetItemSlot(myHero, 3146) > 0 and IsReady(GetItemSlot(myHero, 3146)) and JaxMenu.Combo.useGun:Value() then
                CastTargetSpell(target, GetItemSlot(myHero, 3146))
            end
            if GetItemSlot(myHero, 3144) > 0 and IsReady(GetItemSlot(myHero, 3144)) and SkarnerMenu.Combo.useCut:Value() then
                CastTargetSpell(target, GetItemSlot(myHero, 3144)) 
            end 
        end
    end
end)

JaxMenu:SubMenu("s", "Skin Changer")
  skinMeta = {["Jax"] = {"Classic", "The Mighty", "Vandal", "Angler", "PAX", "Jaximus", "Temple", "Nemesis", "SKT T1", "Chroma1", "Chroma2", "Chroma3", "Warden"}}
  JaxMenu.s:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName],function(model)
        HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") 
    end,
true)
