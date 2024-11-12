-- 76. Liệt kê top 3 chuyên gia có nhiều kỹ năng nhất và số lượng kỹ năng của họ.
SELECT TOP 3 cg.HoTen, COUNT(ck.MaKyNang) AS SoLuongKyNang
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang ck ON cg.MaChuyenGia = ck.MaChuyenGia
GROUP BY cg.HoTen
ORDER BY SoLuongKyNang DESC;

-- 77. Tìm các cặp chuyên gia có cùng chuyên ngành và số năm kinh nghiệm chênh lệch không quá 2 năm.
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2, cg1.ChuyenNganh
FROM ChuyenGia cg1
JOIN ChuyenGia cg2 ON cg1.ChuyenNganh = cg2.ChuyenNganh 
    AND cg1.MaChuyenGia < cg2.MaChuyenGia 
    AND ABS(cg1.NamKinhNghiem - cg2.NamKinhNghiem) <= 2;

-- 78. Hiển thị tên công ty, số lượng dự án và tổng số năm kinh nghiệm của các chuyên gia tham gia dự án của công ty đó.
SELECT c.TenCongTy, COUNT(DISTINCT d.MaDuAn) AS SoLuongDuAn, SUM(cg.NamKinhNghiem) AS TongNamKinhNghiem
FROM CongTy c
JOIN DuAn d ON c.MaCongTy = d.MaCongTy
JOIN ChuyenGia_DuAn cgd ON d.MaDuAn = cgd.MaDuAn
JOIN ChuyenGia cg ON cgd.MaChuyenGia = cg.MaChuyenGia
GROUP BY c.TenCongTy;

-- 79. Tìm các chuyên gia có ít nhất một kỹ năng cấp độ 5 nhưng không có kỹ năng nào dưới cấp độ 3.
SELECT cg.HoTen
FROM ChuyenGia cg
JOIN ChuyenGia_KyNang ck ON cg.MaChuyenGia = ck.MaChuyenGia
GROUP BY cg.HoTen
HAVING MAX(ck.CapDo) = 5 AND MIN(ck.CapDo) >= 3;

-- 80. Liệt kê các chuyên gia và số lượng dự án họ tham gia, bao gồm cả những chuyên gia không tham gia dự án nào.
SELECT cg.HoTen, COUNT(cgd.MaDuAn) AS SoLuongDuAn
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_DuAn cgd ON cg.MaChuyenGia = cgd.MaChuyenGia
GROUP BY cg.HoTen;

-- 81*. Tìm chuyên gia có kỹ năng ở cấp độ cao nhất trong mỗi loại kỹ năng.
SELECT k.TenKyNang, cg.HoTen, ck.CapDo
FROM KyNang k
JOIN ChuyenGia_KyNang ck ON k.MaKyNang = ck.MaKyNang
JOIN ChuyenGia cg ON ck.MaChuyenGia = cg.MaChuyenGia
WHERE ck.CapDo = (
    SELECT MAX(ck2.CapDo)
    FROM ChuyenGia_KyNang ck2
    WHERE ck2.MaKyNang = k.MaKyNang
);

-- 82. Tính tỷ lệ phần trăm của mỗi chuyên ngành trong tổng số chuyên gia.
SELECT ChuyenNganh, 
       COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ChuyenGia) AS TyLePhanTram
FROM ChuyenGia
GROUP BY ChuyenNganh;

-- 83. Tìm các cặp kỹ năng thường xuất hiện cùng nhau nhất trong hồ sơ của các chuyên gia.
SELECT k1.TenKyNang AS KyNang1, k2.TenKyNang AS KyNang2, COUNT(*) AS SoLanXuatHien
FROM ChuyenGia_KyNang ck1
JOIN ChuyenGia_KyNang ck2 ON ck1.MaChuyenGia = ck2.MaChuyenGia AND ck1.MaKyNang < ck2.MaKyNang
JOIN KyNang k1 ON ck1.MaKyNang = k1.MaKyNang
JOIN KyNang k2 ON ck2.MaKyNang = k2.MaKyNang
GROUP BY k1.TenKyNang, k2.TenKyNang
ORDER BY SoLanXuatHien DESC;

