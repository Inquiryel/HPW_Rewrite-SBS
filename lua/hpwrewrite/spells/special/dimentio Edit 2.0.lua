local Spell = { }
Spell.LearnTime = 600
Spell.Description = [[
	Enter the mind of your
	victim and show them
	their worst and most
	terrible of fears.
]]
Spell.FlyEffect = "hpw_sectumsemp_main"
Spell.ImpactEffect = "hpw_white_impact"
Spell.ApplyDelay = 0.2
Spell.AccuracyDecreaseVal = 0.5
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.AnimSpeedCoef = 1.00
Spell.ShouldSay = false
Spell.ForceDelay = 10.00

Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_1, ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(255, 255, 255)
Spell.NodeOffset = Vector(483, -1032, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	return true
end

function Spell:OnCollide(spell, data)
	local ply = data.HitEntity

	if IsValid(ply) and ply:IsPlayer() then
		--if not ply.HpwRewrite.WasInDimension then
			ply.HpwRewrite.InDimension = true

			local oldWep = ""
			if IsValid(ply:GetActiveWeapon()) then oldWep = ply:GetActiveWeapon():GetClass() end

			--local weps = { }
			--for k, v in pairs(ply:GetWeapons()) do table.insert(weps, v:GetClass()) end

			--ply:StripWeapons()
			--ply:DrawWorldModel(false)
			ply:SetNotSolid(true)
			ply:SetMaterial("Models/effects/vol_light001")
			ply:GetActiveWeapon():SetMaterial("Models/effects/vol_light001")
			ply.HpwRewrite.BlockSpelling = true

			timer.Create("hpwrewrite_dimension_handler" .. ply:EntIndex(), 60, 1, function()
				if IsValid(ply) then
					ply.HpwRewrite.BlockSpelling = false
					ply.HpwRewrite.InDimension = false
					ply:SetMaterial("")
					ply:GetActiveWeapon():SetMaterial("")
					ply:SetNotSolid(false)
				end
			end)

			-- Visual effects
			net.Start("hpwrewrite_Dim")
			net.Send(ply)

			ply.HpwRewrite.WasInDimension = true
		--[[else
			util.ScreenShake(data.HitPos, 4000, 4000, 3, 200)
			sound.Play("npc/stalker/go_alert2a.wav", data.HitPos, 60, 90)
		end--]]
	end
end

if SERVER then
	hook.Add("PlayerSwitchWeapon","HPWDimensioStopSwitching",function(who)
		if who.HpwRewrite.InDimension == true then
			return true
		end
	end)

	hook.Add("PlayerCanPickupItem","HPWDimensioStopIPickup",function(who)
		if who.HpwRewrite.InDimension == true then
			return false
		end
	end)

	hook.Add("PlayerCanPickupWeapon","HPWDimensioStopWPickup",function(who)
		if who.HpwRewrite.InDimension == true then
			return false
		end
	end)

	hook.Add("PlayerUse","HPWDimensioStopUse",function(who)
		if who.HpwRewrite.InDimension == true then
			return false
		end
	end)
end

HpwRewrite:AddSpell("Dimentio", Spell)

---

local Spell = { }
Spell.Description = [[
	Cast this three times to negate
	the effect of Dimentio
]]
Spell.FlyEffect = "hpw_crucio_main"
Spell.ApplyFireDelay = 0.5
Spell.Category = HpwRewrite.CategoryNames.Special
Spell.CanSelfCast = true
Spell.ForceAnim = { ACT_VM_PRIMARYATTACK_5 }
Spell.SpriteColor = Color(0, 0, 255)
Spell.OnlyIfLearned = { "Dimentio" }

Spell.NodeOffset = Vector(683, -1082, 0)

function Spell:OnSpellSpawned(wand, spell)
	wand:PlayCastSound()
end

function Spell:OnFire(wand)
	if not self.Attempt then self.Attempt = 0 end

	self.Attempt = self.Attempt + 1

	sound.Play("npc/zombie/zombie_hit.wav", wand:GetPos(), 70, math.random(110, 130))

	if self.Attempt >= 3 then
		sound.Play("npc/zombie_poison/pz_warn" .. math.random(1, 2) .. ".wav", wand:GetPos(), 70, math.random(130, 140))

		if math.random(1, 3) == 1 then
			sound.Play("ambient/materials/metal4.wav", wand:GetPos(), 70)

			net.Start("hpwrewrite_EDim")
			net.Send(self.Owner)

			self.Attempt = 0
		end
	end
end

HpwRewrite:AddSpell("AntiDemntio", Spell)
