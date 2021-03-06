settings_table = {
  {
    name='time',
    arg='%I.%M',
    max=12,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xffffff,
    fg_alpha=0.2,
    x=60, y=82,
    radius=40,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='time',
    arg='%M.%S',
    max=60,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xffffff,
    fg_alpha=0.4,
    x=60, y=82,
    radius=46,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='time',
    arg='%S',
    max=60,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=60, y=82,
    radius=55,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
 {
    name='time',
    arg='%M.%S',
    max=60,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=60, y=82,
    radius=44,
    thickness=10,
    start_angle=0,
    end_angle=360
  },
 {
    name='time',
    arg='%I.%M',
    max=12,
    bg_colour=0xffffff,
    bg_alpha=0.2,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=60, y=82,
    radius=34,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
}

--Use these settings to define the origin and extent of your clock.
  clock_r=50

--Coordinates of the centre of the clock, in pixels, from the top left of the Conky window.
  clock_x=60
  clock_y=82

--Colour & alpha of the clock hands
  clock_colour=0xffffff
  clock_alpha=0.6

--Show the seconds hand ?
  show_seconds=true

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

function draw_clock_hands(cr,xc,yc)
  local secs,mins,hours,secs_arc,mins_arc,hours_arc
  local xh,yh,xm,ym,xs,ys

  secs=os.date("%S")
  mins=os.date("%M")
  hours=os.date("%I")

  secs_arc=(2*math.pi/60)*secs
  mins_arc=(2*math.pi/60)*mins+secs_arc/60
  hours_arc=(2*math.pi/12)*hours+mins_arc/12

  --Draw hour hand
  xh=xc+0.65*clock_r*math.sin(hours_arc)
  yh=yc-0.65*clock_r*math.cos(hours_arc)
  cairo_move_to(cr,xc,yc)
  cairo_line_to(cr,xh,yh)
  --
  cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
  cairo_set_line_width(cr,5)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(clock_colour,clock_alpha))
  cairo_stroke(cr)

  --Draw minute hand
  xm=xc+0.95*clock_r*math.sin(mins_arc)
  ym=yc-0.95*clock_r*math.cos(mins_arc)
  cairo_move_to(cr,xc,yc)
  cairo_line_to(cr,xm,ym)
  --
  cairo_set_line_width(cr,3)
  cairo_stroke(cr)

  -- Draw seconds hand
  if show_seconds then
    xs=xc+1.1*clock_r*math.sin(secs_arc)
    ys=yc-1.1*clock_r*math.cos(secs_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xs,ys)
    --
    cairo_set_line_width(cr,1)
    cairo_stroke(cr)
  end
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

  draw_clock_hands(cr,clock_x,clock_y)
end
