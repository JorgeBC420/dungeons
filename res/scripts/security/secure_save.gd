# res://scripts/security/secure_save.gd
extends Node
class_name SecureSave

## Sistema de guardar datos con soporte local (guest/account) y sincronización en nube (Google Play)

const SAVE_PATH = "user://calabozos_save.encrypted"
const SAVE_BACKUP_PATH = "user://calabozos_save.backup"
const DEVICE_KEY_PATH = "user://calabozos_device.key"

# Rutas para sincronización con Google Play
const CLOUD_SYNC_MARKER = "user://calabozos_cloud_synced"

var crypto = Crypto.new()
var anti_cheat: AntiCheat
var game_mode: GameMode
var _device_encryption_key: String = ""  # Se genera/carga en _ready()
var save_validator: SaveValidator = SaveValidator.new()  # ← Nuevo validator

func _ready() -> void:
	anti_cheat = AntiCheat.new()
	add_child(anti_cheat)
	# Cargar o generar clave de encriptación por dispositivo
	_device_encryption_key = _get_or_create_device_key()
	# GameMode debe ser inyectado por GameManager
	# game_mode se asigna externamente

func save_player_data(save_data: SaveData) -> bool:
	"""Guarda los datos del jugador de forma segura"""
	
	# Validar datos antes de guardar
	if not _validate_save_data(save_data):
		push_error("SaveData validation failed")
		return false
	
	# Crear backup
	if FileAccess.file_exists(SAVE_PATH):
		var err = DirAccess.copy_absolute(SAVE_PATH, SAVE_BACKUP_PATH)
		if err != OK:
			push_warning("Failed to create backup: %d" % err)
	
	# Preparar datos
	var data_to_save = {
		"version": 1,
		"timestamp": Time.get_ticks_msec(),
		"inventory": save_data.inventory,
		"coins": save_data.coins,
		"checksum": ""
	}
	
	# Calcular checksum
	data_to_save["checksum"] = _calculate_checksum(data_to_save)
	
	# Convertir a JSON
	var json_string = JSON.stringify(data_to_save)
	
	# Encriptar
	var encrypted = _encrypt_data(json_string)
	
	if encrypted.size() == 0:
		push_error("Failed to encrypt save data")
		return false
	
	# Guardar a archivo
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: %d" % FileAccess.get_open_error())
		return false
	
	file.store_var(encrypted)
	
	print("Game saved successfully at: %s" % SAVE_PATH)
	return true

func load_player_data() -> SaveData:
	"""Carga los datos del jugador de forma segura"""
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("No existing save file found")
		return null
	
	# Leer archivo
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: %d" % FileAccess.get_open_error())
		return _load_from_backup()
	
	var encrypted_data = file.get_var()
	
	# Desencriptar
	var json_string = _decrypt_data(encrypted_data)
	if json_string.is_empty():
		push_error("Failed to decrypt save data")
		return _load_from_backup()
	
	# Parsear JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Failed to parse save data")
		return _load_from_backup()
	
	var data = json.data
	
	# Verificar checksum
	var stored_checksum = data.get("checksum", "")
	data.erase("checksum")
	
	if _calculate_checksum(data) != stored_checksum:
		push_error("Save file checksum mismatch - possible tampering detected!")
		anti_cheat._log_tamper("Save file tampering detected", "Checksum mismatch")
		return _load_from_backup()
	
	# Validar datos
	if not _validate_loaded_data(data):
		push_error("Loaded data validation failed")
		return _load_from_backup()
	
	# Crear SaveData
	var save_data = SaveData.new()
	save_data.inventory = data.get("inventory", {})
	save_data.coins = data.get("coins", 300)
	
	print("Game loaded successfully")
	return save_data

func _encrypt_data(data: String) -> PackedByteArray:
	"""Encripta datos usando AES-256-GCM con clave generada por dispositivo"""
	if _device_encryption_key.is_empty():
		push_error("Device encryption key not initialized")
		return PackedByteArray()
	
	var key = _device_encryption_key.sha256_buffer()
	var iv = crypto.generate_random_bytes(16)
	
	var plaintext = data.to_utf8_buffer()
	var ciphertext = crypto.encrypt_aes256_gcm(key, iv, plaintext)
	
	if ciphertext == null or ciphertext.size() == 0:
		push_error("Encryption failed")
		return PackedByteArray()
	
	# Combinar IV + ciphertext
	var result = iv + ciphertext
	return result

func _decrypt_data(encrypted: PackedByteArray) -> String:
	"""Desencripta datos usando AES-256-GCM con clave generada por dispositivo"""
	if _device_encryption_key.is_empty():
		push_error("Device encryption key not initialized")
		return ""
	
	if encrypted.size() < 16:
		push_error("Encrypted data too small")
		return ""
	
	var key = _device_encryption_key.sha256_buffer()
	
	# Separar IV y ciphertext
	var iv = encrypted.slice(0, 16)
	var ciphertext = encrypted.slice(16)
	
	var plaintext = crypto.decrypt_aes256_gcm(key, iv, ciphertext)
	
	if plaintext == null or plaintext.size() == 0:
		push_error("Decryption failed")
		return ""
	
	return plaintext.get_string_from_utf8()

