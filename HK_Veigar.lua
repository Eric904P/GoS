--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Veigar" then return end
--          [[ Updater ]]
local ver = "0.06"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/HK_Veigar.lua", SCRIPT_PATH .. "HK_Veigar.lua", function() print("Update Complete, please 2x F6!") return end)
    else
    	print("Version " .. ver .. "HK Veigar loaded!")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/Eric904P/GoS/master/HK_Veigar.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local VeigarMenu = Menu("Veigar", "Veigar")
--          [[ Combo ]]
VeigarMenu:SubMenu("Combo", "Combo Settings")
VeigarMenu.Combo:Boolean("Q", "Use Q", true)
VeigarMenu.Combo:Boolean("W", "Use W", true)
VeigarMenu.Combo:Boolean("WS", "Use W Only Stun", true)
VeigarMenu.Combo:Boolean("E", "Use E", true)
--          [[ Harass ]]
VeigarMenu:SubMenu("Harass", "Harass Settings")
VeigarMenu.Harass:Boolean("Q", "Use Q", true)
VeigarMenu.Harass:Boolean("W", "Use W", true)
VeigarMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
VeigarMenu:SubMenu("Farm", "Farm Settings")
VeigarMenu.Farm:Boolean("Q", "Use Q", true)
VeigarMenu.Farm:Boolean("QL", "Use Q Only LastHit", true)
VeigarMenu.Farm:Boolean("W", "Use W", false)
VeigarMenu.Farm:Slider("Mana", "Min. Mana", 0, 0, 100, 1)
VeigarMenu.Farm:Boolean("Sup", "Support mode", false)
--          [[ Jungle ]]
VeigarMenu:SubMenu("JG", "Jungle Settings")
VeigarMenu.JG:Boolean("Q", "Use Q", true)
VeigarMenu.JG:Boolean("W", "Use W", true)
--          [[ KillSteal ]]
VeigarMenu:SubMenu("KS", "KillSteal Settings")
VeigarMenu.KS:Boolean("Q", "Use Q", true)
VeigarMenu.KS:Boolean("R", "Use R", true)
--          [[ Draw ]]
VeigarMenu:SubMenu("Draw", "Drawing Settings")
VeigarMenu.Draw:Boolean("Q", "Draw Q", false)
VeigarMenu.Draw:Boolean("W", "Draw W", false)
VeigarMenu.Draw:Boolean("E", "Draw E", false)
VeigarMenu.Draw:Boolean("R", "Draw R", false)
--          [[ Spell ]]
local Spells = {
 Q = {range = 900, delay = 0.25, speed = 2000, width = 30},
 W = {range = 925, delay = 0.25, speed = 1300, width = 112},
 E = {range = 700, delay = 0.25, speed = math.huge, radius = 375},
 R = {range = 650, delay = 0.25, speed = math.huge, width = 30}
}
--          [[ Orbwalker ]]
function Mode()
	if _G.IOW_Loaded and IOW:Mode() then 
		if VeigarMenu.Farm.Sup:Value() then 
			if IOW:Mode() == "LaneClear" then 
				IOW.attacksEnabled = true 
			else
				IOW.attacksEnabled = false
			end
		else
			IOW.attacksEnabled = true
		end
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		if VeigarMenu.Farm.Sup:Value() then 
			if PW:Mode() == "LaneClear" then 
				PW.attacksEnabled = true 
			else
				PW.attacksEnabled = false
			end
		else
			PW.attacksEnabled = true
		end
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
		if VeigarMenu.Farm.Sup:Value() then 
			if DAC:Mode() == "LaneClear" then 
				DAC.attacksEnabled = true 
			else
				DAC.attacksEnabled = false
			end
		else
			DAC.attacksEnabled = true
		end
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		if VeigarMenu.Farm.Sup:Value() then 
			if DACR:Mode() == "LaneClear" then 
				DACR.attacksEnabled = true 
			else
				DACR.attacksEnabled = false
			end
		else
			DACR.attacksEnabled = true
		end
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		if VeigarMenu.Farm.Sup:Value() then 
			if SLW:Mode() == "LaneClear" then 
				SLW.attacksEnabled = true 
			else
				SLW.attacksEnabled = false
			end
		else
			SLW.attacksEnabled = true
		end
		return SLW:Mode()
	elseif _G.EOW_Loaded and EOW:Mode() then
		if VeigarMenu.Farm.Sup:Value() then 
			if EOW:Mode() == "LaneClear" then 
				EOW:AttackEnabled(true) 
			else
				EOW:AttackEnabled(false)
			end
		else
			EOW:AttackEnabled(true)
		end
		return EOW:Mode()
	end
