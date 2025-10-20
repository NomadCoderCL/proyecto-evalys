# Prototipo EVALYS - Jugador (Godot 4)

Este prototipo contiene un jugador que se mueve en 8 direcciones, puede recolectar recursos con clic izquierdo, tiene una barra de energía y un inventario básico.

Archivos creados:
- `scenes/Player.tscn` - escena del jugador
- `scenes/Resource.tscn` - escena de recurso
- `scenes/Main.tscn` - escena principal
- `scenes/HUD.tscn` - HUD con barra de energía e inventario
- `scripts/player.gd`, `scripts/resource.gd`, `scripts/hud.gd`, `scripts/main.gd`

Cómo probar:
1. Abre Godot 4 y carga este proyecto (la carpeta donde está `project.godot`).
2. Abre la escena `res://scenes/Main.tscn` y ejecútala.
3. Mueve con las teclas configuradas (`ui_up`, `ui_down`, `ui_left`, `ui_right`). Clic izquierdo sobre un recurso cercano para recolectarlo (consume 5 energía).

Notas rápidas:
- Acciones `ui_up`, `ui_down`, `ui_left`, `ui_right` están en InputMap por defecto en Godot.
- Puedes ajustar `speed` y `energy_max` desde el inspector seleccionando el `Player`.

Nuevas funciones añadidas en esta iteración:

- Interacción por proximidad: el jugador solo puede recolectar si está a menos de `collect_range` (48 px por defecto). Si haces clic fuera del rango aparece una notificación "Demasiado lejos".
- Regeneración de energía: la energía se regenera pasivamente a `energy_regen_per_second` (4 por segundo por defecto). Si la energía es 0 no se puede recolectar hasta recuperar al menos `collect_cost`.
- Fruta: `scenes/Fruit.tscn` es un recurso que restaura energía al recolectarlo (30 unidades por defecto).
- HUD mejorado: ahora hay un grid de inventario con iconos en `res://assets/` y notificaciones temporales cuando recolectas o cambias energía. También se reproduce un sonido corto al recolectar.
- Assets placeholder: `res://assets/` contiene iconos simples y `collect_beep.wav`.

Cómo probar cada nueva función:

1. Proximidad: haz clic lejos de un recurso; deberías ver la notificación "Demasiado lejos".
2. Regeneración: agota tu energía haciendo varias recolecciones y espera unos segundos para ver cómo sube la barra de energía.
3. Fruta: haz clic sobre la fruta (ícono diferente) estando cerca; restaurará energía y mostrará una notificación.
4. HUD y notificaciones: observa el grid de inventario en pantalla cuando recolectas madera u otros recursos; aparece una notificación con texto y suena un beep.

Uso de ítems y persistencia:

1. Usar ítem: haz clic sobre un slot en el HUD. Si el ítem restaura energía (ej. `Fruit`), su cantidad disminuirá y la energía aumentará; escucharás `use_item.wav`.
	- Si el ítem no tiene efecto, aparecerá la notificación "Nada que hacer con <item>".
2. Persistencia: al cerrar la escena o el juego, el estado (energía e inventario) se guarda automáticamente en `user://savegame.json`.
	- Para probar: recoge algunos ítems, cierra el juego (o la escena) y vuelve a abrir `res://scenes/Main.tscn`. El inventario y la energía deberían restaurarse.

