local modulePath = (...):match("(.-)[^%.]+$")
local Class = require(modulePath .. "Dependencies.class")

local Canvas = Class{
	ObjectType = "Canvas";

	init = function(self, width, height)
		self.widgets = {}
		self.widgetId = 1
		local windowW, windowH = love.window.getMode()
		self.width = width or windowW 
		self.height = height or windowH
		self.hoveredWidget = nil

		return self
	end;

	addWidget = function(self, newWidget)
		if utils.typeOf(newWidget, "Widget") then
			if newWidget.id then
				if self.widgets[newWidget.id] then
					return false
				else
					self.widgets[newWidget.id] = newWidget
					return true
				end
			else 
				self.widgets[self.widgetId] = newWidget
				newWidget.id = self.widgetId
				self.widgetId = self.widgetId + 1
				return true
			end
		end

		return false
	end;

	removeWidget = function(self, widget)
		if type(widget) == "Number" then
			return self:removeWidgetById(widget)
		elseif utils.typeOf(widget, "Widget") then
			return self:removeWidgetByRef(widget)
		end
		return false
	end;

	removeWidgetById = function(self, id)
		if self.widgets[id] then
			self.widgets[id] = nil
			return true
		end
		return false
	end;

	removeWidgetByRef = function(self, ref)
		for k, widget in pairs(self.widgets) do
			if ref == widget then
				self.widgets[k] = nil
				return true
			end
		end
		return false
	end;

	draw = function(self, debugging)
		for k, widget in pairs(self.widgets) do
			widget:draw(debugging)
		end
	end;

	update = function(self, dt)
		for k, widget in pairs(self.widgets) do
			if widget.update then
				widget:update(dt)
			end
		end
	end;

	-- Return true if click was used.
	hoverUpdate = function(self, x, y, hUpdate)
		if hUpdate then
			for k, widget in pairs(self.widgets) do
				if 	x >= widget.x and 
					x <= widget.x + widget.w and 
					y >= widget.y and 
					y <= widget.y + widget.h
				then
					if widget ~= self.hoveredWidget then
						if widget.exec_hovered then
							if widget:exec_hovered() then
								if self.hoveredWidget then
									self.hoveredWidget:exec_unhovered()
								end
								self.hoveredWidget = widget
								hUpdate = false
							end
						end
					else
						hUpdate = false
					end
				end
			end
		end
		if hUpdate then
			if self.hoveredWidget then
				self.hoveredWidget:exec_unhovered()
				self.hoveredWidget = nil
			end
		end

		return hUpdate
	end;

	-- User pressed button
	click = function(self, x, y, button)
		for k, widget in pairs(self.widgets) do
			if 	x >= widget.x and 
				x <= widget.x + widget.w and 
				y >= widget.y and 
				y <= widget.y + widget.h
			then
				if widget.exec_click then
					if widget:exec_click(x, y, button) then
						return true
					end
				end
			end
		end
	end;

	-- User released button
	clicked = function(self, x, y, button)
		for k, widget in pairs(self.widgets) do
			if 	x >= widget.x and 
				x <= widget.x + widget.w and 
				y >= widget.y and 
				y <= widget.y + widget.h
			then
				if widget.exec_clicked then
					if widget:exec_clicked(x, y, button) then
						return true 
					end
				end
			end
		end
	end;

	-- y is the relevant up / down
	wheelmoved = function(self, x, y)
		for k, widget in pairs(self.widgets) do
			widget:exec_wheelmoved(x, y)
		end
	end;

	resize = function(self, w, h)
		for k, widget in pairs(self.widgets) do
			widget:exec_resize(w, h)
		end
	end;
}

return Canvas