-- PUBLIC LICENSE STB STYLE -- 



local can_move_into_a_group = true
local UP = 1
local DOWN = -1

if app.tip == nil then
  app.tip = function()
  end
end

function movelayer(move)
  -- move should be either 1 or -1
  assert(move == UP or move == DOWN)

  --check whether the image is open
  if app.sprite == nil then
    app.tip("app.sprite is nil") 
    return;
  end

  local sortedlayers = {}
  local testparent = app.layer.parent
  for _,layer in ipairs(app.range.layers) do
    if layer.parent ~= testparent then
      app.tip("layers of multiple parent selected NOT GONNA DO IT")
      return
    end
    table.insert(sortedlayers, layer)
  end
  table.sort(
    sortedlayers, 
    function(a,b)
      if move == UP then
        return a.stackIndex > b.stackIndex
      else
        return a.stackIndex < b.stackIndex
      end
    end
  )

  local threshold
  if move == UP then
    threshold = #app.layer.parent.layers
  else
    threshold = 1
  end

  local thelayer = sortedlayers[1]

  if thelayer.stackIndex == threshold then
    -- on TOP || BOTTOM of the stack 
    if thelayer.parent == app.sprite then
      -- no PARENT
      app.tip("layer parent is the app.sprite so i cant move above or below him. hitting top or bottom")
      return
    else
      -- has parent
      local parent = thelayer.parent
      for _,layer in ipairs(sortedlayers) do
        layer.parent = parent.parent
        -- add it to parent of our parent (default behaviour : adds it to the below of already existing layer with stackindex)
        layer.stackIndex = parent.stackIndex
        if move == UP then
          -- to overcome the default behaviour
          layer.stackIndex = layer.stackIndex + 1
        end
      end
    end
  else
    local parent = thelayer.parent.layers[thelayer.stackIndex + move]
   
    -- add to the above or below parent
    if parent.isGroup == true 
      and parent.isEditable == true 
      and parent.isExpanded == true then
     
      for _,layer in ipairs(sortedlayers) do
        layer.parent = parent
        if move == UP then 
          -- add to the bottom of the above parent
          layer.stackIndex = 1
        else
          -- add to the top of the below parent
          layer.stackIndex = #parent.layers
        end
      end
    else
      for _,layer in ipairs(sortedlayers) do
        layer.stackIndex = layer.stackIndex + move
      end
    end
  
  end
end

function selectlayer(move)
  assert(move == UP or move == DOWN)

  local newrange = {}

  for _,layer in ipairs(app.range.layers) do
    if app.layer.parent == layer.parent then 
      table.insert(newrange, layer)  
    else
      app.tip("Selected Layers have Different parents")
      return
    end
  end

  table.sort(
    newrange,
    function(a,b)
      return a.stackIndex < b.stackIndex
    end
  )
  
  if move == UP then
    if app.layer.stackIndex > newrange[1].stackIndex then
      table.remove(newrange, 1) 
    else
      local tlayer = newrange[#newrange]
      if tlayer.stackIndex == #app.layer.parent.layers then
        app.tip("TOP of the current parent")
        return
      end
      local layer = app.layer.parent.layers[tlayer.stackIndex + UP]
      table.insert(newrange, layer)
    end
  else
    if app.layer.stackIndex < newrange[#newrange].stackIndex then
      table.remove(newrange, #newrange)
    else
      local tlayer = newrange[1]
      if tlayer.stackIndex == 1 then
        app.tip("BOTTOM of the current parent")
        return
      end
      local layer = app.layer.parent.layers[tlayer.stackIndex + DOWN]
      table.insert(newrange, layer)
    end
  end
 
  app.range.layers = newrange
end

function init(plugin)
  plugin:newMenuGroup{
    id ="kmovelayer-menu",
    title = "K Move Layer",
    group = "layer_duplicate",
  }

  plugin:newCommand {
    id = "kmovelayer-up",
    title = "K Move Layer Up",
    group = "kmovelayer-menu",   
    onenabled = function ()
      if app.sprite then return true else return false end
    end,
    onclick = function ()
      movelayer(UP)
    end 
  }
  plugin:newCommand {
    id = "kmovelayer-down",
    title = "K Move Layer Down",
    group = "kmovelayer-menu",   
    onenabled = function ()
      if app.sprite then return true else return false end
    end,
    onclick = function ()
      movelayer(DOWN)
    end 
  }

  plugin:newCommand {
    id = "kselectlayer-up",
    title = "K select layer up",
    group = "kmovelayer-menu",
    onenabled = function ()
      if app.sprite then return true else return false end
    end,
    onclick = function ()
      selectlayer(UP)
    end
  }

 plugin:newCommand {
    id = "kselectlayer-down",
    title = "K select layer down",
    group = "kmovelayer-menu",
    onenabled = function ()
      if app.sprite then return true else return false end
    end,
    onclick = function ()
      selectlayer(DOWN)
    end
  }

end
