extends Node2D

signal time_tick(hour: int, minute: int)

@export var canvas_modulate: CanvasModulate
@export var day_night_gradient: GradientTexture1D
@export var game_speed: float = 1.0 # 1.0 = real time (too slow), try 60.0 or more

var time: float = 0.0
const MINUTES_PER_DAY = 1440.0
const MINUTES_PER_HOUR = 60.0
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

func _ready() -> void:
    # Default fast speed for testing: 1 game day = 24 seconds roughly if speed is high enough
    # Let's say we want 1 game day = 1 real minute -> speed = 1440
    # Let's start with Noon (12:00)
    time = 12 * MINUTES_PER_HOUR 

func _process(delta: float) -> void:
    time += delta * game_speed
    if time >= MINUTES_PER_DAY:
        time = 0.0
    
    _update_visuals()
    _emit_time_signal()

func _update_visuals() -> void:
    # 0.0 to 1.0 represents the full day cycle in the gradient
    # If the gradient goes from 0=Midnight to 1=Midnight
    var value = time / MINUTES_PER_DAY
    if canvas_modulate and day_night_gradient:
        canvas_modulate.color = day_night_gradient.gradient.sample(value)

func _emit_time_signal() -> void:
    var hour = int(time / MINUTES_PER_HOUR)
    var minute = int(fmod(time, MINUTES_PER_HOUR))
    time_tick.emit(hour, minute)
