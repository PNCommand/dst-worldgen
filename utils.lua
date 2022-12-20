function TableLength(table)
  local count = 0
  for _ in pairs(table) do count = count + 1 end
  return count
end

function Indexof(array, target)
  for i, elem in ipairs(array) do
      if elem == target then
          return i
      end
  end
  return -1
end

function Split(input, char)
  if char == nil then char = "%s" end
  local array={}
  for str in string.gmatch(input, "([^"..char.."]+)") do
      table.insert(array, str)
  end
  return array
end

function GetSortedKeyArray(obj)  
  local key_array = {}
  local n = 0
  for k, _ in pairs(obj) do
    n = n + 1
    key_array[n] = k
  end
  table.sort(key_array)
  return key_array
end
