extends PanelContainer

@onready var bilgi_yazisi: Label = $HBoxContainer/BilgiYazisi
@onready var gelistir_butonu: Button = $HBoxContainer/GelistirButonu

# DÜZELTME: Yanındaki iki nokta (:) veya sınıf tanımlamalarını sildik.
# Sadece esnek değişken olarak bırakıyoruz ki döngüsel kilitlenme yaşanmasın!
var dukkan_verisi 
var ana_arayuz    

func karti_hazirla(mekan, arayuz_referansi) -> void:
	dukkan_verisi = mekan
	ana_arayuz = arayuz_referansi
	
	# Sinyal kilitleyici hattı: Arayüzdeki tüm bozuk bağları çözüp kodla sıfırdan bağlar
	if gelistir_butonu:
		if gelistir_butonu.pressed.is_connected(_on_gelistir_butonu_basildi):
			gelistir_butonu.pressed.disconnect(_on_gelistir_butonu_basildi)
		gelistir_butonu.pressed.connect(_on_gelistir_butonu_basildi)
		gelistir_butonu.custom_minimum_size = Vector2(140, 60)
		
	karti_guncelle()

func karti_guncelle() -> void:
	if not dukkan_verisi or not ana_arayuz or not ana_arayuz.ekonomi: return
	
	var oyuncu_parasi = ana_arayuz.ekonomi.oyuncu_parasi
	
	# --- GELİŞTİRME EKRANI ---
	if dukkan_verisi.isgal_edildi_mi:
		var maliyet = dukkan_verisi.guncel_gelistirme_maliyeti_hesapla()
		var gelecek_gelir = dukkan_verisi.sonraki_seviye_geliri_hesapla()
		
		bilgi_yazisi.text = "[ " + dukkan_verisi.isim + " ] - Seviye " + str(dukkan_verisi.seviye) + "\n"
		bilgi_yazisi.text += "💰 Gelir: " + str(int(dukkan_verisi.gelir_hesapla())) + "$ -> [" + str(int(gelecek_gelir)) + "$]\n"
		bilgi_yazisi.text += "🛡️ Savunma Puanı: " + str(dukkan_verisi.savunma_gucu)
		
		gelistir_butonu.text = "Geliştir\n" + str(int(maliyet)) + " $"
		gelistir_butonu.disabled = (oyuncu_parasi < maliyet)
			
	# --- İŞGAL ETME EKRANI ---
	else:
		var isgal_maliyeti = dukkan_verisi.gelistirme_maliyeti * 3.5
		
		bilgi_yazisi.text = "❌ " + dukkan_verisi.isim + " [RAKİP ÇETE]\n"
		bilgi_yazisi.text += "📋 Kategori: " + dukkan_verisi.kategori + "\n"
		bilgi_yazisi.text += "🛡️ Rakip Defansı: " + str(dukkan_verisi.savunma_gucu)
		
		gelistir_butonu.text = "🚨 İŞGAL ET\n" + str(int(isgal_maliyeti)) + " $"
		gelistir_butonu.disabled = (oyuncu_parasi < isgal_maliyeti)

# TIKLAMA TETİKLENMESİ
func _on_gelistir_butonu_basildi() -> void:
	if not dukkan_verisi or not ana_arayuz or not ana_arayuz.ekonomi: return
	
	var eko = ana_arayuz.ekonomi
	var islem_basarili = false
	
	if dukkan_verisi.isgal_edildi_mi:
		# Merkezi ekonomi motorundaki geliştirme fonksiyonunu tetikle
		islem_basarili = eko.mekan_gelistir_merkezi(dukkan_verisi)
	else:
		# Merkezi ekonomi motorundaki işgal fonksiyonunu tetikle
		islem_basarili = eko.mekan_isgal_et_merkezi(dukkan_verisi)
		
	if islem_basarili:
		# Motor onay verdi parayı düşürdü, arayüzü tamamen yenile!
		ana_arayuz.arayuzu_guncelle()
