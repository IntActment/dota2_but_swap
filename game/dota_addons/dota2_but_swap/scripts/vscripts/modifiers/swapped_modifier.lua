
swapped_modifier = class({})

function swapped_modifier:RemoveOnDeath() return true end
function swapped_modifier:IsPurgable() return false end
function swapped_modifier:IsPurgeException() return false end
function swapped_modifier:IsHidden() return false end 	-- we can hide the modifier

function swapped_modifier:GetTexture() return "swap" end

function swapped_modifier:OnCreated( kv )
	if IsClient() then return end
	
	self.newTeam = kv.newTeam
	self.oldTeam = kv.oldTeam
	
	local parent = self:GetParent()
	
	--print(parent:GetName() .. ":SetTeam(" .. tostring(self.newTeam) .. ")")
	
	parent:EmitSound("spark")
	
	parent:SetAbsOrigin( Vector( kv.pos_1, kv.pos_2, kv.pos_3 ) )
	parent:SetAngles( kv.rot_1, kv.rot_2, kv.rot_3 )
	
	--PlayerResource:SetCameraTarget(  )
	
	FindClearSpaceForUnit( parent, parent:GetAbsOrigin(), true )
	ResolveNPCPositions( parent:GetAbsOrigin(), 100 )	
	
	parent:SetTeam( self.newTeam )
	if parent:IsRealHero() then
		PlayerResource:SetCustomTeamAssignment( parent:GetPlayerID(), self.newTeam )
	end
	
	parent:SetHealth( kv.setHpPerc * parent:GetMaxHealth() )
	
	--print( "range: " .. tostring(parent:Script_GetAttackRange()))
	
	local units = FindUnitsInRadius( 
		parent:GetTeamNumber(), 
		parent:GetAbsOrigin(),
		parent,
		parent:Script_GetAttackRange() + 150,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,
		FIND_CLOSEST, 
		false )

	local hitTarget = nil

	for u,unit in pairs(units) do
		hitTarget = unit
		break
	end
	
	if hitTarget ~= nil then
		--print( "found a foe to hit" )
		parent:MoveToTargetToAttack( hitTarget )
		parent:PerformAttack( hitTarget, true, true, true, false, true, false, true )
	end
	
end

function swapped_modifier:OnDestroy()
	if IsClient() then return end
	
	local parent = self:GetParent()
	
	parent:SetTeam( self.oldTeam )
	if parent:IsRealHero() then
		PlayerResource:SetCustomTeamAssignment( parent:GetPlayerID(), self.oldTeam )
	end
	
	--print(parent:GetName() .. ":SetTeam back(" .. tostring(self.oldTeam) .. ")")
	
	if parent:IsAlive() then
		FindClearSpaceForUnit( parent, parent:GetAbsOrigin(), true )
		ResolveNPCPositions( parent:GetAbsOrigin(), 100 )
	end
	
end

function swapped_modifier:DeclareFunctions()
	if IsClient() then return end
	
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE,
	}

	return funcs
end

function swapped_modifier:GetModifierMoveSpeedBonus_Percentage( params )
	if IsClient() then return 0 end
	return 70
end

function swapped_modifier:GetModifierBaseDamageOutgoing_Percentage( params )
	if IsClient() then return 0 end
	return 150
end


function swapped_modifier:GetModifierMagicDamageOutgoing_Percentage( params )
	if IsClient() then return 0 end
	return 50
end
