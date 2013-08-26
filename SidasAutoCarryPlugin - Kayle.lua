if myHero.charName ~= "Kayle" then return end

function PluginOnLoad()
	mainLoad()
	mainMenu()
end

function PluginOnTick()
	Checks()
	if Target and (Menu2.AutoCarry or Menu2.MixedMode) then
		if EREADY and Menu.useE and GetDistance(Target) < eRange then
			CastSpell(_E)
		end
		if QREADY and Menu.useQ and GetDistance(Target) < qRange then
			CastSpell(_Q, Target)
		end
		if WREADY and Menu.useW and GetDistance(Target) > wBuffer then
			CastSpell(_W, myHero)
		end
	end
end

function PluginOnDraw()	
	if Menu.drawQ and not myHero.dead then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0xFF80FF00)
	end
end

--> Checks
function Checks()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
end

--> Main Load
function mainLoad()
	AutoCarry.SkillsCrosshair.range = 1050
	qRange, wBuffer, eRange = 650, 400, 525
	QREADY, WREADY, EREADY = false, false, false
	Menu = AutoCarry.PluginMenu
	Menu2 = AutoCarry.MainMenu
end

function mainMenu()
	Menu:addParam("sep", "-- Cast Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("useQ", "Use - Reckoning", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useW", "Use - Divine Blessing", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use - Righteous Fury", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("sep1", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawQ", "Draw - Reckoning", SCRIPT_PARAM_ONOFF, false)
end