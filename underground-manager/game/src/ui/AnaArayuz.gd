extends Control

# Ekrandaki üst bar yazılarına ulaşıyoruz
# Üst bar elemanları
@onready var para_yazisi: Label = $UstBar/ParaYazisi
@onready var mal_yazisi: Label = $UstBar/MalYazisi

# Dükkan listesi elemanları
@onready var dukkan_kaydirici: ScrollContainer = %DukkanKaydirici
@onready var dukkan_listesi_kutusu: VBoxContainer = %DukkanListesi


# Tasarladığımız dükkan kartı şablonunu koda tanıtıyoruz (Preload)
const DUKKAN_KARTI_SABLOBU = preload("res://game/src/ui/DukkanKarti.tscn")

var ekonomi # TestMerkezi'nden gelecek olan ekonomi motoru
var kart_listesi: Array = [] # Ekrandaki kartları güncel tutmak için liste

func _ready() -> void:
	if dukkan_kaydirici:
		dukkan_kaydirici.offset_top = 100

# Bu fonksiyon TestMerkezi tarafından ekonomi motoru bağlandığında tetiklenecek
func ilk_kurulumu_yap() -> void:
	if not dukkan_listesi_kutusu or not ekonomi: 
		print("HATA: Liste kutusu veya ekonomi baglanmadi!")
		return
	
	for cocuk in dukkan_listesi_kutusu.get_children():
		cocuk.queue_free()
	kart_listesi.clear()
	
	for mekan in ekonomi.tum_mekanlar:
		var yeni_kart = DUKKAN_KARTI_SABLOBU.instantiate()
		dukkan_listesi_kutusu.add_child(yeni_kart)
		
		# GÜVENLİK HATTI: Nesnenin koda sahip olup olmadığını zorla kontrol ediyoruz
		if yeni_kart.has_method("karti_hazirla"):
			yeni_kart.karti_hazirla(mekan, self)
			kart_listesi.append(yeni_kart)
		else:
			print("KRİTİK HATA: Olusturulan sahne DukkanKarti.gd koduna sahip degil!")
	
	arayuzu_guncelle()

# Hem üst barı hem de dükkan kartlarını tazeleyen ana fonksiyon
func arayuzu_guncelle() -> void:
	if ekonomi:
		# Üst barı güncelle
		para_yazisi.text = "Para: " + str(int(ekonomi.oyuncu_parasi)) + " $"
		mal_yazisi.text = "Stok: " + str(ekonomi.oyuncu_mallari) + " Adet"
		
		# Ekrandaki tüm dükkan kartlarının yazılarını ve maliyetlerini güncelle
		for kart in kart_listesi:
			if is_instance_valid(kart):
				kart.karti_guncelle()
