if myHero.charName ~= "Tryndamere" then return end

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 850
	--> Main Load
	mainLoad()
	--> Main Menu
	mainMenu()
	--> Tower Table
	towersUpdate()
end

function PluginOnTick()
	Checks()
	if Target and Menu2.AutoCarry then
		if WREADY and Menu.useW and GetDistance(Target) <= wRange then CastSpell(_W) end
		if EREADY and Menu.useE then castE(Target) end
	end
	if RREADY and Menu.autoR then autoUlt() end
	if EREADY and Menu.eKS then eKS() end
end

function autoUlt()
	if RREADY and not myHero.dead then
		if myHero.health <= myHero.maxHealth*(Menu.rHealth/100) then
			if Target or TargetHaveBuff("SummonerDot", myHero) then
				CastSpell(_R)
			end
		elseif myHero.health <= myHero.maxHealth*((Menu.rHealth*1.5)/100) and inTurretRange(myHero) then
			CastSpell(_R)
		end
	end
end

function eKS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if enemy and not enemy.dead and enemy.health < getDmg("E", enemy, myHero) then
			castE(enemy)
		end
	end
end

--> Tower Checks
function towersUpdate()
	for i = 1, objManager.iCount, 1 do
		local obj = objManager:getObject(i)
		if obj ~= nil and string.find(obj.type, "obj_Turret") ~= nil and string.find(obj.name, "_A") == nil and obj.health > 0 then
			if not string.find(obj.name, "TurretShrine") and obj.team ~= player.team then
				table.insert(towers, obj)
			end
		end
	end
end

function inTurretRange(unit)
	local check = false
	for i, tower in ipairs(towers) do
		if tower.health > 0 then
			if math.sqrt((tower.x - unit.x) ^ 2 + (tower.z - unit.z) ^ 2) < 950 then
				check = true
			end
		else
			table.remove(towers, i)
		end
	end
return check
end

function castE(target)
	ePred = AutoCarry.GetPrediction(SkillE, target)
	if ePred and GetDistance(ePred) <= eRange then
		TargetPos = Vector(ePred.x, ePred.y, ePred.z)
		MyPos = Vector(myHero.x, myHero.y, myHero.z)
		ePred2 = TargetPos + (TargetPos-MyPos)*((150/GetDistance(ePred)))
		CastSpell(_E, ePred2.x, ePred2.z)
	end
end

--> Checks
function Checks()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
end

--> Main Load
function mainLoad()
	AutoCarry.SkillsCrosshair.range = 900
	QREADY, WREADY, EREADY, RREADY = false, false, false, false
	wRange, eRange = 860, 700
	SkillE = {spellKey = _E, range = eRange, speed = 1.6, delay = 225, width = 160}
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
	towers = {}
end

--> Main Menu
function mainMenu()
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("eKS", "Spinning Slash - Kill Steal", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("autoR", "Undying Rage - Auto Ult", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("rHealth", "Undying Rage - Min Health(%)", SCRIPT_PARAM_SLICE, 20, 0, 100, 0)
	Menu:addParam("sep1", "-- Ability Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useW", "Use - Mocking Shout", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Spinning Slash", SCRIPT_PARAM_ONOFF, true)
end