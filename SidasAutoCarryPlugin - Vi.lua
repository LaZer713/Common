 -- Vi SAC Plugin By jbman
 
if myHero.charName ~= "Vi" then return end

function PluginOnLoad()
	AutoCarry.SkillsCrosshair.range = 900
	mainLoad()
	mainMenu()
  Qtick = 0
  Qcast = false
  qcastrange = 0
  Qtarget = nil
  HeroPos = nil
  MPos = nil
  QPos = nil
  targetSelected = true
  smoothness = 50
  delay = 0.1
  speed = 1250
end

function PluginOnTick()
	Checks()
  if Menu.alt then   
    Menu.flashEscape = true 
    quickQ = true
  elseif Menu.alt == false then   
    Menu.flashEscape = false
    quickQ = false
  end
  if Menu.escape then 
    if not QREADY then myHero:MoveTo(mousePos.x,mousePos.z) end
    if not Menu.flashEscape then
      mouseQ()
    end  
    if Menu.flashEscape and FREADY then
      if Menu.flashEscape and FREADY then
        myHero:MoveTo(mousePos.x,mousePos.z)
        CastSpell(Flash,mousePos.x,mousePos.z)
        myHero:MoveTo(mousePos.x,mousePos.z)
      end
    end
  end  
	if Target then
    if (AutoCarry.MainMenu.AutoCarry) then
      if RREADY and Menu.useR and GetDistance(Target) <= rRange then CastSpell(_R,Target) end 
      if not quickQ and QREADY and GetDistance(Target) <= qRange then castQ(Target) end      
      if quickQ and QREADY and GetDistance(Target) <= qRange then fastQ(Target) end
    end   
	end
end

function castQ(target)  
  if target and GetDistance(target) < qcastrange and not Qcast then
    CastSpell(_Q, mousePos.x, mousePos.z)        
    Qtick = GetTickCount()
  end
  if Qcast then
    Qtarget = tp:GetPrediction(target)
  end
  if Qtarget and target and Qcast and GetTickCount()-Qtick > 1300 and GetDistance(Qtarget) < qRange then
    pQ2 = CLoLPacket(0xE6)
    pQ2:EncodeF(myHero.networkID)
    pQ2:Encode1(0x80)
    pQ2:EncodeF(Qtarget.x)
    pQ2:EncodeF(Qtarget.y)
    pQ2:EncodeF(Qtarget.z)
    pQ2.dwArg1 = 1
    pQ2.dwArg2 = 0
    SendPacket(pQ2)
    myHero:Attack(target)
    Qtick = GetTickCount()
    Qcast = false       
  end
end

function fastQ(target)  
  if target and GetDistance(target) < qcastrange and not Qcast then
    CastSpell(_Q, mousePos.x, mousePos.z)        
    Qtick = GetTickCount()   
  end
  if Qcast then
    Qtarget = tp:GetPrediction(target)
  end
  if Qtarget and target and Qcast and GetTickCount()-Qtick > (GetDistance(target)*1.39) and GetDistance(Qtarget) < qRange then
    pQ2 = CLoLPacket(0xE6)
    pQ2:EncodeF(myHero.networkID)
    pQ2:Encode1(0x80)
    pQ2:EncodeF(Qtarget.x)
    pQ2:EncodeF(Qtarget.y)
    pQ2:EncodeF(Qtarget.z)
    pQ2.dwArg1 = 1
    pQ2.dwArg2 = 0
    SendPacket(pQ2)
    myHero:Attack(target)
    Qtick = GetTickCount()
    Qcast = false        
  end
end

function mouseQ()
  MPos = Vector(mousePos.x, mousePos.y, mousePos.z)
  HeroPos = Vector(myHero.x, myHero.y, myHero.z)
  QPos = HeroPos + ( HeroPos - MPos )*(-qRange/GetDistance(MPos)) 
  if QPos and not Qcast then
    CastSpell(_Q, mousePos.x, mousePos.z)        
    Qtick = GetTickCount()
  end
  if QPos and Qcast and GetTickCount()-Qtick > 1300 then
    pQ2 = CLoLPacket(0xE6)
    pQ2:EncodeF(myHero.networkID)
    pQ2:Encode1(0x80)
    pQ2:EncodeF(QPos.x)
    pQ2:EncodeF(QPos.y)
    pQ2:EncodeF(QPos.z)
    pQ2.dwArg1 = 1
    pQ2.dwArg2 = 0
    SendPacket(pQ2)
    Qtick = GetTickCount()
    Qcast = false            
  end
end

function PluginOnDraw()
  if not myHero.dead then
    if QREADY and Menu.drawQ then
      DrawCircle(myHero.x, myHero.y, myHero.z, qRange, 0x992D3D) --0x00FF00)				
    end
    if RREADY and Menu.drawR then
      DrawCircle(myHero.x, myHero.y, myHero.z, rRange, 0x00FFFF)
    end		
	end
end

function PluginOnProcessSpell(unit,spell)
  if unit.isMe and spell and (spell.name:find("ViQ") ~= nil) then
    Qtick = GetTickCount()
    Qcast = true      
  end
end

function PluginOnAnimation(unit,animation)
  if unit.isMe and animation ~= nil and ((animation:find"Spell1_Fire") or (animation:find"Spell1_end")) then
    Qtarget = nil
    Qtick = 0
    QPos = nil
    Qcast = false
  end
end

function Checks()
  qcastrange = (((myHero.ms * 0.85) * 1.2)/5) + qRange
  
  tp = TargetPredictionVIP(qRange, speed, delay)

	Target = AutoCarry.GetAttackTarget()
	QREADY = (myHero:CanUseSpell(_Q) == READY)
  WREADY = (myHero:CanUseSpell(_W) == READY)
	EREADY = (myHero:CanUseSpell(_E) == READY)
	RREADY = (myHero:CanUseSpell(_R) == READY)
  FREADY = (Flash ~= nil and myHero:CanUseSpell(Flash) == READY)
end


function mainLoad()
	Menu = AutoCarry.PluginMenu
	qRange, wRange, eRange, rRange = 900, 0, 0, 800
	QREADY, WREADY, RREADY = false, false, false
  if (myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") == nil) and (myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") == nil) then Flash = nil
  elseif myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then Flash = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then Flash = SUMMONER_2 end
end

function mainMenu()
  Menu:addParam("alt", "Alt", SCRIPT_PARAM_ONKEYDOWN, false, 17)
  Menu:addParam("escape", "Escape", SCRIPT_PARAM_ONKEYDOWN, false, 84)
	Menu:addParam("sep", "-- Combo Options --", SCRIPT_PARAM_INFO, "") 
	Menu:addParam("sep1", "-- Ability Options --", SCRIPT_PARAM_INFO, "")
  Menu:addParam("useR", "Use - Ultimate in Combo", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("R"))
	Menu:addParam("sep3", "-- Draw Options --", SCRIPT_PARAM_INFO, "")
	Menu:addParam("drawQ", "Draw - Blinding Assault", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("drawR", "Draw - Vault", SCRIPT_PARAM_ONOFF, true)

	AutoCarry.PluginMenu:permaShow("useR")
	
	PrintChat(">> Vi SAC Plugin -- Unbind Any Q casting hotkeys in Game, or Q may bug out if you use this key!") 
end