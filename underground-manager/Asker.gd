extends CharacterBody3D

@export var takim: String = "Oyuncu" 
@export var can: float = 100.0
@export var hareket_hizi: float = 5.0      
@export var hasar_gucu: float = 12.0      
@export var atis_menzili: float = 35.0    

# Efekt Sahneleri (Proje dizininde bu isimlerle var olduklarından emin ol şef)
var kan_efekti_sahnesi = preload("res://KanEfekti.tscn")

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var hedef_timer: Timer = $HedefGuncellemeSaati
@onready var can_bari = $SubViewport/ProgressBar

var mevcut_hedef: CharacterBody3D = null
var savas_yoneticisi = null
var ates_edebilir_mi: bool = true
var harita_hazir: bool = false

func _ready() -> void:
	savas_yoneticisi = get_tree().current_scene
	add_to_group("Askerler") 
	
	if can_bari:
		can_bari.max_value = can
		can_bari.value = can
	
	# Temel Takım Renklendirmesi
	var yeni_materyal = StandardMaterial3D.new()
	if takim == "Oyuncu":
		yeni_materyal.albedo_color = Color(0.1, 0.5, 1.0) # Parlak Mavi
	else:
		yeni_materyal.albedo_color = Color(1.0, 0.1, 0.1) # Parlak Kırmızı
		
	if has_node("MeshInstance3D"):
		$MeshInstance3D.material_override = yeni_materyal

	# Otomatik Basit Silah Kutusu Oluşturma
	if not has_node("Silah"):
		var yeni_silah_node = Node3D.new()
		yeni_silah_node.name = "Silah"
		add_child(yeni_silah_node)
		
		var namlu_mesh = MeshInstance3D.new()
		namlu_mesh.name = "Namlu"
		var box = BoxMesh.new()
		box.size = Vector3(0.2, 0.2, 0.8) 
		namlu_mesh.mesh = box
		namlu_mesh.position = Vector3(0.0, 0.2, -0.6)
		
		var sila_mat = StandardMaterial3D.new()
		sila_mat.albedo_color = Color.BLACK
		namlu_mesh.material_override = sila_mat
		yeni_silah_node.add_child(namlu_mesh)

	nav_agent.path_desired_distance = 2.0
	nav_agent.target_desired_distance = 2.0
	
	if not nav_agent.velocity_computed.is_connected(_on_navigation_agent_3d_velocity_computed):
		nav_agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)

	hedef_timer.wait_time = 0.2
	if not hedef_timer.timeout.is_connected(_en_yakin_dusmani_bul):
		hedef_timer.timeout.connect(_en_yakin_dusmani_bul)
	hedef_timer.start()
	_en_yakin_dusmani_bul() 

	await get_tree().physics_frame
	harita_hazir = true

func _physics_process(delta: float) -> void:
	if can <= 0 or not harita_hazir: return
	if Engine.get_physics_frames() < 10: return
		
	var hesaplanan_hiz = Vector3.ZERO
		
	if mevcut_hedef and is_instance_valid(mevcut_hedef) and mevcut_hedef.can > 0:
		var hedef_konum = mevcut_hedef.global_position
		
		var bakis_konumu = Vector3(hedef_konum.x, global_position.y, hedef_konum.z)
		if global_position.distance_to(bakis_konumu) > 0.2:
			look_at(bakis_konumu, Vector3.UP)
		
		var mesafe = global_position.distance_to(hedef_konum)
		
		if mesafe <= atis_menzili:
			velocity = Vector3.ZERO
			_ates_et_denetle()
			move_and_slide() 
		else:
			nav_agent.target_position = hedef_konum
			if not nav_agent.is_navigation_finished():
				var sonraki_nokta = nav_agent.get_next_path_position()
				var yon = (sonraki_nokta - global_position).normalized()
				hesaplanan_hiz = yon * hareket_hizi
				nav_agent.set_velocity(hesaplanan_hiz)
			else:
				velocity = Vector3.ZERO
				move_and_slide()
	else:
		velocity = Vector3.ZERO
		move_and_slide()
		_en_yakin_dusmani_bul()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if can <= 0: return
	if mevcut_hedef and is_instance_valid(mevcut_hedef) and mevcut_hedef.can > 0:
		if global_position.distance_to(mevcut_hedef.global_position) > atis_menzili:
			velocity = safe_velocity
			move_and_slide()

