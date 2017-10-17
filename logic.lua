--shortcuts
local min = math.min;
local atan2 = math.atan2;
local sort = table.sort;
local sortFunction = function(a, b) return a.angle < b.angle end;
local cos = math.cos;
local sin = math.sin;
local setColor = love.graphics.setColor;
local setBlendMode = love.graphics.setBlendMode;
local setStencilTest = love.graphics.setStencilTest;
local stencil = love.graphics.stencil;
local draw = love.graphics.draw;
local polygon = love.graphics.polygon;
local print = love.graphics.print;

--required objects
local Box = require("box");
local Light = require("light");

--global variables
local world, width, height;
local fps, fps_count, fps_temp = 0, 0, 0;
local boxIntensity, boxObject = {}, {};
local boxes, lights = {}, {};
local canvas;
local grav_state = "off";

local load = function(w, h)
	world = love.physics.newWorld(0, 0, true);
	canvas = love.graphics.newCanvas(w, h);
	width = w;
	height = h;
	Box.load(world);

	--create walls at edges of screen
	boxes[#boxes+1] = Box.new(-25, h/2, 50, h, "static");
	boxes[#boxes+1] = Box.new(w+25, h/2, 50, h, "static");
	boxes[#boxes+1] = Box.new(w/2, -25, w, 50, "static");
	boxes[#boxes+1] = Box.new(w/2, h+25, w, 50, "static");
end

local draw = function()
	--get list of vertices
	local verts = {};
	verts[1] = {x = 0, y = 0};
	verts[2] = {x = width, y = 0};
	verts[3] = {x = 0, y = height};
	verts[4] = {x = width, y = height};
	for i = 5, #boxes do
		local box = boxes[i];
		local a,b,c,d,e,f,g,h = box.body:getWorldPoints(box.shape:getPoints());
		verts[#verts+1] = {x = a, y = b, box = box};
		verts[#verts+1] = {x = c, y = d, box = box};
		verts[#verts+1] = {x = e, y = f, box = box};
		verts[#verts+1] = {x = g, y = h, box = box};
	end

	--shadowcast
	setBlendMode("add") do
		for i = 1, #lights do
			local light = lights[i];
			local inside = Light.inside(light, boxes);

			if inside then
				--case : light is above a box;
				local intens = boxIntensity[inside];
				if intens then
					intens.r = min(255, intens.r + light.r);
					intens.g = min(255, intens.g + light.g);
					intens.b = min(255, intens.b + light.b);
				end
			else
				local x, y = light.x, light.y;

				local angles = {};
				for j = 1, #verts do
					local vert = verts[j];
					local dx = vert.x - x;
					local dy = vert.y - y;
					local angle = atan2(dy, dx);
					angles[#angles+1] = {angle = angle - 0.0005, box = vert.box};
					angles[#angles+1] = {angle = angle + 0.0005, box = vert.box};
				end

				sort(angles, sortFunction);

				local hitInfo = {};
				local hitBoxes = {};
				local n = #angles;
				for j = 1, n do
					local angle = angles[j].angle;
					local offX = 2048 * cos(angle);
					local offY = 2048 * sin(angle);
					local hitX, hitY, hitB = x + offX, y + offY, nil;
					local dist = 2048;

					local callback = world:rayCast(
						x, y, hitX, hitY, function(f, hx, hy)
							local dx = x - hx;
							local dy = y - hy;
							local hitDist = (dx*dx + dy*dy)^0.5;
							if hitDist < dist then
								hitB = f:getBody();
								hitX, hitY = hx, hy;
								dist = hitDist;
							end
							return 1;
						end
					);

					hitInfo[j] = {angle = angle, x = hitX, y = hitY};
					if hitB and boxObject[hitB] then
						local px, py = hitB:getPosition();
						local dx = px - x;
						local dy = py - y;
						hitBoxes[boxObject[hitB]] = 1 - ((dx*dx + dy*dy)^0.5)/500; 
					end
				end

				for box, v in pairs(hitBoxes) do
					local intens = boxIntensity[box];
					if intens then
						intens.r = min(255, intens.r + v*light.r);
						intens.g = min(255, intens.g + v*light.g);
						intens.b = min(255, intens.b + v*light.b);
					end
				end

				stencil(function()
					setColor(255, 255, 255);
					for j = 1, n do
						local curr = hitInfo[j];
						local prev = j == 1 and hitInfo[n] or hitInfo[j-1];
						polygon("fill",
							x, y,
							prev.x, prev.y,
							curr.x, curr.y
						);
					end
				end, "replace", 1);
				setStencilTest("greater", 0);
				setColor(light.r, light.g, light.b);
				draw(Light.image(), x-500, y-500);
				setStencilTest();
			end
		end
	end setBlendMode("replace");

	--draw boxes
	for i = 5, #boxes do
		local box = boxes[i];
		local body = box.body;
		local shape = box.shape;
		local intens = boxIntensity[box];
		setColor(
			box.r*intens.r/255,
			box.g*intens.g/255,
			box.b*intens.b/255);
		polygon("fill", body:getWorldPoints(shape:getPoints()));
		boxIntensity[box] = {r = 0, g = 0, b = 0};
	end

	--draw lights
	setBlendMode("add") do
		for i = 1, #lights do
			local light = lights[i];
			setColor(light.r, light.g, light.b);
			draw(Light.image(), light.x-5, light.y-5, 0, 0.01, 0.01);
		end
	end setBlendMode("replace");

	--display fps counter
	setColor(255, 255, 255);
	print("FPS:\t\t"..fps, 30, 30);
	print("Lights:\t"..#lights, 30, 45);
	print("Boxes:\t"..(#boxes-4), 30, 60);
end

local update = function(dt)
	--world physics step
	world:update(dt);

	--fps counter logic
	fps_temp = fps_temp + 1;
	fps_count = fps_count + dt;
	if fps_count > 1 then
		fps_count = 0;
		fps = fps_temp;
		fps_temp = 0;
	end
end

local mousepressed = function(x, y, b)
	if b == 1 then
		local newBox = Box.new(x, y, math.random(20, 50), math.random(20, 50));
		boxIntensity[newBox] = {r = 0, g = 0, b = 0};
		boxObject[newBox.body] = newBox;
		boxes[#boxes+1] = newBox;
	elseif b == 2 then
		local r = math.random(85, 127);
		local g = math.random(85, 127);
		local b = math.random(85, 127);
		lights[#lights+1] = Light.new(x, y, r, g, b);
	end
end

local keypressed = function(key)
	if key == "space" then
		grav_state = grav_state == "on" and "off" or "on";
		world:setGravity(0, grav_state == "on" and 250 or 0);
		for _, box in pairs(boxes) do
			box.body:setAwake(grav_state == "on");
		end
	end
end

return {
	load = load;
	draw = draw;
	update = update;
	mousepressed = mousepressed;
	keypressed = keypressed;
}