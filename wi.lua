local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local vicious = require("vicious")
local naughty = require("naughty")

--based on setkeh theme https://github.com/setkeh/Awesome-Laptop-3.5/

--Configure home path so you dont have too
home_path  = os.getenv('HOME') .. '/'

-- {{{ all widget images
beautiful.widget_disk = home_path .. ".config/awesome/images/disk.png"
beautiful.widget_cpu = home_path .. ".config/awesome/images/cpu.png"
beautiful.widget_ac = home_path .. ".config/awesome/images/ac.png"
beautiful.widget_acblink = home_path .. ".config/awesome/images/acblink.png"
beautiful.widget_blank = home_path .. ".config/awesome/images/blank.png"
beautiful.widget_batfull = home_path .. ".config/awesome/images/batfull.png"
beautiful.widget_batmed = home_path .. ".config/awesome/images/batmed.png"
beautiful.widget_batlow = home_path .. ".config/awesome/images/batlow.png"
beautiful.widget_batempty = home_path .. ".config/awesome/images/batempty.png"
beautiful.widget_vol = home_path .. ".config/awesome/images/vol.png"
beautiful.widget_mute = home_path .. ".config/awesome/images/mute.png"
beautiful.widget_pac = home_path .. ".config/awesome/images/pac.png"
beautiful.widget_pacnew = home_path .. ".config/awesome/images/pacnew.png"
beautiful.widget_mail = home_path .. ".config/awesome/images/mail.png"
beautiful.widget_mailnew = home_path .. ".config/awesome/images/mailnew.png"
beautiful.widget_temp = home_path .. ".config/awesome/images/temp.png"
beautiful.widget_tempwarn = home_path .. ".config/awesome/images/tempwarm.png"
beautiful.widget_temphot = home_path .. ".config/awesome/images/temphot.png"
beautiful.widget_wifi = home_path .. ".config/awesome/images/wifi.png"
beautiful.widget_nowifi = home_path .. ".config/awesome/images/nowifi.png"
beautiful.widget_mpd = home_path .. ".config/awesome/images/mpd.png"
beautiful.widget_play = home_path .. ".config/awesome/images/play.png"
beautiful.widget_pause = home_path .. ".config/awesome/images/pause.png"
beautiful.widget_ram = home_path .. ".config/awesome/images/ram.png"
-- }}}

-- Spacers
volspace = wibox.widget.textbox()
volspace:set_text(" ")
spacer = wibox.widget.textbox()
spacer:set_text(' ')

--memory usage (progressbar)
memwidget = awful.widget.progressbar()
memwidget:set_width(8)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color("#222222")
memwidget:set_border_color(nil)
memwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#AECF96"}, {0.5, "#88A175"},  {1, "#FF5656"}}})
vicious.register(memwidget, vicious.widgets.mem, "$1", 2)

-- CPU usage graph
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color("#222222")
cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, {1, "#AECF96" }}})
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 0.5)


-- {{{ BATTERY
-- Battery attributes
local bat_state  = ""
local bat_charge = 0
local bat_time   = 0
local blink      = true

-- Icons
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batfull)

-- Charge %
batpct = wibox.widget.textbox()
vicious.register(batpct, vicious.widgets.bat, function(widget, args)
  bat_state  = args[1]
  bat_charge = args[2]
  bat_time   = args[3]

  if args[1] == "-" then
    if bat_charge > 70 then
      baticon:set_image(beautiful.widget_batfull)
    elseif bat_charge > 30 then
      baticon:set_image(beautiful.widget_batmed)
    elseif bat_charge > 10 then
      baticon:set_image(beautiful.widget_batlow)
    else
      baticon:set_image(beautiful.widget_batempty)
    end
  else
    baticon:set_image(beautiful.widget_ac)
    if args[1] == "+" then
      blink = not blink
      if blink then
        baticon:set_image(beautiful.widget_acblink)
      end
    end
  end

  return args[2] .. "%"
end, nil, "BAT0")

-- Buttons
function popup_bat()
  local state = ""
  if bat_state == "↯" then
    state = "Full"
  elseif bat_state == "↯" then
    state = "Charged"
  elseif bat_state == "+" then
    state = "Charging"
  elseif bat_state == "-" then
    state = "Discharging"
  elseif bat_state == "⌁" then
    state = "Not charging"
  else
    state = "Unknown"
  end

  naughty.notify { text = "Charge : " .. bat_charge .. "%\nState  : " .. state ..
    " (" .. bat_time .. ")", timeout = 5, hover_timeout = 0.5 }
end
batpct:buttons(awful.util.table.join(awful.button({ }, 1, popup_bat)))
baticon:buttons(batpct:buttons())
-- End Battery}}}

-- {{{ VOLUME
-- Cache
vicious.cache(vicious.widgets.volume)
--
-- Icon
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
--
-- Volume %
volpct = wibox.widget.textbox()
vicious.register(volpct, vicious.widgets.volume, "$1%", nil, "Master")
--
-- Buttons
volicon:buttons(awful.util.table.join(
	awful.button({ }, 1,
	function() awful.util.spawn_with_shell("amixer -q set Master toggle") end),
	awful.button({ }, 4,
	function() awful.util.spawn_with_shell("amixer -q set Master 3+% unmute") end),
	awful.button({ }, 5,
	function() awful.util.spawn_with_shell("amixer -q set Master 3-% unmute") end)
	    ))
	volpct:buttons(volicon:buttons())
	volspace:buttons(volicon:buttons())
-- End Volume }}}
