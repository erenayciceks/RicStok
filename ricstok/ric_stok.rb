require 'json'
require 'date'

# Renk modülü
module Renkler
  def self.kirmizi(text); "\e[31m#{text}\e[0m" end
  def self.yesil(text); "\e[32m#{text}\e[0m" end
  def self.sari(text); "\e[33m#{text}\e[0m" end
  def self.mavi(text); "\e[34m#{text}\e[0m" end
  def self.mor(text); "\e[35m#{text}\e[0m" end
  def self.turkuaz(text); "\e[36m#{text}\e[0m" end
end

def show_banner
  puts "\n"
  puts Renkler.turkuaz("██████╗ ██╗ ██████╗███████╗████████╗ ██████╗ ██╗  ██╗")
  puts Renkler.turkuaz("██╔══██╗██║██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██║ ██╔╝")
  puts Renkler.turkuaz("██████╔╝██║██║     ███████╗   ██║   ██║   ██║█████╔╝ ")
  puts Renkler.turkuaz("██╔══██╗██║██║     ╚════██║   ██║   ██║   ██║██╔═██╗ ")
  puts Renkler.turkuaz("██║  ██║██║╚██████╗███████║   ██║   ╚██████╔╝██║  ██╗")
  puts Renkler.turkuaz("╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝")
  puts "\n"
  puts Renkler.sari("     Market Yönetim Sistemi v2.0")
  puts Renkler.sari("     Geliştirici: RicSoft Yazılım")
  puts Renkler.sari("     © 2024 Tüm hakları saklıdır.")
  puts "\n"
  puts Renkler.mor("=" * 60)
  puts "\n"
end

