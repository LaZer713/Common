--[[ Auto Carry Plugin: MasterYi ]]--


function PluginOnLoad()

	AutoCarry.SkillsCrosshair.range = 600
	mainLoad()
	Menu:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("useR", "Use Ultimate in Combo", SCRIPT_PARAM_ONOFF, false)
	Menu:addParam("QKS", "KS with Q", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("drawQ", "Draw QRange", SCRIPT_PARAM_ONOFF, false)
	
end

function PluginOnTick()
	Tick()
	if Target and (AutoCarry.MainMenu.AutoCarry) then
		if QREADY and Menu.useQ then CastSpell(_Q, Target) end
		if EREADY and Menu.useE and GetDistance(Target) < 150 then CastSpell(_E) end
		if Menu.useR and GetDistance(Target) < 300 then CastSpell(_R) end
		end
	if Menu.QKS and QREADY then QKS() end
end

function PluginOnDraw()
	if not Menu.drawMaster and not myHero.dead then
		if QREADY and Menu.drawQ then
			DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x00FFFF)
		end
		
	
		
	end
end


function QKS()
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local rDmg = nil
		qDmg = getDmg("Q", enemy, myHero)
				
		if enemy and not enemy.dead and enemy.health < qDmg then
			PrintFloatText(enemy,0,"Ult!")
			if GetDistance(enemy) < 600 then
			CastSpell(_Q, enemy)
			end
		end
	end
end


function Tick()
	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
end

function mainLoad()
	qRange, eRange, rRange = 600, 160, 200
	QREADY, WREADY, RREADY = false, false, false

	Menu = AutoCarry.PluginMenu
	Cast = AutoCarry.CastSkillshot
	Col = AutoCarry.GetCollision
	
end