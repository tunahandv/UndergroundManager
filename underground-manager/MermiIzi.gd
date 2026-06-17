extends MeshInstance3D

func _ready() -> void:
	# Mermi izi ekranda çok kısa (0.04 saniye) kalıp hemen silinecek
	get_tree().create_timer(0.04).timeout.connect(queue_free)

func mermiyi_uzat_ve_yonlendir(baslangic: Vector3, bitis: Vector3) -> void:
	var mesafe = baslangic.distance_to(bitis)
	
	# Silindiri Y ekseninde (boylamasına) hedefin mesafesi kadar uzatıyoruz
	scale.y = mesafe
	
	# Kalınlaşmayı önlemek için genişlik eksenlerini jilet gibi ince yapıyoruz
	scale.x = 1.0
	scale.z = 1.0
	
	# Tam iki noktanın ortasına yerleştir
	global_position = baslangic.lerp(bitis, 0.5)
	
	# Hedefe doğru bakmasını sağla
	look_at(bitis, Vector3.UP)
	
	# Silindirin yan duruş eksenini düzeltmek için yerel 90 derece döndür
	rotate_object_local(Vector3.RIGHT, deg_to_rad(90))
