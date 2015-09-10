local lpc = require"lpc-emul"
printf = function(fmt, ...) io.stdout:write( (fmt:format(...)) ) end

do
local pid, stdin, stdout, stderr = lpc.run("cat")
stdin:write("aa bb\n") ; stdin:close()
local a = stdout:read("*a")
assert( lpc.wait(pid) == 0 )

assert( a == "aa bb\n" and a)

printf('%s',a) -- aa bb
end

do
	local pid, stdin, stdout, stderr = lpc.run("cat")
	stdin:write( ("a"):rep(64*1024).."\n") ; stdin:close()
	local a = stdout:read("*a")
	assert( lpc.wait(pid) == 0 )
	assert( #a == 64*1024+1)
	printf('%s...%s', a:sub(1,3), a:sub(-3,-1))
end
