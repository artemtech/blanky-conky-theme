settings_table = {
  {
        name='memperc',
        arg='',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=0.2,
        fg_colour=0xd7d7d7,
        fg_alpha=0.6,
        x=150, y=110,
        radius=72,
        thickness=15,
        start_angle=180,
        end_angle=420
    },
    {
        name='swapperc',
        arg='',
        max=100,
        bg_colour=0xffffff,
        bg_alpha=0.2,
        fg_colour=0xd7d7d7,
        fg_alpha=0.6,
        x=150, y=110,
        radius=57,
        thickness=10,
        start_angle=180,
        end_angle=420
    },
{
    name='fs_used_perc',
    arg='/',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=105, y=496,
    radius=50,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
{
    name='fs_used_perc',
    arg='/var',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=105, y=496,
    radius=43,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
{
    name='fs_used_perc',
    arg='/home',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=105, y=496,
    radius=36,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
}
  require 'cairo'

function rgb_to_r_g_b(colour,alpha)
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
  local w,h=conky_window.width,conky_window.height

  local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
  local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

  local angle_0=sa*(2*math.pi/360)-math.pi/2
  local angle_f=ea*(2*math.pi/360)-math.pi/2
  local t_arc=t*(angle_f-angle_0)

  --Draw background ring
  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
  cairo_set_line_width(cr,ring_w)
  cairo_stroke(cr)

  --Draw indicator ring
  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
  cairo_stroke(cr)
end


function conky_clock_rings()
  local function setup_rings(cr,pt)
  local str=''
  local value=0

  str=string.format('${%s %s}',pt['name'],pt['arg'])
  str=conky_parse(str)

  value=tonumber(str)
  if value == nil then value = 0 end

  if pt['arg'] == "%I.%M"  then
    value=os.date("%I")+os.date("%M")/60
    if value>12 then value=value-12 end
  end

  if pt['arg'] == "%M.%S"  then
    value=os.date("%M")+os.date("%S")/60
  end

  pct=value/pt['max']
  draw_ring(cr,pct,pt)
end

--Check that Conky has been running for at least 5s
  if conky_window==nil then return end
  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

  local cr=cairo_create(cs)  

  local updates=conky_parse('${updates}')
  update_num=tonumber(updates)

  if update_num>5 then
    for i in pairs(settings_table) do
      setup_rings(cr,settings_table[i])
    end
  end

  --draw_clock_hands(cr,clock_x,clock_y)
end
