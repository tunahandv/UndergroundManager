extends Node3D

@export var asker_sahnesi: PackedScene = preload("res://Asker.tscn")

@onready var oyuncu_spawn = $OyuncuSpawnNoktasi
@onready var dusman_spawn = $DusmanSpawnNoktasi
@onready var kamera: Camera3D = $Camera3D

var secilen_mekan_verisi = null
var oyuncu_asker_sayisi: int = 5
var dusman_asker_sayisi: int = 3

# Kamera Titreme Motoru Değişkenleri
var titreme_gucu: float = 0.0
var titreme_azalma_hizi: float = 5.0
var orijinal_kamera_konumu: Vector3

func _ready() -> void:
	print("🛡️ Savaş Yöneticisi efektler aktif, şehir kapalı olarak başlatıldı.")
	if kamera:
		orijinal_kamera_konumu = kamera.position
	_test_icin_sahte_veri_kur()
	savas_kurulumunu_baslat()

func _process(delta: float) -> void:
	# 🔥 KAMERA TİTREME MOTORU AKTİF
	if titreme_gucu > 0.0 and kamera:
		var rastgele_ofset = Vector3(
			randf_range(-titreme_gucu, titreme_gucu),
			randf_range(-titreme_gucu, titreme_gucu),
			randf_range(-titreme_gucu, titreme_gucu)
		)
		kamera.position = orijinal_kamera_konumu + rastgele_ofset
		titreme_gucu = move_toward(titreme_gucu, 0.0, titreme_azalma_hizi * delta)
	elif kamera and kamera.position != orijinal_kamera_konumu:
		kamera.position = orijinal_kamera_konumu

func kamera_salla(guc: float = 0.2) -> void:
	titreme_gucu = min(titreme_gucu + guc, 0.4)

func _test_icin_sahte_veri_kur() -> void:
	secilen_mekan_verisi = {
		"isim": "Ceylan Street Food",
		"savunma_gucu": 30
	}

func savas_kurulumunu_baslat() -> void:
	askerleri_sahaya_sur()

func askerleri_sahaya_sur() -> void:
	# Oyuncular spawn noktası etrafında rahatça yayılır
	for i in range(oyuncu_asker_sayisi):
		var yeni_asker = asker_sahnesi.instantiate()
		yeni_asker.takim = "Oyuncu"
		add_child(yeni_asker)
		var rastgele_ofset = Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))
		yeni_asker.global_position = oyuncu_spawn.global_position + rastgele_ofset

	# Düşmanlar spawn noktası etrafında rahatça yayılır
	for i in range(dusman_asker_sayisi):
		var yeni_asker = asker_sahnesi.instantiate()
		yeni_asker.takim = "Dusman"
		add_child(yeni_asker)
		var rastgele_ofset = Vector3(randf_range(-3.0, 3.0), 0.0, randf_range(-3.0, 3.0))
		yeni_asker.global_position = dusman_spawn.global_position + rastgele_ofset

func asker_oldu(takim_adi: String) -> void:
	print("💀 Bir asker elendi. Takım: ", takim_adi)
