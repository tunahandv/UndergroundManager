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

# Savaş ve İşgal Mekanikleri
var savunma_gucu: int = 50    # Rakip çetelerin çökmesini zorlaştıran koruma puanı
var isgal_edildi_mi: bool = false # Oyuncu burayı ele geçirdi mi?
var sahip_cete: String = "YapayZeka_Çete" # Başlangıçta mekanlar rakip çetelerdedir

func _init(p_id: int, p_isim: String, p_kategori: String, p_temel_gelir: float, p_maliyet: float, p_mal_orani: int = 0):
	mekan_id = p_id
	isim = p_isim
	kategori = p_kategori
	temel_gelir = p_temel_gelir
	gelistirme_maliyeti = p_maliyet
	uretilen_mal_orani = p_mal_orani
	
	# Eğer mekan başlangıçta oyuncunun ilk mekanı (Sokak Pilavcısı) olacaksa bunu dışarıdan değiştireceğiz
	if p_id == 1:
		sahip_cete = "Oyuncu_Çetesi"
		isgal_edildi_mi = true

# Oyuncuyu hırslandıracak katlanarak artan gelir formülü
func gelir_hesapla() -> float:
	if not isgal_edildi_mi:
		return 0.0 # Mekan bizim değilse bize para kazandırmaz!
	return temel_gelir * pow(seviye, 1.5)

# Saatte üretilen malı hesaplar (Lojistik mekanlar için)
func mal_uretimi_hesapla() -> int:
	if not isgal_edildi_mi:
		return 0
	return int(uretilen_mal_orani * pow(seviye, 1.2))

# Seviye atlama mekaniği (Hırs yaptıran kısım)
func seviye_atlat(oyuncu_parasi: float) -> float:
	var guncel_maliyet = gelistirme_maliyeti * (seviye * 2.0)
	if oyuncu_parasi >= guncel_maliyet and isgal_edildi_mi:
		seviye += 1
		savunma_gucu += 25
		return guncel_maliyet # Harcanan parayı düşmek için ekonomi yöneticisine gönderiyoruz
	else:
		return 0.0 # Yetersiz bakiye veya mekan henüz işgal edilmemiş!
