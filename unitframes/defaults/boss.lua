--[[
	Project....: LUI NextGenWoWUserInterface
	File.......: boss.lua
	Description: oUF Boss Defaults
]]

local addonname, LUI = ...
local module = LUI:GetModule("Unitframes")

module.defaults.profile.Boss = {
	Enable = true,
	UseBlizzard = false,
	Height = 24,
	Width = 130,
	X = -25,
	Y = -250,
	Scale = 1,
	Point = "TOPRIGHT",
	GrowDirection = "BOTTOM",
	Padding = 6,
	Border = {
		EdgeFile = "glow",
		EdgeSize = 5,
		Insets = {
			Left = 3,
			Right = 3,
			Top = 3,
			Bottom = 3,
		},
		Color = {
			r = 0,
			g = 0,
			b = 0,
			a = 1,
		},
	},
	Backdrop = {
		Texture = "Blizzard Tooltip",
		Padding = {
			Left = -4,
			Right = 4,
			Top = 4,
			Bottom = -4,
		},
		Color = {
			r = 0,
			g = 0,
			b = 0,
			a = 1,
		},
	},
	Bars = {
		Health = {
			Height = 24,
			Width = 130,
			X = 0,
			Y = 0,
			Color = "Individual",
			Texture = "LUI_Gradient",
			TextureBG = "LUI_Gradient",
			BGAlpha = 1,
			BGMultiplier = 0.4,
			BGInvert = false,
			Smooth = true,
			IndividualColor = {
				r = 0.25,
				g = 0.25,
				b = 0.25,
			},
		},
		Power = {
			Enable = false,
			Height = 10,
			Width = 130,
			X = 0,
			Y = -26,
			Color = "By Class",
			Texture = "LUI_Minimalist",
			TextureBG = "LUI_Minimalist",
			BGAlpha = 1,
			BGMultiplier = 0.4,
			BGInvert = false,
			Smooth = true,
			IndividualColor = {
				r = 0.8,
				g = 0.8,
				b = 0.8,
			},
		},
		Full = {
			Enable = false,
			Height = 14,
			Width = 130,
			X = 0,
			Y = -36,
			Texture = "LUI_Minimalist",
			Alpha = 1,
			IndividualColor = {
				r = 0.11,
				g = 0.11,
				b = 0.11,
				a = 1,
			},
		},
	},
	Aura = {
		Buffs = {
			Enable = false,
			ColorByType = false,
			PlayerOnly = false,
			IncludePet = false,
			AuraTimer = false,
			DisableCooldown = false,
			CooldownReverse = true,
			X = 0,
			Y = -42,
			InitialAnchor = "BOTTOMLEFT",
			GrowthY = "DOWN",
			GrowthX = "RIGHT",
			Size = 26,
			Spacing = 2,
			Num = 8,
		},
		Debuffs = {
			Enable = true,
			ColorByType = true,
			PlayerOnly = true,
			IncludePet = false,
			FadeOthers = true,
			AuraTimer = false,
			DisableCooldown = false,
			CooldownReverse = true,
			X = 35,
			Y = -5,
			InitialAnchor = "RIGHT",
			GrowthY = "DOWN",
			GrowthX = "RIGHT",
			Size = 26,
			Spacing = 2,
			Num = 36,
		},
	},
	Castbar = {
		General = {
			Enable = false,
			Height = 20,
			Width = 140,
			X = -140,
			Y = -35,
			Texture = "LUI_Gradient",
			TextureBG = "LUI_Minimalist",
			IndividualColor = false,
			Icon = false,
			Shield = true,
		},
		Text = {
			Name = {
				Enable = true,
				Font = "neuropol",
				Size = 13,
				OffsetX = 5,
				OffsetY = 1,
			},
			Time = {
				Enable = false,
				ShowMax = true,
				Font = "neuropol",
				Size = 13,
				OffsetX = -5,
				OffsetY = 1,
			},
		},
		Border = {
			Texture = "glow",
			Thickness = 4,
			Inset = {
				left = 3,
				right = 3,
				top = 3,
				bottom = 3,
			},
		},
		Colors = {
			Bar = {
				r = 0.13,
				g = 0.59,
				b = 1,
				a = 0.68,
			},
			Background = {
				r = 0.15,
				g = 0.15,
				b = 0.15,
				a = 0.67,
			},
			Border = {
				r = 0,
				g = 0,
				b = 0,
				a = 0.7,
			},
			Shield = {
				r = 0.5,
				g = 0,
				b = 0,
				a = 0.1,
			},
			Name = {
				r = 0.9,
				g = 0.9,
				b = 0.9,
			},
			Time = {
				r = 0.9,
				g = 0.9,
				b = 0.9,
			},
		},
		Shield = {
			Enable = true,
			Text = true,
			IndividualColor = false,
			BarColor = {
				r = 0.13,
				g = 0.59,
				b = 1,
				a = 0.68,
			},
			IndividualBorder = true,
			Color = {
				r = 0.13,
				g = 0.59,
				b = 1,
				a = 0.68,
			},
			Border = false,
			Texture = "glow",
			Thickness = 4,
			Inset = {
				left = 3,
				right = 3,
				top = 3,
				bottom = 3,
			},
		},
	},
	Portrait = {
		Enable = false,
		Height = 43,
		Width = 90,
		X = 0,
		Y = 0,
		Alpha = 1,
	},
	Icons = {
		Raid = {
			Enable = true,
			Size = 55,
			X = 0,
			Y = 0,
			Point = "CENTER",
		},
	},
	Texts = {
		Name = {
			Enable = true,
			Font = "Prototype",
			Size = 15,
			X = 0,
			Y = 0,
			IndividualColor = {
				r = 1,
				g = 1,
				b = 1,
			},
			Outline = "NONE",
			Point = "CENTER",
			RelativePoint = "CENTER",
			Format = "Name",
			Length = "Short",
			ColorNameByClass = false,
			ColorClassByClass = false,
			ColorLevelByDifficulty = false,
			ShowClassification = false,
			ShortClassification = false,
		},
		Health = {
			Enable = false,
			Font = "Prototype",
			Size = 24,
			X = 0,
			Y = -43,
			Color = "Individual",
			ShowAlways = false,
			IndividualColor = {
				r = 0,
				g = 0,
				b = 0,
			},
			Outline = "NONE",
			Point = "BOTTOMLEFT",
			RelativePoint = "BOTTOMRIGHT",
			Format = "Absolut Short",
			ShowDead = false,
		},
		Power = {
			Enable = false,
			Font = "Prototype",
			Size = 24,
			X = 0,
			Y = -66,
			Color = "By Class",
			ShowFull = true,
			ShowEmpty = true,
			IndividualColor = {
				r = 0,
				g = 0,
				b = 0,
			},
			Outline = "NONE",
			Point = "BOTTOMLEFT",
			RelativePoint = "BOTTOMRIGHT",
			Format = "Absolut Short",
		},
		HealthPercent = {
			Enable = false,
			Font = "Prototype",
			Size = 24,
			X = 0,
			Y = 0,
			Color = "Individual",
			ShowAlways = false,
			IndividualColor = {
				r = 0,
				g = 0,
				b = 0,
			},
			Outline = "NONE",
			Point = "CENTER",
			RelativePoint = "CENTER",
			ShowDead = true,
		},
		PowerPercent = {
			Enable = false,
			Font = "Prototype",
			Size = 24,
			X = 0,
			Y = 0,
			Color = "Individual",
			ShowFull = false,
			ShowEmpty = false,
			IndividualColor = {
				r = 0,
				g = 0,
				b = 0,
			},
			Outline = "NONE",
			Point = "CENTER",
			RelativePoint = "CENTER",
		},
		HealthMissing = {
			Enable = false,
			Font = "Prototype",
			Size = 24,
			X = 0,
			Y = 0,
			Color = "Individual",
			ShortValue = true,
			ShowAlways = false,
			IndividualColor = {
				r = 0,
				g = 0,
				b = 0,
			},
			Outline = "NONE",
			Point = "RIGHT",
			RelativePoint = "RIGHT",
		},
		PowerMissing = {
			Enable = false,
			Font = "Prototype",
			Size = 24,
			X = 0,
			Y = 0,
			Color = "Individual",
			ShortValue = true,
			ShowFull = false,
			ShowEmpty = false,
			IndividualColor = {
				r = 0,
				g = 0,
				b = 0,
			},
			Outline = "NONE",
			Point = "RIGHT",
			RelativePoint = "RIGHT",
		},
	},
	Fader = {
		Casting = true,
		Combat = true,
		Enable = false,
		Health = true,
		HealthClip = 1.0,
		Hover = true,
		HoverAlpha = 0.75,
		InAlpha = 1.0,
		OutAlpha = 0.1,
		OutDelay = 0.0,
		OutTime = 1.5,
		Power = true,
		PowerClip = 0.9,
		Targeting = true,
		UseGlobalSettings = true,
	},
}
