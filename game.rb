require 'gosu'

module ZOrder
  LAY0, LAY1, LAY2, LAY3, LAY4, LAY5, LAY6, LAY7, LAY8, LAY9, LAY10, LAY11, LAY12 = *0..12
end

WIN_WIDTH = 1920
WIN_HEIGHT = 1080

class Player
    attr_accessor   :player_top_angle, :player_top_turn_spd, :player_top_current_turn,
                    :player_bottom_angle, :player_bottom_turn_spd, :player_bottom_current_turn,
                    :player_x, :player_y,
                    :player_top, :player_shadow_top, :player_bottom, :player_shadow_bottom, :player_top_type, :player_bottom_type,
                    :player_spd_up, :player_spd_down, :player_accel, :player_decel, :player_max_spd,
                    :player_max_health, :player_current_health
    def initialize
        @player_top = Gosu::Image.new("media/player/player_top/single/1.png")
        @player_bottom = Gosu::Image.new("media/player/player_bottom/normal/1.png")
        @player_shadow_top = Gosu::Image.new("media/player/player_top/single/s1.png")
        @player_shadow_bottom = Gosu::Image.new("media/player/player_bottom/normal/s.png")
        @player_x = WIN_WIDTH / 2
        @player_y = WIN_HEIGHT / 2
        @player_top_angle = 0
        @player_top_current_turn = 0
        @player_top_turn_spd = 5
        @player_bottom_angle = 0
        @player_bottom_current_turn = 0.01
        @player_bottom_turn_spd = 1
        @player_spd_up = 0
        @player_spd_down = 0
        @player_accel = 0.1
        @player_decel = 0.1
        @player_max_spd = 5
        case rand(3) #bottom
            when 0
                @player_bottom_type = "normal"
                @player_max_health = 100
            when 1
                @player_bottom_type = "speed"
                @player_max_health = 75
            when 2
                @player_bottom_type = "armor"
                @player_max_health = 800
        end
        case rand(6) #top
            when 0
                @player_top_type = "single"
            when 1
                @player_top_type = "double"
            when 2
                @player_top_type = "sniper"
            when 3
                @player_top_type = "shotgun"
            when 4
                @player_top_type = "minigun"
            when 5
                @player_top_type = "grenade"
        end
        @player_current_health = @player_max_health
    end
end

class Bullet
    attr_accessor :x, :y, :angle, :speed, :damage, :sprite, :type, :hit, :distance
    def initialize(x, y, angle, type)
        @x = x
        @y = y
        @angle = angle
        @hit = false
        @type = type
        case type
            when "single"
                @sprite = Gosu::Image.new("media/bullet/1.png")
                @speed = 30
                @damage = 20
            when "double"
                @sprite = Gosu::Image.new("media/bullet/2.png")
                @speed = 30
                @damage = 15
            when "sniper"
                @sprite = Gosu::Image.new("media/bullet/3.png")
                @speed = 100
                @damage = 100
            when "shotgun"
                @sprite = Gosu::Image.new("media/bullet/4.png")
                @speed = rand(35..45)
                @damage = 10
                @distance = rand(600..800)
            when "minigun"
                @sprite = Gosu::Image.new("media/bullet/4.png")
                @speed = 45
                @damage = 5
            when "enemy"
                @sprite = Gosu::Image.new("media/enemy/sentry/bullet/1.png")
                @speed = 30
                @damage = 20
        end
    end
end

def bullet_draw bullet
    bullet.sprite.draw_rot(bullet.x, bullet.y, ZOrder::LAY8, bullet.angle)
end

def bullet_move bullet
         bullet.x += bullet.speed * Math.cos(bullet.angle * Math::PI / 180)
         bullet.y += bullet.speed * Math.sin(bullet.angle * Math::PI / 180)
end

class Grenade
    attr_accessor :x, :y, :start_x, :start_y, :end_x, :end_y, :angle, :sprite, :sprite_s, :speed, :distance, :damage, :phase, :phase_timer, :layer
    def initialize(x, y, angle, end_x, end_y)
        @x = x
        @y = y
        @start_x = x
        @start_y = y
        @end_x = end_x
        @end_y = end_y
        @angle = angle
        @sprite = Gosu::Image.new("media/bullet/grenade/0.png")
        @sprite_s = Gosu::Image.new("media/bullet/grenade/s.png")
        @speed = 30
        @distance = Math.sqrt( ( (@end_x - @start_x) ** 2 ) + ( (@end_y - @start_y) ** 2 ) )
        @damage = 300
        @phase = 0
        @phase_timer = 0
        @layer = 6
    end
end

def grenade_move grenade
    grenade.sprite.draw_rot(grenade.x, grenade.y, grenade.layer, grenade.angle)
    grenade.sprite_s.draw_rot(grenade.x - 25, grenade.y + 25, ZOrder::LAY6, grenade.angle)
    case grenade.phase
        when 0
            grenade.x += grenade.speed * Math.cos(grenade.angle * Math::PI / 180)
            grenade.y += grenade.speed * Math.sin(grenade.angle * Math::PI / 180)
            if ( Math.sqrt( ( (grenade.x - grenade.start_x) ** 2 ) + ( (grenade.y - grenade.start_y) ** 2 ) ) ) >= grenade.distance
                grenade.phase = 1
            end
        when 1
            grenade.layer = 12
            grenade.phase_timer += 1
            case grenade.phase_timer
                when 0
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/0.png")
                when 1
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/1.png")
                    Gosu::Sample.new("media/audio/player/top/grenade/deto.wav").play(0.1, 1, false)
                when 2
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/2.png")
                when 3
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/3.png")
                when 4
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/4.png")
                when 5
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/5.png")
                when 6
                    grenade.sprite = Gosu::Image.new("media/bullet/grenade/6.png")
            end
    end
end

class Drop
    attr_accessor :x, :y, :angle, :type, :sprite, :despawn_timer
    def initialize (x, y)
        @x = x
        @y = y
        @angle = rand(-15..15)
        @despawn_timer = 500
        case rand (3)
            when 0
                @type = "health"
            when 1, 2
                case rand (4)
                    when 0, 1, 2 #top
                        case rand (6)
                            when 0
                                @type = "single"
                            when 1
                                @type = "double"
                            when 2
                                @type = "sniper"
                            when 3
                                @type = "shotgun"
                            when 4
                                @type = "minigun"
                            when 5
                                @type = "grenade"
                        end
                    when 3 #bottom
                        case rand (3)
                            when 0
                                @type = "normal"
                            when 1
                                @type = "speed"
                            when 2
                                @type = "armor"
                        end
                end
        end
        case @type
            when "health"
                direct = "media/drop/health.png"
            when "single"
                direct = "media/drop/top/single.png"
            when "double"
                direct = "media/drop/top/double.png"
            when "sniper"
                direct = "media/drop/top/sniper.png"
            when "shotgun"
                direct = "media/drop/top/shotgun.png"
            when "minigun"
                direct = "media/drop/top/minigun.png"
            when "grenade"
                direct = "media/drop/top/grenade.png"
            when "normal"
                direct = "media/drop/bottom/normal.png"
            when "speed"
                direct = "media/drop/bottom/speed.png"
            when "armor"
                direct = "media/drop/bottom/armor.png"
        end
        @sprite = Gosu::Image.new(direct)
    end
end

def drop_draw drop
    drop.sprite.draw_rot(drop.x, drop.y, ZOrder::LAY5, drop.angle)
end

def drop_effect drop
    case drop.type
        when "health"
            @player.player_current_health += 20
        when "normal", "speed", "armor"
            @player.player_bottom_type = drop.type
            @player.player_current_health = @player.player_max_health
        when "single", "double", "sniper", "shotgun", "minigun", "grenade"
            @player.player_top_type = drop.type
    end
end

def drop_despawn drop
    drop.despawn_timer -= 1
end

class Enemy_sentry
    attr_accessor   :x, :y, :health,
                    :desired_angle, :current_angle, :turn_spd,
                    :sprite_bottom, :sprite_top,
                    :sprite_bottom_shadow, :sprite_top_shadow,
                    :fire_timer, :fire_cooldown,
                    :phase, :death_ani, :phase_0_timer, :phase_0_size
    def initialize
        @x = rand(100..(WIN_WIDTH - 100))
        @y = rand(200..(WIN_HEIGHT - 200))
        @health = 100
        @current_angle = 0.01
        @turn_spd = 1.5
        @fire_timer = 0
        @fire_cooldown = 200
        @phase = 0
        @phase_0_timer = 40
        @phase_0_size = 5
        @death_ani = 0
        @sprite_top = Gosu::Image.new("media/enemy/sentry/phase_0.png")
        @sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s1.png")
        @sprite_bottom = Gosu::Image.new("media/enemy/sentry/bottom/sentry.png")
        @sprite_bottom_shadow = Gosu::Image.new("media/enemy/sentry/bottom/s_sentry.png")
    end
