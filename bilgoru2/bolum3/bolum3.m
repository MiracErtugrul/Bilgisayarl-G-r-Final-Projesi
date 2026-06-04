pkg load image;
close all;
clear all;

disp('--- Kahve Cekirdekleri Icin Guncel Sayim Baslatildi ---');
img = imread('taneler.jpg');

if size(img, 3) == 3
    gray_img = rgb2gray(img);
else
    gray_img = img;
end

bw = gray_img < 220;
bw_filled = imfill(bw, 'holes');

maske = ones(3, 3);
bw_clean = imopen(bw_filled, maske);
bw_clean = imclose(bw_clean, maske);

[~, tane_sayisi] = bwlabel(bw_clean);

fid = fopen('tane_sonucu.txt', 'w');
fprintf(fid, '==================================================\n');
fprintf(fid, '        BOLUM 3: KAHVE CEKIRDEGI RAPORU           \n');
fprintf(fid, '==================================================\n');
fprintf(fid, 'Analiz Edilen Gorsel : taneler.jpg\n');
fprintf(fid, 'Tespit Edilen Tane   : %d adet\n', tane_sayisi);
fprintf(fid, 'Durum                : Basariyla Tamamlandi\n');
fprintf(fid, '==================================================\n');
fclose(fid);

fprintf('\n>>> Analiz Tamamlandi! Sonuc "tane_sonucu.txt" dosyasina yazildi. <<<\n');
fprintf('>>> Gorseldeki Net Tane Sayisi: %d <<<\n\n', tane_sayisi);

imshow(bw_clean);
title(['Kahve Cekirdegi Sayisi: ' num2str(tane_sayisi)]);