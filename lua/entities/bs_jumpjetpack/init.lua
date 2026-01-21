AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')
--codeToby/icons/Jump Pack.png
function ENT:Initialize()
    self:SetModel('models/codetoby/jump_jetpack.mdl')
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    self.phys = self:GetPhysicsObject()
    if ( IsValid( self.phys ) ) then
        self.phys:Wake()
    end

    self.isEquipped = false
    self.equippedBy = nil
    self.isInKS = false

    self.thrusting_snd = CreateSound(self, 'thrusters/rocket00.wav')

    self.ks_canThurstJump = true
    self.ks_charge = 100
    self.ks_landing = false

    self.grnd_effectdata = EffectData()
        self.grnd_effectdata:SetScale(200)
        self.grnd_effectdata:SetEntity(self)
end

function ENT:Use(activator)
    if self.isEquipped == false then
        if activator.hasPack == false or activator.hasPack == nil then
            self.isEquipped = true
            self.equippedBy = activator
            self.equippedBy.hasPack = true

            self:SetEquippedBy(self.equippedBy)
            self:SetParent(self.equippedBy, self.equippedBy:LookupBone('ValveBiped.Bip01_Spine2'))
            self:SetLocalPos(Vector(-7,0,-3))
            self:SetLocalAngles(Angle(0,0,0))
            
            self:SetSolid(SOLID_NONE)
        end
    end
end

function ENT:Think()
    if self.equippedBy != nil and self.equippedBy:IsPlayer() then
        
        if IsValid(AS_IsInCombat) then
            self.isInKS = self.equippedBy:AS_IsInCombat()
        end

        self:SetIsThrusting(self.thrusting_snd:IsPlaying())
        self.gndTr = util.TraceLine({
                start = self.equippedBy:GetPos() + Vector(0,0,0),
                endpos = self.equippedBy:GetPos() - Vector(0,0,1000000000),
                filter = {self.equippedBy}
        })
        self.dist = self.equippedBy:GetPos():Distance(self.gndTr.HitPos)
        self.upVel = -self.equippedBy:GetVelocity()[3]
        self.grnd_effectdata:SetOrigin( self.gndTr.HitPos )
        
        if self.equippedBy:IsOnGround() then
            if self.ks_charge <= 0 then
                if !timer.Exists(tostring(self)..'_recharge_thrust') then
                    timer.Create(tostring(self)..'_recharge_thrust', 0.01, 100, function()
                        self.ks_charge = self.ks_charge + 1

                        if self.ks_charge > 99 then
                            self:EmitSound('hl1/fvox/fuzz.wav')
                        end
                    end)
                end
            end
            if self.thrusting_snd:IsPlaying() then
                self.thrusting_snd:Stop()
            end
            self.ks_landing = false
            self.ks_canThurstJump = true
        else
            if self.dist < (100 + (self.upVel/20)) and self.ks_charge == 0 then
                self.ks_landing = true
            end
        end

--hd2_jumppack_thrust thrusting effect name
        if self.equippedBy:KeyDown(IN_JUMP) then
            if !self.isInKS then
                self.thrusting_snd:Play()
                self.equippedBy:SetVelocity( (self.equippedBy:GetForward() * 50) + (self.equippedBy:GetUp() * 200))
            else
                if self.ks_canThurstJump and self.ks_charge >= 100 then
                    self.ks_canThurstJump = false
                    self.equippedBy:SetVelocity( (self.equippedBy:GetForward() * 250) + (self.equippedBy:GetUp() * 500))
                    self.thrusting_snd:Play()

                    for i=0, 10 do
                        util.Effect('ThumperDust', self.grnd_effectdata)
                    end
                    self:SetIsThrusting(true)
                    if !timer.Exists(tostring(self)..'_charge_set_dly') then
                        timer.Create(tostring(self)..'_charge_set_dly', 0.5, 1, function()
                            self.ks_charge = 0
                            if self.thrusting_snd:IsPlaying() then
                                self.thrusting_snd:Stop()
                            end
                        end)
                    end
                end
            end
        else
            if self.ks_charge == 100 then
                self.thrusting_snd:Stop()
            end
        end

        if self.ks_landing then
            self.equippedBy:SetVelocity(Vector(0,0,(self.upVel - 50)))
            self.thrusting_snd:Play()

            for i=0, 2 do
                util.Effect('ThumperDust', self.grnd_effectdata)
            end
        end

        

        --[[
        if self.ks_charge == 0 then
            

            
            local upVel = self.equippedBy:GetVelocity()[3]
            self.equippedBy:SetVelocity(Vector(0,0,(upVel*2) / dist))
        end
        --]]
    end
end

function ENT:OnRemove()
    if self.equippedBy != nil then
        self.equippedBy.hasPack = false
    end

    self.isEquipped = false
    self.equippedBy = nil

    if timer.Exists(tostring(self)..'_recharge_thrust') then
        timer.Remove(tostring(self)..'_recharge_thrust')
    end

    if timer.Exists(tostring(self)..'_landing') then
        timer.Remove(tostring(self)..'_landing')
    end
end