end

def Enemy_sentry_AI enemy
    enemy.desired_angle = _angle_(enemy.x, enemy.y, @player.player_x, @player.player_y)
    if enemy.health <= 0
        enemy.phase = 2
    end
    case enemy.phase
        when 0
            if enemy.phase_0_timer == 39
                Gosu::Sample.new("media/audio/enemy/sentry/open.wav").play(0.1, 1, false)
            end
            if enemy.phase_0_timer == 1
                Gosu::Sample.new("media/audio/enemy/sentry/land.wav").play(0.1, 1, false)
            end
            enemy.health = 100
            enemy.phase_0_size -= 0.1
            enemy.phase_0_timer -= 1
            enemy.current_angle = enemy.desired_angle
            enemy.sprite_top.draw_rot(enemy.x, enemy.y, ZOrder::LAY11, enemy.current_angle, 0.5, 0.5, enemy.phase_0_size, enemy.phase_0_size)
            if enemy.phase_0_timer <= 0
                enemy.phase = 1
            end
        when 1
            if (enemy.fire_cooldown <= 200) && (enemy.fire_cooldown > 0)
                enemy.fire_cooldown -= 1
            end
            if enemy.fire_cooldown <= 0
                enemy.fire_timer += 1
            end
            if enemy.fire_timer >= 60
                enemy.fire_cooldown = 200
                enemy.fire_timer = 0
            end
            case enemy.fire_timer
                when 0
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/1.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s1.png")
                when 5
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/3.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s3.png")
                when 10
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/5.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s5.png")
                    @enemy_bullet_on_screen.push(Bullet.new(enemy.x, enemy.y, enemy.current_angle, "enemy"))
                when 20
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/4.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s4.png")
                when 30
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/3.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s3.png")
                when 40
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/2.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s2.png")
                when 50
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/top/1.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/top/s1.png")
            end
            if enemy.desired_angle != enemy.current_angle
                if ((enemy.desired_angle) * (enemy.current_angle)) <0
                    if enemy.current_angle > 0
                        if enemy.current_angle < (enemy.desired_angle + 180)
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    else
                        if enemy.current_angle < (enemy.desired_angle - 180)
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    end
                else
                    if enemy.desired_angle.abs > enemy.current_angle.abs
                        if enemy.current_angle < 0
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    else
                        if enemy.current_angle > 0
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    end
                end
            end
            if enemy.current_angle < -180
                enemy.current_angle = 179.09
            end
            if enemy.current_angle > 180
                enemy.current_angle = -179.09
            end
            if (enemy.current_angle.abs - enemy.desired_angle.abs) < 1 && (enemy.current_angle.abs - enemy.desired_angle.abs) > -1
                enemy.turn_spd = 0.1
            else
                enemy.turn_spd = 2
            end
            enemy.sprite_bottom.draw_rot(enemy.x, enemy.y, ZOrder::LAY7)
            enemy.sprite_bottom_shadow.draw(enemy.x - 25 - (enemy.sprite_bottom.width / 2), enemy.y + 25 - (enemy.sprite_bottom.height / 2), ZOrder::LAY6)
            enemy.sprite_top.draw_rot(enemy.x, enemy.y, ZOrder::LAY9, enemy.current_angle)
            enemy.sprite_top_shadow.draw_rot(enemy.x - 25, enemy.y + 25, ZOrder::LAY6, enemy.current_angle)
        when 2
            if enemy.death_ani <= 30
                enemy.death_ani += 1
            end
            case enemy.death_ani
                when 0
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/death/1.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/death/s1.png")
                when 10
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/death/2.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/death/s2.png")
                when 20
                    enemy.sprite_top = Gosu::Image.new("media/enemy/sentry/death/3.png")
                    enemy.sprite_top_shadow = Gosu::Image.new("media/enemy/sentry/death/s3.png")
                when 29
                    case rand (10)
                        when 0, 1, 2, 3, 4, 5, 6, 7
                            @drop_on_screen.push(Drop.new(enemy.x, enemy.y))
                    end
                    @point += rand (10..20)
            end
            enemy.sprite_bottom.draw(enemy.x - (enemy.sprite_bottom.width / 2), enemy.y - (enemy.sprite_bottom.height / 2), ZOrder::LAY7)
            enemy.sprite_bottom_shadow.draw(enemy.x - 25 - (enemy.sprite_bottom.width / 2), enemy.y + 25 - (enemy.sprite_bottom.height / 2), ZOrder::LAY6)
            enemy.sprite_top.draw_rot(enemy.x, enemy.y, ZOrder::LAY9, enemy.current_angle)
            enemy.sprite_top_shadow.draw_rot(enemy.x - 25, enemy.y + 25, ZOrder::LAY6, enemy.current_angle)
    end
end

class Enemy_rammer
    attr_accessor   :x, :y, :damage, :health,
                    :current_angle, :desired_angle, :turn_spd,
                    :spd, :max_spd, :accel,
                    :sprite, :sprite_shadow,
                    :phase, :phase_timer, :check
    def initialize
        case rand(2)
            when 0
                @x = rand(-50..0)
            when 1
                @x = rand(WIN_WIDTH..(WIN_WIDTH + 50))
        end
        @y = rand(20..(WIN_HEIGHT - 20))
        @current_angle = _angle_(@x, @y, WIN_WIDTH / 2, WIN_HEIGHT / 2)
        @turn_spd = 3
        @spd = 21
        @max_spd = 20
        @accel = 0.15
        @damage = 60
        @health = 35
        @phase = 0
        @phase_timer = 0
        @sprite = Gosu::Image.new("media/enemy/rammer/1.png")
        @sprite_shadow = Gosu::Image.new("media/enemy/rammer/s.png")
        @check = true
    end
end

