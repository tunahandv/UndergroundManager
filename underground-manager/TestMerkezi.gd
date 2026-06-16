extends Node2D

var ekonomi: EkonomiKontrolcu
var zamanlayici: float = 0.0

# Düğümü yakalıyoruz
@onready var ana_arayuz = $CanvasLayer/AnaArayuz

func _ready() -> void:
	ekonomi = EkonomiKontrolcu.new()
	
	await get_tree().process_frame
	
	if ana_arayuz:
		ana_arayuz.ekonomi = ekonomi
		# İŞTE BURASI DEĞİŞTİ: Artık direkt ilk kurulum fonksiyonunu çağırıyoruz
		ana_arayuz.ilk_kurulumu_yap()
	
	print("=== YERALTI İMPARATORLUĞU BAŞLADI ===")
	print("Başlangıç Parası: ", ekonomi.oyuncu_parasi, "$")
	print("-------------------------------------")

func _process(delta: float) -> void:
	zamanlayici += delta
	if zamanlayici >= 2.0:
		zamanlayici = 0.0
		ekonomi.saatlik_dongu_tetikle()
		
		# Test geliştirmesi (Pilavcıyı otomatik büyütür)
		ekonomi.mekan_gelistir(1)
		
		# Sayılar değiştikçe ekranı güncelle
		if ana_arayuz and ana_arayuz.has_method("arayuzu_guncelle"):
			ana_arayuz.arayuzu_guncelle()
