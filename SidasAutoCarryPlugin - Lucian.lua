--[[
 
        Auto Carry Plugin - Lucian Edition
		Author: Kain
		Version: 1.07d
		Copyright 2013

		Dependency: Sida's Auto Carry: Revamped
 
		How to install:
			Make sure you already have AutoCarry installed.
			Name the script EXACTLY "SidasAutoCarryPlugin - Lucian.lua" without the quotes.
			Place the plugin in BoL/Scripts/Common folder.
		
		Version History:
			Version: 1.07e: http://pastebin.com/kgFKdwuS
				Sword of the Divine supported.
				Improved dynamic draw ranges.
				Harass fixed. Fires Q.
				Hack fixed killsteal until BoL finally gets updated properly.
				Killsteal fix resolved firing spells without key pressed.
			Version: 1.07c: http://pastebin.com/tK2WNXsy
				Relentless Pursuit Out of Enemy slows.
				Tweaked prediction variables.
				Killsteal enabled.
			Version: 1.06c: http://pastebin.com/sdvmmNyR
				Spell weaving.
				Draw range logic improvement.
				Menu updates.
			Version: 1.05d Beta: http://pastebin.com/rE5X8puE
				Improvements to mechanics of Culling Lockon. (Still more to do here.)
				Fix issue with Ultimate ending early.
				Miscellaneous bug fixes.
			Version: 1.04 Beta Pre-Release: http://pastebin.com/ayEX5Bfq
				Culling Lockon added. Considered experimental, but seems to be working pretty well.
			Version: 1.02 Beta Pre-Release: http://pastebin.com/tXxr95g9
			Version: 1.0 Alpha: http://pastebin.com/xWbRz89K
--]]

if myHero.charName ~= "Lucian" then return end

function PluginOnLoad()
	Vars()
	Menu()

	AutoCarry.SkillsCrosshair.range = QMaxRange
end

function Vars()
	tick = nil
	Target = nil

	-- Confirm ranges on release.
	QRange = 550
	QMaxRange = 1100
	WRange = 1000
	ERange = 425
	RRange = 1400

	QSpeed = 19.346
	WSpeed = 1.47 -- Old: 1.009
	ESpeed = 3.867
	RSpeed = 2.9 -- Old: 1.3

	QWidth = 250
	WWidth = 250
	EWidth = 250
	RWidth = 250

	QDelay = 405
	WDelay = 288 -- Old: 256
	EDelay = 1070
	RDelay = 200

	RRefresh = 0.1
	RDuration = 3.2 -- Old: 3.0 2.871 - 3.167

	ParticleRProjectileName = "Lucian_R_mis.troy"
	ParticleRProjectileNameOld = "bowMaster_volley_mis.troy"
	ParticleR = "Lucian_R_tar.troy"
	ParticleRFiring = "Lucian_R_self.troy"

	-- Start New
	BuffPassive = "lucianpassivebuff" -- Old: "Lightslinger"
	BuffW = "lucianwcastingbuff"
	BuffR = "LucianR"

	-- End New
