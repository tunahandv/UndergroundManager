extends Node2D

var ekonomi: EkonomiKontrolcu
var zamanlayici: float = 0.0

func _ready() -> void:
	# Ekonomi kontrolcüsünü doğuruyoruz
	ekonomi = EkonomiKontrolcu.new()
	print("=== YERALTI İMPARATORLUĞU BAŞLADI ===")
	print("Başlangıç Parası: ", ekonomi.oyuncu_parasi, "$")
	print("-------------------------------------")

func _process(delta: float) -> void:
	# Her 2 saniyede bir oyunda 1 saat geçmiş gibi döngüyü tetikliyoruz
	zamanlayici += delta
	if zamanlayici >= 2.0:
		zamanlayici = 0.0
		ekonomi.saatlik_dongu_tetikle()
		
		# TEST: Oyuncunun parası yettiğinde 1 ID'li Sokak Pilavcısı'nı otomatik geliştirsin
		# Böylece katlanarak artan gelir formülümüzü test etmiş olacağız
		ekonomi.mekan_gelistir(1)
