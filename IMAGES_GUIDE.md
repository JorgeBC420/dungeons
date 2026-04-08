# Guía: Enlazar Imágenes de Cartas

## Estructura de Carpetas Assets

```
res/assets/
├── humans/
│   ├── paladin_alba.png
│   ├── medico_campo.png
│   ├── caballero_real.png
│   ├── inquisidor_hierro.png
│   ├── arquero_muralla.png
│   ├── herrero_imperial.png
│   ├── hechicero_corte.png
│   ├── escudero_novato.png
│   └── general_valerius.png
├── orcs/
│   ├── berserker_feroz.png
│   ├── chaman_sangre.png
│   ├── jinete_lobo.png
│   ├── rompefilas.png
│   ├── lanzador_hachas.png
│   ├── brujo_sombras.png
│   ├── capataz_esclavos.png
│   ├── trasgo_saqueador.png
│   └── gran_jefe_gromm.png
└── elf/
    ├── guardian_bosque.png
    ├── curandero_sagrado.png
    ├── arquero_maestro.png
    ├── asesino_sombrio.png
    ├── druida_formas.png
    ├── cantante_viento.png
    ├── tejedora_hechizos.png
    ├── explorador_silvano.png
    └── reina_estrellas.png
```

## CardImageMapper

El script `res/scripts/card_image_mapper.gd` automáticamente enlaza cartas con sus imágenes:

```gdscript
# Obtener la textura de una carta
var card_portrait = CardImageMapper.get_card_portrait("paladin_alba")

# Obtener la ruta de imagen
var image_path = CardImageMapper.get_image_path("paladin_alba", "human")
# Resultado: "res://assets/humans/paladin_alba.png"
```

## Cómo Agregar Imágenes

### Opción 1: Importar Imágenes PNG (Recomendado)

1. **Prepara tus imágenes**:
   - Tamaño recomendado: **200x280 píxeles** (radio 5:7)
   - Formato: **PNG** con transparencia (preferible)
   - Resolución: **72-150 DPI**

2. **Coloca en carpeta correcta**:
   ```
   res/assets/humans/paladin_alba.png    ← Imagen para Paladín
   res/assets/orcs/berserker_feroz.png   ← Imagen para Berserker
   res/assets/elf/guardian_bosque.png    ← Imagen para Guardián
   ```

3. **Godot auto-importa**:
   - Cada PNG se importa automáticamente
   - Se crea un archivo `.import`
   - En editor, verás "✓" verde

### Opción 2: Crear Placeholders en Godot

Si no tienes imágenes aún, crea placeholders:

1. En el editor, click derecho en carpeta → **New Resource**
2. Elige **Image** o **CanvasTexture**
3. Dibuja un placeholder simple
4. Guarda con el nombre correcto

### Opción 3: Scripts de Generación

Script para auto-generar placeholders:

```gdscript
# res/scripts/gen_placeholders.gd
extends Node

func _ready() -> void:
	var cards = CardDatabase.get_card_data()
	
	for card_id in cards.keys():
		var card = cards[card_id]
		generate_placeholder(card)

func generate_placeholder(card: Dictionary) -> void:
	var faction = card.faction
	var folder = "res://assets/%s/" % CardImageMapper._get_faction_folder(faction)
	var filename = "%s%s.png" % [folder, card.id]
	
	# Crear imagen
	var image = Image.new()
	image.create(200, 280, false, Image.FORMAT_RGB8)
	
	# Llenar con color según facción
	var color = _get_faction_color(faction)
	for y in range(280):
		for x in range(200):
			image.set_pixel(x, y, color)
	
	# Guardar
	var err = image.save_png(filename)
	if err == OK:
		print("Placeholder creado: %s" % filename)

func _get_faction_color(faction: String) -> Color:
	match faction:
		"human":
			return Color(0.2, 0.4, 0.8)  # Azul
		"orc":
			return Color(0.3, 0.6, 0.2)  # Verde
		"elf":
			return Color(0.6, 0.2, 0.6)  # Púrpura
		_:
			return Color.GRAY
```

## Verificar que Imágenes Estén Enlazadas

### En el Editor:

1. Abre **Main.tscn**
2. Press **F5** para ejecutar
3. Juega una carta
4. **Si ves la imagen**: ✓ Funcionó
5. **Si ves gris/blanco**: ✗ Archivo faltante

### En la Consola:

```gdscript
# Comprueba si la imagen existe
var portrait = CardImageMapper.get_card_portrait("paladin_alba")
if portrait == null:
	print("ERROR: Imagen no encontrada!")
else:
	print("OK: Imagen cargada")
```

### Debug Output:

Si Godot no encuentra una imagen, verás en consola:
```
WARNING: Card portrait not found: res://assets/humans/paladin_alba.png
```