--[[
	Raw data dump:

	spellName = LucianBasicAttack
	projectileName = ???
	castDelay = 4001.50 (827.00-7176.00)
	projectileSpeed = 6321.08 (724.19-11917.96)
	range = 2594.85 (541.70-4648.01)

	spellName = LucianW
	projectileName = Lucian_W_mis.troy
	castDelay = 288.67 (265.00-297.00)
	projectileSpeed = 1484.95 (1391.22-1640.62)
	range = 661.85 (304.68-1000.83)

	spellName = LucianE
	projectileName = Lucian_W_mis.troy
	castDelay = 8189.75 (0.00-32245.00)
	projectileSpeed = 25590.51 (703.58-79656.61)
	range = 3772.70 (372.90-8054.26)

	spellName = LucianR
	projectileName = Lucian_R_mis.troy
	castDelay = 210.50 (187.00-234.00)
	projectileSpeed = 2850.25 (2342.64-3357.86)
	range = 405.05 (261.91-548.18)

	Raw data dump #2:

	spellName = LucianW
	projectileName = Lucian_W_mis.troy
	castDelay = 313.81 (265.00-453.00)
	projectileSpeed = 1459.60 (558.14-1797.76)
	range = 648.24 (17.30-1007.14)

	spellName = LucianE
	projectileName = Lucian_W_mis.troy
	castDelay = 2147.83 (0.00-10530.00)
	projectileSpeed = 4680.15 (632.65-14746.30)
	range = 3349.24 (809.79-8272.67)

	spellName = LucianR
	projectileName = Lucian_R_mis.troy
	castDelay = 199.80 (172.00-218.00)
	projectileSpeed = 3023.31 (2816.79-3321.66)
	range = 757.80 (205.94-1063.38)

--]]

	SkillQ = {spellKey = _Q, range = QRange, speed = QSpeed, delay = QDelay, width = QWidth, configName = "piercinglight", displayName = "Q (Piercing Light)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true }
	SkillW = {spellKey = _W, range = WRange, speed = WSpeed, delay = WDelay, width = WWidth, configName = "ardentblaze", displayName = "W (Ardent Blaze)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	SkillE = {spellKey = _E, range = ERange, speed = ESpeed, delay = EDelay, width = EWidth, configName = "relentlesspursuit", displayName = "E (Relentless Pursuit)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = false }
	SkillR = {spellKey = _R, range = RRange, speed = RSpeed, delay = RDelay, width = RWidth, configName = "theculling", displayName = "R (The Culling)", enabled = true, skillShot = true, minions = false, reset = false, reqTarget = true }

	KeyQ = string.byte("Q")
	KeyW = string.byte("W")
	KeyE = string.byte("E")
	KeyR = string.byte("R")

	KeyTest = string.byte("U")

	DFGSlot, HXGSlot, BWCSlot, STDSlot, SheenSlot, TrinitySlot, LichBaneSlot = nil, nil, nil, nil, nil, nil, nil
	QReady, WReady, EReady, RReady, DFGReady, HXGReady, BWCReady, STDReady, IReady = false, false, false, false, false, false, false, false

	ultCastTick = 0
	ultCastTarget = nil
	ultVectorX = nil
	ultVectorZ = nil

	isSlowed = false

	healthLastTick = 0
	healthLastHealth = 0

	isUltFiring = false
	lastUltMessage = 0

	comboActive = false
	nextAttack = 0

	debugMode = false
	debugModeDisableNonR = false
end

function Menu()
	AutoCarry.PluginMenu:addParam("sep", "----- [ Combo ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("Combo", "Combo - Default Spacebar", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("FullCombo", "Insta Blast Combo (No AA)", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("Z"))
	AutoCarry.PluginMenu:addParam("ComboQ", "Use Piercing Light", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboW", "Use Ardent Blaze", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboE", "Use Relentless Pursuit", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("ComboR", "Use The Culling", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("SmartE", "Smart Relentless Pursuit", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("UltLockOn", "Use Ultimate Lock On (Beta)", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Misc ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("PursuitSlow", "Pursuit Out of Slows", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("AutoHarass", "Auto Harass", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Killsteal ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("Killsteal", "Killsteal", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("KillstealUlt", "Killsteal with Ult", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Advanced ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("EMinMouseDiff", "Pursuit Min. Mouse Diff.", SCRIPT_PARAM_SLICE, 600, 100, 1000, 0)
	AutoCarry.PluginMenu:addParam("ProMode", "Use Auto QWER Keys", SCRIPT_PARAM_ONOFF, true)
--	AutoCarry.PluginMenu:addParam("HealthPercentage", "Health Drop %",SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
--	AutoCarry.PluginMenu:addParam("HealthTime", "Health Tracking Time",SCRIPT_PARAM_SLICE, 0, 2, 5, 0)
	AutoCarry.PluginMenu:addParam("sep", "----- [ Draw ] -----", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("DisableDraw", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	AutoCarry.PluginMenu:addParam("DrawFurthest", "Draw Furthest Spell Available", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("DrawQ", "Draw Piercing Light", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("DrawW", "Draw Ardent Blaze", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("DrawE", "Draw Relentless Pursuit", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("DrawR", "Draw The Culling", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnTick()
	tick = GetTickCount()
	Target = AutoCarry.GetAttackTarget(true)

	SpellCheck()

	-- GetTickCount() % 5 == 0) and 
	if IsTickReady(25) and IsFiringUlt() then
		CheckRPosition()
	else
		if AutoCarry.MainMenu.AutoCarry then
			comboActive = true
			Combo()
		else
			comboActive = false
		end

		if AutoCarry.PluginMenu.FullCombo then
			FullCombo()
		end

		if AutoCarry.MainMenu.MixedMode or AutoCarry.PluginMenu.AutoHarass then
			Harass()
		end

		if AutoCarry.PluginMenu.Killsteal then
			KillSteal()
		end
	end
end

function PluginOnCreateObj(obj)
	-- Nothing to do here.
	if obj.name == ParticleRFiring then
		if debugMode then PrintChat("Ult Particle Started") end
		isUltFiring = true
		if debugMode then PrintChat("start: "..(GetTickCount() / 1000)) end
	end
end

function PluginOnDeleteObj(obj)
	if obj.name == ParticleRFiring then
		if debugMode then PrintChat("Ult Particle Stopped") end
		isUltFiring = false
		UltFireStop()
		if debugMode then PrintChat("stop: "..(GetTickCount() / 1000)) end
	end
end

function OnAttacked()
	-- AA > Q > AA
	if AutoCarry.MainMenu.MixedMode or AutoCarry.PluginMenu.AutoHarass then CastQ() end

	if AutoCarry.MainMenu.AutoCarry and comboActive and GetTickCount() > nextAttack then
		nextAttack = AutoCarry.GetNextAttackTime()

		if AutoCarry.PluginMenu.ComboW then CastW() end
		if AutoCarry.PluginMenu.ComboE then CastE() end
		if AutoCarry.PluginMenu.ComboQ then CastQ() end

		comboActive = false
	end
end

--[[
function CustomAttackEnemy(enemy)
		if enemy.dead or not enemy.valid then return end
		-- myHero:Attack(enemy)
		-- AutoCarry.shotFired = true
end
--]]

function OnGainBuff(unit, buff)
	if buff and buff.type ~= nil and unit.name == myHero.name and unit.team == myHero.team and (buff.type == 5 or buff.type == 10 or buff.type == 11) then
		-- BUFF_STUN = 5 BUFF_SLOW = 10 BUFF_ROOT = 11
		if AutoCarry.PluginMenu.PursuitSlow then
			isSlowed = true
			CastE()
		end
	end 
end

function SpellCheck()
	DFGSlot, HXGSlot, BWCSlot, BRKSlot, STDSlot, SheenSlot, TrinitySlot, LichBaneSlot = GetInventorySlotItem(3128),
	GetInventorySlotItem(3146), GetInventorySlotItem(3144), GetInventorySlotItem(3153), GetInventorySlotItem(3131),
	GetInventorySlotItem(3057), GetInventorySlotItem(3078), GetInventorySlotItem(3100)

	QReady = (myHero:CanUseSpell(SkillQ.spellKey) == READY)
	WReady = (myHero:CanUseSpell(SkillW.spellKey) == READY)
	EReady = (myHero:CanUseSpell(SkillE.spellKey) == READY)
	RReady = (myHero:CanUseSpell(SkillR.spellKey) == READY)

	DFGReady = (DFGSlot ~= nil and myHero:CanUseSpell(DFGSlot) == READY)
	HXGReady = (HXGSlot ~= nil and myHero:CanUseSpell(HXGSlot) == READY)
	BWCReady = (BWCSlot ~= nil and myHero:CanUseSpell(BWCSlot) == READY)
	BRKReady = (BRKSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)
	STDReady = (STDSlot ~= nil and myHero:CanUseSpell(BRKSlot) == READY)

	IReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end

-- Handle SBTW Skill Shots

function Combo()
	if not debugModeDisableNonR then
		CastSlots()
	end

	if AutoCarry.PluginMenu.ComboR then CastR() end
end

function FullCombo()
	CastSlots()
	CastW()
	CastE()
	CastQ()
	CastR()
end

function CastSlots()
	if Target ~= nil then
		if GetDistance(Target) <= QRange then
			if DFGReady then CastSpell(DFGSlot, Target) end
			if HXGReady then CastSpell(HXGSlot, Target) end
			if BWCReady then CastSpell(BWCSlot, Target) end
			if BRKReady then CastSpell(BRKSlot, Target) end
			if STDReady then CastSpell(STDSlot, Target) end
		end
	end
end

function Harass()
	CastQ()
end

function IsTickReady(tickFrequency)
	-- Improves FPS
	-- Disabled for now.
	if 1 == 1 then return true end

	if tick ~= nil and math.fmod(tick, tickFrequency) == 0 then
		return true
	else
		return false
	end
end

function CastQ(enemy)
	-- Q (Piercing Light)
	if not enemy then enemy = Target end

	if enemy ~= nil and QReady and ValidTarget(enemy, QRange) then
		if debugMode then PrintChat("Cast Q") end

		CastSpell(SkillQ.spellKey, enemy)
		return true
	end
end

function CastW(enemy)
	-- W (Ardent Blaze)
	if not enemy then enemy = Target end

	if enemy ~= nil and WReady and ValidTarget(enemy, WRange) then
		if debugMode then PrintChat("Cast W") end
		AutoCarry.CastSkillshot(SkillW, enemy)
		return true
	end
end

--[[
function CastEOld()
	-- E (Relentless Pursuit)
	if debugMode then
		-- PrintChat("Mouse Distance: "..GetDistance(mousePos))
	end

	if EReady then
		-- if ( math.abs(mousePos.x - myHero.x) > PursuitMinMouseDiff or math.abs(mousePos.z - myHero.z) > PursuitMinMouseDiff) then
		if ((GetDistance(mousePos) > PursuitMinMouseDiff) and isEnemyInRange(SkillE.range + SkillR.range)) then
			if debugMode then PrintChat("Cast E") end
			CastSpell(SkillE.spellKey, mousePos.x, mousePos.z)
		end
	end
end
--]]

function CastE()
	if AutoCarry.PluginMenu.SmartE then
		if ((GetDistance(mousePos) > AutoCarry.PluginMenu.EMinMouseDiff or isSlowed) and isEnemyInRange(SkillE.range + SkillR.range)) then
			local dashSqr = math.sqrt((mousePos.x - myHero.x)^2+(mousePos.z - myHero.z)^2)
			local dashX = myHero.x + ERange*((mousePos.x - myHero.x)/dashSqr)
			local dashZ = myHero.z + ERange*((mousePos.z - myHero.z)/dashSqr)
			CastSpell(SkillE.spellKey, dashX, dashZ)
			isSlowed = false
			return true
		end
	else
		CastSpell(SkillE.spellKey, mousePos.x, mousePos.z)
		isSlowed = false
		return true
	end
end

function CastR(enemy)
	if not enemy then enemy = Target end
	-- R (The Culling)
	if enemy ~= nil and RReady and ValidTarget(enemy, RRange) then
		if not IsFiringUlt() then
			if debugMode then PrintChat("Cast R") end
			if not isUltFiring then
				AutoCarry.CastSkillshot(SkillR, enemy)
				if AutoCarry.PluginMenu.UltLockOn and GetTickCount() > (lastUltMessage + 2000) then
					lastUltMessage = GetTickCount()
					PrintFloatText(myHero, 10, "Ultimate Locked On!")
				end
			end

			ultCastTarget = enemy
			ultCastTick = GetTickCount()

			-- Vector from target -> myHero
			if ultVectorX == nil and ultVectorZ == nil then
				if debugMode and false then PrintChat("update x,z") end
				ultVectorX,y,ultVectorZ = (Vector(myHero) - Vector(ultCastTarget)):normalized():unpack()
			end
		end

		CheckRPosition()
	end
end

function CheckRPosition()
	if (ultCastTick > 0) then
		if debugMode and IsFiringUlt() then burp = "true" else burp = "false" end
		if debugMode and false then PrintChat("Tick: "..GetTickCount()..", ultCastTick: "..ultCastTick..", RDuration: "..(ultCastTick + (RDuration * 1000))..", IsFiringUlt: "..burp) end
	end

	if AutoCarry.PluginMenu.UltLockOn and IsFiringUlt() then
		MoveMyHeroToRPosition()
	end
end

function MoveMyHeroToRPosition()
	-- Please don't steal this function!
	local tpR = VIP_USER and TargetPredictionVIP(RRange, RSpeed*1000, RRefresh, RWidth) or TargetPrediction(RRange, RSpeed, RRefresh*1000, RWidth)

	local target = nil
	if ultCastTarget ~= nil then
		target = ultCastTarget
	else
		target = Target
	end

	local predR = tpR:GetPrediction(target)

	if not predR then return end

	local RRangeBuffered = RRange * .98 -- Allow a bit of slippage for targets running away.
	local posX = predR.x + (ultVectorX * RRangeBuffered)
	local posZ = predR.z + (ultVectorZ * RRangeBuffered)

	-- Thank you, Pythagoras
	-- local distanceBetweenPoints = math.sqrt((predR.x - posX)^2 + (predR.z - posZ)^2)
	-- local distanceBetweenPoints = GetDistance(Point(posX, posZ), predR)
	-- local posXRanged = (posX + (posX - predR.x)) / distanceBetweenPoints * RRangeBuffered
	-- local posZRanged = (posZ + (posZ - predR.z)) / distanceBetweenPoints * RRangeBuffered

	local predRPath = LineSegment(Point(predR.x, predR.z), Point(posX, posZ))

	local closePoint = nil
	if predRPath ~= nil then
		closePoint = Point(myHero.x, myHero.z):closestPoint(predRPath)
	else
		if debugMode then PrintChat("predRPath is nil") end
	end

	if debugMode and closePoint ~= nil then
		--	PrintChat("moveto: "..posX..", "..posZ.."... targetat: "..ultCastTarget.x..", "..ultCastTarget.z..", ultVectorX: "..ultVectorX..", ultVectorZ: "..ultVectorZ..", RDuration: "..RDuration)
		--	PrintChat("posXRanged: "..posXRanged..", posZRanged: "..posZRanged..", closePoint: "..closePoint.x..", "..closePoint.y)
		PrintChat("moveto: "..closePoint.x..", "..closePoint.y.."; targetat: "..predR.x..", "..predR.z..", ultVectorX: "..ultVectorX..", ultVectorZ: "..ultVectorZ)
	end

	if debugMode then
		PrintChat("distance: method 1: "..GetDistance(closePoint, predR)..", method 2: "..GetDistance(Point(posX, posZ), predR))
	end

	if predRPath ~= nil and closePoint ~= nil and not IsWall(D3DXVECTOR3(closePoint.x, myHero.y, closePoint.y)) and GetDistance(closePoint, predR) > ERange then
		-- Closest Point Method
		if debugMode then PrintChat("Move: Method 1") end
		myHero:MoveTo(closePoint.x, closePoint.y)
	elseif predR ~= nil and posX ~= nil and posZ ~= nil and not IsWall(D3DXVECTOR3(posX, myHero.y, posZ))
		-- and GetDistance(Point(posX, posZ), predR) > 500
		and GetDistance(Point(posX, posZ), predR) < RRange and GetDistance(Point(posX, posZ), predR) > 100 then
		-- Full Vector Method
		if debugMode then PrintChat("Move: Method 2") end
		if (GetTickCount() > (lastUltMessage + 2000)) then
			-- lastUltMessage = GetTickCount()
			-- PrintFloatText(myHero, 10, "Ultimate Manual Mode!")
		end
		myHero:MoveTo(posX, posZ)
--	elseif not IsWall(D3DXVECTOR3(posXRanged, myHero.y, posZRanged)) then
--		-- Last Ditch Method
--		if debugMode then PrintChat("Move: Method 3") end
--		myHero:MoveTo(posXRanged, posZRanged)
	else
		-- Fallback to User Aiming
		if debugMode then PrintChat("Move: Wall") end
		myHero:MoveTo(mousePos.x, mousePos.z)
	end
	-- myHero:MoveTo(posXRanged, posZRanged)
end

function getDistanceBetweenPoints(pointA, pointB)
	-- Thank you, Pythagoras
	local distanceBetweenPoints = math.sqrt((predR.x - posX)^2 + (predR.z - posZ)^2)
end

function IsFiringUlt()
	local tickCount = GetTickCount()

	-- if (ultCastTick > 0) and (tickCount >= ultCastTick) and (tickCount <= (ultCastTick + (RDuration * 1000))) and not RReady and ultCastTarget ~= nil and not ultCastTarget.dead then
	if (ultCastTick > 0) and (tickCount >= ultCastTick) and isUltFiring and ultCastTarget ~= nil and not ultCastTarget.dead then
		AutoCarry.CanMove = false
		return true
	else
		UltFireStop()
		return false
	end
end

function UltFireStop()
	ultCastTick = 0
	ultVectorX = nil
	ultVectorZ = nil
	AutoCarry.CanMove = true
end

function isEnemyInRange(range)
	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if ValidTarget(enemy, range) and not enemy.dead then
			return true
		end
	end

	return false
end

--[[
function TakingRapidDamage()
	if GetTickCount() - healthLastTick > (AutoCarry.PluginMenu.HealthTime * 1000) then
		--> Check amount of health lost
		if myHero.health - healthLastHealth > myHero.maxHealth * (AutoCarry.PluginMenu.HealthPercentage / 100) then
			return true
		else
			--> Reset counters
			healthLastTick = GetTickCount()
			healthLastHealth = myHero.health
		end
	end
end
--]]

function KillSteal()
	-- Will try to perform a killsteam using any spell.
	if not AutoCarry.PluginMenu.Killsteal then return end

	-- Killsteal disabled until Bol update for Lucian

	for _, enemy in pairs(AutoCarry.EnemyTable) do
		if enemy and not enemy.dead then
			-- getDmg broken in BoL for Lucian right now.
			local qDmg = 80 -- getDmg("Q", enemy, myHero)
			local wDmg = 60 -- getDmg("W", enemy, myHero)
			local rDmg = 50 -- getDmg("R", enemy, myHero)

			if QReady and ValidTarget(enemy, QRange) and (enemy.health + 20) < qDmg then
				if debugMode then PrintChat("Cast Q KS") end
				CastQ(enemy)
			elseif WReady and ValidTarget(enemy, WRange) and (enemy.health + 20) < wDmg then
				if debugMode then PrintChat("Cast W KS") end
				CastW(enemy)
			elseif AutoCarry.PluginMenu.KillstealUlt and RReady and ValidTarget(enemy, RRange) and (enemy.health + 20) < rDmg then
				if debugMode then PrintChat("Cast R KS") end
				CastR(enemy)
			end

		end
	end
end

function PluginOnWndMsg(msg,key)
	Target = AutoCarry.GetAttackTarget()
	if Target ~= nil and AutoCarry.PluginMenu.ProMode then
		-- if msg == KEY_DOWN and key == KeyQ then CastQ() end
		if msg == KEY_DOWN and key == KeyW then CastW() end
		if msg == KEY_DOWN and key == KeyE then CastE() end
		if msg == KEY_DOWN and key == KeyR then CastR() end
		if msg == KEY_DOWN and key == KeyTest and debugMode then
			if ultVectorX == nil and ultVectorZ == nil then
				ultCastTarget = Target
				ultVectorX,y,ultVectorZ = (Vector(myHero) - Vector(ultCastTarget)):normalized():unpack()
			end
			MoveMyHeroToRPosition()
		end
		
		if msg == KEY_UP and key == KeyTest and debugMode then
			ultVectorX = nil
			ultVectorZ = nil
		end
	end
end

-- Draw
function PluginOnDraw()
	-- if Target ~= nil and not Target.dead and QReady and ValidTarget(Target, QMaxRange) then
	if Target ~= nil and not Target.dead and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
		DrawArrowsToPos(myHero, Target)
	end

	if not AutoCarry.PluginMenu.DisableDraw and not myHero.dead then
		local farSpell = FindFurthestReadySpell()
		-- if debugMode and farSpell then PrintChat("far: "..farSpell.configName) end

		-- Not needed as SAC has the same range draw.
		-- DrawCircle(myHero.x, myHero.y, myHero.z, getTrueRange(), 0x808080) -- Gray

		if AutoCarry.PluginMenu.DrawQ and QReady and ((AutoCarry.PluginMenu.DrawFurthest and farSpell and farSpell == SkillQ) or not AutoCarry.PluginMenu.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, QRange, 0x0099CC) -- Blue
		end

		if AutoCarry.PluginMenu.DrawW and WReady and ((AutoCarry.PluginMenu.DrawFurthest and farSpell and farSpell == SkillW) or not AutoCarry.PluginMenu.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, WRange, 0xFFFF00) -- Yellow
		end
		
		if AutoCarry.PluginMenu.DrawE and EReady and ((AutoCarry.PluginMenu.DrawFurthest and farSpell and farSpell == SkillE) or not AutoCarry.PluginMenu.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, ERange, 0x00FF00) -- Green
		end

		if AutoCarry.PluginMenu.DrawR and RReady and ((AutoCarry.PluginMenu.DrawFurthest and farSpell and farSpell == SkillR) or not AutoCarry.PluginMenu.DrawFurthest) then
			DrawCircle(myHero.x, myHero.y, myHero.z, RRange, 0xFF0000) -- Red
		end

		Target = AutoCarry.GetAttackTarget()
		if Target ~= nil then
			for j=0, 10 do
				DrawCircle(Target.x, Target.y, Target.z, 40 + j*1.5, 0x00FF00) -- Green
			end
		end

	end
end

function FindFurthestReadySpell()
	local farSpell = nil

	if AutoCarry.PluginMenu.DrawQ and QReady then farSpell = SkillQ end
	if AutoCarry.PluginMenu.DrawW and WReady and (not farSpell or WRange > farSpell.range) then farSpell = SkillW end
	if AutoCarry.PluginMenu.DrawE and EReady and (not farSpell or ERange > farSpell.range) then farSpell = SkillE end
	if AutoCarry.PluginMenu.DrawR and RReady and (not farSpell or RRange > farSpell.range) then farSpell = SkillR end

	return farSpell
end

function getTrueRange()
    return myHero.range + GetDistance(myHero.minBBox)
end

function DrawArrowsToPos(pos1, pos2)
	if pos1 and pos2 then
		startVector = D3DXVECTOR3(pos1.x, pos1.y, pos1.z)
		endVector = D3DXVECTOR3(pos2.x, pos2.y, pos2.z)
		-- directionVector = (endVector-startVector):normalized()
		DrawArrows(startVector, endVector, 60, 0xE97FA5, 100)
	end
end

--[[
class 'ColorARGB' -- {

    function ColorARGB:__init(red, green, blue, alpha)
        self.R = red or 255
        self.G = green or 255
        self.B = blue or 255
        self.A = alpha or 255
    end

    function ColorARGB.FromArgb(red, green, blue, alpha)
        return Color(red,green,blue, alpha)
    end

    function ColorARGB:ToARGB()
        return ARGB(self.A, self.R, self.G, self.B)
    end

    ColorARGB.Red = ColorARGB(255, 0, 0, 255)
    ColorARGB.Yellow = ColorARGB(255, 255, 0, 255)
    ColorARGB.Green = ColorARGB(0, 255, 0, 255)
    ColorARGB.Aqua = ColorARGB(0, 255, 255, 255)
    ColorARGB.Blue = ColorARGB(0, 0, 255, 255)
    ColorARGB.Fuchsia = ColorARGB(255, 0, 255, 255)
    ColorARGB.Black = ColorARGB(0, 0, 0, 255)
    ColorARGB.White = ColorARGB(255, 255, 255, 255)
-- }

--Notification class
class 'Message' -- {

    Message.instance = ""

    function Message:__init()
        self.notifys = {} 

        AddDrawCallback(function(obj) self:OnDraw() end)
    end

    function Message.Instance()
        if Message.instance == "" then Message.instance = Message() end return Message.instance 
    end

    function Message.AddMessage(text, color, target)
        return Message.Instance():PAddMessage(text, color, target)
    end

    function Message:PAddMessage(text, color, target)
        local x = 0
        local y = 200 
        local tempName = "Screen" 
        local tempcolor = color or ColorARGB.Red

        if target then  
            tempName = target.networkID
        end

        self.notifys[tempName] = { text = text, color = tempcolor, duration = GetGameTimer() + 2, object = target}
    end

    function Message:OnDraw()
        for i, notify in pairs(self.notifys) do
            if notify.duration < GetGameTimer() then notify = nil 
            else
                notify.color.A = math.floor((255/2)*(notify.duration - GetGameTimer()))

                if i == "Screen" then  
                    local x = 0
                    local y = 200
                    local gameSettings = GetGameSettings()
                    if gameSettings and gameSettings.General then 
                        if gameSettings.General.Width then x = gameSettings.General.Width/2 end 
                        if gameSettings.General.Height then y = gameSettings.General.Height/4 - 100 end
                    end  
                    --PrintChat(tostring(notify.color))
                    local p = GetTextArea(notify.text, 40).x 
                    self:DrawTextWithBorder(notify.text, 40, x - p/2, y, notify.color:ToARGB(), ARGB(notify.color.A, 0, 0, 0))
                else    
                    local pos = WorldToScreen(D3DXVECTOR3(notify.object.x, notify.object.y, notify.object.z))
                    local x = pos.x
                    local y = pos.y - 25
					local p = GetTextArea(notify.text, 40).x 

					self:DrawTextWithBorder(notify.text, 30, x- p/2, y, notify.color:ToARGB(), ARGB(notify.color.A, 0, 0, 0))
                end
            end
        end
    end 

    function Message:DrawTextWithBorder(textToDraw, textSize, x, y, textColor, backgroundColor)
        DrawText(textToDraw, textSize, x + 1, y, backgroundColor)
        DrawText(textToDraw, textSize, x - 1, y, backgroundColor)
        DrawText(textToDraw, textSize, x, y - 1, backgroundColor)
        DrawText(textToDraw, textSize, x, y + 1, backgroundColor)
        DrawText(textToDraw, textSize, x , y, textColor)
    end
-- }
--]]