-- 84. Tính số ngày trung bình giữa ngày bắt đầu và ngày kết thúc của các dự án cho mỗi công ty.
SELECT c.TenCongTy, AVG(DATEDIFF(DAY, d.NgayBatDau, d.NgayKetThuc)) AS SoNgayTrungBinh
FROM CongTy c
JOIN DuAn d ON c.MaCongTy = d.MaCongTy
GROUP BY c.TenCongTy;

-- 85*. Tìm chuyên gia có sự kết hợp độc đáo nhất của các kỹ năng (kỹ năng mà chỉ họ có).
SELECT cg.HoTen
FROM ChuyenGia cg
WHERE NOT EXISTS (
    SELECT 1
    FROM ChuyenGia cg2
    WHERE cg.MaChuyenGia <> cg2.MaChuyenGia
    AND NOT EXISTS (
        SELECT 1
        FROM ChuyenGia_KyNang ck1
        JOIN ChuyenGia_KyNang ck2 ON ck1.MaKyNang = ck2.MaKyNang
        WHERE ck1.MaChuyenGia = cg.MaChuyenGia AND ck2.MaChuyenGia = cg2.MaChuyenGia
    )
);

-- 86*. Tạo một bảng xếp hạng các chuyên gia dựa trên số lượng dự án và tổng cấp độ kỹ năng.
SELECT cg.HoTen, 
       COUNT(cgd.MaDuAn) AS SoLuongDuAn, 
       SUM(ck.CapDo) AS TongCapDoKyNang,
       RANK() OVER (ORDER BY COUNT(cgd.MaDuAn) DESC, SUM(ck.CapDo) DESC) AS XepHang
FROM ChuyenGia cg
LEFT JOIN ChuyenGia_DuAn cgd ON cg.MaChuyenGia = cgd.MaChuyenGia
LEFT JOIN ChuyenGia_KyNang ck ON cg.MaChuyenGia = ck.MaChuyenGia
GROUP BY cg.HoTen;

-- 87. Tìm các dự án có sự tham gia của chuyên gia từ tất cả các chuyên ngành.
SELECT d.TenDuAn
FROM DuAn d
JOIN ChuyenGia_DuAn cgd ON d.MaDuAn = cgd.MaDuAn
JOIN ChuyenGia cg ON cgd.MaChuyenGia = cg.MaChuyenGia
GROUP BY d.TenDuAn
HAVING COUNT(DISTINCT cg.ChuyenNganh) = (SELECT COUNT(DISTINCT ChuyenNganh) FROM ChuyenGia);

-- 88. Tính tỷ lệ thành công của mỗi công ty dựa trên số dự án hoàn thành so với tổng số dự án.
SELECT c.TenCongTy, 
       COUNT(CASE WHEN d.TrangThai = 'HoanThanh' THEN 1 END) * 100.0 / COUNT(*) AS TyLeThanhCong
FROM CongTy c
JOIN DuAn d ON c.MaCongTy = d.MaCongTy
GROUP BY c.TenCongTy;

-- 89. Tìm các chuyên gia có kỹ năng "bù trừ" nhau (một người giỏi kỹ năng A nhưng yếu kỹ năng B, người kia ngược lại).
SELECT cg1.HoTen AS ChuyenGia1, cg2.HoTen AS ChuyenGia2, k1.TenKyNang AS KyNangA, k2.TenKyNang AS KyNangB
FROM ChuyenGia_KyNang ck1
JOIN ChuyenGia_KyNang ck2 ON ck1.MaKyNang = ck2.MaKyNang AND ck1.MaChuyenGia < ck2.MaChuyenGia
JOIN ChuyenGia cg1 ON ck1.MaChuyenGia = cg1.MaChuyenGia
JOIN ChuyenGia cg2 ON ck2.MaChuyenGia = cg2.MaChuyenGia
JOIN KyNang k1 ON ck1.MaKyNang = k1.MaKyNang
JOIN KyNang k2 ON ck2.MaKyNang = k2.MaKyNang
WHERE ck1.CapDo >= 4 AND ck2.CapDo <= 2;
