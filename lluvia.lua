require 'cairo'

-- === COLORES ===
local color_white = {1, 1, 1, 1}
local color_cyan  = {0.4, 0.9, 1.0, 1}
local color_purple_soft = {0.7, 0.5, 0.9, 1}
local color_green_soft  = {0.5, 0.9, 0.6, 1}
local color_red_soft    = {0.9, 0.5, 0.5, 1}

-- === AJUSTES DE "NEGRITA" ===
-- Aumentamos el tamaño del punto para que se vea más grueso
local dot_size = 6       -- Antes 5 (Más gorditos)
local dot_spacing = 7    -- Mantenemos 7 (Quedarán casi juntos, efecto negrita)

-- PATRONES
local patterns = {
    ['0'] = { {1,1,1,1,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1} },
    ['1'] = { {0,0,1,0,0}, {0,1,1,0,0}, {0,0,1,0,0}, {0,0,1,0,0}, {0,0,1,0,0}, {0,0,1,0,0}, {1,1,1,1,1} },
    ['2'] = { {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {1,1,1,1,1}, {1,0,0,0,0}, {1,0,0,0,0}, {1,1,1,1,1} },
    ['3'] = { {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {1,1,1,1,1} },
    ['4'] = { {1,0,0,0,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {0,0,0,0,1} },
    ['5'] = { {1,1,1,1,1}, {1,0,0,0,0}, {1,0,0,0,0}, {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {1,1,1,1,1} },
    ['6'] = { {1,1,1,1,1}, {1,0,0,0,0}, {1,0,0,0,0}, {1,1,1,1,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1} },
    ['7'] = { {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {0,0,0,1,0}, {0,0,1,0,0}, {0,0,1,0,0}, {0,0,1,0,0} },
    ['8'] = { {1,1,1,1,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1} },
    ['9'] = { {1,1,1,1,1}, {1,0,0,0,1}, {1,0,0,0,1}, {1,1,1,1,1}, {0,0,0,0,1}, {0,0,0,0,1}, {1,1,1,1,1} },
    [':'] = { {0,0,0,0,0}, {0,0,1,0,0}, {0,0,0,0,0}, {0,0,0,0,0}, {0,0,0,0,0}, {0,0,1,0,0}, {0,0,0,0,0} }
}

local drops = {}
local num_drops = 35
local width, height = 0, 0
local clock_area_y_start = 180
local clock_area_y_end = 250

function conky_main()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)
    
    local updates = tonumber(conky_parse('${updates}'))
    if updates > 3 then
        setup(cr)
        draw_particles(cr)
        draw_main_clock(cr)
    end
    
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

function setup(cr)
    width, height = conky_window.width, conky_window.height
    if #drops == 0 then
        for i = 1, num_drops do
            table.insert(drops, {
                -- CENTRADO: Movimos el área de lluvia también a la derecha (+60px)
                x = math.random(360, 1010), 
                y = math.random(clock_area_y_start, clock_area_y_end),
                speed = math.random(3, 6) * 1.0, 
                size = math.random(14, 22),
                alpha = math.random(),
                char = get_random_char()
            })
        end
    end
end

function get_random_char()
    local chars = {"x", "+", "s", "u", "n", "l", "i", "·", "°", "*"}
    return chars[math.random(1, #chars)]
end

function draw_dotted_string(cr, str, start_x, start_y)
    cairo_set_source_rgba(cr, color_white[1], color_white[2], color_white[3], 1) 
    local current_x = start_x
    for i = 1, #str do
        local char = string.sub(str, i, i)
        local pattern = patterns[char]
        if pattern then
            for row = 1, #pattern do
                for col = 1, #pattern[row] do
                    if pattern[row][col] == 1 then
                        cairo_arc(cr, current_x + (col-1)*dot_spacing, start_y + (row-1)*dot_spacing, dot_size/2, 0, 2*math.pi)
                        cairo_fill(cr)
                    end
                end
            end
            current_x = current_x + (5 * dot_spacing) + (dot_spacing * 2)
        end
    end
end

function draw_main_clock(cr)
    local base_y = 180 
    
    -- === COORDENADAS CORREGIDAS (CENTRADO TOTAL) ===
    -- Se ha sumado +60px aprox a todas las coordenadas X anteriores
    
    local day_x = 400         -- Antes 340 -> Ahora 400
    local time_x = 580        -- Antes 520 -> Ahora 580
    local date_x, date_y = 520, base_y + 65 -- Antes 460 -> Ahora 520

    local day_str = conky_parse('${time %d}')
    local time_str = conky_parse('${time %H:%M}')
    local month_str = conky_parse('${time %b}')
    local week_str = conky_parse('${time %a}')
    
    -- 1. Números (Ahora más gruesos)
    draw_dotted_string(cr, day_str, day_x, base_y)
    draw_dotted_string(cr, time_str, time_x, base_y)
    
    -- 2. Fecha
    cairo_set_source_rgba(cr, color_cyan[1], color_cyan[2], color_cyan[3], 0.9)
    cairo_select_font_face(cr, "Roboto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, 22)
    cairo_move_to(cr, date_x, date_y)
    cairo_show_text(cr, month_str)
    cairo_move_to(cr, date_x + 50, date_y + 25)
    cairo_show_text(cr, week_str)
    cairo_stroke(cr)

    -- 3. Estadísticas
    -- Mantenemos la distancia relativa (+240px desde la hora)
    local stats_x = time_x + 240 
    local stats_y_start = base_y + 10

    cairo_set_font_size(cr, 14)

    -- CPU
    cairo_set_source_rgba(cr, color_purple_soft[1], color_purple_soft[2], color_purple_soft[3], 0.9)
    cairo_move_to(cr, stats_x, stats_y_start)
    cairo_show_text(cr, conky_parse('| CPU: ${cpu cpu0}%'))
    cairo_stroke(cr)

    -- RAM
    cairo_set_source_rgba(cr, color_green_soft[1], color_green_soft[2], color_green_soft[3], 0.9)
    cairo_move_to(cr, stats_x, stats_y_start + 25)
    cairo_show_text(cr, conky_parse('| RAM: ${memperc}%'))
    cairo_stroke(cr)
    
    -- Disk
    cairo_set_source_rgba(cr, color_red_soft[1], color_red_soft[2], color_red_soft[3], 0.9)
    cairo_move_to(cr, stats_x, stats_y_start + 50)
    cairo_show_text(cr, conky_parse('| Disk: ${fs_used_perc /}%'))
    cairo_stroke(cr)
end

function draw_particles(cr)
    for i, drop in ipairs(drops) do
        drop.y = drop.y + drop.speed
        
        if drop.y > clock_area_y_end + 200 then
            drop.y = math.random(clock_area_y_start, clock_area_y_end)
            -- Lluvia también centrada al nuevo eje
            drop.x = math.random(360, 1010) 
            drop.char = get_random_char()
            drop.alpha = 0 
        end

        drop.alpha = drop.alpha + 0.05
        local fade = drop.alpha
        if drop.y > clock_area_y_end + 50 then 
             fade = 1 - ((drop.y - (clock_area_y_end + 50)) / 150)
        end
        if fade < 0 then fade = 0 end
        if fade > 1 then fade = 1 end

        cairo_set_source_rgba(cr, color_cyan[1], color_cyan[2], color_cyan[3], fade * 0.7)
        cairo_select_font_face(cr, "Roboto Mono", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_LIGHT)
        cairo_set_font_size(cr, drop.size)
        cairo_move_to(cr, drop.x, drop.y)
        cairo_show_text(cr, drop.char)
        cairo_stroke(cr)
    end
end
