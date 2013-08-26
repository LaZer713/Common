--[[
 
        Auto Carry Plugin - Ashe Edition  --- DeniCevap
 
        Activates Q when attacking enemy hero and disables when attacking minions.
 
--]]
 
if myHero.charName ~= "Ashe" then return end
 
local frostOn = false
AutoCarry.PluginMenu:addParam("AutoQ", "Activate Q Against Enemy", SCRIPT_PARAM_ONOFF, true)
AutoCarry.PluginMenu:addParam("ManaCheck", "Do not activate Q if low on mana", SCRIPT_PARAM_ONOFF, true)
 
function CustomAttackEnemy(enemy)
        if enemy.dead or not enemy.valid or not AutoCarry.CanAttack then return end
        if AutoCarry.PluginMenu.AutoQ then
                if ValidTarget(enemy) and enemy.type == "obj_AI_Hero" and not frostOn and ((AutoCarry.PluginMenu.ManaCheck and myHero.mana > 100) or not AutoCarry.PluginMenu.ManaCheck) then
                        CastSpell(_Q)
                elseif ValidTarget(enemy) and enemy.type ~= "obj_AI_Hero" and frostOn then
                        CastSpell(_Q)
                end
        end
        myHero:Attack(enemy)
        AutoCarry.shotFired = true
end
 
function PluginOnCreateObj(obj)
        if GetDistance(obj) < 100 and obj.name:lower():find("icesparkle") then
                frostOn = true
        end
end
 
function PluginOnDeleteObj(obj)
        if GetDistance(obj) < 100 and obj.name:lower():find("icesparkle") then
                frostOn = false
        end
end