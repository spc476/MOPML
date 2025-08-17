#!/usr/bin/env lua
-- luacheck: ignore 611

local html = require "org.conman.app.mod_blog.html"

local function abort(...)
  io.stderr:write(string.format(...),"\n")
  os.exit(1)
end

local f,err do
  if not arg[1] then
    f = io.stdin
    arg[1] = '(stdin)' -- luacheck: ignore
  else
    f,err = io.open(arg[1],"r")
    if not f then
      abort("%s: %s",arg[1],err)
    end
  end
end
  
local linecnt = 1
local author  = false
local title   = false
local class   = false

while true do
  local line = f:read("l")
  if line == "" then break end
  linecnt = linecnt + 1
  
  local name,value = line:match("^([^:]+):%s*(.*)")
  
  if not name then
    abort("%s(%d): bad header line",arg[1],linecnt)
  end
  
  name = name:lower()
  
  if name == 'title' then
    if title then
      abort("%s(%d): dupliate TITLE header",arg[1],linecnt)
    end
    title = value ~= ""
  elseif name == 'author' then
    if author then
      abort("%s(%d): duplicate AUTHOR header",arg[1],linecnt)
    end
    author = value ~= ""
  elseif name == 'class' then
    if class then
      abort("%s(%d): duplicate CLASS header",arg[1],linecnt)
    end
    class = value ~= ""
  end
end

if not author then
  abort("%s: missing AUTHOR header",arg[1])
end
if not title then
  abort("%s: missing TITLE header",arg[1])
end
if not class then
  abort("%s: missing CLASS header",arg[1])
end

local contents = f:read("a")
local doc,line = html(contents)

if not doc then
  abort("%s(%d): invalid HTML",arg[1],line + linecnt)
end
