local substr = function (text, begin_index, end_index)
  local codepoints = vim.str_utf_pos(text)

  local last_byte_size = vim.str_utf_end(text, codepoints[end_index])
  return string.sub(
    text,
    codepoints[begin_index],
    codepoints[end_index] + last_byte_size
  )
end
local strlen = function (text)
  return #vim.str_utf_pos(text)
end
local scroll = function (text, offset, length)
  local text_length = strlen(text)
  if text_length <= length then
    return text
  end
  text = text .. '   '
  text_length = strlen(text)

  local adjusted_offset = offset % text_length
  local output = substr(
    text,
    adjusted_offset + 1,
    math.min(adjusted_offset + length, text_length)
  )

  local remaining = length - strlen(output)
  while remaining > 0 do
    if text_length <= remaining then
      output = output .. text
    else
      output = output .. substr(
        text,
        1,
        remaining
      )
    end
    remaining = length - strlen(output)
  end

  return output
end

if #arg < 3 then
  -- print('usage: lua scroll.lua <text> <offset> <length>')
  os.exit(1)
end
print(scroll(arg[1], tonumber(arg[2]), tonumber(arg[3])))
