# ✅ Checklist de Implementación

## 📋 Antes de Publicar en Google Play

### 🎨 Paso 1: Assets y Imágenes
- [ ] Crear/obtener 27 imágenes de cartas
- [ ] Verificar tamaño: 200x280 píxeles
- [ ] Formato: PNG con transparencia
- [ ] Colocar en:
  - [ ] `res/assets/humans/` (9 imágenes)
  - [ ] `res/assets/orcs/` (9 imágenes)
  - [ ] `res/assets/elf/` (9 imágenes)
- [ ] Verificar que Godot las importa ✓
- [ ] Testear en editor: juega una carta y verifica que se ve

### 🌍 Paso 2: Traducci ón
- [ ] Abrir Godot Project Settings
- [ ] Ve a Localization
- [ ] Agrega idiomas soportados:
  - [ ] es (Español)
  - [ ] en (Inglés)
  - [ ] pt (Portugués)
- [ ] Carga `res://i18n/translations.csv` como Translation
- [ ] Testea cambio de idioma:
  ```gdscript
  TranslationServer.set_locale("en")
  ```
- [ ] Verifica que la UI cambia

### 🔒 Paso 3: Seguridad Anti-Cheats
- [ ] Verifica que `AntiCheat` se instancia en GameManager
- [ ] Verifica que `SecureSave` se instancia en GameManager
- [ ] Testea jugada: debe validarse sin errores
- [ ] Testea guardado: must create `calabozos_save.encrypted`
- [ ] Intenta editar save: debe fallar con checksum error

### 📦 Paso 4: Configuración de Proyecto
- [ ] Verifica `project.godot` tiene Android config
- [ ] Verifica package name: `com.calabozos.guerrafacciones`
- [ ] Verifica Min SDK: 21
- [ ] Verifica Target SDK: 31+
- [ ] Verifica orientación: portrait

### 🤖 Paso 5: Testing en Editor
- [ ] Abre `Main.tscn`
- [ ] Press F5
- [ ] Verifica UI en español
- [ ] Juega 3-4 turnos
- [ ] Verifica logs de combate
- [ ] Termina partida correctamente
- [ ] Sin errores en consola

### 🎯 Paso 6: Crear Keystore (Certificado)

En Godot:
1. Project → Export
2. Selecciona Android Platform
3. Click en "Create New" Keystore
4. Rellena:
   - [ ] Common Name (CN): Tu nombre
   - [ ] Organization (O): Tu compañía
   - [ ] Organization Unit (OU): Development
   - [ ] Country Code (C): es (o tu país)
5. **Contraseña Keystore**: Guarda en lugar seguro
6. **Contraseña Alias**: Misma contraseña
7. Guarda el archivo `.keystore` en lugar seguro

### 🏗️ Paso 7: Exportar Build

1. Project → Export
2. Android Platform → Export
3. Elige:
   - Formato: `APK` (para testeo local)
   - Tipo: `Release`
   - Keystore: Selecciona el que creaste
4. Genera APK
5. Testea en dispositivo:
   ```bash
   adb install calabozos_release.apk
   ```

### 🌐 Paso 8: Crear Google Play Console

