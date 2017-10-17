local logic = require("logic");

local WIDTH = 800;
local HEIGHT = 600;

function love.load()
	math.randomseed(os.time());
	love.window.setMode(WIDTH, HEIGHT, {resizable = false, msaa = 16});

	logic.load(WIDTH, HEIGHT);
end

function love.draw()
	logic.draw();
end

function love.update(dt)
	logic.update(dt);
end

function love.mousepressed(x, y, b)
	logic.mousepressed(x, y, b);
end

function love.keypressed(key)
	logic.keypressed(key);
end

--[[
	cache if no change?
	don't need to check every vertex ??
	complexity : O(m*n*log(n)), m = #lights, n = #vertices
]]