extends Node2D

var ekonomi: EkonomiKontrolcu
var zamanlayici: float = 0.0

# Düğümü yakalıyoruz
@onready var ana_arayuz = $AnaArayuz

func _ready() -> void:
	# Önce ekonomi motorunu hafızada canlandırıyoruz
	ekonomi = EkonomiKontrolcu.new()
	
	# EN GÜVENLİ YOL: Arayüzün yüklenmesi için 1 karecik bekletiyoruz
	await get_tree().process_frame
	
	# Şimdi bağlantıyı kuruyoruz
	if ana_arayuz:
		ana_arayuz.ekonomi = ekonomi
		ana_arayuz.arayuzu_guncelle()
	
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