def Enemy_rammer_AI enemy
    if (enemy.phase != 0) && (enemy.health <= 0)
        enemy.phase = 3
    end
    case enemy.phase
        when 0
            enemy.health = 35
            enemy.phase_timer += 1
            if enemy.phase_timer < 8
                enemy.x += enemy.spd * Math.cos(enemy.current_angle * Math::PI / 180)
                enemy.y += enemy.spd * Math.sin(enemy.current_angle * Math::PI / 180)
            end
            if enemy.phase_timer >= 8
                enemy.phase_timer = 0
                enemy.phase = 1
            end
        when 1
            enemy.desired_angle = _angle_(enemy.x, enemy.y, @player.player_x, @player.player_y)
            if enemy.desired_angle != enemy.current_angle
                if ((enemy.desired_angle) * (enemy.current_angle)) <0
                    if enemy.current_angle > 0
                        if enemy.current_angle < (enemy.desired_angle + 180)
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    else
                        if enemy.current_angle < (enemy.desired_angle - 180)
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    end
                else
                    if enemy.desired_angle.abs > enemy.current_angle.abs
                        if enemy.current_angle < 0
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    else
                        if enemy.current_angle > 0
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    end
                end
            end
            if enemy.current_angle < -180
                enemy.current_angle = 179.09
            end
            if enemy.current_angle > 180
                enemy.current_angle = -179.09
            end
            if (enemy.current_angle.abs - enemy.desired_angle.abs) < 1 && (enemy.current_angle.abs - enemy.desired_angle.abs) > -1
                enemy.turn_spd = 0.1
            else
                enemy.turn_spd = 3
            end
            enemy.phase_timer += 1
            case enemy.phase_timer
                when 25..50
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/2.png")
                when 50..75
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/3.png")
            end
            if enemy.phase_timer == 76
                enemy.phase = 2
            end
        when 2
            if enemy.spd == 21
                enemy.spd = 0
            end
            if enemy.spd < enemy.max_spd
                enemy.spd += enemy.accel
            elsif enemy.spd >= enemy.max_spd
                enemy.spd = enemy.max_spd
            end
            enemy.turn_spd = 0.7
            enemy.desired_angle = _angle_(enemy.x, enemy.y, @player.player_x, @player.player_y)
            if enemy.desired_angle != enemy.current_angle
                if ((enemy.desired_angle) * (enemy.current_angle)) <0
                    if enemy.current_angle > 0
                        if enemy.current_angle < (enemy.desired_angle + 180)
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    else
                        if enemy.current_angle < (enemy.desired_angle - 180)
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    end
                else
                    if enemy.desired_angle.abs > enemy.current_angle.abs
                        if enemy.current_angle < 0
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    else
                        if enemy.current_angle > 0
                            enemy.current_angle -= enemy.turn_spd
                        else
                            enemy.current_angle += enemy.turn_spd
                        end
                    end
                end
            end
            if enemy.current_angle < -180
                enemy.current_angle = 179.09
            end
            if enemy.current_angle > 180
                enemy.current_angle = -179.09
            end
            if enemy.spd < enemy.max_spd
                enemy.spd += enemy.accel
            elsif enemy.spd >= enemy.max_spd
                enemy.spd = enemy.max_spd
            end
            enemy.x += enemy.spd * Math.cos(enemy.current_angle * Math::PI / 180)
            enemy.y += enemy.spd * Math.sin(enemy.current_angle * Math::PI / 180)
            enemy.phase_timer += 1
            if enemy.phase_timer > 10
                enemy.phase_timer = 0
            end
            case enemy.phase_timer
                when 0..5
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/4.png")
                when 5..10
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/5.png")
            end
            #if ( enemy.phase_timer % 2 ) == 1
                @trail_on_screen.push(Trail.new(enemy.x, enemy.y, enemy.current_angle + 45))
            #end
        when 3
            if enemy.check
                enemy.phase_timer = 0
                enemy.check = false
            end
            enemy.phase_timer += 1
            case enemy.phase_timer
                when 5
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/death/1.png")
                    enemy.sprite_shadow = Gosu::Image.new("media/enemy/rammer/death/s1.png")
                    if @player.player_current_health > 0
                        @point += rand (25..35)
                    end
                when 10
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/death/2.png")
                    enemy.sprite_shadow = Gosu::Image.new("media/enemy/rammer/death/s2.png")
                when 15
                    enemy.sprite = Gosu::Image.new("media/enemy/rammer/death/3.png")
                    enemy.sprite_shadow = Gosu::Image.new("media/enemy/rammer/death/s3.png")
            end
            if enemy.phase_timer == 15
                if (Gosu.distance(enemy.x, enemy.y, @player.player_x, @player.player_y) > 100)
                    case rand(5)
                        when 0, 1, 2
                            @drop_on_screen.push(Drop.new(enemy.x, enemy.y))
                    end
                end
            end
    end

    enemy.sprite.draw_rot(enemy.x, enemy.y, ZOrder::LAY7, enemy.current_angle + 45)
    enemy.sprite_shadow.draw_rot(enemy.x - 25, enemy.y + 25, ZOrder::LAY6, enemy.current_angle + 45)
end

class Trail
    attr_accessor :x, :y, :angle, :sprite, :size, :timer
    def initialize (x, y, angle)
        @x = x
        @y = y
        @angle = angle
        @timer = 20
        @size = 1
        @sprite = Gosu::Image.new("media/enemy/rammer/trail.png")
    end
end

def trail_spawn trail
    trail.sprite.draw_rot(trail.x, trail.y, ZOrder::LAY6, trail.angle, 0.5, 0.5, trail.size, trail.size)
    trail.timer -= 1
    trail.size -= 0.05
end

class Player_Trail
    attr_accessor :x, :y, :angle, :type, :sprite, :transparency
    def initialize (x, y, angle, type)
        @x = x
        @y = y
        @angle = angle
        @transparency = 100
        @type = type
        case @type
            when "normal"
                @sprite = Gosu::Image.new("media/player/player_bottom/normal/trail.png")
            when "speed"
                @sprite = Gosu::Image.new("media/player/player_bottom/speed/trail.png")
            when "armor"
                @sprite = Gosu::Image.new("media/player/player_bottom/armor/trail.png")
        end
    end
end

def player_trail_spawn trail
    trail.sprite.draw_rot(trail.x, trail.y, ZOrder::LAY1, trail.angle, 0.5, 0.5, 1, 1, Gosu::Color.argb(trail.transparency, 0, 0, 0))
    trail.transparency -= 1
end

def _angle_(x0, y0, x1, y1)
    return (180 / Math::PI * Math.atan2(y1 - y0, x1 - x0)).round(4)
end