func _get_or_create_device_key() -> String:
	"""Obtiene o crea una clave de encriptación única por dispositivo
	La clave se genera usando OS.get_unique_id() + timestamp
	Se almacena en user://calabozos_device.key
	"""
	# Si ya existe, cargar la clave guardada
	if FileAccess.file_exists(DEVICE_KEY_PATH):
		var file = FileAccess.open(DEVICE_KEY_PATH, FileAccess.READ)
		if file != null:
			var stored_key = file.get_as_text()
			if stored_key != "":
				print("Device encryption key loaded from storage")
				return stored_key
	
	# Generar nueva clave única para el dispositivo
	var unique_id = OS.get_unique_id()  # ID único del dispositivo
	var timestamp = str(Time.get_ticks_msec())
	var device_key = "%s_%s" % [unique_id, timestamp]
	
	# Guardar la clave para futuras sesiones
	var file = FileAccess.open(DEVICE_KEY_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(device_key)
		print("Device encryption key generated and stored")
	else:
		push_warning("Failed to store device encryption key")
	
	return device_key

func _calculate_checksum(data: Dictionary) -> String:
	"""Calcula un checksum para verificar integridad"""
	var json_str = JSON.stringify(data)
	return json_str.sha256_text()

func _validate_save_data(save_data: SaveData) -> bool:
	"""Valida que los datos a guardar sean legítimos"""
	
	# Validar coins
	if save_data.coins < 0 or save_data.coins > 999999:
		push_error("Invalid coins value: %d" % save_data.coins)
		return false
	
	# Validar inventario (solo valida valores que se guardan: copies y level)
	for card_id in save_data.inventory.keys():
		var card_info = save_data.inventory[card_id]
		
		# Nota: SaveData solo guarda 'copies' y 'level' cuando difieren del default
		# No incluye 'unlocked' ni otros campos (se calcula en CardUnit)
		if card_info.has("level"):
			if card_info.level < 1 or card_info.level > 10:
				return false
		
		if card_info.has("copies"):
			if card_info.copies < 0 or card_info.copies > 999:
				return false
	
	return true

func _validate_loaded_data(data: Dictionary) -> bool:
	"""Valida que los datos cargados sean legítimos
	Delega a SaveValidator para validación consistente
	"""
	return save_validator.validate_save_data(data)

func _load_from_backup() -> SaveData:
	"""Intenta cargar desde el backup si la carga principal falla"""
	
	if not FileAccess.file_exists(SAVE_BACKUP_PATH):
		print("No backup file found - starting fresh")
		return null
	
	print("Attempting to load from backup...")
	
	var file = FileAccess.open(SAVE_BACKUP_PATH, FileAccess.READ)
	if file == null:
		return null
	
	var encrypted_data = file.get_var()
	var json_string = _decrypt_data(encrypted_data)
	
	if json_string.is_empty():
		return null
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return null
	
	var data = json.data
	
	var save_data = SaveData.new()
	save_data.inventory = data.get("inventory", {})
	save_data.coins = data.get("coins", 300)
	
	# Guardar el backup como el archivo principal
	DirAccess.copy_absolute(SAVE_BACKUP_PATH, SAVE_PATH)
	
	return save_data

func delete_save_data() -> bool:
	"""Elimina los datos guardados"""
	var err = DirAccess.remove_absolute(SAVE_PATH)
	if err != OK:
		push_error("Failed to delete save file: %d" % err)
		return false
	
	print("Save data deleted")
	return true

## SINCRONIZACIÓN EN NUBE (Google Play) - DESACTIVADA TEMPORALMENTE

## Sincroniza datos a la nube (Solo en modo ACCOUNT con Google Play)
## NOTA: Desactivada temporalmente para reducir acoplamiento
## TODO: Implementar después de validar core gameplay
func sync_to_cloud(save_data: SaveData) -> bool:
	"""Sincroniza datos a Google Play (modo account solamente)
	TEMPORALMENTE DESACTIVADO: Todos los datos se guardan solo localmente
	Se implementará post-lanzamiento cuando sea necesario
	"""
	
	# Desactivada temporalmente - solo guardar localmente
	print("Cloud sync: Temporarily disabled - data saved locally only")
	return true

## Marca que los datos fueron sincronizados a la nube
func _mark_cloud_synced(timestamp: int) -> void:
	var file = FileAccess.open(CLOUD_SYNC_MARKER, FileAccess.WRITE)
	if file != null:
		file.store_var(timestamp)

## Obtiene la última hora de sincronización con la nube
func get_last_cloud_sync() -> int:
	if not FileAccess.file_exists(CLOUD_SYNC_MARKER):
		return 0
	
	var file = FileAccess.open(CLOUD_SYNC_MARKER, FileAccess.READ)
	if file == null:
		return 0
	
	return file.get_var()

## Retorna true si los datos están sincronizados con la nube
func is_cloud_synced() -> bool:
	if game_mode == null or game_mode.is_guest_mode():
		return false  # Guest mode nunca está sincronizado
	
	if game_mode.player_email == "":
		return false  # Sin Google Play, no hay sincronización
	
	return get_last_cloud_sync() > 0

## Obtiene el estado de sincronización para mostrar en UI
func get_sync_status() -> Dictionary:
	"""Retorna información de sincronización para UI"""
	return {
		"mode": game_mode.get_mode_string() if game_mode != null else "unknown",
		"is_synced": is_cloud_synced(),
		"last_sync": get_last_cloud_sync(),
		"can_sync": game_mode != null and game_mode.is_account_mode() and game_mode.player_email != ""
	}

## Limpia marcas de sincronización (cuando se cierra sesión)
func clear_cloud_sync() -> void:
	if FileAccess.file_exists(CLOUD_SYNC_MARKER):
		DirAccess.remove_absolute(CLOUD_SYNC_MARKER)
	print("Cloud sync markers cleared")