- [ ] Abre [play.google.com/console](https://play.google.com/console)
- [ ] Registra como Developer ($25)
- [ ] Click "Create App"
- [ ] Nombre: "Calabozos: Guerra de Facciones"
- [ ] Default language: Spanish
- [ ] Category: Games > Card
- [ ] Type: Free

### 📝 Paso 9: Configurar Store Listing

En Google Play Console:

#### Store Listing
- [ ] Título: "Calabozos: Guerra de Facciones"
- [ ] Descripción corta (80 chars):
  ```
  Juega batallas de cartas contra la IA en tiempo real
  ```
- [ ] Descripción completa:
  ```
  Calabozos: Guerra de Facciones es un juego de cartas estratégico
  por turnos con 27 cartas únicas.
  
  Características:
  - 3 facciones: Humanos, Orcos, Elfos
  - IA inteligente
  - Sistema de progresión
  - Sin compras in-app
  - 3 idiomas: Español, Inglés, Portugués
  - Seguridad anti-trampa
  
  ¡Demuestra tu estrategia en la Guerra de Facciones!
  ```

#### Imágenes
- [ ] Screenshots: 2-8 imágenes (1080x1920 px)
  - Menú principal
  - Partida en progreso
  - Batalla con cartas
  - Victoria
- [ ] Feature graphic: 1024x500 png
- [ ] Icon: 512x512 png
- [ ] Promo graphic (opcional): 180x120 png

#### Clasificación de Contenido
- [ ] Rellena cuestionario
- [ ] Violencia: "Cartoon/Fantasy Violence"
- [ ] Contenido sexual: "None"
- [ ] Lenguaje: "None"
- [ ] Advertencia de alcohol: "None"

### 📱 Paso 10: Preparar Versión

En Google Play Console:

#### App Releases
1. Click "Internal testing" o "Closed testing"
2. "Create new release"
3. Upload:
   - [ ] AAB (Android App Bundle) - Preferido
     - O APK si no tienes AAB
4. Release name: "1.0"
5. Release notes:
   ```
   Lanzamiento inicial de Calabozos: Guerra de Facciones
   
   Incluye:
   - 27 cartas únicas
   - Modo de juego contra IA
   - Traducciones en español, inglés y portugués
   ```

### ✍️ Paso 11: Completar App Privacy

En Google Play Console:

- [ ] Va a "Data safety" → "Manage"
- [ ] Rellena questionnaire:
  - "Does your app collect or share personal data?"
    - [ ] No (es un juego local)
  - "Does your app request sensitive permissions?"
    - [ ] Internet (opcional - para analytics futuro)
- [ ] Selecciona el nivel de privacidad

### 🧪 Paso 12: Internal Testing

1. Agrega testers (emails de Google):
   - [ ] Tu email
   - [ ] Otros desarrolladores
2. Comparte enlace de testing
3. Testers descargan desde Google Play (internal track)
4. Verifica:
   - [ ] Instalación correcta
   - [ ] Gameplay funciona
   - [ ] No hay crashes
   - [ ] Traducción correcta
   - [ ] Seguridad (no permite cheats)
5. Corre 3-5 días

### 🌟 Paso 13: Closed Testing (Opcional)

Si quieres más testers:
1. Agrega 5-20 testers
2. Corre 1-2 semanas
3. Recolecta feedback
4. Arregla bugs si es necesario
5. Actualiza versión

### 🚀 Paso 14: Production Release

1. En Google Play Console
2. App releases → Production
3. "Create new release"
4. Upload AAB/APK (misma o version superior)
5. Click "Review and publish"
6. Verifica:
   - [ ] Rating app rating review page
   - [ ] App compliance (3+, 7+, 12+, 16+, 18+)
   - [ ] Content rating: Select based on above
7. Click "Publish"
8. **Esperar 2-24 horas** para revisión

### ✅ Paso 15: Post-Launch

**Primeras 24h:**
- [ ] Monitorea Google Play Console
- [ ] Verifica no hay crashes
- [ ] Lee primeros reviews
- [ ] Monitorea descargas

**Primera semana:**
- [ ] Interactúa con usuarios en reviews
- [ ] Arregla bugs críticos si hay
- [ ] Publica v1.0.1 si es necesario
- [ ] Trackea DAU (Daily Active Users)

---

## 🐛 Troubleshooting Common Issues

### "Imágenes no se cargan"
```gdscript
# Verifica en console:
var carte = CardImageMapper.get_card_portrait("paladin_alba")
if carte == null:
    print("Archivo no encontrado. Verifica:")
    print("1. Archivo existe en res://assets/humans/paladin_alba.png")
    print("2. Godot ya lo importó (archivo .import)")
    print("3. No hay typos en el nombre")
```

### "Traducción no funciona"
```gdscript
# Verifica:
print(TranslationServer.get_locale())  # Debe mostrar "es", "en", o "pt"
print(tr("card_paladin_alba_name"))   # Si no está traducido, mostrará la clave
```

### "Google Play rechaza la app"
- [ ] Verifica API level 31+
- [ ] Verifica 64-bit support
- [ ] Verifica no usa APIs deprecated
- [ ] Verifica permissions son mínimas

### "App crashea al iniciar"
- [ ] Verifica MAIN_SCENE en project.godot es Main.tscn
- [ ] Verifica todas las export vars están llenas
- [ ] Verifica no hay typos en rutas
- [ ] Abre console de Godot para ver error exacto

---

## 📊 Métricas a Monitorear

En Google Play Console:

**Descarga:**
- [ ] Daily installs
- [ ] Total installs
- [ ] Uninstall rate

**User:**
- [ ] Crash rate
- [ ] ANR (App Not Responding) rate
- [ ] Session length
- [ ] Return rate

**Quality:**
- [ ] Stars (target: 4+)
- [ ] Review count
- [ ] Crash logs

---

## 🎊 Señales de Éxito

✅ App es aprobada por Google Play
✅ App aparece en búsqueda de Google Play
✅ Primeras descargas dentro de 24h
✅ Usuarios dejan reviews positivos
✅ No hay crashes reportados
✅ Interfaz funciona sin errores

---

## 📞 Enlaces Útiles

- [Google Play Console](https://play.google.com/console)
- [Google Play Policies](https://play.google.com/about/developer-content-policy/)
- [Godot Android Export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html)
- [AAB vs APK](https://developer.android.com/guide/app-bundle)
- [Target API Level](https://developer.android.com/guide/topics/manifest/uses-sdk-element)

---

## 🏁 Resumen Rápido

```
├─ Agregar 27 imágenes PNG ................. [ ] 
├─ Testear traducción 3 idiomas ........... [ ]
├─ Crear keystore certificado ............. [ ]
├─ Exportar APK/AAB ........................ [ ]
├─ Crear Google Play Console .............. [ ]
├─ Llenar store listing ................... [ ]
├─ Subir build a internal testing ......... [ ]
├─ Testear con 2-3 personas ............... [ ]
├─ Subir a production y publicar .......... [ ]
└─ ¡PUBLICADO! ............................ [ ]
```

---

**Tiempo estimado**: 2-3 horas para completar TODO
**Dificultad**: Media (nada técnico, solo formularios)
**Costo**: $25 USD (Google Developer Account - pago único)

¡TÚ PUEDES! 💪

---
