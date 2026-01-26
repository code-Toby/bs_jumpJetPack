include('shared.lua')

game.AddParticles( "particles/rockettrail.pcf" )
PrecacheParticleSystem('rockettrail_airstrike')

function ENT:Think()
    self.equippedBy = self:GetEquippedBy()

    if  self.equippedBy:IsPlayer() and self.equippedBy == LocalPlayer() then
        self:SetNoDraw(!self.equippedBy:ShouldDrawLocalPlayer())
    end

    if self:GetIsThrusting() then

        if  self.thrust_eff_l == nil then
            self.thrust_eff_l = CreateParticleSystem( self, 'rockettrail_airstrike', PATTACH_CUSTOMORIGIN)
        end
        if self.thrust_eff_r == nil then
            self.thrust_eff_r = CreateParticleSystem( self, 'rockettrail_airstrike', PATTACH_CUSTOMORIGIN)
        end

        if self.thrust_eff_l != nil then
            if self.thrust_eff_l:IsValid() then
                self.thrust_eff_l:SetControlPoint(0, self:LocalToWorld(Vector(-1,4.5,-10)))
                self.thrust_eff_l:SetControlPointForwardVector( 0, -self:GetUp())
            end
        end

        if self.thrust_eff_r != nil then
            if self.thrust_eff_r:IsValid() then
                self.thrust_eff_r:SetControlPoint(0, self:LocalToWorld(Vector(-1,-4.5,-10)))
                self.thrust_eff_r:SetControlPointForwardVector( 0, -self:GetUp())
            end
        end
    else
        if self.thrust_eff_l != nil then
            if self.thrust_eff_l:IsValid() then
                self.thrust_eff_l:StopEmission(true, false, true)
                self.thrust_eff_l = nil
            end
        end
        if self.thrust_eff_r != nil then
            if self.thrust_eff_r:IsValid() then
                self.thrust_eff_r:StopEmission(true, false, true)
                self.thrust_eff_r = nil
            end
        end
    end
end
