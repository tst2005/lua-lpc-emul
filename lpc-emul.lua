
-- from lua-popen3 https://github.com/kylemanna/lua-popen3

--
-- Name: Lua 5.2 + popen3() implementation
-- Author: Kyle Manna <kyle [at] kylemanna.com>
-- License: MIT License <http://opensource.org/licenses/MIT>
-- Copyright (c) 2013 Kyle Manna
--
-- Description:
-- Open pipes for stdin, stdout, and stderr to a forked process
-- to allow for IPC with the process.  When the process terminates
-- return the status code.
--

local posix = require("posix")
 
--
-- Simple popen3() implementation
--
local function popen3(path, ...)
	local r0, w0 = posix.pipe()
	local r1, w1 = posix.pipe()
	local r2, w2 = posix.pipe()

	assert((w0 ~= nil and r1 ~= nil and r2 ~= nil), "pipe() failed")

	local pid, err = posix.fork()
	assert(pid ~= nil, "fork() failed")
	if pid == 0 then
		posix.close(w0)
		posix.close(r1)
		posix.close(r2)

		posix.dup2(r0, posix.fileno(io.stdin))
		posix.dup2(w1, posix.fileno(io.stdout))
		posix.dup2(w2, posix.fileno(io.stderr))

		local ret, err = posix.execp(path, ...)
		assert(ret ~= nil, "execp() failed")

		posix._exit(1)
		return
	end

	posix.close(r0)
	posix.close(w1)
	posix.close(w2)

	return pid, w0, r1, r2
end

local function readall(fd, blocksize)
	blocksize = blocksize or 1024
	local all = {}
	while true do
		local x = posix.read(fd, blocksize)
		if type(x) ~= "string" or x == "" then break end
		all[#all+1] = x
	end
	return table.concat(all, "")
end

local function readline(fd, blocksize)
	blocksize = blocksize or 1024
	error("not implemented yet", 2)
end

local function readnumber(fd)
	error("not implemented yet", 2)
end

local lpc = {}

function lpc.run(...)
	local pid, stdin, stdout, stderr = popen3(...)
	-- wrap stdin/out/err to have *:close() *:read() ...
	local function wrap(fd, info)
		local o = {
			read = function(_, opt)
				opt = opt == nil and "*l" or opt
				if type(opt) == "string" then
					local opt2 = opt:sub(1,2)
					if opt2 == "*l" then
						return readline(fd)
					elseif opt2 == "*a" then
						return readall(fd)
					elseif opt2 == "*n" then
						return readnumber(fd)
					end
					error("unknown option", 2)
				elseif type(opt) == "number" then
					if opt == 0 then return "" end
					return posix.read(fd, opt)
				end
				error("unknown option", 2)
			end,
			write = function(_, data) return posix.write(fd, data) end,
			close = function(_) posix.close(fd) end,
		}
		local str =  "posix-file("..info.."): "..tostring(fd)
		local mt = {
			__tostring = function() return str end,
			__index=o,
		}
		return setmetatable({}, mt)
	end
	return pid, wrap(stdin, "in"), wrap(stdout, "out"), wrap(stderr, "err")
end

lpc.wait = function(pid)
	local a, b, code = posix.wait(pid)
	assert(a == pid)
	return code
end

return lpc
