if GetObjectName(GetMyHero()) ~= "Soraka" then return end

require("OpenPredict")
require("DamageLib")

local ver = "0.02"

function AutoUpdate(data)
	if tonumber(data) > tonumber(ver) then
		print("New version available! " .. data)
		print("Downloading update, please wait...")
		DownloadFileAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/Raka.lua", SCRIPT_PATH .. "Raka.lua", function() print("Update complete, please 2x F6 to load") return end)
	end
end

GetWebResultAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/Raka.version", AutoUpdate)

local Menu = Menu("Soraka", "Soraka")

Menu:SubMenu("Combo", "Combo settings")
Menu.Combo:Boolean("Q", "Use Q", true)
Menu.Combo:Boolean("W", "Use W", true)
Menu.Combo:Boolean("E", "Use E", true)
Menu.Combo:Boolean("R", "Use R", true)

Menu:SubMenu("Harass", "Harass settings")
Menu.Harass:Boolean("Q", "Use Q", true)
Menu.Harass:Boolean("E", "Use E", true)
Menu.Harass:Boolean("AA", "Disable AA", true)
Menu.Harass:Slider("Mana", "Minimum mana", 15,0,100,1)

Menu:SubMenu("Farm", "Farm settings")
Menu.Farm:Boolean("Q", "Use Q", true)
Menu.Farm:Boolean("AA", "Disable AA", false)
Menu.Farm:Slider("Mana", "Minimum mana", 40,0,100,1)

Menu:SubMenu("Heal", "Heal settings")
Menu.Heal:Boolean("AutoR", "Auto R", true)
Menu.Heal:Boolean("AutoW", "Auto W", true)
Menu.Heal:Slider("RCount", "How many to R?", 2,0,5,1)
Menu.Heal:Slider("RHP", "HP to R", 20,0,100,1)
Menu.Heal:Slider("Mana", "Minimum mana", 0,0,100,1)

Menu:SubMenu("Misc", "Misc settings")
Menu.Misc:Boolean("DrawQ", "Draw Q", true)
Menu.Misc:Boolean("DrawW", "Draw W", false)
Menu.Misc:Boolean("DrawE", "Draw E", false)
Menu.Misc:Slider("HC", "Global hitchance", 70,0,100,1)

local Spells = {
	Q = {delay = 0.5, range = 800, radius = 235, speed = 1750},
	W = {range = 550},
	E = {delay = 1.5, range = 925, radius = 275, speed = math.huge}
}

local SpellsBase = {
Q = {70,110,150,190,230},
W = {80,110,140,170,200},
E = {70,110,150,190,230},
R = {150,250,350}
}

function Mode()
	if _G.IOW_Loaded and IOW:Mode() then
		if Menu.Farm.AA:Value() and IOW:Mode() == "LaneClear" then
			IOW.attacksEnabled = false
		elseif Menu.Harass.AA:Value() and IOW:Mode() == "Harass" then
			IOW.attacksEnabled = false
		else
			IOW.attacksEnabled = true
		end
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		if Menu.Farm.AA:Value() and PW:Mode() == "LaneClear" then
			PW.attacksEnabled = false
		elseif Menu.Harass.AA:Value() and PW:Mode() == "Harass" then
			PW.attacksEnabled = false
		else
			PW.attacksEnabled = true
		end
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
		if Menu.Farm.AA:Value() and DAC:Mode() == "LaneClear" then
			DAC.attacksEnabled = false
		elseif Menu.Harass.AA:Value() and DAC:Mode() == "Harass" then
			DAC.attacksEnabled = false
		else
			DAC.attacksEnabled = true
		end
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		if Menu.Farm.AA:Value() and DACR:Mode() == "LaneClear" then
			DACR.attacksEnabled = false
		elseif Menu.Harass.AA:Value() and DACR:Mode() == "Harass" then
			DACR.attacksEnabled = false
		else
			DACR.attacksEnabled = true
		end
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		if Menu.Farm.AA:Value() and SLW:Mode() == "LaneClear" then
			SLW.attacksEnabled = false
		elseif Menu.Harass.AA:Value() and SLW:Mode() == "Harass" then
			SLW.attacksEnabled = false
		else
			SLW.attacksEnabled = true
		end
		return SLW:Mode()
	elseif _G.EOW_Loaded and EOW:Mode() then
		if Menu.Farm.AA:Value() and EOW:Mode() == "LaneClear" then
			EOW:AttackEnabled(false)
		elseif Menu.Harass.AA:Value() and EOW:Mode() == "Harass" then
			EOW:AttackEnabled(false)
		else
			EOW:AttackEnabled(true)
		end
		return EOW:Mode()
	end
