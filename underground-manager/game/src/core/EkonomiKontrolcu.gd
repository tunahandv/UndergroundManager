class_name EkonomiKontrolcu
extends RefCounted

# Oyuncunun ana kaynakları
var oyuncu_parasi: float = 500.0  # Oyuna 500$ cep harçlığıyla başlıyoruz
var oyuncu_mallari: int = 0        # Depolardan gelen satılacak hammadde/mal

# Dünyadaki tüm mekanların tutulacağı liste
var tum_mekanlar: Array[Mekan] = []

func _init():
	_dunyayi_olustur()

# Oyun ilk açıldığında haritadaki 7 mekanı başlangıç değerleriyle doğurur
func _dunyayi_olustur():
	# Parametreler: id, isim, kategori, temel_gelir, gelistirme_maliyeti, (opsiyonel) mal_orani
	tum_mekanlar.append(Mekan.new(1, "Sokak Pilavcısı", "Sokak Lezzeti", 10.0, 100.0))
	tum_mekanlar.append(Mekan.new(2, "Ceylan Street Food", "Sokak Lezzeti", 35.0, 450.0))
	tum_mekanlar.append(Mekan.new(3, "Köşe Tantunicisi", "Sokak Lezzeti", 60.0, 800.0))
	tum_mekanlar.append(Mekan.new(4, "Merkez Depo", "Lojistik", 0.0, 1200.0, 50)) # Saatte 50 mal üretir
	tum_mekanlar.append(Mekan.new(5, "Oto Sanayi / Parçalama", "Lojistik", 120.0, 3000.0, 20)) # Para + 20 mal
	tum_mekanlar.append(Mekan.new(6, "Lüks Gece Kulübü", "Eğlence", 250.0, 6500.0))
	tum_mekanlar.append(Mekan.new(7, "Yeraltı Kumarhanesi", "Suç", 500.0, 15000.0))

# BURASI ÇOK KRİTİK: Oyundaki zaman döngüsü (Örn: Her 5 saniyede bir tetiklenecek)
# Bu fonksiyon her tetiklendiğinde oyunda 1 saat geçmiş gibi tüm dükkanlardan gelir toplar
func saatlik_dongu_tetikle():
	var toplam_gelen_para: float = 0.0
	var toplam_gelen_mal: int = 0
	
	for mekan in tum_mekanlar:
		if mekan.isgal_edildi_mi and mekan.sahip_cete == "Oyuncu_Çetesi":
			toplam_gelen_para += mekan.gelir_hesapla()
			toplam_gelen_mal += mekan.mal_uretimi_hesapla()
			
	oyuncu_parasi += toplam_gelen_para
	oyuncu_mallari += toplam_gelen_mal
	
	print("--- SAATLİK RAPOR ---")
	print("Kazanılan Para: +", toplam_gelen_para, "$ | Güncel Kasa: ", oyuncu_parasi, "$")
	print("Üretilen Mal: +", toplam_gelen_mal, " Adet | Güncel Stok: ", oyuncu_mallari)

# Oyuncunun bir mekanı geliştirmek istediğinde çağıracağı fonksiyon
func mekan_gelistir(mekan_id: int) -> bool:
	for mekan in tum_mekanlar:
		if mekan.mekan_id == mekan_id:
			var maliyet = mekan.gelistirme_maliyeti * (mekan.seviye * 2.0)
			if oyuncu_parasi >= maliyet:
				var harcanan = mekan.seviye_atlat(oyuncu_parasi)
				if harcanan > 0:
					oyuncu_parasi -= harcanan
					print(mekan.isim, " başarıyla Seviye ", mekan.seviye, " yapıldı!")
					return true
			else:
				print("Yetersiz bakiye! Gereken: ", maliyet, "$")
	return false
