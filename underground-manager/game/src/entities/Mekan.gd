class_name Mekan
extends RefCounted

# Her dükkanın temel kimlik bilgileri
var mekan_id: int
var isim: String
var kategori: String         # Örn: "Sokak Lezzeti", "Depo", "Kumarhane"
var seviye: int = 1
var temel_gelir: float       # Saatlik getirdiği ham para
var gelistirme_maliyeti: float
var savunma_gucu: int = 50   # Rakip çetelerin çökmesini zorlaştıran koruma puanı

func _init(p_id: int, p_isim: String, p_kategori: String, p_temel_gelir: float, p_maliyet: float):
	mekan_id = p_id
	isim = p_isim
	kategori = p_kategori
	temel_gelir = p_temel_gelir
	gelistirme_maliyeti = p_maliyet

# Oyuncuyu hırslandıracak katlanarak artan gelir formülü
func gelir_hesapla() -> float:
	return temel_gelir * pow(seviye, 1.5)

# Seviye atlama mekaniği
func seviye_atlat(oyuncu_parasi: float) -> float:
	var guncel_maliyet = gelistirme_maliyeti * (seviye * 2.0)
	if oyuncu_parasi >= guncel_maliyet:
		seviye += 1
		savunma_gucu += 25
		return guncel_maliyet # Harcanan parayı düşmek için geri döndürüyoruz
	else:
		return 0.0 # Yetersiz bakiye!
