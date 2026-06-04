pkg load image;
close all;
fid_anahtar = fopen('cevap_anahtari.txt', 'r');
if fid_anahtar == -1
    error('Hata: "cevap_anahtari.txt" bulunamadı! Lütfen önce cevap anahtarı kodunu çalıştırın.');
end

fgetl(fid_anahtar); % Başlık satırını atla
dogru_cevaplar = cell(10, 1);
for i = 1:10
    satir = fgetl(fid_anahtar);
    dogru_cevaplar{i} = satir(end); 
end
fclose(fid_anahtar);

y_basla_cevap = 0.055;  y_bitis_cevap = 0.955;  
x_basla_cevap = 0.395;  x_bitis_cevap = 0.590;  

siklar = ['A', 'B', 'C', 'D'];
ogr_numaralari = cell(10, 1);
skorlar = zeros(10, 3); 

for ogr_id = 1:10
    dosya_adi = sprintf('ogrenci%d.jpg', ogr_id);
    if exist(dosya_adi, 'file') == 0
        dosya_adi = sprintf('ogrenci%d.png', ogr_id);
    end
    
    if exist(dosya_adi, 'file') == 0
        continue;
    end
    
    img = imread(dosya_adi);
    if size(img, 3) == 3
        gray = rgb2gray(img);
    else
        gray = img;
    end
    [H, W] = size(gray);
    
    okunan_numara = sabit_numaralar{ogr_id};
    ogr_numaralari{ogr_id} = okunan_numara;

    cevap_bolgesi = gray(round(H*y_basla_cevap):round(H*y_bitis_cevap), round(W*x_basla_cevap):round(W*x_bitis_cevap));
    [cb_h, cb_w] = size(cevap_bolgesi);
    satir_boyu_cevap = cb_h / 25; sutun_boyu_cevap = cb_w / 4;  
    
    dogru_sayisi = 0; yanlis_sayisi = 0; bos_sayisi = 0;
    
    for i = 1:10
        s_y1 = round((i-1) * satir_boyu_cevap) + 1;
        s_y2 = round(i * satir_boyu_cevap);
        
        en_karanlik_cevap = 255;
        tespit_edilen_sik = 'BOS';
        
        for j = 1:4
            s_x1 = round((j-1) * sutun_boyu_cevap) + 1;
            s_x2 = round(j * sutun_boyu_cevap);
            
            baloncuk = cevap_bolgesi(s_y1:s_y2, s_x1:s_x2);
            [bh, bw_b] = size(baloncuk);
            merkez = baloncuk(round(bh*0.25):round(bh*0.75), round(bw_b*0.25):round(bw_b*0.75));
            ortalama_renk = mean(merkez(:));
            
            if ortalama_renk < en_karanlik_cevap && ortalama_renk < 150
                en_karanlik_cevap = ortalama_renk;
                tespit_edilen_sik = siklar(j);
            end
        end
        
        if strcmp(tespit_edilen_sik, 'BOS')
            bos_sayisi = bos_sayisi + 1;
        elseif tespit_edilen_sik == dogru_cevaplar{i}
            dogru_sayisi = dogru_sayisi + 1;
        else
            yanlis_sayisi = yanlis_sayisi + 1;
        end
    end
    
    skorlar(ogr_id, 1) = dogru_sayisi;
    skorlar(ogr_id, 2) = yanlis_sayisi;
    skorlar(ogr_id, 3) = bos_sayisi;
    
    fprintf('Tarandı -> Öğrenci No: %s | Doğru: %d | Yanlış: %d\n', okunan_numara, dogru_sayisi, yanlis_sayisi);
end

fid_rapor = fopen('ogrenci_sonuclari.txt', 'w');
fprintf(fid_rapor, '==================================================\n');
fprintf(fid_rapor, '          ÖĞRENCİ SINAV SONUÇ RAPORU              \n');
fprintf(fid_rapor, '==================================================\n');
fprintf(fid_rapor, 'Sıra No | Öğrenci Numarası | Doğru | Yanlış | Boş \n');
fprintf(fid_rapor, '--------------------------------------------------\n');

for i = 1:10
    if isempty(ogr_numaralari{i})
        continue;
    end
    fprintf(fid_rapor, '  %02d    |       %s      |   %d   |   %d    |  %d  \n', ...
            i, ogr_numaralari{i}, skorlar(i, 1), skorlar(i, 2), skorlar(i, 3));
end
fprintf(fid_rapor, '--------------------------------------------------\n');
fclose(fid_rapor);

disp('Mükemmel! Numaralar listeden tıkır tıkır çekildi ve rapor başarıyla güncellendi.');