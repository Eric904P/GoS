-- Champion
if GetObjectName(GetMyHero()) ~= "Lux" then return end

-- Auto Updater
local ver = "0.01"

function AutoUpdate(data)
	if tonumber(data) > tonumber(ver) then
		print("New version found! " .. data)
		print("Downloading update, please wait...")
		DownloadFileAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/HK_Lux.lua", SCRIPT_PATH .. "HK_Lux.lua", function() print("Update complete, please 2x F6!") return end)
	else
		print("Version " .. ver .. "HK Lux loaded!")
	end
end

GetWebResultAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/HK_Lux.version", AutoUpdate)

-- Required Libs
require("OpenPredict")
require("DamageLib")

-- Menu
local Menu = Menu("Lux", "Lux")

-- 		Combo
Menu:SubMenu("Combo", "Combo Settings")
Menu.Combo:Boolean("Q", "Use Q", true)
Menu.Combo:Boolean("W", "Use W", true)
Menu.Combo:Boolean("E", "Use E", true)
Menu.Combo:Boolean("R", "Use R", true)
Menu.Combo:Boolean("RKS", "R only kill", true)

-- 		Harass
Menu:SubMenu("Harass", "Harass Settings")
Menu.Harass:Boolean("Q", "Use Q", true)
Menu.Harass:Boolean("W", "Use W", true)
Menu.Harass:Boolean("E", "Use E", true)
Menu.Harass:Slider("Mana", "Harass min mana", 20,0,100,1)

--		Farm
Menu:SubMenu("Farm", "Farming Settings")
Menu.Farm:Boolean("Q", "Use Q", true)
Menu.Farm:Boolean("E", "Use E", true)
Menu.Farm:Slider("Mana", "Farm min mana", 40,0,100,1)

--		Drawing
Menu:SubMenu("Draw", "Drawing Settings")
Menu.Draw:Boolean("Q", "Draw Q", true)
Menu.Draw:Boolean("W", "Draw W", false)
Menu.Draw:Boolean("E", "Draw E", false)
Menu.Draw:Boolean("R", "Draw R", false)

-- Spell Data
local Spells = {
	Q = {delay = 0.25, range = 1175, speed = 1200, width = 70},
	W = {delay = 0.25, range = 1075, speed = 1400, width = 100},
	E = {delay = 0.25, range = 1000, speed = 1300, radius = 350},
	R = {delay = 1, range = 3340, speed = math.huge, width = 190}
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

-- Game Tick
OnTick(function()
	KS()
	target = GetCurrentTarget()
		Combo()
		Harass()
		Farm()
end)

-- Spell Functions
function castQ()
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance > 0.9 and not QPred:mCollision(1) then 
		CastSkillShot(_Q, QPred.castPos)
	end
end

function castW()
	CastSkillShot(_W, GetOrigin(myHero))
end

function castE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.7 then
		CastSkillShot(_E, EPred.castPos)
	end
end

function castR()
	local RPred = GetLinearAOEPrediction(target, Spells.R)
	if RPred.hitChance > 0.7 then
		CastSkillShot(_R, RPred.castPos) 
	end
end

-- Mode Functions
function Combo()
	if Mode() == "Combo" then
		if Menu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			castQ()
		end
		if Menu.Combo.W:Value() and Ready(_W) and (GetCurrentHP(myHero)/GetMaxHP(myHero)) < 0.3 then
			castW()
		end
		if Menu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			castE()
		end
		if Menu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) then
			local RPred = GetPrediction(enemy, Spells.R)
			if Menu.Combo.RKS:Value() and GetHealthPrediction(enemy, RPred.timeToHit) < getdmg("R", enemy, myHero) then
				CastSkillShot(_R, RPred.castPos)
			elseif not Menu.Combo.RKS:Value() then
				CastSkillShot(_R, RPred.castPos)
			end
		end
	end
end

function Harass()
	if Mode() == "Harass" then
		if Menu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
			castQ()
		end
		if Menu.Harass.W:Value() and Ready(_W) and (GetCurrentHP(myHero)/GetMaxHP(myHero)) < 0.3 and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
			castW()
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
					CastSkillShot(_Q, minion)
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
					CastSkillShot(_Q, mob)
				end
				if Menu.Farm.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					CastSkillShot(_E, mob)
				end
			end
		end
	end
end

-- Kill Steal
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do
		if Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			local QPred = GetPrediction(enemy, Spells.Q)
			if GetHealthPrediction(enemy, QPred.timeToHit) < getdmg("Q", enemy, myHero) then
				CastSkillShot(_Q, QPred.castPos)
			end
		end
		if Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			local EPred = GetCircularAOEPrediction(enemy, Spells.E)
			if GetHealthPrediction(enemy, EPred.timeToHit) < getdmg("E", enemy, myHero) then
				CastSkillShot(_E, EPred.castPos)
			end
		end
		if Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			local RPred = GetPrediction(enemy, Spells.R)
			if GetHealthPrediction(enemy, RPred.timeToHit) < getdmg("R", enemy, myHero) then
				CastSkillShot(_R, RPred.castPos)
			end
		end
	end
end

-- Drawing
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	
	if Menu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Pink) end
	if Menu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
	if Menu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Yellow) end
	if Menu.Draw.R:Value() then DrawCircle(pos, Spells.R.range, 0, 25, GoS.Red) end
end)
