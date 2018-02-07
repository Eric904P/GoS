-- Champion
if GetObjectName(GetMyHero()) ~= "" then return end

-- Auto Updater
local ver = "0.01"

function AutoUpdate(data)
	if tonumber(data) > tonumber(ver) then
		print("New version found! " .. data)
		print("Downloading update, please wait...")
		DownloadFileAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/HK_Nasus.lua", SCRIPT_PATH .. "HK_Nasus.lua", function() print("Update complete, please 2x F6!") return end)
	else
		print("Version " .. ver .. "Template loaded!")
	end
end

GetWebResultAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/HK_Nasus.version", AutoUpdate)

-- Required Libs
require("OpenPredict")
require("DamageLib")

-- Menu
local Menu = Menu("Nasus", "Nasus")

-- 		Combo
Menu:SubMenu("Combo", "Combo Settings")
Menu.Combo:Boolean("Q", "Use Q", true)
Menu.Combo:Boolean("W", "Use W", true)
Menu.Combo:Boolean("E", "Use E", true)
Menu.Combo:Boolean("R", "Use R", true)
Menu.Combo:Slider("RHP", "R at % HP", 15,0,100,1)

-- 		Harass
Menu:SubMenu("Harass", "Harass Settings")
Menu.Harass:Boolean("Q", "Use Q", true)
Menu.Harass:Boolean("W", "Use W", true)
Menu.Harass:Boolean("E", "Use E", true)
Menu.Harass:Slider("Mana", "Harass min mana", 20,0,100,1)

--		Farm
Menu:SubMenu("Farm", "Farming Settings")
Menu.Farm:Boolean("Q", "Use Q", true)
Menu.Farm:Boolean("SQ", "Save Q for LH", true)
Menu.Farm:Boolean("AQ", "Auto Q", true)
Menu.Farm:Boolean("E", "Use E", false)
Menu.Farm:Slider("Mana", "Farm min mana", 40,0,100,1)

--		Drawing
Menu:SubMenu("Draw", "Drawing Settings")
Menu.Draw:Boolean("Q", "Draw Q", true)
Menu.Draw:Boolean("W", "Draw W", true)
Menu.Draw:Boolean("E", "Draw E", true)
Menu.Draw:Boolean("R", "Draw R", true)

-- Spell Data
local Spells = {
	Q = {range = 125},
	W = {range = 600},
	E = {delay = 0.25, range = 650, speed = math.huge, radius = 400},
	R = {radius = 175}
}

-- Orbwalker
function Mode()
	if _G.IOW_Loaded and IOW:Mode() then
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then 
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		return SLW:Mode()
	elseif _G.EOW_Loaded and EOW:Mode() then
		return EOW:Mode()
	end
end

IOW:AddCallBack(AFTER_ATTACK, function(target) 
	if IOW:Mode() == "Combo" and Ready(_Q) and ValidTarget(target, Spells.Q.range) then 
		CastSpell(_Q)
		IOW:ResetAA()
	end
end)

EOW:AddCallBack(AFTER_ATTACK, function(target)
	if EOW:Mode() == "Combo" and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
		CastSpell(_Q)
		EOW:ResetAA()
	end
end)

OnAfterAttack(function(myHero, target)
	if DACR:Mode() == "Combo" and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
		CastSpell(_Q)
		DACR:ResetAA()
	end
end)


-- Game Tick
OnTick(function()
	AutoR()
	if Menu.Farm.AQ:Value() then AutoQ() end
	target = GetCurrentTarget()
		Combo()
		Harass()
		Farm()
end)

-- Spell Functions
function castE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end
end

-- Mode Functions
function Combo()
	if Mode() == "Combo" then
		if Menu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			CastSpell(_Q)
			ResetAA()
			AttackUnit(target)
		end
		if Menu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			CastTargetSpell(target, _W)
		end
		if Menu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			castE()
		end
		if Menu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) and (GetCurrentHP(myHero)/GetMaxHP(myHero)) <= (Menu.Combo.RHP:Value()/100) then
			CastSpell(_R)
		end
	end
end

function Harass()
	if Mode() == "Harass" then
		if Menu.Harass.Q:Value() and not Menu.Farm.SQ:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
			CastSpell(_Q)
			AttackUnit(target)
		end
		if Menu.Harass.Q:Value() and Menu.Farm.SQ:Value() and Ready(_Q) and GetDistance(target, myHero) > 1250 and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100)then
			CastSpell(_Q)
		end
		if Menu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
			CastTargetSpell(target, _W)
		end
		if Menu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
			castE()
		end
	end
end

function Farm()
	if Mode() == "LaneClear" then
		-- Lane Minions
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if Menu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					if not Menu.Farm.SQ:Value() then
						CastSpell(_Q)
						AttackUnit(minion)
					elseif GetHealthPrediction(minion, GetAnimationTime(myHero)) < getdmg("Q", minion, myHero) then
						CastSpell(_Q)
						AttackUnit(minion)
					end
				end
				if Menu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					CastSkillShot(_E, minion)
				end
			end
		end
		-- Jungle Mobs
		for _, mob in pairs(minionManager.objects) do
			if GetTeam(mob) == MINION_JUNGLE then
				if Menu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					CastSpell(_Q)
					AttackUnit(mob)
				end
				if Menu.Farm.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					CastSkillShot(_E, mob)
				end
			end
		end
	end
end

function AutoQ()
	for _, minion in pairs(mininoManager.objects) do
		if GetTeam(minion) == MINION_ENEMY then
			if GetHealthPrediction(minion, GetAnimationTime(myHero)) < getdmg("Q", minion, myHero) and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
				CastSpell(_Q)
				ResetAA()
				AttackUnit(minion)
			end	
		end
	end
end

-- Kill Steal
function AutoR()
	if IsObjectAlive(myHero) and Ready(_R) and GetDistance(myHero, target) > 1250 and (GetCurrentHP(myHero)/GetMaxHP(myHero)) <= (Menu.Combo.RHP:Value()/100) then
		CastSpell(_R)
	end
end

-- Drawing
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	
	if Menu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Green) end
	if Menu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
	if Menu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Yellow) end
	if Menu.Draw.R:Value() then DrawCircle(pos, Spells.R.range, 0, 25, GoS.Red) end
end)