## Tamaños Recomendados

| Uso | Tamaño | Formato |
|-----|--------|---------|
| Card Portrait | 200x280 px | PNG |
| Faction Icon | 64x64 px | PNG |
| Button Icon | 48x48 px | PNG |
| Background | 1920x1080 px | PNG/JPG |

## Optimización de Imágenes

### Para Mobile (Google Play):

```gdscript
# Reducir tamaño para ahorrar memoria
func optimize_card_image(image_path: String) -> void:
	var image = Image.new()
	image.load(image_path)
	
	# Reducir a 150x210 max
	if image.get_width() > 200:
		image.resize(150, 210)
	
	# Guardar optimizado
	image.save_png(image_path)
```

**Tamaño total recomendado**:
- 27 cartas × 40KB = ~1.1MB (aceptable)

## Integración con CardView.tscn

El script ya usa las imágenes automáticamente:

```gdscript
# En card_view.gd - _update_ui()
var portrait_texture = CardImageMapper.get_card_portrait(card_unit.data.id)
if portrait_texture != null and portrait != null:
	portrait.texture = portrait_texture
```

## Testing Locales

### Crear estructura de prueba:

```bash
# En PowerShell
$factions = @("humans", "orcs", "elf")
$humans = @("paladin_alba", "medico_campo", "caballero_real", "inquisidor_hierro", "arquero_muralla", "herrero_imperial", "hechicero_corte", "escudero_novato", "general_valerius")
$orcs = @("berserker_feroz", "chaman_sangre", "jinete_lobo", "rompefilas", "lanzador_hachas", "brujo_sombras", "capataz_esclavos", "trasgo_saqueador", "gran_jefe_gromm")
$elves = @("guardian_bosque", "curandero_sagrado", "arquero_maestro", "asesino_sombrio", "druida_formas", "cantante_viento", "tejedora_hechizos", "explorador_silvano", "reina_estrellas")

# Crear carpetas
New-Item -ItemType Directory -Force -Path "res:\\assets\\humans"
New-Item -ItemType Directory -Force -Path "res:\\assets\\orcs"
New-Item -ItemType Directory -Force -Path "res:\\assets\\elf"

# Crear archivos PNG vacíos
$humans | foreach { New-Item -Type File -Path "res:\\assets\\humans\\$_.png" -Force }
$orcs | foreach { New-Item -Type File -Path "res:\\assets\\orcs\\$_.png" -Force }
$elves | foreach { New-Item -Type File -Path "res:\\assets\\elf\\$_.png" -Force }
```

## Fuentes de Imágenes

### Recursos Gratuitos:
- [OpenGameArt.org](https://opengameart.org) - Recursos CC
- [Itch.io](https://itch.io) - Arte indie
- [Pixabay](https://pixabay.com) - Imágenes libres

### Cómo Generar Imágenes AI:
- **Hugging Face**: Stable Diffusion gratuito
- **Midjourney**: Inicio gratuito
- **Leonardo.AI**: Específico para juegos

### Prompts Sugeridos:

**Humanos:**
```
"Medieval knight card art style, high fantasy, professional game card illustration"
"Paladin warrior with golden armor and holy symbols, detailed card art"
```

**Orcos:**
```
"Orc warrior fantasy card, green skin, strong muscular character, game card style"
"Berserker orc with axes, rage expression, detailed fantasy card art"
```

**Elfos:**
```
"Elf archer fantasy card, elegant nature themed, magical aura, detailed illustration"
"Forest guardian elf, glowing nature magic, fantasy card art"
```

## Importar Archivos PSD (Photoshop)

Si tienes arte en PSD:

1. Abre en Photoshop/GIMP
2. Exporta cada carta como PNG:
   - Archivo → Exportar como → PNG
   - Resolución: 72 DPI
   - Tamaño: 200x280
3. Coloca en carpeta correcta en `res/assets/`

## Validar Importación

```gdscript
# Script para verificar todas las imágenes
extends Node

func _ready() -> void:
	var cards = CardDatabase.get_card_data()
	var missing = []
	
	for card_id in cards.keys():
		var texture = CardImageMapper.get_card_portrait(card_id)
		if texture == null:
			missing.append(card_id)
	
	if missing.is_empty():
		print("✓ Todas las imágenes están cargadas!")
	else:
		print("✗ Imágenes faltantes:", missing)
```

## Próximos Pasos

1. ✓ Estructura de carpetas: HECHO
2. → **Agregar imágenes PNG** (48 archivos total)
3. → Verificar en editor
4. → Exportar para Google Play
5. → Publicar

---

**Nota**: El juego funciona sin imágenes (mostrará gris), pero para Google Play necesitas imágenes de buena calidad.
