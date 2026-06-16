extends PanelContainer

# Kartın üzerindeki yazılara ve butona ulaşıyoruz
@onready var bilgi_yazisi: Label = $HBoxContainer/BilgiYazisi
@onready var gelistir_butonu: Button = $HBoxContainer/GelistirButonu

var mekan_verisi: Mekan
var ana_arayuz # Ana arayüze geri haber uçurmak için

# Bu fonksiyonu ana arayüz çağıracak ve kartın içini dolduracak
func karti_hazirla(p_mekan: Mekan, p_ana_arayuz) -> void:
	mekan_verisi = p_mekan
	ana_arayuz = p_ana_arayuz
	karti_guncelle()

# Kartın üzerindeki metinleri tazeleyen fonksiyon
func karti_guncelle() -> void:
	if mekan_verisi:
		var durum = ""
		if not mekan_verisi.isgal_edildi_mi:
			durum = " [KİLİTLİ - RAKİP ÇETE]"
			gelistir_butonu.text = "İşgal Et!"
		else:
			durum = " (Seviye " + str(mekan_verisi.seviye) + ")"
			var guncel_maliyet = mekan_verisi.gelistirme_maliyeti * (mekan_verisi.seviye * 2.0)
			gelistir_butonu.text = "Geliştir (" + str(int(guncel_maliyet)) + "$)"
			
		bilgi_yazisi.text = mekan_verisi.isim + durum + "\nSaatlik Gelir: " + str(int(mekan_verisi.gelir_hesapla())) + "$"

# Butona tıklandığında çalışacak olan Godot Sinyali
func _on_gelistir_butonu_pressed() -> void:
	if not mekan_verisi.isgal_edildi_mi:
		# Şimdilik direkt işgal edilmiş saysın, ileride buraya savaş mekaniği yazacağız
		mekan_verisi.isgal_edildi_mi = true
		mekan_verisi.sahip_cete = "Oyuncu_Çetesi"
		print(mekan_verisi.isim, " İŞGAL EDİLDİ!")
	else:
		# Zaten bizimse parayı düşüp seviye atlatmayı dene
		if ana_arayuz.ekonomi.mekan_gelistir(mekan_verisi.mekan_id):
			print(mekan_verisi.isim, " oyuncu tarafından geliştirildi!")
			
	karti_guncelle()
	ana_arayuz.arayuzu_guncelle()
