ListenToGameEvent("dota_player_killed",function(keys)
	-- for k,v in pairs(keys) do print("dota_player_killed",k,v) end
	local playerID = keys.PlayerID
	local heroKill = keys.HeroKill
	local towerKill = keys.TowerKill


end, nil)

ListenToGameEvent("entity_killed", function(keys)
	-- for k,v in pairs(keys) do	print("entity_killed",k,v) end
	local attackerUnit = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
	local killedUnit = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

	if (killedUnit and killedUnit:IsRealHero()) then
		-- when a hero dies
	end

end, nil)

ListenToGameEvent("npc_spawned", function(keys)
	-- for k,v in pairs(keys) do print("npc_spawned",k,v) end
	local spawnedUnit = keys.entindex and EntIndexToHScript(keys.entindex)

end, nil)

ListenToGameEvent("entity_hurt", function(keys)
	-- for k,v in pairs(keys) do print("entity_hurt",k,v) end
	local damage = keys.damage
	local attackerUnit = keys.entindex_attacker and EntIndexToHScript(keys.entindex_attacker)
	local victimUnit = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
	local damagebits = keys.damagebits -- This might always be 0 and therefore useless

end, nil)

ListenToGameEvent("dota_player_gained_level", function(keys)
	-- for k,v in pairs(keys) do print("dota_player_gained_level",k,v) end
	local newLevel = keys.level
	local playerEntindex = keys.player
	local playerUnit = EntIndexToHScript(playerEntindex)
	local heroUnit = playerUnit:GetAssignedHero()
	
end, nil)

LinkLuaModifier( "swapped_modifier", "modifiers/swapped_modifier", LUA_MODIFIER_MOTION_NONE )

local castTable = {}
local chance = 4.0
local range = 1500.0

ListenToGameEvent("dota_player_used_ability", function(keys)
	-- for k,v in pairs(keys) do print("dota_player_used_ability",k,v) end
	local casterUnit = keys.caster_entindex and EntIndexToHScript(keys.caster_entindex)
	local abilityname = keys.abilityname
	local playerID = keys.PlayerID
	local player = keys.PlayerID and PlayerResource:GetPlayer(keys.PlayerID)
	local ability = casterUnit and casterUnit.FindAbilityByName and casterUnit:FindAbilityByName(abilityname) -- bugs if hero has 2 times the same ability
	
	if ability and ( GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS ) then
		if not ability:IsToggle() and not ability:GetAutoCastState() and RandomFloat( 0.0, 100.0 ) < chance then
			
			if castTable[playerID] == nil then
				castTable[playerID] = Time()
			else
				local newTime = Time()
				
				if newTime - castTable[playerID] < 4.0 then
					return
				end
			end
			
			-- refresh
			ability:EndCooldown()
			
			local units = FindUnitsInRadius( 
				casterUnit:GetTeamNumber(), 
				casterUnit:GetAbsOrigin(),
				casterUnit,
				range,
				DOTA_UNIT_TARGET_TEAM_BOTH,
				DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER, 
				false )
				
			local targets = {}
			local count = 0
			
			-- look for 2 units
			for u,unit in pairs(units) do
				if not unit:HasModifier( "swapped_modifier" ) then
					--print("first found")
					
					table.insert(targets, unit)
					count = count + 1
					
					if count == 2 then
						--print("second found")
						break
					end					
				end
			end
			
			if count == 2 then
			
				local dur = RandomFloat( 2.7, 6.8 )
				castTable[playerID] = newTime
				chance = math.min( chance + 0.15, 50.0 )
				range = math.min( range + 35, 9000.0 )
					
				--print("both found")
				local target1_pos = targets[1]:GetAbsOrigin()
				local target2_pos = targets[2]:GetAbsOrigin()
				
				local target1_rot = targets[1]:GetAngles()
				local target2_rot = targets[2]:GetAngles()
				
				local target1_mul = 1
				local target2_mul = 1
				
				if not targets[1]:IsRealHero() then
					target1_mul = 3.5
				end
				
				if not targets[2]:IsRealHero() then
					target2_mul = 3.5
				end
				
				local target1_data =
				{
					duration = dur * target1_mul,
					oldTeam = targets[1]:GetTeam(),
					newTeam = targets[2]:GetTeam(),
					setHpPerc = targets[2]:GetHealth() / targets[2]:GetMaxHealth(),
					pos_1 = target2_pos[1],
					pos_2 = target2_pos[2],
					pos_3 = target2_pos[3],
					rot_1 = target2_rot[1],
					rot_2 = target2_rot[2],
					rot_3 = target2_rot[3],
					
				}
				
				local target2_data =
				{
					duration = dur * target2_mul,
					oldTeam = targets[2]:GetTeam(),
					newTeam = targets[1]:GetTeam(),
					setHpPerc = targets[1]:GetHealth() / targets[1]:GetMaxHealth(),
					pos_1 = target1_pos[1],
					pos_2 = target1_pos[2],
					pos_3 = target1_pos[3],
					rot_1 = target1_rot[1],
					rot_2 = target1_rot[2],
					rot_3 = target1_rot[3],
				}
				
				-- do swap
				targets[1]:AddNewModifier( casterUnit, ability, "swapped_modifier", target1_data )				
				targets[2]:AddNewModifier( casterUnit, ability, "swapped_modifier", target2_data )
			end
			
		end
	
	end

end, nil)

ListenToGameEvent("last_hit", function(keys)
	-- for k,v in pairs(keys) do print("last_hit",k,v) end
	local killedUnit = keys.EntKilled and EntIndexToHScript(keys.EntKilled)
	local playerID = keys.PlayerID
	local firstBlood = keys.FirstBlood
	local heroKill = keys.HeroKill
	local towerKill = keys.TowerKill

end, nil)

ListenToGameEvent("dota_tower_kill", function(keys)
	-- for k,v in pairs(keys) do print("dota_tower_kill",k,v) end
	local gold = keys.gold
	local towerTeam = keys.teamnumber
	local killer_userid = keys.killer_userid

end, nil)

------------------------------------------ example --------------------------------------------------

ListenToGameEvent("this_is_just_an_example", function(keys)
	local targetUnit = EntIndexToHScript(keys.entindex)

	local neighbours = FindUnitsInRadius(
		targetUnit:GetTeam(), -- int teamNumber, 
		targetUnit:GetAbsOrigin(), -- Vector position, 
		false, -- handle cacheUnit, 
		1000, -- float radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- int teamFilter, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, -- int typeFilter, 
		DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, -- int flagFilter, 
		FIND_ANY_ORDER, -- int order, 
		false -- bool canGrowCache
	)

	for n,neighUnit in pairs(neighbours) do

		ApplyDamage({
			victim = neighUnit,
			attacker = targetUnit,
			damage = 100,
			damage_type = DAMAGE_TYPE_MAGICAL,
			damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
			ability = nil
		})

		neighUnit:AddNewModifierButt(
			targetUnit, -- handle caster, 
			nil, -- handle optionalSourceAbility, 
			"someweirdmodifier", -- string modifierName, 
			{duration = 5} -- handle modifierData
		)

	end
end, nil)