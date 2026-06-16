class_name Mekan
extends RefCounted

# Her dükkanın temel kimlik bilgileri
var mekan_id: int
var isim: String
var kategori: String          # Örn: "Sokak Lezzeti", "Lojistik", "Suç"
var seviye: int = 1

# Ekonomi ve Üretim Değişkenleri
var temel_gelir: float        # Saatlik getirdiği ham para
var gelistirme_maliyeti: float
var uretilen_mal_orani: int   # Eğer lojistik mekansa (Merkez Depo gibi) saatte kaç mal ürettiği

# Gelişmiş Savaş ve İşgal Mekanikleri
var savunma_gucu: int = 50    
var isgal_edildi_mi: bool = false 
var sahip_cete: String = "YapayZeka_Çete" 

func _init(p_id: int, p_isim: String, p_kategori: String, p_temel_gelir: float, p_maliyet: float, p_mal_orani: int = 0):
	mekan_id = p_id
	isim = p_isim
	kategori = p_kategori
	temel_gelir = p_temel_gelir
	gelistirme_maliyeti = p_maliyet
	uretilen_mal_orani = p_mal_orani
	
	# Başlangıç savunma güçlerini kategoriye göre özelleştiriyoruz
	match kategori:
		"Sokak Lezzeti": savunma_gucu = 30
		"Lojistik": savunma_gucu = 100
		"Suç": savunma_gucu = 250
		_: savunma_gucu = 50

	if p_id == 1:
		sahip_cete = "Oyuncu_Çetesi"
		isgal_edildi_mi = true

# Mevcut geliri hesaplar
func gelir_hesapla() -> float:
	if not isgal_edildi_mi: return 0.0
	return temel_gelir * pow(seviye, 1.5)

# BİR SONRAKI SEVİYENİN gelirini oyuncuya önizlemek için fonksiyon
func sonraki_seviye_geliri_hesapla() -> float:
	return temel_gelir * pow(seviye + 1, 1.5)

# BİR SONRAKI SEVİYENİN maliyetini hesaplayan merkezi fonksiyon
func guncel_gelistirme_maliyeti_hesapla() -> float:
	# Kategoriye göre maliyet katlanma çarpanı (Suç mekanlarını büyütmek daha pahalı)
	var carpan = 2.0
	match kategori:
		"Sokak Lezzeti": carpan = 1.8
		"Lojistik": carpan = 2.5
		"Suç": carpan = 3.5
	return gelistirme_maliyeti * (seviye * carpan)

# Saatte üretilen malı hesaplar (Lojistik mekanlar için - EKSİK OLAN FONKSİYON GERİ GELDİ)
func mal_uretimi_hesapla() -> int:
	if not isgal_edildi_mi: return 0
	return int(uretilen_mal_orani * pow(seviye, 1.2))

# Kategoriye özel savunma gücü artış hesaplaması
func savunma_artisi_hesapla() -> int:
	match kategori:
		"Sokak Lezzeti": return 15 # Basit dükkanlar az artar
		"Lojistik": return 40      # Depolar daha korunaklı olur
		"Suç": return 85           # Kumarhane ve mekanlara bodyguard ordusu gerekir
		_: return 25

# Seviye atlama mekaniği (Gelişmiş Versiyon)
func seviye_atlat(oyuncu_parasi: float) -> float:
	var maliyet = guncel_gelistirme_maliyeti_hesapla()
	if oyuncu_parasi >= maliyet and isgal_edildi_mi:
		seviye += 1
		savunma_gucu += savunma_artisi_hesapla() # Kategoriye özel dinamik artış!
		return maliyet 
	return 0.0
