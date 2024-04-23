package main

import "vendor:raylib"
import "core:fmt"

Player :: struct {
    pos: raylib.Vector2,
    size: raylib.Vector2,
    color: raylib.Color,
    speed: raylib.Vector2,
    can_jump: bool
}

init_player :: proc() -> Player {
    position: raylib.Vector2 = {400, 225}
    size: raylib.Vector2 = {20, 20}
    color: raylib.Color = raylib.GREEN
    speed: raylib.Vector2 = {5, 0}

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
    ladders: [dynamic]Ladders
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
        init_ladders()
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
    pos: raylib.Vector2,
    size: raylib.Vector2,
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

    if raylib.IsKeyDown(raylib.KeyboardKey.D) {
        player.pos.x += player.speed.x
    }
    if raylib.IsKeyDown(raylib.KeyboardKey.A) {
        player.pos.x -= player.speed.x
    }
    if raylib.IsKeyPressed(raylib.KeyboardKey.W) && player.can_jump {
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
            player.speed.y = 10
            player.can_jump = true
        }
    }
    if player.pos.y >= f32(env.window_height) - player.size.y {
        player.pos.y = f32(env.window_height) - player.size.y
    }
    if player.speed.y > 0 {
        player.speed.y -= f32(env.gravity.time)
    } else {
        player.speed.y = 0
    }
    
}

Platform :: struct {
    pos: raylib.Vector2,
    size: raylib.Vector2,
    color: raylib.Color
}


init_platforms :: proc() -> [dynamic]Platform {
        return {
            {{200, 100}, {900, 15}, raylib.BROWN},
            {{450, 200}, {900, 15}, raylib.BROWN},
            {{200, 300}, {900, 15}, raylib.BROWN},
            {{450, 400}, {900, 15}, raylib.BROWN},
            {{200, 500}, {900, 15}, raylib.BROWN},
            {{450, 600}, {900, 15}, raylib.BROWN},
            {{200, 700}, {900, 15}, raylib.BROWN},
            {{450, 800}, {900, 15}, raylib.BROWN},
        }

}

Ladders :: struct {
    pos: raylib.Vector2,
    size: raylib.Vector2,
    color: raylib.Color
}

init_ladders :: proc() -> [dynamic]Ladders {
    return {
        {{500, 815}, {25, 85}, raylib.ORANGE}
    }
}