end
--          [[ Tick ]]
OnTick(function()
	KS()
	target = GetCurrentTarget()
	         Combo()
	         Harass()
	         Farm()
	    end)  
--          [[ VeigarQ ]]
function VeigarQ()	
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance > 0.3 and not QPred:mCollision(1) then
		CastSkillShot(_Q, QPred.castPos)
	end
end   
--          [[ VeigarW ]]
function VeigarW()
	local WPred = GetCircularAOEPrediction(target, Spells.W)
	if WPred.hitChance > 0.3 then
		CastSkillShot(_W, WPred.castPos)
	end	
end	
--          [[ VeigarE ]]
function VeigarE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  
--          [[ VeigarR ]]
function VeigarR()
	CastTargetSpell(target, _R)
end	
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
--		[[ Use Q ]]
		if VeigarMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			VeigarQ()
			end
--		[[ Use W ]]
		if VeigarMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			VeigarW()
			end
--		[[ Use W Only Stun ]]
		if VeigarMenu.Combo.WS:Value() and Ready(_W) and ValidTarget(target, GetCastRange(myHero, _W)) and GotBuff(target, "veigareventhorizonstun") > 0  then
			VeigarW()
			end
--		[[ Use E ]]
		if VeigarMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			VeigarE()
		end
	end
end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= VeigarMenu.Harass.Mana:Value() /100) then
-- 			[[ Use Q ]]
			if VeigarMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				VeigarQ()
			end
-- 			[[ Use W ]]
			if VeigarMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
				VeigarW()
			end
			for _, minion in pairs(minionManager.objects) do
				if VeigarMenu.Farm.QL:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
					if GetCurrentHP(minion) < getdmg("Q", minion, myHero) then
						CastSkillShot(_Q, minion)
			    	end
				end
			end 
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= VeigarMenu.Farm.Mana:Value() /100) then
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q LastHit]]
					if VeigarMenu.Farm.QL:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
						if GetCurrentHP(minion) < getdmg("Q", minion, myHero) then
							CastSkillShot(_Q, minion)
					    end
					end 
-- 					[[ Use Q ]]
					if VeigarMenu.Farm.Q:Value() and not VeigarMenu.Farm.QL:Value()and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
-- 					[[ Use W ]]
					if VeigarMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, Spells.W.range) then
							CastSkillShot(_W, minion)
						end	
					end
				end	
			-- [[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if VeigarMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
					    end
-- 					[[ Use W ]]
					if VeigarMenu.JG.W:Value() and Ready(_W) and ValidTarget(mob, Spells.W.range) then
							CastSkillShot(_W, mob)
						end	
					end
				end
			end
		end
	end
--          [[ KillSteal ]]
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do
-- 		[[ Use Q ]]
		if VeigarMenu.KS.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			local qPred = GetPrediction(enemy, Spells.Q)
			if GetHealthPrediction(enemy, qPred.timeToHit) < getdmg("Q", enemy, myHero) then
				VeigarQ()
				end
			end
-- 		[[ Use R ]]
		if VeigarMenu.KS.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			local rPred = GetPrediction(enemy, Spells.R)
			if GetHealthPrediction(enemy, rPred.timeToHit) < getdmg("R", enemy, myHero) and GetHealthPrediction(enemy, rPred.timeToHit) > 0 then
				VeigarR()
			end
		end
	end
end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if VeigarMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
--  [[ Draw W ]]
	if VeigarMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
--  [[ Draw E ]]
	if VeigarMenu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Blue) end
--  [[ Draw R ]] 
	if VeigarMenu.Draw.R:Value() then DrawCircle(pos, Spells.R.range, 0, 25, GoS.Green) end
end)	