class Game < Gosu::Window
  def initialize
    super(WIN_WIDTH, WIN_HEIGHT, false)
    self.caption = "War tank (full release V1.0)"
    @dev_mode = false
    @background = Gosu::Image.new("media/background.png")
    @player = Player.new
    @info_font = Gosu::Font.new(30)
    @player_fire_timer = 0
    @player_move_timer = 0
    @player_death = 0
    @slow = 0
    @enemy_sentry_spawn_rate = 0
    @enemy_rammer_spawn_rate = 0
    @drop_on_screen = Array.new
    @player_bullet_on_screen = Array.new
    @player_grenade_on_screen = Array.new
    @enemy_sentry_on_screen = Array.new
    @enemy_bullet_on_screen = Array.new
    @enemy_rammer_on_screen = Array.new
    @trail_on_screen = Array.new
    @player_trail_on_screen = Array.new
    @point = 0
    @Invincibility = false
    @minigun_warm_up_timer = 0
    @difficulty_timer = 0
    @difficulty = 1
    #display
    @hide = false
    @point_display = @point
    @health_bar_corner = Gosu::Image.new("media/display/health_bar_corner.png")
    @max_hp_display = @player.player_max_health
    @current_hp_display = @player.player_current_health
    @skull = Gosu::Image.new("media/player/death/skull.png")
    @cursor = Gosu::Image.new("media/player/cursor/single.png")
    @current_cursor = Gosu::Image.new("media/player/cursor/single.png")
    @w = Gosu::Image.new("media/display/keys/w.png")
    @a = Gosu::Image.new("media/display/keys/a.png")
    @s = Gosu::Image.new("media/display/keys/s.png")
    @d = Gosu::Image.new("media/display/keys/d.png")
    @mouse = Gosu::Image.new("media/display/keys/mouse.png")
    @tab = Gosu::Image.new("media/display/keys/tab.png")
    @h = Gosu::Image.new("media/display/keys/h.png")
    @gradient = 0
    @difficulty_display = "easy"
    #end_display
    @song = Gosu::Song.new("media/audio/song.wav")
    @song.volume = 0.3
    @song.play(true)
  end
  
  def update
    if @player.player_current_health > 0
        if @player.player_current_health > @player.player_max_health
            @player.player_current_health = @player.player_max_health
        end
        if button_down?(26) #w
            if @player.player_spd_up < @player.player_max_spd
                @player.player_spd_up += @player.player_accel
            elsif @player.player_spd_up >= @player.player_max_spd
                @player.player_spd_up = @player.player_max_spd
            end
        end
        if button_down?(22) #s
            if @player.player_spd_down < @player.player_max_spd
                @player.player_spd_down += @player.player_accel
            elsif @player.player_spd_down >= @player.player_max_spd
                @player.player_spd_down = @player.player_max_spd
            end
        end
        if !button_down?(26) && !button_down?(22)
            if button_down?(4) #a
                @player.player_bottom_current_turn -= @player.player_bottom_turn_spd
            end
            if button_down?(7) #d
                @player.player_bottom_current_turn += @player.player_bottom_turn_spd
            end
        end
        if button_down?(26)
            if button_down?(4) #a
                @player.player_bottom_current_turn -= @player.player_bottom_turn_spd
            end
            if button_down?(7) #d
                @player.player_bottom_current_turn += @player.player_bottom_turn_spd
            end
        end
        if button_down?(22) #s
            if button_down?(4) #a
                @player.player_bottom_current_turn += @player.player_bottom_turn_spd
            end
            if button_down?(7) #d
                @player.player_bottom_current_turn -= @player.player_bottom_turn_spd
            end
        end
        
        if !button_down?(26)
            if @player.player_spd_up > 0
                @player.player_spd_up -= @player.player_decel
            elsif @player.player_spd_up < 0
                @player.player_spd_up = 0
            end
        end
        if !button_down?(22)
            if @player.player_spd_down > 0
                @player.player_spd_down -= @player.player_decel
            elsif @player.player_spd_down < 0
                @player.player_spd_down = 0
            end
        end

        @player.player_x += @player.player_spd_up * Math.cos(@player.player_bottom_current_turn * Math::PI / 180)
        @player.player_y += @player.player_spd_up * Math.sin(@player.player_bottom_current_turn * Math::PI / 180)
        @player.player_x -= @player.player_spd_down * Math.cos(@player.player_bottom_current_turn * Math::PI / 180)
        @player.player_y -= @player.player_spd_down * Math.sin(@player.player_bottom_current_turn * Math::PI / 180)
        @player.player_top_angle = _angle_(@player.player_x, @player.player_y, mouse_x, mouse_y)


        if @player.player_top_angle != @player.player_top_current_turn
            if ((@player.player_top_angle) * (@player.player_top_current_turn)) <0
                if @player.player_top_current_turn > 0
                    if @player.player_top_current_turn < (@player.player_top_angle + 180)
                        @player.player_top_current_turn -= @player.player_top_turn_spd
                    else
                        @player.player_top_current_turn += @player.player_top_turn_spd
                    end
                else
                    if @player.player_top_current_turn < (@player.player_top_angle - 180)
                        @player.player_top_current_turn -= @player.player_top_turn_spd
                    else
                        @player.player_top_current_turn += @player.player_top_turn_spd
                    end
                end
            else
                if @player.player_top_angle.abs > @player.player_top_current_turn.abs
                    if @player.player_top_current_turn < 0
                        @player.player_top_current_turn -= @player.player_top_turn_spd
                    else
                        @player.player_top_current_turn += @player.player_top_turn_spd
                    end
                else
                    if @player.player_top_current_turn > 0
                        @player.player_top_current_turn -= @player.player_top_turn_spd
                    else
                        @player.player_top_current_turn += @player.player_top_turn_spd
                    end
                end
            end
        end
        if @player.player_top_current_turn < -180
            @player.player_top_current_turn = 179.09
        end
        if @player.player_top_current_turn > 180
            @player.player_top_current_turn = -179.09
        end

        if @player.player_x > ( WIN_WIDTH + ( @player.player_bottom.width / 10 ) )
            @player.player_x = - ( @player.player_bottom.width / 10 ) + 1
        elsif @player.player_x < - ( @player.player_bottom.width / 10 )
            @player.player_x = ( WIN_WIDTH + ( @player.player_bottom.width / 10 ) ) - 1
        end
        if @player.player_y > ( WIN_HEIGHT + ( @player.player_bottom.height / 10 ) )
            @player.player_y = - ( @player.player_bottom.height / 10 ) + 1
        elsif @player.player_y < - ( @player.player_bottom.height / 10 )
            @player.player_y = ( WIN_HEIGHT + ( @player.player_bottom.height / 10 ) ) - 1
        end
    end
    
    
    
  end
  
  def draw
    case @difficulty
        when 1
            @difficulty_display = "easy"
        when 2
            @difficulty_display = "medium"
        when 3
            @difficulty_display = "hard"
    end
    if @dev_mode
        if button_down?(30)
            @player.player_top_type = "single"
        end
        if button_down?(31)
            @player.player_top_type = "double"
        end
        if button_down?(32)
            @player.player_top_type = "sniper"
        end
        if button_down?(33)
            @player.player_top_type = "shotgun"
        end
        if button_down?(34)
            @player.player_top_type = "minigun"
        end
        if button_down?(35)
            @player.player_top_type = "grenade"
        end

        if button_down?(37)
            @player.player_bottom_type = "normal"
        end
        if button_down?(38)
            @player.player_bottom_type = "speed"
        end
        if button_down?(39)
            @player.player_bottom_type = "armor"
        end
        if button_down?(19)
            @drop_on_screen.push(Drop.new(rand(20..(WIN_WIDTH - 20)), rand(20..(WIN_HEIGHT - 20))))
        end
        if button_down?(12)
            @enemy_sentry_on_screen.push(Enemy_sentry.new)
        end
        if button_down?(18)
            @enemy_rammer_on_screen.push(Enemy_rammer.new)
        end
        if button_down?(15)
            @drop_on_screen.reject! do
                @drop_on_screen.size > 0
            end
            @enemy_sentry_on_screen.reject! do
                @enemy_sentry_on_screen.size > 0
            end
            @enemy_rammer_on_screen.reject! do
                @enemy_rammer_on_screen.size > 0
            end
            @enemy_bullet_on_screen.reject! do
                @enemy_bullet_on_screen.size > 0
            end
            @player_bullet_on_screen.reject! do
                @player_bullet_on_screen.size > 0
            end
            @player_grenade_on_screen.reject! do
                @player_grenade_on_screen.size > 0
            end
        end
    end
    
    @background.draw(0, 0, z = ZOrder::LAY0)
    @drop_on_screen.each { |drop| drop_draw drop}
    @drop_on_screen.each { |drop| drop_despawn drop}
    #drop
    @drop_on_screen.each do |drop|
        if ( drop.x > (@player.player_x - 50) ) && ( drop.x < (@player.player_x + 50) ) && ( drop.y > (@player.player_y - 50) ) && ( drop.y < (@player.player_y + 50) )
            drop_effect drop
        end
    end
    @drop_on_screen.reject! do |drop|
        ( ( drop.x > (@player.player_x - 50) ) && ( drop.x < (@player.player_x + 50) ) && ( drop.y > (@player.player_y - 50) ) && ( drop.y < (@player.player_y + 50) ) ) || ( drop.despawn_timer <= 0 )
    end
    #end drop
    #Enemy_sentry
    @enemy_sentry_spawn_rate += 1
    if @enemy_sentry_spawn_rate > 100
        @enemy_sentry_spawn_rate = 0
    end
    case @difficulty
        when 1
            sentry_num = 1
            rammer_num = 1
        when 2
            sentry_num = 2
            rammer_num = 2
        when 3
            sentry_num = 3
            rammer_num = 4
    end
    if (@enemy_sentry_spawn_rate == 100) && (@enemy_sentry_on_screen.size < sentry_num)
        @enemy_sentry_on_screen.push(Enemy_sentry.new)
    end
    @enemy_sentry_on_screen.each {|enemy| Enemy_sentry_AI enemy}
    
    @enemy_sentry_on_screen.reject! do |enemy|
        (enemy.health <= 0 ) && (enemy.phase == 2) && (enemy.death_ani >= 30)
    end
    #end Enemy_sentry
    #Enemy_rammer
    @enemy_rammer_spawn_rate += 1
    if @enemy_rammer_spawn_rate > 90
        @enemy_rammer_spawn_rate = 0
    end
    if (@enemy_rammer_spawn_rate == 90) && (@enemy_rammer_on_screen.size < rammer_num)
        @enemy_rammer_on_screen.push(Enemy_rammer.new)
    end
    @enemy_rammer_on_screen.each {|enemy| Enemy_rammer_AI enemy}
    @enemy_rammer_on_screen.reject! do |enemy|
        ( (enemy.health <= 0 ) && (enemy.phase == 3) && (enemy.phase_timer >= 30) ) || ( (enemy.phase == 2) && ((enemy.x > WIN_WIDTH) || (enemy.x < 0) || (enemy.y > WIN_HEIGHT) || (enemy.y < 0)))
    end
    @enemy_rammer_on_screen.each do |enemy|
        if ( (enemy.x > @player.player_x - 50) && (enemy.x < @player.player_x + 50) ) && ( (enemy.y > @player.player_y - 50) && (enemy.y < @player.player_y + 50) ) && (enemy.phase != 0)
            enemy.health -= 100
            if (enemy.phase != 0) && (enemy.phase_timer == 1)
                @player.player_current_health -= enemy.damage
            end
        end
    end
    @trail_on_screen.each { |trail| trail_spawn trail }
    @trail_on_screen.reject! do |trail|
        trail.timer <= 0
    end
    #end Enemy_rammer
    #player_bullet
    @player_bullet_on_screen.each { |bullet| bullet_draw bullet}
    @player_bullet_on_screen.each { |bullet| bullet_move bullet}
    @player_bullet_on_screen.reject! do |bullet|
        (bullet.x > WIN_WIDTH) || (bullet.x < 0) || (bullet.y > WIN_HEIGHT) || (bullet.y < 0)
    end
    @player_bullet_on_screen.each do |bullet|
        @enemy_rammer_on_screen.each do |enemy|
            if bullet.type == "sniper"
                if (bullet.x > enemy.x - 51) && (bullet.x < enemy.x + 51) && (bullet.y > enemy.y - 51) && (bullet.y < enemy.y + 51)
                enemy.health -= bullet.damage
                bullet.hit = true
            end
            end
            if (bullet.x > enemy.x - 35) && (bullet.x < enemy.x + 35) && (bullet.y > enemy.y - 35) && (bullet.y < enemy.y + 35)
                enemy.health -= bullet.damage
                bullet.hit = true
            end
        end
        @enemy_sentry_on_screen.each do |enemy|
            if (bullet.x > enemy.x - 60) && (bullet.x < enemy.x + 60) && (bullet.y > enemy.y - 60) && (bullet.y < enemy.y + 60)
                enemy.health -= bullet.damage
                bullet.hit = true
            end
        end     
    end
    @player_bullet_on_screen.reject! do |bullet|
        bullet.hit && ((bullet.type == "single") || (bullet.type == "double") || (bullet.type == "minigun") || (bullet.type == "shotgun") || (bullet.type == "minigun"))
    end
    @player_bullet_on_screen.reject! do |bullet|
        (bullet.type == "shotgun") && (Gosu.distance(@player.player_x, @player.player_y, bullet.x, bullet.y) > bullet.distance)
    end
    @player_grenade_on_screen.each { |grenade| grenade_move grenade }
    @player_grenade_on_screen.each do |grenade|
        @enemy_sentry_on_screen.each do |enemy|
            if ((enemy.x > (grenade.x - 200)) && (enemy.x < (grenade.x + 200)) && (enemy.y > (grenade.y - 200)) && (enemy.y < (grenade.x + 200))) && (grenade.phase == 1)
                enemy.health -= grenade.damage
            end
        end
        @enemy_rammer_on_screen.each do |enemy|
            if ((enemy.x > (grenade.x - 200)) && (enemy.x < (grenade.x + 200)) && (enemy.y > (grenade.y - 200)) && (enemy.y < (grenade.x + 200))) && (grenade.phase == 1)
                enemy.health -= grenade.damage
            end
        end
    end
    @player_grenade_on_screen.reject! do |grenade|
        (grenade.phase_timer > 6) || ((grenade.x > WIN_WIDTH) || (grenade.x < 0) || (grenade.y > WIN_HEIGHT) || (grenade.y < 0))
    end
    #end player_bullet
    #enemy_bullet
    @enemy_bullet_on_screen.each { |bullet| bullet_draw bullet}
    @enemy_bullet_on_screen.each { |bullet| bullet_move bullet}
    @enemy_bullet_on_screen.each do |bullet|
        if ( (bullet.x > @player.player_x - 50) && (bullet.x < @player.player_x + 50) ) && ( (bullet.y > @player.player_y - 50) && (bullet.y < @player.player_y + 50) )
            @player.player_current_health -= bullet.damage
        end
    end
    @enemy_bullet_on_screen.reject! do |bullet|
        (bullet.x > WIN_WIDTH) || (bullet.x < 0) || (bullet.y > WIN_HEIGHT) || (bullet.y < 0) || ( (bullet.x > @player.player_x - 50) && (bullet.x < @player.player_x + 50) ) && ( (bullet.y > @player.player_y - 50) && (bullet.y < @player.player_y + 50) )
    end
    #end enemy_bullet
    #player_trail
    @player_trail_on_screen.each { |trail| player_trail_spawn trail}
    @player_trail_on_screen.reject! do |trail|
        trail.transparency <= 0
    end
    #end_player_trail
    if @player.player_current_health > 0
        case @player.player_top_type
            when "single"
                if button_down?(256) || ( @player_fire_timer != 0 && @player_fire_timer < 60 )
                    @player_fire_timer += 1
                end
                if @player_fire_timer >= 60
                    @player_fire_timer = 0
                end
                case @player_fire_timer
                    when 0
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s1.png")
                    when 2
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s3.png")
                        Gosu::Sample.new("media/audio/player/top/single/fire.wav").play(0.3, 1, false)
                    when 4
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s5.png")
                        @player_bullet_on_screen.push(Bullet.new(@player.player_x, @player.player_y, @player.player_top_current_turn, @player.player_top_type))
                    when 6
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/7.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s7.png")
                    when 8
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/9.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s9.png")
                    when 10
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/10.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s10.png")
                    when 15
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/9.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s9.png")
                    when 20
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/8.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s8.png")
                    when 25
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/7.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s7.png")
                    when 30
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/6.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s6.png")
                    when 35
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s5.png")
                    when 40
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/4.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s4.png")
                    when 45
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s3.png")
                    when 50
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/2.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s2.png")
                    when 55
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s1.png")
                    when 60
                        @player.player_top = Gosu::Image.new("media/player/player_top/single/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/single/s1.png")
                end
                if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                    @player.player_top_turn_spd = 0.1
                else
                    @player.player_top_turn_spd = 2
                end
            when "double"
                if button_down?(256) || ( @player_fire_timer != 0 && @player_fire_timer != 60 && @player_fire_timer != 30)
                    @player_fire_timer += 1
                end
                if @player_fire_timer >= 60
                    @player_fire_timer = 0
                end
                case @player_fire_timer
                    when 0
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s1.png")
                    when 3
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s3.png")
                        Gosu::Sample.new("media/audio/player/top/double/fire.wav").play(0.3, 1, false)
                    when 6
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/6.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s6.png")
                        @player_bullet_on_screen.push(Bullet.new(@player.player_x, @player.player_y, @player.player_top_current_turn, @player.player_top_type))
                    when 10
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/9.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s9.png")
                    when 13
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/8.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s8.png")
                    when 15
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/7.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s7.png")
                    when 18
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/6.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s6.png")
                    when 20
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s5.png")
                    when 23
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/4.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s4.png")
                    when 25
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s3.png")
                    when 28
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/2.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s2.png")
                    when 30
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s1.png")
                    when 33
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/11.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s11.png")
                        Gosu::Sample.new("media/audio/player/top/double/fire.wav").play(0.3, 1, false)
                    when 36
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/14.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s14.png")
                    when 40
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/17.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s17.png")
                        @player_bullet_on_screen.push(Bullet.new(@player.player_x, @player.player_y, @player.player_top_current_turn, @player.player_top_type))
                    when 43
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/16.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s16.png")
                    when 45
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/15.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s15.png")
                    when 48
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/14.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s14.png")
                    when 50
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/13.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s13.png")
                    when 53
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/12.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s12.png")
                    when 55
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/11.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s11.png")
                    when 58
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/10.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s10.png")
                    when 60
                        @player.player_top = Gosu::Image.new("media/player/player_top/double/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/double/s1.png")
                end
                if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                    @player.player_top_turn_spd = 0.1
                else
                    @player.player_top_turn_spd = 2
                end
            when "sniper"
                if button_down?(256) || ( @player_fire_timer != 0 && @player_fire_timer < 153 )
                    @player_fire_timer += 1
                end
                if @player_fire_timer >= 153
                    @player_fire_timer = 0
                end
                case @player_fire_timer
                    when 0
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s1.png")
                    when 3
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s5.png")
                        Gosu::Sample.new("media/audio/player/top/sniper/fire.wav").play(0.3, 1, false)
                    when 5
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/9.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s9.png")
                        @player_bullet_on_screen.push(Bullet.new(@player.player_x, @player.player_y, @player.player_top_current_turn, @player.player_top_type))
                    when 7
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/13.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s13.png")
                    when 9
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/17.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s17.png")
                    when 18
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/16.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s16.png")
                    when 27
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/15.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s15.png")
                    when 36
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/14.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s14.png")
                    when 45
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/13.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s13.png")
                    when 54
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/12.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s12.png")
                    when 63
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/11.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s11.png")
                    when 72
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/10.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s10.png")
                    when 81
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/9.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s9.png")
                    when 90
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/8.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s8.png")
                    when 99
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/7.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s7.png")
                    when 108
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/6.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s6.png")
                    when 117
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s5.png")
                    when 126
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/4.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s4.png")
                    when 135
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s3.png")
                    when 144
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/2.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s2.png")
                        Gosu::Sample.new("media/audio/player/top/sniper/aim.wav").play(0.7, 1, false)
                    when 153
                        @player.player_top = Gosu::Image.new("media/player/player_top/sniper/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/sniper/s1.png")
                end
                if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                    @player.player_top_turn_spd = 0.1
                else
                    @player.player_top_turn_spd = 0.7
                end
            when "shotgun"
                if button_down?(256) || ( @player_fire_timer != 0 && @player_fire_timer < 36 )
                    @player_fire_timer += 1
                end
                if @player_fire_timer >= 36
                    @player_fire_timer = 0
                end
                case @player_fire_timer
                    when 0
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s1.png")
                    when 2
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s3.png")
                        Gosu::Sample.new("media/audio/player/top/shotgun/fire.wav").play(0.3, 1, false)
                    when 4
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s5.png")
                        20.times {@player_bullet_on_screen.push(Bullet.new(@player.player_x, @player.player_y, @player.player_top_current_turn + rand(-10..10), @player.player_top_type))}
                    when 6
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/7.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s7.png")
                    when 11
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/6.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s6.png")
                    when 16
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s5.png")
                    when 21
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/4.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s4.png")
                    when 26
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s3.png")
                    when 31
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/2.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s2.png")
                    when 36
                        @player.player_top = Gosu::Image.new("media/player/player_top/shotgun/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/shotgun/s1.png")
                end
                if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                    @player.player_top_turn_spd = 0.1
                else
                    @player.player_top_turn_spd = 2
                end
            when "minigun"
                if button_down?(256) && @minigun_warm_up_timer < 40
                    @minigun_warm_up_timer += 1
                    if @minigun_warm_up_timer == 1
                        Gosu::Sample.new("media/audio/player/top/minigun/start.wav").play(0.3, 0.9, false)
                    end
                end
                if !button_down?(256) && @minigun_warm_up_timer > 0
                    @minigun_warm_up_timer -= 1
                    if @minigun_warm_up_timer == 39
                        Gosu::Sample.new("media/audio/player/top/minigun/end.wav").play(0.3, 1, false)
                    end
                end
                case @minigun_warm_up_timer
                    when 0, 20
                        @player.player_top = Gosu::Image.new("media/player/player_top/minigun/1.png")
                    when 5, 25
                        @player.player_top = Gosu::Image.new("media/player/player_top/minigun/2.png")
                    when 10, 30
                        @player.player_top = Gosu::Image.new("media/player/player_top/minigun/3.png")
                    when 15, 35
                        @player.player_top = Gosu::Image.new("media/player/player_top/minigun/4.png")
                end
                if @minigun_warm_up_timer == 40
                    @player_fire_timer += 1
                    if @player_fire_timer > 3
                        @player_fire_timer = 0
                    end
                    case @player_fire_timer
                        when 0
                            @player.player_top = Gosu::Image.new("media/player/player_top/minigun/1.png")
                        when 1
                            @player.player_top = Gosu::Image.new("media/player/player_top/minigun/2.png")
                        when 2
                            @player.player_top = Gosu::Image.new("media/player/player_top/minigun/3.png")
                        when 3
                            @player.player_top = Gosu::Image.new("media/player/player_top/minigun/4.png")
                    end
                    @player_bullet_on_screen.push(Bullet.new(@player.player_x, @player.player_y, @player.player_top_current_turn + rand(-5..5), @player.player_top_type))
                    Gosu::Sample.new("media/audio/player/top/minigun/fire.wav").play(0.02, 0.7, false)
                end
                if button_down?(256)
                    if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                        @player.player_top_turn_spd = 0.1
                    else
                        @player.player_top_turn_spd = 0.7
                    end
                else
                    if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                        @player.player_top_turn_spd = 0.1
                    else
                        @player.player_top_turn_spd = 2
                    end
                end
            when "grenade"
                if button_down?(256) || ( @player_fire_timer != 0 && @player_fire_timer < 64 )
                    @player_fire_timer += 1
                end
                if @player_fire_timer > 63
                    @player_fire_timer = 0
                end
                case @player_fire_timer
                    when 0
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/1.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s1.png")
                    when 2
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/2.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s2.png")
                    when 4
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/3.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s3.png")
                    when 6
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/4.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s4.png")
                        @player_grenade_on_screen.push(Grenade.new(@player.player_x, @player.player_y, @player.player_top_current_turn, mouse_x, mouse_y))
                        Gosu::Sample.new("media/audio/player/top/grenade/fire.wav").play(0.3, 1, false)
                    when 8
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/5.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 13
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/6.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 18
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/7.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 23
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/8.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 28
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/9.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 33
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/10.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 38
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/11.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 43
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/12.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 48
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/13.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 53
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/14.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 58
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/15.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                    when 63
                        @player.player_top = Gosu::Image.new("media/player/player_top/grenade/16.png")
                        @player.player_shadow_top = Gosu::Image.new("media/player/player_top/grenade/s5.png")
                        Gosu::Sample.new("media/audio/player/top/grenade/reload.wav").play(0.3, 0.7, false)
                end
                if (@player.player_top_current_turn.abs - @player.player_top_angle.abs) < 1 && (@player.player_top_current_turn.abs - @player.player_top_angle.abs) > -1
                    @player.player_top_turn_spd = 0.1
                else
                    @player.player_top_turn_spd = 2
                end
        end
        case @player.player_bottom_type
            when "normal"
                if ( button_down?(26) || button_down?(4) || button_down?(22) || button_down?(7) )
                    @player_move_timer += 1
                    @slow = 50
                else
                    if @slow > 0
                        @player_move_timer += 0.5
                        @slow -= 1
                    end
                end
                if @player_move_timer > 30
                    @player_move_timer = 0
                end
                case @player_move_timer
                    when 3, 8, 13, 18, 23, 28
                        @player_trail_on_screen.push(Player_Trail.new(@player.player_x, @player.player_y, @player.player_bottom_current_turn, "normal"))
                end
                case @player_move_timer
                    when 0..5
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/normal/1.png")
                    when 5..10
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/normal/2.png")
                    when 10..15
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/normal/3.png")
                    when 15..20
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/normal/4.png")
                    when 20..25
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/normal/5.png")
                    when 25..30
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/normal/6.png")
                end
                @player.player_shadow_bottom = Gosu::Image.new("media/player/player_bottom/normal/s.png")
                @player.player_accel = 0.1
                @player.player_decel = 0.1
                @player.player_max_spd = 5
                @player.player_bottom_turn_spd = 1
                @player.player_max_health = 100
            when "speed"
                @player_trail_on_screen.push(Player_Trail.new(@player.player_x, @player.player_y, @player.player_bottom_current_turn, "speed"))
                if ( button_down?(26) || button_down?(4) || button_down?(22) || button_down?(7) )
                    @player_move_timer += 1
                    @slow = 10
                else
                    if @slow > 0
                        @player_move_timer += 0.5
                        @slow -= 1
                    end
                end
                if @player_move_timer >= 10
                    @player_move_timer = 0
                end
                case @player_move_timer
                    when 0..5
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/speed/1.png")
                    when 5..10
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/speed/2.png")
                end
                @player.player_shadow_bottom = Gosu::Image.new("media/player/player_bottom/speed/s.png")
                @player.player_accel = 0.3
                @player.player_decel = 0.5
                @player.player_max_spd = 15
                if (@player.player_bottom_current_turn.abs - @player.player_bottom_angle.abs) < 5 && (@player.player_bottom_current_turn.abs - @player.player_bottom_angle.abs) > -5
                    @player.player_bottom_turn_spd = 1
                else
                    @player.player_bottom_turn_spd = 5
                end
                @player.player_max_health = 75
            when "armor"
                @player_trail_on_screen.push(Player_Trail.new(@player.player_x, @player.player_y, @player.player_bottom_current_turn, "armor"))
                if ( button_down?(26) || button_down?(4) || button_down?(22) || button_down?(7) )
                    @player_move_timer += 1
                    @slow = 100
                else
                    if @slow > 0
                        @player_move_timer += 0.5
                        @slow -= 1
                    end
                end
                if @player_move_timer >= 80
                    @player_move_timer = 0
                end
                case @player_move_timer
                    when 0..10
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/1.png")
                    when 10..20
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/2.png")
                    when 20..30
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/3.png")
                    when 30..40
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/4.png")
                    when 40..50
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/5.png")
                    when 50..60
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/6.png")
                    when 60..70
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/7.png")
                    when 70..80
                        @player.player_bottom = Gosu::Image.new("media/player/player_bottom/armor/8.png")
                end
                @player.player_shadow_bottom = Gosu::Image.new("media/player/player_bottom/armor/s.png")
                @player.player_accel = 0.04
                @player.player_decel = 0.01
                @player.player_max_spd = 1.5
                @player.player_bottom_turn_spd = 0.3
                @player.player_max_health = 800
            end
        @player.player_top.draw_rot(@player.player_x, @player.player_y, ZOrder::LAY9, @player.player_top_current_turn)
        @player.player_shadow_top.draw_rot(@player.player_x - 25, @player.player_y + 25, ZOrder::LAY6, @player.player_top_current_turn)
        @player.player_bottom.draw_rot(@player.player_x, @player.player_y, ZOrder::LAY7, @player.player_bottom_current_turn)
        @player.player_shadow_bottom.draw_rot(@player.player_x - 25, @player.player_y + 25, ZOrder::LAY6, @player.player_bottom_current_turn)
    else
        @player_death += 1
        case @player_death
            when 0..5
                Gosu::Image.new("media/player/death/1.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 5..10
                Gosu::Image.new("media/player/death/2.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 10..20
                Gosu::Image.new("media/player/death/3.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 20..30
                Gosu::Image.new("media/player/death/4.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 30..40
                Gosu::Image.new("media/player/death/5.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 40..50
                Gosu::Image.new("media/player/death/6.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 50..60
                Gosu::Image.new("media/player/death/7.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
            when 60..70
                Gosu::Image.new("media/player/death/8.png").draw_rot(@player.player_x, @player.player_y, z = ZOrder::LAY9, @player.player_top_current_turn)
        end
    end
    if !@dev_mode
        case @difficulty_timer
        when 0..9000
            @difficulty = 1
        when 9000..18000
            @difficulty = 2
        end
        if @difficulty_timer > 18000
            @difficulty = 3
        end
        if @difficulty_timer < 18001
            @difficulty_timer += 1
        end
        def needs_cursor?; false; end
        @Invincibility = false
        if @max_hp_display > @player.player_max_health
            if (@max_hp_display - @player.player_max_health) > 15
                @max_hp_display -= 10
            else
                @max_hp_display -= 1
            end
        elsif @max_hp_display < @player.player_max_health
            if (@player.player_max_health - @max_hp_display) > 15
                @max_hp_display += 10
            else
                @max_hp_display += 1
            end
        end
        if @current_hp_display < 0
            @current_hp_display = 0
        end
        if @current_hp_display > @player.player_current_health
            if (@current_hp_display - @player.player_current_health) > 15
                @current_hp_display -= 10
            else
                @current_hp_display -= 1
            end
        elsif @current_hp_display < @player.player_current_health
            if (@player.player_current_health - @current_hp_display) > 15
                @current_hp_display += 10
            else
                @current_hp_display += 1
            end
        end
        if @point_display < @point
            @point_display += 1
        end
        @health_bar_corner.draw_rot((WIN_WIDTH / 2) - @max_hp_display, WIN_HEIGHT - 100, ZOrder::LAY3, 0)
        @health_bar_corner.draw_rot((WIN_WIDTH / 2) + @max_hp_display, WIN_HEIGHT - 100, ZOrder::LAY3, 180)
        Gosu.draw_rect((WIN_WIDTH / 2) - @max_hp_display, WIN_HEIGHT - 150, ( @max_hp_display * 2 ), 5, Gosu::Color::BLACK, ZOrder::LAY3, mode = :default)
        Gosu.draw_rect((WIN_WIDTH / 2) - @max_hp_display, WIN_HEIGHT - 55, ( @max_hp_display * 2 ), 5, Gosu::Color::BLACK, ZOrder::LAY3, mode = :default)
        Gosu.draw_rect((WIN_WIDTH / 2) - @current_hp_display, WIN_HEIGHT - 145, ( @current_hp_display * 2 ), 95, 0xff_4ecc50, ZOrder::LAY2, mode = :default)
        Gosu.draw_rect((WIN_WIDTH / 2) - @max_hp_display, WIN_HEIGHT - 145, ( @max_hp_display * 2 ), 95, 0xff_999999, ZOrder::LAY1, mode = :default)
        @info_font.draw_text_rel("Score: #{@point_display}", WIN_WIDTH / 2, 50, ZOrder::LAY11, 0.5, 0.5, 2, 2, Gosu::Color::BLACK)
        @info_font.draw_text_rel("Score: #{@point_display}", (WIN_WIDTH / 2) - 10, 60, ZOrder::LAY10, 0.5, 0.5, 2, 2, 0x20_000000)
        if @player.player_current_health > 0
            @info_font.draw_text_rel("#{@current_hp_display}/#{@max_hp_display}", (WIN_WIDTH / 2), WIN_HEIGHT - 95, ZOrder::LAY3, 0.5, 0.5, 1.2, 1.2, Gosu::Color::WHITE)
        else
            @skull.draw_rot((WIN_WIDTH / 2), WIN_HEIGHT - 95, ZOrder::LAY3, 0)
        end
        case @player.player_top_type
            when "single"
                @cursor = Gosu::Image.new("media/player/cursor/single.png")
                @cursor.draw_rot(mouse_x, mouse_y, ZOrder::LAY11, 0)
            when "double"
                @cursor = Gosu::Image.new("media/player/cursor/double.png")
                @cursor.draw_rot(mouse_x, mouse_y, ZOrder::LAY11, 0)
            when "sniper"
                @cursor = Gosu::Image.new("media/player/cursor/sniper/sniper.png")
                @current_cursor = Gosu::Image.new("media/player/cursor/sniper/current.png")
                @cursor.draw_rot(mouse_x, mouse_y, ZOrder::LAY11, 0)
                @current_cursor.draw_rot( @player.player_x + ( ( Math.cos( @player.player_top_current_turn * Math::PI / 180 ) ) * Math.sqrt( ( (mouse_x - @player.player_x) ** 2 ) + ( (mouse_y - @player.player_y) ** 2 ) ) ),  @player.player_y + ( ( Math.sin( @player.player_top_current_turn * Math::PI / 180 ) ) * Math.sqrt( ( (mouse_x - @player.player_x) ** 2 ) + ( (mouse_y - @player.player_y) ** 2 ) ) ), ZOrder::LAY11, @player.player_top_current_turn)
            when "shotgun"
                @cursor = Gosu::Image.new("media/player/cursor/shotgun/shotgun.png")
                @cursor.draw_rot(mouse_x, mouse_y, ZOrder::LAY11, 0)
                @current_cursor = Gosu::Image.new("media/player/cursor/shotgun/current.png")
                @current_cursor.draw_rot( @player.player_x + ( ( Math.cos( @player.player_top_current_turn * Math::PI / 180 ) ) * 700 ),  @player.player_y + ( ( Math.sin( @player.player_top_current_turn * Math::PI / 180 ) ) * 700 ), ZOrder::LAY11, @player.player_top_current_turn)
            when "minigun"
                @current_cursor = Gosu::Image.new("media/player/cursor/minigun/current.png")
                distance_x = @player.player_x + ( ( Math.cos( @player.player_top_current_turn * Math::PI / 180 ) ) * Math.sqrt( ( (mouse_x - @player.player_x) ** 2 ) + ( (mouse_y - @player.player_y) ** 2 ) ) )
                distance_y = @player.player_y + ( ( Math.sin( @player.player_top_current_turn * Math::PI / 180 ) ) * Math.sqrt( ( (mouse_x - @player.player_x) ** 2 ) + ( (mouse_y - @player.player_y) ** 2 ) ) )
                @current_cursor.draw_rot( distance_x,  distance_y, ZOrder::LAY11, @player.player_top_current_turn, 0.5, 0.5, 0.0005 * Gosu.distance(@player.player_x, @player.player_y, distance_x, distance_y), 0.0005 * Gosu.distance(@player.player_x, @player.player_y, distance_x, distance_y))
                Gosu.draw_line(distance_x, distance_y, Gosu::Color::RED, mouse_x, mouse_y, Gosu::Color::RED, ZOrder::LAY11, mode = :default)
                @cursor = Gosu::Image.new("media/player/cursor/minigun/minigun.png")
                @cursor.draw_rot(mouse_x, mouse_y, ZOrder::LAY11, 0)
            when "grenade"
                @cursor = Gosu::Image.new("media/player/cursor/grenade/grenade.png")
                @current_cursor = Gosu::Image.new("media/player/cursor/grenade/current.png")
                @cursor.draw_rot(mouse_x, mouse_y, ZOrder::LAY11, 0)
                @current_cursor.draw_rot( @player.player_x + ( ( Math.cos( @player.player_top_current_turn * Math::PI / 180 ) ) * Math.sqrt( ( (mouse_x - @player.player_x) ** 2 ) + ( (mouse_y - @player.player_y) ** 2 ) ) ),  @player.player_y + ( ( Math.sin( @player.player_top_current_turn * Math::PI / 180 ) ) * Math.sqrt( ( (mouse_x - @player.player_x) ** 2 ) + ( (mouse_y - @player.player_y) ** 2 ) ) ), ZOrder::LAY11, @player.player_top_current_turn)
        end
        Gosu.draw_rect(WIN_WIDTH - 120, (WIN_HEIGHT / 5 * 2) - 5, 75, (WIN_HEIGHT / 5 * 2) + 10, Gosu::Color::BLACK, ZOrder::LAY1)
        Gosu.draw_quad(WIN_WIDTH - 115, WIN_HEIGHT / 5 * 2, Gosu::Color::GREEN, WIN_WIDTH - 50, WIN_HEIGHT / 5 * 2, Gosu::Color::GREEN, WIN_WIDTH - 50, WIN_HEIGHT / 5 * 4, Gosu::Color::RED, WIN_WIDTH - 115, WIN_HEIGHT / 5 * 4, Gosu::Color::RED, ZOrder::LAY2)
        Gosu::Image.new("media/difficulty/easy.png").draw_rot(WIN_WIDTH - 82.5, (WIN_HEIGHT / 5 * 2) + 40, ZOrder::LAY3, 0) #easy
        Gosu::Image.new("media/difficulty/medium.png").draw_rot(WIN_WIDTH - 82.5, (WIN_HEIGHT / 5 * 3), ZOrder::LAY3, 0) #medium
        Gosu::Image.new("media/difficulty/hard.png").draw_rot(WIN_WIDTH - 82.5, (WIN_HEIGHT / 5 * 4) - 40, ZOrder::LAY3, 0) #hard
        Gosu::Image.new("media/difficulty/pointer.png").draw_rot(WIN_WIDTH - 130, (WIN_HEIGHT / 5 * 2) + (@difficulty_timer * WIN_HEIGHT / ( 5 * 9000)), ZOrder::LAY4, 0) #pointer
        if !@hide
            @w.draw_rot(100, 50, ZOrder::LAY1, 0)
            @a.draw_rot(30, 120, ZOrder::LAY1, 0)
            @s.draw_rot(100, 120, ZOrder::LAY1, 0)
            @d.draw_rot(170, 120, ZOrder::LAY1, 0)
            @mouse.draw_rot(310, 85, ZOrder::LAY1, 0)
            @tab.draw_rot(WIN_WIDTH - 100, 85, ZOrder::LAY1, 0)
            @h.draw_rot(WIN_WIDTH - 100, 285, ZOrder::LAY1, 0)
            @info_font.draw_text_rel("Movement", 100, 190, ZOrder::LAY1, 0.5, 0.5, 1.5, 1.5, Gosu::Color::BLACK)
            @info_font.draw_text_rel("Shoot", 310, 190, ZOrder::LAY1, 0.5, 0.5, 1.5, 1.5, Gosu::Color::BLACK)
            @info_font.draw_text_rel("Dev mode", WIN_WIDTH - 100, 160, ZOrder::LAY1, 0.5, 0.5, 1.5, 1.5, Gosu::Color::BLACK)
            @info_font.draw_text_rel("Hide", WIN_WIDTH - 100, 345, ZOrder::LAY1, 0.5, 0.5, 1.5, 1.5, Gosu::Color::BLACK)
        end
        if @player.player_current_health < 0#
            @song.pause
            if @gradient < 250
                @gradient += 2
            end
            if @gradient == 4
                Gosu::Sample.new("media/audio/player/death/death.wav").play(1, 1, false)
            end
            Gosu.draw_rect(0, 0, WIN_WIDTH, WIN_HEIGHT, Gosu::Color.argb(@gradient, 0, 0, 0), ZOrder::LAY11)
            @info_font.draw_text("U DED!!", WIN_WIDTH / 100 * 38, WIN_HEIGHT / 7, ZOrder::LAY12, 5.0, 5.0, Gosu::Color.argb(@gradient, 255, 0, 0))
            if @gradient > 249
                @info_font.draw_text("Score: #{@point}", WIN_WIDTH / 100 * 45, WIN_HEIGHT / 7 * 2, ZOrder::LAY12, 2.0, 2.0, Gosu::Color.argb(@gradient, 50, 50, 255))
                Gosu::Image.new("media/display/keys/enter.png").draw_rot(WIN_WIDTH / 2, WIN_HEIGHT / 2, ZOrder::LAY12, 0)
            end
        end
    else #dev mode
        def needs_cursor?; true; end
        case @player.player_top_angle
            when -90..90
                rotate = @player.player_top_angle
            else
                rotate = @player.player_top_angle + 180
        end
        if @Invincibility
            @player.player_current_health = @player.player_max_health
        end
        Gosu.rotate(rotate, mouse_x - ((mouse_x - @player.player_x) / 2), mouse_y - ((mouse_y - @player.player_y) / 2)) {@info_font.draw_text("angle: #{@player.player_top_angle.round(2)}", mouse_x - ((mouse_x - @player.player_x) / 2), mouse_y - ((mouse_y - @player.player_y) / 2), ZOrder::LAY10, 1.0, 1.0, Gosu::Color::BLACK)}
        Gosu.draw_line(@player.player_x, @player.player_y, Gosu::Color::BLACK, mouse_x, mouse_y, Gosu::Color::BLACK, ZOrder::LAY10, mode = :default) #grid
        Gosu.draw_line(@player.player_x, 0, Gosu::Color::BLACK, @player.player_x, WIN_HEIGHT, Gosu::Color::BLACK, ZOrder::LAY10, mode = :default) #grid
        Gosu.draw_line(0, @player.player_y, Gosu::Color::BLACK, WIN_WIDTH, @player.player_y, Gosu::Color::BLACK, ZOrder::LAY10, mode = :default) #grid
        @info_font.draw_text("x: #{@player.player_x.round(4)}", @player.player_x / 2, @player.player_y + 5, ZOrder::LAY10, 1.0, 1.0, Gosu::Color::BLACK) #grid
        @info_font.draw_text("y: #{@player.player_y.round(4)}", @player.player_x + 5, @player.player_y / 2, ZOrder::LAY10, 1.0, 1.0, Gosu::Color::BLACK) #grid
        @info_font.draw_text("point: #{@point}", 5, 0, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("max_hp: #{@player.player_max_health}", 5, 30, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("health: #{@player.player_current_health}", 5, 60, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("top: #{@player.player_top_type}", 5, 90, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("bottom: #{@player.player_bottom_type}", 5, 120, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("spd: #{(@player.player_spd_up - @player.player_spd_down).round(2)}", 5, 150, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("accel: #{@player.player_accel}", 5, 180, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("decel: #{@player.player_decel}", 5, 210, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("player bullet: #{@player_bullet_on_screen.size} + grenade: #{@player_grenade_on_screen.size}", 5, 240, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("enemy bullet: #{@enemy_bullet_on_screen.size}", 5, 270, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("sentry num: #{@enemy_sentry_on_screen.size}", 5, 300, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("rammer num: #{@enemy_rammer_on_screen.size}", 5, 330, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("drop num: #{@drop_on_screen.size}", 5, 360, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("Invincibility: #{@Invincibility}", 5, 390, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("enemy_trail_num: #{@trail_on_screen.size}", 5, 420, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("player_trail_num: #{@player_trail_on_screen.size}", 5, 450, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("1..6 : Change top", 5, 480, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("8..0 : Change bottom", 5, 510, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("I : spawn sentry", 5, 540, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("O : spawn rammer", 5, 570, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("P : spawn drop", 5, 600, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("L : delete all", 5, 630, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("up + down: change difficulty", 5, 660, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
        @info_font.draw_text("current difficulty: #{@difficulty_display}", 5, 690, ZOrder::LAY10, 0.5, 0.5, Gosu::Color::BLACK)
    end
    
  end
  def button_down(id)
    puts id
    if button_down?(43)
        if @dev_mode
            @dev_mode = false
        else
            @dev_mode = true
        end
    end
    if button_down?(53) # `
        if @Invincibility
            @Invincibility = false
        else
            @Invincibility = true
        end
    end
    if button_down?(11)
        if @hide
            @hide = false
        else
            @hide = true
        end
    end
    if id == Gosu::KB_ESCAPE
      close
    end
    if button_down?(40)
        close
        Game.new.show
    end
    if button_down?(82) #up
        puts "hi"
        case @difficulty
            when 2
                @difficulty = 1
            when 3
                @difficulty = 2
        end
    end
    if button_down?(81) #down
        puts "hello"
        case @difficulty
            when 1
                puts "yo"
                @difficulty = 2
            when 2
                @difficulty = 3
        end
    end
  end
end

Game.new.show
