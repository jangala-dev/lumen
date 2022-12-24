--look for packages one folder up.
package.path = package.path .. ";;;../../?.lua;../../?/init.lua"

local sched = require 'lumen.sched'
local stream = require 'lumen.stream'
local selector = require 'lumen.tasks.selector'
local nixio = require 'nixio'

selector.init({service='nixio'})

local handles = {
    out_r = {
        pattern = "*a",
        handler = stream.new()
    },
    err_r = {
        pattern = "*a",
        handler = stream.new()
    },
    ret_r = {
        pattern = "*a",
        handler = stream.new()
    },
}

-- task that issues command
sched.run(function()
    local sktd, pid = selector.grab_all('ping -c 5 8.8.8.8', handles)
    local a = handles.ret_r.handler:read()
    if a ~= nil then
        print("return code: "..a)
    end
    nixio.waitpid(pid)
    print("function completed!")
end)

-- task receives ping std_out
sched.run(function()
	while true do
        local a, b, c = handles.out_r.handler:read()
        if a ~= nil then
            print("stdout: "..a)
        else
            print("returning from stdout wait")
            return
        end
    end
end)

-- task receives ping std_err
sched.run(function()
	while true do
        local a, b, c = handles.err_r.handler:read()
        if a ~= nil then
            print("stderr: "..a)
        else
            print("returning from stderr wait")
            return
        end
    end
end)

sched.loop()
