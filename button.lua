local modulePath = (...):match("(.-)[^%.]+$")
local Class = require(modulePath .. "Dependencies.class")
local Utils = require(modulePath .. "Dependencies.utils")
local Widget = require(modulePath .. "widget")
local Addons = require(modulePath .. "addons")

local Callback = Addons.Callback

local Button = Class{
	ObjectType = "Button";
	__includes = {Widget, Addons.Clickable};

	img_normal = love.graphics.newImage("button_normal.png");
	img_hover = love.graphics.newImage("button_hover.png");
	img_click = love.graphics.newImage("button_click.png");
	img_disabled = love.graphics.newImage("button_click.png");

	init = function(self, px, py, pw, ph, exec)
		Widget.init(self, px, py, pw, ph)

		local callbacks = 
		Addons.Clickable.init(self, 
			{
				fBeginHover = Callback(self.hovered, self),
				fEndHover 	= Callback(self.unhovered, self),
				fClick 		= Callback(self.click, self),
				fClicked 	= Callback(self.clicked, self),
				fDisable 	= Callback(self.disable, self),
				fEnable		= Callback(self.enable, self)
			}
		)

		self.exec = exec

		self:addDrawable(self.img_normal)

		self.originalDraw = self.draw

		return self
	end;

	enable = function(self)
		self:removeDrawable(self.img_disabled)
		self:addDrawable(self.img_normal)
	end;

	disable = function(self)
		self:removeDrawable(self.img_normal)
		self:removeDrawable(self.img_hover)
		self:removeDrawable(self.img_click)
		self:addDrawable(self.img_disabled)
	end;

	click = function(self)
		self:removeDrawable(self.img_hover)
		self:addDrawable(self.img_click)
	end;

	clicked = function(self)
		self:removeDrawable(self.img_click)
		self:addDrawable(self.img_hover)
		self:exec()
	end;

	hovered = function(self)
		self:removeDrawable(self.img_normal)
		self:addDrawable(self.img_hover)
	end;

	unhovered = function(self)
		self:removeDrawable(self.img_hover)
		self:addDrawable(self.img_normal)
	end;
}

return Button