extends Control

# Sahne bağlantıları
@onready var para_yazisi: Label = $UstBar/ParaYazisi
@onready var mal_yazisi: Label = $UstBar/MalYazisi
@onready var mal_sat_butonu: Button = $UstBar/MalSatButonu  # Yeni eklediğimiz buton
@onready var dukkan_listesi_kutusu: VBoxContainer = %DukkanListesi

const DUKKAN_KARTI_SABLOBU = preload("res://game/src/ui/DukkanKarti.tscn")
var ekonomi 
var kart_listesi: Array = []

func _ready() -> void:
	# Mal sat butonunun sinyalini koda bağlıyoruz
	if mal_sat_butonu:
		if mal_sat_butonu.pressed.is_connected(_on_mal_sat_butonu_basildi):
			mal_sat_butonu.pressed.disconnect(_on_mal_sat_butonu_basildi)
		mal_sat_butonu.pressed.connect(_on_mal_sat_butonu_basildi)

# EKKSİKSİZ GERİ GETİRİLEN KURULUM FONKSİYONU (Hatanın Çözümü)
func ilk_kurulumu_yap() -> void:
	if not dukkan_listesi_kutusu or not ekonomi: 
		print("HATA: Liste kutusu veya ekonomi baglanmadi!")
		return
	
	# Eski kartlar varsa temizle
	for cocuk in dukkan_listesi_kutusu.get_children():
		cocuk.queue_free()
	kart_listesi.clear()
	
	# 7 dükkanı da sırayla ekrana bas ve koda bağla
	for mekan in ekonomi.tum_mekanlar:
		var yeni_kart = DUKKAN_KARTI_SABLOBU.instantiate()
		dukkan_listesi_kutusu.add_child(yeni_kart)
		
		if yeni_kart.has_method("karti_hazirla"):
			yeni_kart.karti_hazirla(mekan, self)
			kart_listesi.append(yeni_kart)
		else:
			print("🚨 KRİTİK HATA: Olusturulan sahne DukkanKarti.gd koduna sahip degil!")
	
	arayuzu_guncelle()

# EKRAN YENİLEME MOTORU
func arayuzu_guncelle() -> void:
	if not ekonomi: return
	
	# Üst bar verilerini anlık olarak güncelliyoruz
	if para_yazisi:
		para_yazisi.text = "💰 Kasa: " + str(int(ekonomi.oyuncu_parasi)) + " $"
	if mal_yazisi:
		mal_yazisi.text = "📦 Stok: " + str(int(ekonomi.oyuncu_mallari)) + " Adet"
	
	# Eğer depoda mal yoksa butona basılmasın (disabled olsun)
	if mal_sat_butonu:
		mal_sat_butonu.disabled = (ekonomi.oyuncu_mallari <= 0)
	
	# Alttaki dükkan kartlarının renklerini ve yazılarını tazele
	for kart in kart_listesi:
		if kart.has_method("karti_guncelle"):
			kart.karti_guncelle()

# BUTONA BASILDIĞINDA ÇALIŞACAK TİCARET FONKSİYONU
func _on_mal_sat_butonu_basildi() -> void:
	if not ekonomi: return
	
	# Ekonomideki satış çarkını döndür ve kasayı doldur
	var kazanc = ekonomi.mallari_nakde_cevir()
	
	# Ekranı ve butonları anlık olarak tazele
	arayuzu_guncelle()
