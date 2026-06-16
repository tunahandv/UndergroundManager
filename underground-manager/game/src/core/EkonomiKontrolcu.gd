class_name EkonomiKontrolcu
extends RefCounted

# Oyuncunun ana kaynakları
var oyuncu_parasi: float = 500.0  # Oyuna 500$ cep harçlığıyla başlıyoruz
var oyuncu_mallari: int = 0        # Depolardan gelen satılacak hammadde/mal

# Dünyadaki tüm mekanların tutulacağı liste
var tum_mekanlar: Array[Mekan] = []

func _init():
	_dunyayi_olustur()

func _dunyayi_olustur():
	tum_mekanlar.append(Mekan.new(1, "Sokak Pilavcısı", "Sokak Lezzeti", 10.0, 100.0))
	tum_mekanlar.append(Mekan.new(2, "Ceylan Street Food", "Sokak Lezzeti", 35.0, 450.0))
	tum_mekanlar.append(Mekan.new(3, "Köşe Tantunicisi", "Sokak Lezzeti", 60.0, 800.0))
	tum_mekanlar.append(Mekan.new(4, "Merkez Depo", "Lojistik", 0.0, 1200.0, 50)) 
	tum_mekanlar.append(Mekan.new(5, "Oto Sanayi / Parçalama", "Lojistik", 120.0, 3000.0, 20)) 
	tum_mekanlar.append(Mekan.new(6, "Lüks Gece Kulübü", "Eğlence", 250.0, 6500.0))
	tum_mekanlar.append(Mekan.new(7, "Yeraltı Kumarhanesi", "Suç", 500.0, 15000.0))

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

# TANE TANE ÇÖZÜM: Geliştirme işini tamamen bu merkezi motora bırakıyoruz
func mekan_gelistir_merkezi(mekan: Mekan) -> bool:
	var maliyet = mekan.guncel_gelistirme_maliyeti_hesapla()
	if oyuncu_parasi >= maliyet and mekan.isgal_edildi_mi:
		var harcanan = mekan.seviye_atlat(oyuncu_parasi)
		if harcanan > 0.0:
			oyuncu_parasi -= harcanan
			print("💥 MOTOR BAŞARILI: ", mekan.isim, " yeni seviye: ", mekan.seviye, " | Kalan Para: ", oyuncu_parasi)
			return true
	return false

# TANE TANE ÇÖZÜM: Olmayan işgal etme motorunu buraya kuruyoruz
func mekan_isgal_et_merkezi(mekan: Mekan) -> bool:
	var isgal_maliyeti = mekan.gelistirme_maliyeti * 3.5
	if oyuncu_parasi >= isgal_maliyeti and not mekan.isgal_edildi_mi:
		oyuncu_parasi -= isgal_maliyeti
		mekan.isgal_edildi_mi = true
		mekan.sahip_cete = "Oyuncu_Çetesi"
		print("💥 MOTOR BAŞARILI: ", mekan.isim, " İŞGAL EDİLDİ! | Kalan Para: ", oyuncu_parasi)
		return true
	return false
	
	# EkonomiKontrolcu.gd dosyasının en altına ekle:

# Elimizdeki tüm malları tek tıkla kara borsada satma fonksiyonu
func mallari_nakde_cevir() -> float:
	if oyuncu_mallari <= 0:
		print("❌ Depoda satılacak mal yok!")
		return 0.0
		
	var mal_basi_fiyat: float = 15.0 # 1 adet mal = 15$
	var kazanilan_toplam_para = oyuncu_mallari * mal_basi_fiyat
	
	# Stokları boşalt, parayı kasaya ekle
	oyuncu_parasi += kazanilan_toplam_para
	var satilan_miktar = oyuncu_mallari
	oyuncu_mallari = 0
	
	print("💰 TİCARET BAŞARILI: ", satilan_miktar, " adet mal satıldı! Kazanç: +", kazanilan_toplam_para, "$")
	return kazanilan_toplam_para
