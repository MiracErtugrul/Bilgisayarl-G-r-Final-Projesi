pkg load image;

img = imread('evrak.jpg'); 
if size(img, 3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

threshold = graythresh(gray);
mask = im2bw(gray, threshold);

mask = imfill(mask, 'holes');
cc = bwconncomp(mask);
numPixels = cellfun(@numel, cc.PixelIdxList);
[~, idx] = max(numPixels);
yeni_maske = false(size(mask));
yeni_maske(cc.PixelIdxList{idx}) = true;
mask = yeni_maske;

maskelenmis_img = img;
mask_3d = repmat(mask, [1 1 size(img,3)]);
maskelenmis_img(~mask_3d) = 0;

imwrite(maskelenmis_img, '1_maskelenmis.jpg');


enhanced = imadjust(gray);
enhanced(~mask) = 255;

imwrite(enhanced, '2_kontrastli.jpg');

[y, x] = find(mask);
noktalar = [x, y];

toplam = x + y;
fark = x - y;

[~, tl_idx] = min(toplam); sol_ust = noktalar(tl_idx, :);
[~, br_idx] = max(toplam); sag_alt = noktalar(br_idx, :);
[~, tr_idx] = max(fark);   sag_ust = noktalar(tr_idx, :);
[~, bl_idx] = min(fark);   sol_alt = noktalar(bl_idx, :);

kose_noktalari = [sol_ust; sag_ust; sag_alt; sol_alt];

genislik = round(max(norm(sag_ust - sol_ust), norm(sag_alt - sol_alt)));
yukseklik = round(max(norm(sol_alt - sol_ust), norm(sag_alt - sag_ust)));

hedef_koseler = [1, 1; genislik, 1; genislik, yukseklik; 1, yukseklik];

tform = cp2tform(kose_noktalari, hedef_koseler, 'projective');
son_evrak = imtransform(enhanced, tform, 'XData', [1 genislik], 'YData', [1 yukseklik]);

imwrite(son_evrak, '3_duzeltilmis_evrak.jpg');

figure;
subplot(1,3,1); imshow(maskelenmis_img); title('1. Maskelenmiş');
subplot(1,3,2); imshow(enhanced); title('2. Kontrast');
subplot(1,3,3); imshow(son_evrak); title('3. Düzeltilmiş');

disp('İşlem Tamam! Çıktılar sol panele kaydedildi. Oradan üzerine tıklayıp indirebilirsiniz.');