if myHero.charName ~= "TwistedFate" then return end

function PluginOnLoad()
	--AutoCarry.PluginMenu:addParam("throwQ", "Harras enemy", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("A")) -- useless, too hard to get someone hit by bot pred :c
	AutoCarry.PluginMenu:addParam("autoQ", "AutoQ on stuned enemies", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("selectgold", "Select Gold Card", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("W"))
	AutoCarry.PluginMenu:addParam("selectblue", "Select Blue Card", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("E"))
	AutoCarry.PluginMenu:addParam("selectred", "Select Red Card", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
	AutoCarry.PluginMenu:addParam("drawCircle", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("drawArrow", "Draw arrow to killable hp enemies", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("drawHealth", "Draw HP after GoldCard + Q combo", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu:addParam("selectgoldult", "Select gold card after ult", SCRIPT_PARAM_ONOFF, true)
	--AutoCarry.PluginMenu:addParam("drawQpred", "Draw Q prediction on harras", SCRIPT_PARAM_ONOFF, true) -- cant do this with SAC I think :C
	AutoCarry.PluginMenu:permaShow("autoQ")
	PrintChat("<font color='#E97FA5'>>> TF Helper v2.0 - Rewritten as SAC Plugin!</font>")
	AutoCarry.SkillsCrosshair.range = 1450 
	AutoCarry.OverrideCustomChampionSupport = true
	SelectedCard = false
	StackedE = false
end

function PluginOnTick()
	if NextCheck ~= nil then 
		if GetTickCount() > NextCheck then
			if myHero:CanUseSpell(_W) == READY then
				if AutoCarry.PluginMenu.selectgold then if myHero:GetSpellData(_W).name == "goldcardlock" then CastSpellEx(_W) elseif myHero:GetSpellData(_W).name == "PickACard" then CastSpellEx(_W) end end 
				if AutoCarry.PluginMenu.selectblue then if myHero:GetSpellData(_W).name == "bluecardlock" then CastSpellEx(_W) elseif myHero:GetSpellData(_W).name == "PickACard" then CastSpellEx(_W) end end 
				if AutoCarry.PluginMenu.selectred then if myHero:GetSpellData(_W).name == "redcardlock" then CastSpellEx(_W) elseif myHero:GetSpellData(_W).name == "PickACard" then CastSpellEx(_W) end end 
			end
			if SelectCardForUlt == true then
				if myHero:GetSpellData(_W).name == "goldcardlock" then
					CastSpellEx(_W)
					SelectCardForUlt = false
				elseif myHero:GetSpellData(_W).name == "PickACard" then
					CastSpellEx(_W)
				end 
			end
			NextCheck = GetTickCount() + 250
		end
	else
		NextCheck = 0
	end
	if AutoCarry.PluginMenu.autoQ then
		for _, enemy in pairs(AutoCarry.EnemyTable) do
			if ValidTarget(enemy) and not enemy.canMove and GetDistance(enemy) < 1450 then
				CastSpell(_Q, enemy.x, enemy.z)
			end
		end
	end
end

function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name == "gate" then if AutoCarry.PluginMenu.selectgoldult then SelectCardForUlt = true end end
end

function PluginOnDraw()
	if not myHero.dead and AutoCarry.PluginMenu.drawCircle then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1450, 0x540069)
	end
	if AutoCarry.PluginMenu.drawArrow and myHero:CanUseSpell(_R) == READY then
		for _, enemy in pairs(AutoCarry.EnemyTable) do
			if ValidTarget(enemy) then
				local QDmg = myHero:CalcMagicDamage(enemy, math.floor((50*(myHero:GetSpellData(_R).level)+10+(0.65*myHero.ap))+0.5))
				local WDmg = myHero:CalcMagicDamage(enemy, math.floor((7.5*(myHero:GetSpellData(_R).level)+7.5+(0.4*myHero.ap)+myHero.damage)+0.5))
				local HPafter = enemy.health - (QDmg+WDmg)
				if HPafter <= 0 then
					local startPos = Vector(myHero.x,myHero.y,myHero.z)
					local endPos = Vector(enemy.x, enemy.y, enemy.z)
					DrawArrows(D3DXVECTOR3(startPos.x,startPos.y,startPos.z),D3DXVECTOR3(endPos.x,endPos.y,endPos.z),100,0xE97FA5,100)
				end
			end
		end
	end
	if AutoCarry.PluginMenu.drawHealth then
		for i=1, heroManager.iCount do
			local EnemyHero = heroManager:GetHero(i)
			if ValidTarget(EnemyHero) then
				local QDmg = myHero:CalcMagicDamage(EnemyHero, math.floor((50*(myHero:GetSpellData(_Q).level)+10+(0.65*myHero.ap))+0.5))
				local WDmg = myHero:CalcMagicDamage(EnemyHero, math.floor((7.5*(myHero:GetSpellData(_W).level)+7.5+(0.4*myHero.ap)+myHero.damage)+0.5))
				local HPafter = EnemyHero.health - (QDmg+WDmg)
				if HPafter <= 0 then
					PrintFloatText(EnemyHero, 0, "Murder Him")
				elseif HPafter <= 300 then
					PrintFloatText(EnemyHero, 0, "Killable")
				else
					PrintFloatText(EnemyHero, 0, "Not Killable")
				end
			end
		end
	end
end

function PluginOnApplyParticle(unit, particle)
	if unit then if unit.isMe then
		local LastCard = "Red"
		if particle.name == "Cardmaster_stackready.troy" then StackedE = true end end
		if particle.name == "Card_Red.troy" then LastCard = "Red" end
		if particle.name == "Card_Blue.troy" then LastCard = "Blue" end
		if particle.name == "Card_Gold.troy" then LastCard = "Gold" end
		if particle.name == "AnineSparks.troy" then
			PickedCard = LastCard
		end
	end
end

function PluginOnDeleteObj(obj)
	if obj.name == "Cardmaster_stackready.troy" and GetDistance(obj, myHero) < 50 then StackedE = false end
	if obj.name == "Card_Red.troy" or obj.name == "Card_Blue.troy" or obj.name == "Card_Gold.troy" then
		if PickedCard ~= "None" then
			PickedCard = "None"
		end
	end
end

function PluginBonusLastHitDamage(minion)
	local TotalBonus = 0
	local EDmg = math.floor(30+(25*myHero:GetSpellData(_E).level)+(myHero.ap*0.4))
	local GoldDmg = math.floor((7.5*(myHero:GetSpellData(_W).level)+7.5+(0.4*myHero.ap)+myHero.damage)+0.5)
	local BlueDmg = math.floor((20*(myHero:GetSpellData(_W).level)+20+(0.4*myHero.ap)+myHero.damage)+0.5)
	local RedDmg = math.floor((15*(myHero:GetSpellData(_W).level)+15+(0.4*myHero.ap)+myHero.damage)+0.5)
	if StackedE == true then TotalBonus = EDmg end
	if PickedCard == "Red" then TotalBonus = TotalBonus + RedDmg end
	if PickedCard == "Blue" then TotalBonus = TotalBonus + BlueDmg end
	if PickedCard == "Gold" then TotalBonus = TotalBonus + GoldDmg end
	return TotalBonus
end