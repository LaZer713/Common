--[[ Sida's Auto Carry Plugin: Fizz ]]--
--[[ Version 1.2 ]]--

function PluginOnLoad()
  AutoCarry.PluginMenu:addParam("autoW", "Seastone Trident - Auto Fire", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawQ", "Draw - Urchin Strike", SCRIPT_PARAM_ONOFF, true)
  AutoCarry.PluginMenu:addParam("drawE", "Draw - Playful/Trickster", SCRIPT_PARAM_ONOFF, false)
  AutoCarry.PluginMenu:addParam("drawR", "Draw - Chum the Waters", SCRIPT_PARAM_ONOFF, true)
end

function PluginOnTick()
  Checks()
  if not AutoCarry.PluginMenu.autoW then return end
  local t = AutoCarry.GetAttackTarget()
  if t and AutoCarry.MainMenu.AutoCarry and WREADY then
    CastSpell(_W)
  end
end

local Wactive = false

function PluginOnCreateObj(obj)
  if GetDistance(obj) < 100 and obj.name == "Fizz_SeastonePassive.troy" then
    Wactive = true
  end
end

function PluginOnDeleteObj(obj)
  if GetDistance(obj) < 100 and obj.name == "Fizz_SeastonePassive.troy" then
    Wactive = false
  end
end

function PluginOnProcessSpell(unit, spell)
  if not AutoCarry.PluginMenu.autoW and unit.isMe and spell.name == "FizzPiercingStrike" and AutoCarry.MainMenu.AutoCarry then
    CastSpell(_W)
  end
end

function PluginBonusLastHitDamage(minion)
  local w = myHero:getSpellData(_W).level
  local wdamage = 0
  if w > 0 then
    if Wactive then
      wdamage = (((w + 1) * 5) + (myHero.ap * 0.35))
      -- 10/15/20/25/30 (+0.35 AP)
    end
    return myHero:CalcMagicDamage(minion, math.floor((((w * 10 + 20) + (myHero.ap * 0.35) + ((minion.maxHealth - minion.health) * (0.01 * w + 0.03))) / 6) + wdamage))
    -- 30/40/50/60/70 (+0.35 AP) (+4/5/6/7/8% of target's missing HP) over 3 seconds
    -- Ticks every 0.5 seconds (6 times) so divide by 6
   end
end

function PluginOnDraw()
  if not myHero.dead then
    if QREADY and AutoCarry.PluginMenu.drawQ then
      DrawCircle(myHero.x, myHero.y, myHero.z, 550, 0x00FFFF)
    end
    if EREADY and AutoCarry.PluginMenu.drawE then
      DrawCircle(myHero.x, myHero.y, myHero.z, 400, 0x00FFFF)
    end
    if RREADY and AutoCarry.PluginMenu.drawR then
      DrawCircle(myHero.x, myHero.y, myHero.z, 1275, 0x00FF00)
    end
  end
end

function Checks()
  QREADY = (myHero:CanUseSpell(_Q) == READY)
  WREADY = (myHero:CanUseSpell(_W) == READY)
  EREADY = (myHero:CanUseSpell(_E) == READY)
  RREADY = (myHero:CanUseSpell(_R) == READY)
end