func _en_yakin_dusmani_bul() -> void:
	var en_yakin_mesafe = 9999.0
	var yeni_hedef = null
	
	var tum_askerler = get_tree().get_nodes_in_group("Askerler")
	for grup_elemani in tum_askerler:
		if is_instance_valid(grup_elemani) and grup_elemani != self and grup_elemani.can > 0:
			if grup_elemani.takim != self.takim:
				var m = global_position.distance_to(grup_elemani.global_position)
				if m < en_yakin_mesafe:
					en_yakin_mesafe = m
					yeni_hedef = grup_elemani
					
	mevcut_hedef = yeni_hedef

# 🎯 NEON MERMİ İZİ, SES VE KAMERA SALLANTISINI KORUYAN ATİŞ MOTORU
func _ates_et_denetle() -> void:
	if ates_edebilir_mi and mevcut_hedef and is_instance_valid(mevcut_hedef) and mevcut_hedef.can > 0:
		ates_edebilir_mi = false
		
		# 1. Neon Mermi İzi Efektini dünyada oluştur
		if ResourceLoader.exists("res://MermiIzi.tscn"):
			var mermi_izi_sahnesi = load("res://MermiIzi.tscn")
			var mermi = mermi_izi_sahnesi.instantiate()
			get_tree().current_scene.add_child(mermi)
			
			var namlu_konumu = global_position + Vector3(0, 0.2, -0.6).rotated(Vector3.UP, rotation.y)
			var dusman_konumu = mevcut_hedef.global_position + Vector3(0, 0.5, 0)
			
			mermi.mermiyi_uzat_ve_yonlendir(namlu_konumu, dusman_konumu)
		
		# 2. Hasarı anında karşıya güvenle işle
		if mevcut_hedef.has_method("hasar_al"):
			mevcut_hedef.hasar_al(hasar_gucu)
		
		# 3. Silah sesini patlat
		if has_node("AtisSesi"):
			$AtisSesi.play()
		
		# 4. Savaş yöneticisinden kamerayı salla
		if savas_yoneticisi and savas_yoneticisi.has_method("kamera_salla"):
			savas_yoneticisi.kamera_salla(0.12)
		
		# 5. Silahın geri tepme efekti (Recoil)
		if has_node("Silah"):
			$Silah.position.z = 0.2
			get_tree().create_timer(0.05).timeout.connect(func(): if has_node("Silah"): $Silah.position.z = 0.0)
		
		get_tree().create_timer(0.4).timeout.connect(func(): ates_edebilir_mi = true)

func hasar_al(miktar: float) -> void:
	if can <= 0: return
	can -= miktar
	
	if can_bari:
		can_bari.value = can
	
	# Vurulma anında tam gövdeden kan fışkırtma motoru aktif
	var kan = kan_efekti_sahnesi.instantiate()
	get_tree().current_scene.add_child(kan)
	kan.global_position = global_position + Vector3(0, 0.5, 0)

	# Hasar anında anlık flaş patlaması (Kapsül rengini bozmaz)
	if has_node("MeshInstance3D"):
		var mat = $MeshInstance3D.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = Color.WHITE
			get_tree().create_timer(0.1).timeout.connect(func(): 
				if is_instance_valid(self) and mat and can > 0:
					mat.albedo_color = Color(0.1, 0.5, 1.0) if takim == "Oyuncu" else Color(1.0, 0.1, 0.1)
			)

	if can <= 0:
		can = 0
		remove_from_group("Askerler")
		if savas_yoneticisi and savas_yoneticisi.has_method("asker_oldu"):
			savas_yoneticisi.asker_oldu(takim)
		queue_free()
