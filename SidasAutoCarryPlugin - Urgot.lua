------------------------########################################-------------------------------
------------------------##								Urgot		  					##-------------------------------
------------------------##					 The Deadly Butcher 			##-------------------------------
------------------------########################################-------------------------------
if myHero.charName ~= "Urgot" then return end

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 1250
	--> Main Load
	mainLoad()
	--> Main Menu
	mainMenu()
end

function PluginOnTick()
	Checks()
	if Target and (AutoCarry.MainMenu.AutoCarry or AutoCarry.MainMenu.MixedMode) then
		if EREADY and Menu.useE and GetDistance(Target) < eRange then Cast(SkillE, Target) end
		if WREADY and Menu.useW and GetDistance(Target) < wRange then CastSpell(_W) end
		if QREADY and Menu.useQ then CastQ(Target) end
	end
	if Target and QREADY and Menu.autoQ then 
		if GetDistance(Target) < qRange2 and GetTickCount() - poisonedtimets < 5000 then
			CastSpell(_Q, Target.x, Target.z)
		end
	end
end

function PluginOnDraw()
	--> Ranges
	if not Menu.drawMaster and not myHero.dead then
		if QREADY and Menu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FFFF)
		end
		if EREADY and Menu.drawE then
			DrawCircle(myHero.x, myHero.y, myHero.z, eRange, 0x00FF00)
		end
	end
end

--> Acid Debuff
function PluginOnCreateObj(obj)
	if obj ~= nil and string.find(obj.name, "UrgotCorrosiveDebuff_buf") then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and GetDistance(obj,enemy) < 80 then
				poisonedtime[i] = GetTickCount()
			end
		end
	end
end

--> Acid Hunter Cast
function CastQ(target)
	if GetDistance(target) <= qRange and GetTickCount()-poisonedtimets < 5000 then
		CastSpell(_Q, target.x, target.z) 
	elseif not Menu.poisonOnly and GetDistance(target) < qRange2 and not Col(SkillQ, myHero, target) then
		Cast(SkillQ, target)
	end
end

--> Checks
function Checks()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	if Target then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if enemy.team ~= myHero.team and enemy.charName == Target.charName then
				poisonedtimets = poisonedtime[i]
			end
		end
	end
end

--> Main Load
function mainLoad()
	poisonedtimets = 0
	poisonedtime = {}
	poisontime = 0
	qRange, qRange2, wRange, eRange = 1000, 1200, 700, 900
	QREADY, WREADY, EREADY = false, false, false
	SkillQ = {spellKey = _Q, range = qRange, speed = 1.6, delay = 175, width = 60}
	SkillE = {spellKey = _E, range = eRange, speed = 1.75, delay = 125, width = 250}
	Cast = AutoCarry.CastSkillshot
	Menu = AutoCarry.PluginMenu
	Col = AutoCarry.GetCollision
	for i=1, heroManager.iCount do
		poisonedtime[i] = 0
	end
end

--> Main Menu
function mainMenu()
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("autoQ", "Acid Hunter - Auto Fire", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("poisonOnly", "Acid Hunter - Poisoned Targets Only", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep1", "-- Weapon Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Fire Acid Hunter", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useW", "Use Terror Capacitor", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Fire Corrosive Charge", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawMaster", "Disable Draw", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawQ", "Draw - Acid Hunter", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("drawE", "Draw - Corrosive Charge", SCRIPT_PARAM_ONOFF, false)
end