end

OnTick(function()
	Heal()
	target = GetCurrentTarget()
				Combo()
				Harass()
				Farm()
	end)

function castQ()
	local qPred = GetCircularAOEPrediction(target, Spells.Q)
	if qPred.hitChance > (Menu.Misc.HC:Value()/100) then
		CastSkillShot(_Q, qPred.castPos)
	end
end

function castW()
	CastTargetSpell(target, _W)
end

function castE()
	local ePred = GetCircularAOEPrediction(target, Spells.E)
	if ePred.hitChance > (Menu.Misc.HC:Value()/100) then
		CastSkillShot(_E, ePred.castPos)
	end
end

function castR()
	CastSpell(_R)
end

function Heal()
	local needHeal = 0
	for _, hero in pairs(GetAllyHeroes()) do
		if not hero == myHero and ValidTarget(hero, Spells.W.range) and (GetMaxHP(hero) - GetCurrentHP(hero)) >= wHeal() and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Heal.Mana:Value()/100) then
			castTargetSpell(hero, _W)
		end
		if (GetCurretnHP(hero)/GetMaxHP(hero)) > (Menu.Heal.RHP:Value()/100) then
			needHeal = (needHeal + 1)
		end
	end
	if needHeal >= Menu.Heal.RCount:Value() then
		CastR()
	end
end

function wHeal()
	return SpellsBase.W[GetSpellData(myHero, _W).level] + (0.6 * GetBonusAP(myHero))
end

function rHeal()
	return SpellsBase.R[GetSpellData(myHero, _R).level] + (0.55 * GetBonusAP(myHero))
end

function Combo()
	if Mode() == "Combo" then
		if Menu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			castQ()
		end
		if Menu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			castE()
		end
	end
end

function Harass()
	if Mode() == "Harass" and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
		if Menu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			castQ()
		end
		if Menu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			castE()
		end
	end
end

function Farm()
	if Mode() == "LaneClear" then
		if (GetCurrentMana(myHero)/GetMaxMana(myHero)) > (Menu.Farm.Mana:Value()/100) then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if Menu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
						local qPred = GetCircularAOEPrediction(minion, Spells.Q)
						if qPred.hitChance > 0.3 then 
							CastSkillShot(_Q, qPred.castPos)
						end
					end
				end
			end
		end
	end
end

OnDraw(function()
	if IsDead(myHero) then return end

	local pos = GetOrigin(myHero)
	if Menu.Misc.DrawQ:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
	if Menu.Misc.DrawW:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Yellow) end
	if Menu.Misc.DrawE:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Blue) end
end)

CHANELLING_SPELLS = {
    ["Caitlyn"]                     = {_R},
    ["Katarina"]                    = {_R},
    ["MasterYi"]                    = {_W},
    ["FiddleSticks"]                = {_W, _R},
    ["Galio"]                       = {_R},
    ["Lucian"]                      = {_R},
    ["MissFortune"]                 = {_R},
    ["VelKoz"]                      = {_R},
    ["Nunu"]                        = {_R},
    ["Shen"]                        = {_R},
    ["Karthus"]                     = {_R},
    ["Malzahar"]                    = {_R},
    ["Pantheon"]                    = {_R},
    ["Warwick"]                     = {_R},
    ["Xerath"]                      = {_Q, _R},
    ["Varus"]                       = {_Q},
    ["TahmKench"]                   = {_R},
    ["TwistedFate"]                 = {_R},
    ["Janna"]                       = {_R}
}

