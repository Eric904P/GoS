-- Champion
if GetObjectName(GetMyHero()) ~= "" then return end

-- Auto Updater
local ver = "0.01"

function AutoUpdate(data)
	if tonumber(data) > tonumber(ver) then
		print("New version found! " .. data)
		print("Downloading update, please wait...")
		DownloadFileAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/Template.lua", SCRIPT_PATH .. "Template.lua", function() print("Update complete, please 2x F6!") return end)
	else
		print("Version " .. ver .. "Template loaded!")
	end
end

GetWebResultAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/Template.version", AutoUpdate)

-- Required Libs
require("OpenPredict")
require("DamageLib")

-- Menu
local Menu = Menu("Template", "Template")

-- 		Combo
Menu:SubMenu("Combo", "Combo Settings")
Menu.Combo:Boolean("Q", "Use Q", true)
Menu.Combo:Boolean("W", "Use W", true)
Menu.Combo:Boolean("E", "Use E", true)
Menu.Combo:Boolean("R", "Use R", true)

-- 		Harass
Menu:SubMenu("Harass", "Harass Settings")
Menu.Harass:Boolean("Q", "Use Q", true)
Menu.Harass:Boolean("W", "Use W", true)
Menu.Harass:Boolean("E", "Use E", true)
Menu.Harass:Slider("Mana", "Harass min mana", 20,0,100,1)

--		Farm
Menu:SubMenu("Farm", "Farming Settings")
Menu.Farm:Boolean("Q", "Use Q", true)
Menu.Farm:Boolean("W", "Use W", true)
Menu.Farm:Boolean("E", "Use E", true)
Menu.Farm:Slider("Mana", "Farm min mana", 40,0,100,1)

--		Drawing
Menu:SubMenu("Draw", "Drawing Settings")
Menu.Draw:Boolean("Q", "Draw Q", true)
Menu.Draw:Boolean("W", "Draw W", true)
Menu.Draw:Boolean("E", "Draw E", true)
Menu.Draw:Boolean("R", "Draw R", true)

-- Spell Data
local Spells = {
	Q = {delay = , range = , speed = , width = },
	W = {delay = , range = , speed = , width = },
	E = {delay = , range = , speed = , width = },
	R = {delay = , range = , speed = , width = }
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
	if QPred.hitChance > 0.3 and not QPred:mCollision(1) then 
		-- this example checks for collision with minions.  See OpenPredict API for details.
		CastSkillShot(_Q, QPred.castPos)
	end
end

function castW()
	local WPred = GetCircularAOEPrediction(target, Spells.W)
	if WPred.hitChance > 0.3 then
		-- this example gets prediction for circular AOE skilshot, such as Veigar W
		CastSkillShot(_W, WPred.castPos)
	end
end

function castE()
	local EPred = GetConicAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		-- this example gets prediction for conic AOE, such as Cho'gath W
		CastSkillShot(_E, EPred.castPos)
	end
end

function castR()
	local RPred = GetLinearAOEPrediction(target, Spells.R)
	if RPred.hitChance > 0.3 then
		-- this example gets linear AOE prediction, such as Xerath Q.  This example also includes double-casting of Xerath Q
		CastSkillShot2(_R, RPred.castPos) -- note there is more to casting Xerath Q or Varus Q so please do research
	end
end

-- Mode Functions
function Combo()
	if Mode() == "Combo" then
		if Menu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			castQ()
		end
		if Menu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			castW()
		end
		if Menu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			castW()
		end
		if Menu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) then
			castR()
		end
	end
end

function Harass()
	if Mode() == "Harass" then
		if Menu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
			castQ()
		end
		if Menu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Harass.Mana:Value()/100) then
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
				if Menu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, Spells.W.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					CastSkillShot(_W, minion)
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
				if Menu.Farm.W:Value() and Ready(_W) and ValidTarget(mob, Spells.W.range) and (GetCurrentMana(myHero)/GetMaxMana(myHero)) >= (Menu.Farm.Mana:Value()/100) then
					CastSkillShot(_W, mob)
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
	
	if Menu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Green) end
	if Menu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
	if Menu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Yellow) end
	if Menu.Draw.R:Value() then DrawCircle(pos, Spells.R.range, 0, 25, GoS.Red) end
end)
