AddCSLuaFile()

ENT.Type = 'anim'
ENT.Base = 'base_anim'

ENT.PrintName   = 'Jump Jetpack'
ENT.Information = 'A jetpack in build mode but a jump pack in kill mode.'
ENT.Author      = '{toby}'

ENT.AdminOnly = false
ENT.Spawnable = true
ENT.Category = 'Other'

function ENT:SetupDataTables()
    self:NetworkVar( 'Entity', 0, "EquippedBy" )
    self:NetworkVar( 'Bool', 1, 'IsThrusting' )
end