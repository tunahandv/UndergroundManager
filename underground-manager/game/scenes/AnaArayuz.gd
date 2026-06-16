extends Control

# Ekrandaki üst bar yazılarına ulaşıyoruz
# Üst bar elemanları
@onready var para_yazisi: Label = $UstBar/ParaYazisi
@onready var mal_yazisi: Label = $UstBar/MalYazisi

# Dükkan listesi elemanları
@onready var dukkan_kaydirici: ScrollContainer = %DukkanKaydirici
@onready var dukkan_listesi_kutusu: VBoxContainer = %DukkanListesi


# Tasarladığımız dükkan kartı şablonunu koda tanıtıyoruz (Preload)
const DUKKAN_KARTI_SABLOBU = preload("res://game/scenes/DukkanKarti.tscn")

var ekonomi # TestMerkezi'nden gelecek olan ekonomi motoru
var kart_listesi: Array = [] # Ekrandaki kartları güncel tutmak için liste

func _ready() -> void:
	if dukkan_kaydirici:
		dukkan_kaydirici.offset_top = 100

# Bu fonksiyon TestMerkezi tarafından ekonomi motoru bağlandığında tetiklenecek
func ilk_kurulumu_yap() -> void:
	# GÜVENLİK KONTROLÜ: Eğer kutu koda yüklenmediyse veya ekonomi yoksa durdur, hata verme
	if not dukkan_listesi_kutusu or not ekonomi: 
		print("HATA: DukkanListesi kutusu sahnede bulunamadi veya ekonomi motoru baglanmadi!")
		return
	
	# Önce listede eski dükkanlar kalmışsa temizleyelim
	for cocuk in dukkan_listesi_kutusu.get_children():
		cocuk.queue_free()
	kart_listesi.clear()
	
	# Ekonomi motorundaki 7 mekanı tek tek dönüyoruz
	for mekan in ekonomi.tum_mekanlar:
		# Şablondan yeni bir dükkan kartı kopyalıyoruz
		var yeni_kart = DUKKAN_KARTI_SABLOBU.instantiate()
		
		# Kartı ekrandaki dikey listenin (VBoxContainer) içine yerleştiriyoruz
		dukkan_listesi_kutusu.add_child(yeni_kart)
		
		# Kartın içindeki yazıları ve butonları bu dükkanın verilerine göre dolduruyoruz
		yeni_kart.karti_hazirla(mekan, self)
		
		# İleride hızlı güncellemek için listemize kaydediyoruz
		kart_listesi.append(yeni_kart)
	
	# İlk verileri ekrana basalım
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
