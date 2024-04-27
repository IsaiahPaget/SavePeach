package main

import rl "vendor:raylib"
import "core:fmt"

Player :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color,
    speed: rl.Vector2,
    can_jump: bool
}

init_player :: proc() -> Player {
    position: rl.Vector2 = {100, 850}
    size: rl.Vector2 = {20, 20}
    color: rl.Color = rl.GREEN
    speed: rl.Vector2 = {5, 0}

    player := Player{
        position, 
        size,
        color,
        speed,
        true
    }
    return player
}

Env :: struct {
    gravity: Gravity,
    window_width: i32,
    window_height: i32,
    name: cstring,
    fps: i32,
    platforms: [dynamic]Platform,
    ladders: [dynamic]Ladder,
    barrels: [dynamic]Barrel
}

init_env :: proc() -> Env {
    screenWidth :i32 = 1600;
    screenHeight :i32 = 900;
    env := Env {
        init_gravity(),
        screenWidth,
        screenHeight,
        "game",
        60,
        init_platforms(),
        init_ladders(),
        nil
    }
    return env
}

Gravity :: struct {
    constant: f32,
    time: int,
}

init_gravity :: proc() -> Gravity {
    return Gravity{5, 1}
}

Object :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
}

objects_are_colliding :: proc(obj: Object, in_obj: Object) -> bool {
    are_colliding := false
    if obj.pos.x >= in_obj.pos.x - obj.size.x &&
        obj.pos.x <= in_obj.pos.x + in_obj.size.x &&
        obj.pos.y >= in_obj.pos.y - obj.size.y &&
        obj.pos.y <= in_obj.pos.y + in_obj.size.y {

        are_colliding = true 
    }
    return are_colliding
}

player_move :: proc(player: ^Player, env: Env) {

    if rl.IsKeyDown(rl.KeyboardKey.D) {
        player.pos.x += player.speed.x
    }
    if rl.IsKeyDown(rl.KeyboardKey.A) {
        player.pos.x -= player.speed.x
    }
    if rl.IsKeyPressed(rl.KeyboardKey.W) && player.can_jump {
        player.speed.y = 15
        player.can_jump = false
    }

    player.pos.y += env.gravity.constant - player.speed.y
    for platform in env.platforms {
        if objects_are_colliding({player.pos, player.size}, {platform.pos, platform.size}) {
            player.pos.y = platform.pos.y - player.size.y
            player.can_jump = true
        }
    }
    for ladder in env.ladders {
        if objects_are_colliding({player.pos, player.size}, {ladder.pos, ladder.size}) {
            player.speed.y = 7
            player.can_jump = true
        }
    }
    if player.pos.y >= f32(env.window_height) - player.size.y {
        player.pos.y = f32(env.window_height) - player.size.y
        player.can_jump = true
    }
    if player.speed.y > 0 {
        player.speed.y -= f32(env.gravity.time)
    } else {
        player.speed.y = 0
    }
    
}

Platform :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color
}


init_platforms :: proc() -> [dynamic]Platform {
        return {
            {{200, 100}, {900, 15}, rl.BROWN},
            {{450, 200}, {900, 15}, rl.BROWN},
            {{200, 300}, {900, 15}, rl.BROWN},
            {{450, 400}, {900, 15}, rl.BROWN},
            {{200, 500}, {900, 15}, rl.BROWN},
            {{450, 600}, {900, 15}, rl.BROWN},
            {{200, 700}, {900, 15}, rl.BROWN},
            {{450, 800}, {900, 15}, rl.BROWN},
        }

}

Ladder :: struct {
    pos: rl.Vector2,
    size: rl.Vector2,
    color: rl.Color
}

init_ladders :: proc() -> [dynamic]Ladder {
    return {
        {{500, 815}, {25, 85}, rl.ORANGE},
        {{1000, 715}, {25, 85}, rl.ORANGE},
        {{600, 615}, {25, 85}, rl.ORANGE},
        {{900, 515}, {25, 85}, rl.ORANGE},
        {{500, 415}, {25, 85}, rl.ORANGE},
        {{1000, 315}, {25, 85}, rl.ORANGE},
        {{500, 215}, {25, 85}, rl.ORANGE},
        {{900, 115}, {25, 85}, rl.ORANGE},
    }
}

Barrel :: struct {
    pos: rl.Vector2,
    radius: f32,
    color: rl.Color,
    speed: rl.Vector2
}


init_barrel :: proc() -> Barrel {
    return {{200,50}, 10, rl.RED, {0, 0}}
    
}

barrel_move :: proc(barrel: ^Barrel, env: Env) {
    if objects_are_colliding({barrel.pos, {barrel.radius, barrel.radius}}, {{0,0},{350, f32(env.window_height) - barrel.radius * 2}}) {
        barrel.speed.x = 3
    } else if objects_are_colliding({barrel.pos, {barrel.radius, barrel.radius}}, {{f32(env.window_width) - 350,0},{350, f32(env.window_height)}}) {
        barrel.speed.x = -3
    } 
    barrel.pos.x += barrel.speed.x
    barrel.pos.y += env.gravity.constant - barrel.speed.y
    for platform in env.platforms {
        if objects_are_colliding({barrel.pos, {barrel.radius, barrel.radius}}, {platform.pos, platform.size}) {
            barrel.pos.y = platform.pos.y - barrel.radius
        }
    }
    if barrel.pos.y >= f32(env.window_height) - barrel.radius {
        barrel.pos.y = f32(env.window_height) - barrel.radius
    }
    if barrel.speed.y > 0 {
        barrel.speed.y -= f32(env.gravity.time)
    } else {
        barrel.speed.y = 0
    }
    if barrel.pos.x <= 0 - barrel.radius {
        barrel.pos.y = -barrel.radius    
        barrel.pos.x = 50    
    }
}
