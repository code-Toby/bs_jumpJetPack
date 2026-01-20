AddCSLuaFile('shared.lua')
AddCSLuaFile('cl_init.lua')

include('shared.lua')

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
    self.isInKS = true

    self.ks_canThurstJump = true
    self.ks_charge = 100
    self.ks_landing = false
end

function ENT:Use(activator)
    if self.isEquipped == false then
        if activator.hasPack == false or activator.hasPack == nil then
            self.isEquipped = true
            self.equippedBy = activator
            self.equippedBy.hasPack = true

            self:SetParent(self.equippedBy, 3)
            self:SetLocalPos(Vector(-7,0,-3))
            self:SetLocalAngles(Angle(0,0,0))
            
            self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        end
    end
end

function ENT:Think()
    if self.equippedBy != nil and self.equippedBy:IsPlayer() then
        -- do checks for ks --

        self.gndTr = util.TraceLine({
                start = self.equippedBy:GetPos() + Vector(0,0,0),
                endpos = self.equippedBy:GetPos() - Vector(0,0,1000000000),
                filter = {self.equippedBy}
        })
        self.dist = self.equippedBy:GetPos():Distance(self.gndTr.HitPos)
        self.upVel = -self.equippedBy:GetVelocity()[3]

        if self.equippedBy:IsOnGround() then
            if self.ks_charge <= 0 then
                if !timer.Exists(tostring(self)..'_recharge_thrust') then
                    timer.Create(tostring(self)..'_recharge_thrust', 0.01, 100, function()
                        self.ks_charge = self.ks_charge + 1
                    end)
                end
            end
            self.ks_landing = false
            self.ks_canThurstJump = true
        else
            if self.dist < (100 + (self.upVel/20)) and self.ks_charge == 0 then
                self.ks_landing = true
            end
        end


        if self.equippedBy:KeyDown(IN_JUMP) then
            if !self.isInKS then
                self.equippedBy:SetVelocity( (self.equippedBy:GetForward() * 50) + (self.equippedBy:GetUp() * 200))
            else
                if self.ks_canThurstJump and self.ks_charge >= 100 then
                    self.ks_canThurstJump = false
                    self.equippedBy:SetVelocity( (self.equippedBy:GetForward() * 250) + (self.equippedBy:GetUp() * 500))
                    if !timer.Exists(tostring(self)..'_charge_set_dly') then
                        timer.Create(tostring(self)..'_charge_set_dly', 0.5, 1, function()
                            self.ks_charge = 0
                        end)
                    end
                end
            end
        end

        if self.ks_landing then
            self.equippedBy:SetVelocity(Vector(0,0,(self.upVel - 50)))
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