class UrunYonetimi
  KATEGORILER = ['Gıda', 'İçecek', 'Temizlik', 'Kişisel Bakım', 'Ev Gereçleri', 'Diğer']

  def initialize
    @urunler = load_urunler
    @satis_gecmisi = load_satis_gecmisi
  end

  def load_urunler
    if File.exist?('urunler.json')
      JSON.parse(File.read('urunler.json'))
    else
      {}
    end
  end

  def load_satis_gecmisi
    if File.exist?('satis_gecmisi.json')
      JSON.parse(File.read('satis_gecmisi.json'))
    else
      []
    end
  end

  def save_urunler
    File.write('urunler.json', JSON.pretty_generate(@urunler))
  end

  def save_satis_gecmisi
    File.write('satis_gecmisi.json', JSON.pretty_generate(@satis_gecmisi))
  end

  def urun_ekle(kod, isim, fiyat, miktar, kategori, birim = 'adet')
    if @urunler[kod]
      puts Renkler.kirmizi("\nHATA: Bu ürün kodu zaten mevcut!")
      return false
    end

    unless KATEGORILER.include?(kategori)
      puts Renkler.kirmizi("\nHATA: Geçersiz kategori!")
      return false
    end

    @urunler[kod] = {
      'isim' => isim,
      'fiyat' => fiyat,
      'miktar' => miktar,
      'kategori' => kategori,
      'birim' => birim,
      'son_guncelleme' => Time.now.strftime("%Y-%m-%d %H:%M:%S"),
      'kritik_stok' => 5
    }
    save_urunler
    puts Renkler.yesil("\nÜrün başarıyla eklendi!")
    true
  end

  def urun_guncelle(kod, yeni_bilgiler)
    unless @urunler[kod]
      puts Renkler.kirmizi("\nHATA: Ürün bulunamadı!")
      return false
    end

    if yeni_bilgiler['kategori'] && !KATEGORILER.include?(yeni_bilgiler['kategori'])
      puts Renkler.kirmizi("\nHATA: Geçersiz kategori!")
      return false
    end

    yeni_bilgiler.each do |anahtar, deger|
      @urunler[kod][anahtar] = deger if ['isim', 'fiyat', 'miktar', 'kategori', 'birim', 'kritik_stok'].include?(anahtar)
    end
    @urunler[kod]['son_guncelleme'] = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    save_urunler
    puts Renkler.yesil("\nÜrün başarıyla güncellendi!")
    true
  end

  def urun_sil(kod)
    if @urunler.delete(kod)
      save_urunler
      puts Renkler.yesil("\nÜrün başarıyla silindi!")
      true
    else
      puts Renkler.kirmizi("\nHATA: Ürün bulunamadı!")
      false
    end
  end

  def stok_raporu(kategori = nil)
    puts "\n" + Renkler.mavi("STOK RAPORU")
    puts Renkler.mavi("=" * 75)
    puts Renkler.turkuaz(sprintf("%-10s %-20s %-10s %-8s %-10s %-10s", 
      "KOD", "İSİM", "FİYAT", "MİKTAR", "BİRİM", "KATEGORİ"))
    puts Renkler.mavi("-" * 75)

    urunler = kategori ? @urunler.select { |_, u| u['kategori'] == kategori } : @urunler

    urunler.each do |kod, urun|
      puts sprintf("%-10s %-20s %-10.2f %-8d %-10s %-10s",
        kod, urun['isim'], urun['fiyat'], urun['miktar'], urun['birim'], urun['kategori'])
    end
    puts Renkler.mavi("=" * 75)
  end

  def kategori_listele
    puts "\n" + Renkler.mavi("KATEGORİLER")
    puts Renkler.mavi("=" * 30)
    KATEGORILER.each_with_index do |kategori, index|
      puts Renkler.turkuaz("#{index + 1}. #{kategori}")
    end
    puts Renkler.mavi("=" * 30)
  end

  def dusuk_stok_raporu
    puts "\n" + Renkler.kirmizi("DÜŞÜK STOK RAPORU")
    puts Renkler.kirmizi("=" * 75)
    dusuk_stoklar = @urunler.select { |_, urun| urun['miktar'] <= urun['kritik_stok'] }
    
    if dusuk_stoklar.empty?
      puts Renkler.yesil("Kritik stok seviyesinin altında ürün bulunmamaktadır.")
    else
      dusuk_stoklar.each do |kod, urun|
        puts Renkler.sari("#{urun['isim']} (#{kod}): #{urun['miktar']} #{urun['birim']} kaldı! (Kritik seviye: #{urun['kritik_stok']})")
      end
    end
    puts Renkler.kirmizi("=" * 75)
  end

  def satis_yap(kod, miktar)
    unless @urunler[kod]
      puts Renkler.kirmizi("\nHATA: Ürün bulunamadı!")
      return false
    end

    if @urunler[kod]['miktar'] < miktar
      puts Renkler.kirmizi("\nHATA: Stokta yeterli ürün yok!")
      return false
    end

    toplam_fiyat = @urunler[kod]['fiyat'] * miktar
    @urunler[kod]['miktar'] -= miktar

    satis = {
      'urun_kodu' => kod,
      'urun_adi' => @urunler[kod]['isim'],
      'miktar' => miktar,
      'birim_fiyat' => @urunler[kod]['fiyat'],
      'toplam_fiyat' => toplam_fiyat,
      'tarih' => Time.now.strftime("%Y-%m-%d %H:%M:%S")
    }

    @satis_gecmisi.push(satis)
    save_urunler
    save_satis_gecmisi

    puts Renkler.yesil("\nSatış başarıyla kaydedildi!")
    puts Renkler.sari("Toplam Tutar: #{toplam_fiyat.round(2)} TL")
    true
  end

  def satis_raporu(baslangic_tarih = nil, bitis_tarih = nil)
    satislar = @satis_gecmisi
    
    if baslangic_tarih && bitis_tarih
      satislar = satislar.select do |satis|
        satis_tarihi = Time.parse(satis['tarih'])
        satis_tarihi >= Time.parse(baslangic_tarih) && satis_tarihi <= Time.parse(bitis_tarih)
      end
    end

    puts "\n" + Renkler.mavi("SATIŞ RAPORU")
    if baslangic_tarih && bitis_tarih
      puts Renkler.mavi("#{baslangic_tarih} - #{bitis_tarih}")
    end
    puts Renkler.mavi("=" * 85)
    puts Renkler.turkuaz(sprintf("%-20s %-20s %-8s %-12s %-12s %-12s",
      "TARİH", "ÜRÜN", "MİKTAR", "BİRİM FİYAT", "TOPLAM", "ÜRÜN KODU"))
    puts Renkler.mavi("-" * 85)

    toplam_gelir = 0
    satislar.each do |satis|
      puts sprintf("%-20s %-20s %-8d %-12.2f %-12.2f %-12s",
        satis['tarih'], satis['urun_adi'], satis['miktar'],
        satis['birim_fiyat'], satis['toplam_fiyat'], satis['urun_kodu'])
      toplam_gelir += satis['toplam_fiyat']
    end

    puts Renkler.mavi("-" * 85)
    puts Renkler.yesil(sprintf("TOPLAM GELİR: %.2f TL", toplam_gelir))
    puts Renkler.mavi("=" * 85)
  end

  def urun_ara(arama_metni)
    puts "\n" + Renkler.mavi("ARAMA SONUÇLARI")
    puts Renkler.mavi("=" * 75)
    
    bulunan_urunler = @urunler.select do |kod, urun|
      urun['isim'].downcase.include?(arama_metni.downcase) || 
      kod.downcase.include?(arama_metni.downcase)
    end

    if bulunan_urunler.empty?
      puts Renkler.kirmizi("Arama kriterine uygun ürün bulunamadı!")
    else
      puts Renkler.turkuaz(sprintf("%-10s %-20s %-10s %-8s %-10s %-10s",
        "KOD", "İSİM", "FİYAT", "MİKTAR", "BİRİM", "KATEGORİ"))
      puts Renkler.mavi("-" * 75)

      bulunan_urunler.each do |kod, urun|
        puts sprintf("%-10s %-20s %-10.2f %-8d %-10s %-10s",
          kod, urun['isim'], urun['fiyat'], urun['miktar'],
          urun['birim'], urun['kategori'])
      end
    end
    puts Renkler.mavi("=" * 75)
  end
end

