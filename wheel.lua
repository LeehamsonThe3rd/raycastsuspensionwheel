local WheelModule = {}
WheelModule.__index = WheelModule

function WheelModule.new(VehicleModel : Model, Model : Model)
	local self = setmetatable({}, WheelModule)
	
	self.SuspensionHeight  = Model:GetAttribute("SuspensionHeight")
	self.SuspensionDamping = Model:GetAttribute("SuspensionDamping")
	self.SuspensionSpring  = Model:GetAttribute("SuspensionSpring")
	self.RollingResistance = Model:GetAttribute("RollingResistance")
	
	self.Debug = Model:GetAttribute("Debug")
	
	self.Vehicle            = VehicleModel
	
	self.Model              = Model
	self.Weld               = self.Model.Weld
	self.Attachment         = self.Model.Attachment
	self.VectorForce        = self.Attachment.VectorForce
	self.RaycastParams      = RaycastParams.new()
	self.Raycast            = nil
	
	self.SuspensionForce         = Vector3.zero
	self.SuspensionFrictionForce = Vector3.zero
	self.ResistanceForce         = Vector3.zero
	self.FrictionForce           = Vector3.zero
	
	self.Offset = self.Weld.C1
	
	self.RaycastParams.FilterDescendantsInstances = {VehicleModel}
	
	if self.Debug then
		self.UpIndicator         = Instance.new("ConeHandleAdornment", workspace)
		self.UpIndicator.Adornee = workspace.Terrain
	end
	
	return self
end

function WheelModule:Update(...)
	self.SuspensionHeight   = self.Model:GetAttribute("SuspensionHeight")
	self.SuspensionDamping  = self.Model:GetAttribute("SuspensionDamping")
	self.SuspensionSpring   = self.Model:GetAttribute("SuspensionSpring")
	self.RollingResistance  = self.Model:GetAttribute("RollingResistance")
	
	self:CalculatePhysics(...)
	self:ApplyForce()
	self:UpdateModel()
	
	self.Debug = self.Model:GetAttribute("Debug")
	self:UpdateDebug()
end

local function AbsoluteVector(v : Vector3)
	return Vector3.new(math.abs(v.X),math.abs(v.Y),math.abs(v.Z))
end

function WheelModule:CalculatePhysics(dt)
	self.Raycast = workspace:Raycast(self.Model.Position-(Vector3.yAxis*self.Weld.C1.Position), -self.Vehicle.PrimaryPart.CFrame.UpVector*self.SuspensionHeight, self.RaycastParams)
	
	if self.Raycast then 
		local Extension        = self.SuspensionHeight-self.Raycast.Distance
		local RelativeVelocity = self.Vehicle.PrimaryPart.CFrame:VectorToObjectSpace(self.Model.Velocity)
		
		self.SuspensionForce         = self.Vehicle.PrimaryPart.CFrame.UpVector*(self.SuspensionSpring*Extension-self.SuspensionDamping*RelativeVelocity.Y)
		self.SuspensionFrictionForce = self.SuspensionForce*-AbsoluteVector(self.Vehicle.PrimaryPart.CFrame:VectorToObjectSpace(Vector3.new(self.Model.CustomPhysicalProperties.Friction,0,self.RollingResistance)))
		self.ResistanceForce         = self.Vehicle.PrimaryPart.CFrame.LookVector*(((RelativeVelocity.Z*self.Model.AssemblyMass))*self.RollingResistance)
		self.FrictionForce           = -self.Vehicle.PrimaryPart.CFrame.RightVector*(((RelativeVelocity.X*self.Model.AssemblyMass))*self.Model.CustomPhysicalProperties.Friction)
	end
end

function WheelModule:ApplyForce()
	if not self.Raycast then self.VectorForce.Force = Vector3.zero return end
	self.VectorForce.Force = self.SuspensionForce + self.SuspensionFrictionForce + self.ResistanceForce + self.FrictionForce
end

function WheelModule:UpdateModel()
	local RelativeVelocity = self.Vehicle.PrimaryPart.CFrame:VectorToObjectSpace(self.Model.Velocity)
	
	self.Weld.C1 = self.Offset * CFrame.new(0,-self.SuspensionHeight+(self.Model.Size.Y/2),0)
	if self.Raycast then self.Weld.C1 = self.Offset * CFrame.new(0,-self.Raycast.Distance+(self.Model.Size.Y/2),0) end
	self.Weld.C0 *= CFrame.Angles(math.rad(-RelativeVelocity.Z/(self.Model.Size.Y/2)),0,0)
end

function WheelModule:UpdateDebug()
	if not self.Debug then return end
	
	self.UpIndicator.CFrame = CFrame.new(self.Model.Position+(Vector3.yAxis*5)) * CFrame.Angles(math.rad(90),0,0)
	if self.Raycast then
		self.UpIndicator.CFrame = CFrame.new(self.Model.Position+(Vector3.yAxis*5)) * CFrame.lookAt(Vector3.zero, self.SuspensionForce.Unit)
	end
	
	print("\n	[Suspension]: "..tostring(self.SuspensionForce), "\n	[SuspensionFriction]: "..tostring(self.SuspensionFrictionForce), "\n	[Resistance]: "..tostring(self.ResistanceForce), "\n	[Friction]: "..tostring(self.FrictionForce), "\n	[NET]: "..tostring(self.VectorForce.Force))
end

return WheelModule