GAPCLOSER_SPELLS = {
    ["Aatrox"]                      = {_Q},
    ["Akali"]                       = {_R},
    ["Alistar"]                     = {_W},
    ["Amumu"]                       = {_Q},
    ["Corki"]                       = {_W},
    ["Diana"]                       = {_R},
    ["Elise"]                       = {_Q, _E},
    ["FiddleSticks"]                = {_R},
    ["Ezreal"]                      = {_E},
    ["Fiora"]                       = {_Q},
    ["Fizz"]                        = {_Q},
    ["Gnar"]                        = {_E},
    ["Gragas"]                      = {_E},
    ["Graves"]                      = {_E},
    ["Hecarim"]                     = {_R},
    ["Irelia"]                      = {_Q},
    ["JarvanIV"]                    = {_Q, _R},
    ["Jax"]                         = {_Q},
    ["Jayce"]                       = {_Q},
    ["Katarina"]                    = {_E},
    ["Kassadin"]                    = {_R},
    ["Kennen"]                      = {_E},
    ["KhaZix"]                      = {_E},
    ["Lissandra"]                   = {_E},
    ["LeBlanc"]                     = {_W, _R},
    ["LeeSin"]                      = {_Q, _W},
    ["Leona"]                       = {_E},
    ["Lucian"]                      = {_E},
    ["Malphite"]                    = {_R},
    ["MasterYi"]                    = {_Q},
    ["MonkeyKing"]                  = {_E},
    ["Nautilus"]                    = {_Q},
    ["Nocturne"]                    = {_R},
    ["Olaf"]                        = {_R},
    ["Pantheon"]                    = {_W, _R},
    ["Poppy"]                       = {_E},
    ["RekSai"]                      = {_E},
    ["Renekton"]                    = {_E},
    ["Riven"]                       = {_Q, _E},
    ["Rengar"]                      = {_R},
    ["Sejuani"]                     = {_Q},
    ["Sion"]                        = {_R},
    ["Shen"]                        = {_E},
    ["Shyvana"]                     = {_R},
    ["Talon"]                       = {_E},
    ["Thresh"]                      = {_Q},
    ["Tristana"]                    = {_W},
    ["Tryndamere"]                  = {_E},
    ["Udyr"]                        = {_E},
    ["Volibear"]                    = {_Q},
    ["Vi"]                          = {_Q},
    ["XinZhao"]                     = {_E},
    ["Yasuo"]                       = {_E},
    ["Zac"]                         = {_E},
    ["Ziggs"]                       = {_W},
}

local spellText = { "Q", "W", "E", "R" }

local callback = nil
local myTeam = GetTeam(GetMyHero())

local d = require 'DLib'
local GetEnemyHeroes = d.GetEnemyHeroes
local CHANELLING_SPELLS_enemy = {}
local GAPCLOSER_SPELLS_enemy = {}
local submenu = menu.addItem(SubMenu.new("interrupter"))

local submenuGapClose = submenu.addItem(SubMenu.new("gap close spell"))
local submenuChannell = submenu.addItem(SubMenu.new("chanelling spell"))

local loaded = false
d.initCallback(function(result)
    if result then
        for _,enemy in pairs(GetEnemyHeroes()) do
            local name = GetObjectName(enemy)
            
            local list = GAPCLOSER_SPELLS[name]
            if list then
                for _, spellSlot in pairs(list) do
                    GAPCLOSER_SPELLS_enemy[name..spellSlot] = submenuGapClose.addItem(MenuBool.new(name.." "..spellText[spellSlot+1], true))
                end
            end
            list = CHANELLING_SPELLS[name]
            if list then
                for _, spellSlot in pairs(list) do
                    CHANELLING_SPELLS_enemy[name..spellSlot] = submenuChannell.addItem(MenuBool.new(name.." "..spellText[spellSlot+1], true))
                end
            end
            -- PrintChat(name)
        end
        loaded = true
    end
end)

OnProcessSpell(function(unit, spell)    
    if not loaded or not callback or not unit or GetObjectType(unit) ~= Obj_AI_Hero  or GetTeam(unit) == myTeam then return end
    local unitName = GetObjectName(unit)
    local unitChanellingSpells = CHANELLING_SPELLS[unitName]
    local unitGapcloserSpells = GAPCLOSER_SPELLS[unitName]
    local spellName = spell.name

    if unitChanellingSpells then
        for _, spellSlot in pairs(unitChanellingSpells) do
            -- PrintChat(spell.name.." "..GetCastName(unit, spellSlot))
            if spellName == GetCastName(unit, spellSlot) and CHANELLING_SPELLS_enemy[unitName..spellSlot].getValue() then 
            	if ValidTarget(unit, Spells.E.range) and Ready(_E) then
            		local ePred = GetCircularAOEPrediction(unit, Spells.E)
            		if ePred.hitChance > 0.3 then
            			CastSkillShot(_E, ePred.castPos)
            		end
            	end
            end
        end
    elseif unitGapcloserSpells then
        for _, spellSlot in pairs(unitGapcloserSpells) do
            if spellName == GetCastName(unit, spellSlot) and GAPCLOSER_SPELLS_enemy[unitName..spellSlot].getValue() then 
               	if ValidTarget(unit, Spells.E.range) and Ready(_E) then
            		local ePred = GetCircularAOEPrediction(unit, Spells.E)
            		if ePred.hitChance > 0.3 then
            			CastSkillShot(_E, ePred.castPos)
            		end
            	end
            end
        end
    end
end)

function addInterrupterCallback( callback0 )
	callback = callback0
end