def ana_menu
  sistem = UrunYonetimi.new
  
  loop do
    show_banner
    puts Renkler.mor("MENÜ SEÇENEKLERİ")
    puts Renkler.mor("-" * 25)
    puts Renkler.turkuaz("1.  Ürün Ekle")
    puts Renkler.turkuaz("2.  Ürün Güncelle")
    puts Renkler.turkuaz("3.  Ürün Sil")
    puts Renkler.turkuaz("4.  Stok Raporu")
    puts Renkler.turkuaz("5.  Kategoriye Göre Listele")
    puts Renkler.turkuaz("6.  Düşük Stok Raporu")
    puts Renkler.turkuaz("7.  Satış Yap")
    puts Renkler.turkuaz("8.  Satış Raporu")
    puts Renkler.turkuaz("9.  Ürün Ara")
    puts Renkler.turkuaz("10. Kategori Listesi")
    puts Renkler.kirmizi("0.  Çıkış")
    puts Renkler.mor("-" * 25)
    print Renkler.sari("Seçiminiz: ")
    
    case gets.chomp
    when "1"
      print Renkler.yesil("\nÜrün Kodu: ")
      kod = gets.chomp
      print Renkler.yesil("Ürün İsmi: ")
      isim = gets.chomp
      print Renkler.yesil("Fiyat (TL): ")
      fiyat = gets.chomp.to_f
      print Renkler.yesil("Miktar: ")
      miktar = gets.chomp.to_i
      print Renkler.yesil("Birim (adet/kg/lt): ")
      birim = gets.chomp
      
      sistem.kategori_listele
      print Renkler.yesil("Kategori Numarası: ")
      kategori_no = gets.chomp.to_i
      kategori = UrunYonetimi::KATEGORILER[kategori_no - 1] if (1..UrunYonetimi::KATEGORILER.length).include?(kategori_no)
      
      sistem.urun_ekle(kod, isim, fiyat, miktar, kategori, birim)
    
    when "2"
      print Renkler.yesil("\nGüncellenecek Ürün Kodu: ")
      kod = gets.chomp
      print Renkler.yesil("Yeni İsim (boş bırakılabilir): ")
      isim = gets.chomp
      print Renkler.yesil("Yeni Fiyat (boş bırakılabilir): ")
      fiyat = gets.chomp
      print Renkler.yesil("Yeni Miktar (boş bırakılabilir): ")
      miktar = gets.chomp
      print Renkler.yesil("Yeni Birim (boş bırakılabilir): ")
      birim = gets.chomp
      print Renkler.yesil("Kritik Stok Seviyesi (boş bırakılabilir): ")
      kritik_stok = gets.chomp
      
      yeni_bilgiler = {}
      yeni_bilgiler['isim'] = isim unless isim.empty?
      yeni_bilgiler['fiyat'] = fiyat.to_f unless fiyat.empty?
      yeni_bilgiler['miktar'] = miktar.to_i unless miktar.empty?
      yeni_bilgiler['birim'] = birim unless birim.empty?
      yeni_bilgiler['kritik_stok'] = kritik_stok.to_i unless kritik_stok.empty?
      
      sistem.urun_guncelle(kod, yeni_bilgiler)
    
    when "3"
      print Renkler.yesil("\nSilinecek Ürün Kodu: ")
      kod = gets.chomp
      sistem.urun_sil(kod)
    
    when "4"
      sistem.stok_raporu
    
    when "5"
      sistem.kategori_listele
      print Renkler.yesil("\nKategori Numarası: ")
      kategori_no = gets.chomp.to_i
      if (1..UrunYonetimi::KATEGORILER.length).include?(kategori_no)
        sistem.stok_raporu(UrunYonetimi::KATEGORILER[kategori_no - 1])
      else
        puts Renkler.kirmizi("\nGeçersiz kategori numarası!")
      end
    
    when "6"
      sistem.dusuk_stok_raporu
    
    when "7"
      print Renkler.yesil("\nÜrün Kodu: ")
      kod = gets.chomp
      print Renkler.yesil("Satış Miktarı: ")
      miktar = gets.chomp.to_i
      
      sistem.satis_yap(kod, miktar)
    
    when "8"
      puts Renkler.yesil("\nTarih aralığı belirtmek ister misiniz? (E/H)")
      if gets.chomp.upcase == 'E'
        print Renkler.yesil("Başlangıç Tarihi (YYYY-AA-GG): ")
        baslangic = gets.chomp
        print Renkler.yesil("Bitiş Tarihi (YYYY-AA-GG): ")
        bitis = gets.chomp
        sistem.satis_raporu(baslangic, bitis)
      else
        sistem.satis_raporu
      end
    
    when "9"
      print Renkler.yesil("\nArama Metni: ")
      arama = gets.chomp
      sistem.urun_ara(arama)
    
    when "10"
      sistem.kategori_listele
    
    when "0"
      puts Renkler.kirmizi("\nProgram sonlandırılıyor...")
      break
    else
      puts Renkler.kirmizi("\nGeçersiz seçim!")
    end
    
    puts "\nDevam etmek için bir tuşa basın..."
    gets
  end
end

# Programı başlat
ana_menu 