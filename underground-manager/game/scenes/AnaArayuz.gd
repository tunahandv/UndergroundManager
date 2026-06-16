extends Control

@onready var para_yazisi: Label = $UstBar/ParaYazisi
@onready var mal_yazisi: Label = $UstBar/MalYazisi

# Tür belirtmeyi kaldırıp serbest bırakıyoruz, böylece hata vermeyecek
var ekonomi

func arayuzu_guncelle() -> void:
	if ekonomi:
		para_yazisi.text = "Para: " + str(int(ekonomi.oyuncu_parasi)) + " $"
		mal_yazisi.text = "Stok: " + str(ekonomi.oyuncu_mallari) + " Adet"
