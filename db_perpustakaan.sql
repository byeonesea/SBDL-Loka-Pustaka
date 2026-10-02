-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 08, 2026 at 05:49 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_perpustakaan`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `id_admin` int(11) NOT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`id_admin`, `nama`, `username`, `password`) VALUES
(3959, 'liriana', 'liriana', 'liriana123'),
(3960, 'Cian', 'Cia', 'cia123');

-- --------------------------------------------------------

--
-- Table structure for table `anggota`
--

CREATE TABLE `anggota` (
  `id_anggota` int(11) NOT NULL,
  `kode_anggota` varchar(20) DEFAULT NULL,
  `nama` varchar(100) DEFAULT NULL,
  `jenis_kelamin` varchar(20) DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `no_hp` varchar(15) DEFAULT NULL,
  `tanggal_daftar` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `anggota`
--

INSERT INTO `anggota` (`id_anggota`, `kode_anggota`, `nama`, `jenis_kelamin`, `alamat`, `no_hp`, `tanggal_daftar`) VALUES
(1, '00001', 'Suci Rahmadani', 'Perempuan', 'Purbalinga', '092845569112', '2026-05-28'),
(2, '00002', 'Sion', 'Laki-laki', 'Purbalingga', '083866955071', '2026-05-27'),
(3, '00003', 'Aina', 'Perempuan', 'Purbalingga, Kalikajar', '083869220991', '2026-05-31');

--
-- Triggers `anggota`
--
DELIMITER $$
CREATE TRIGGER `sebelum_hapus_anggota` BEFORE DELETE ON `anggota` FOR EACH ROW BEGIN
    DECLARE jumlah_pinjaman_aktif INT;
    
    SELECT COUNT(*) INTO jumlah_pinjaman_aktif 
    FROM peminjaman 
    WHERE id_anggota = OLD.id_anggota AND status = 'Dipinjam';
    
    IF jumlah_pinjaman_aktif > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'GAGAL: Anggota ini tidak bisa dihapus karena masih meminjam buku!';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `buku`
--

CREATE TABLE `buku` (
  `id_buku` int(11) NOT NULL,
  `kode_buku` varchar(20) DEFAULT NULL,
  `judul` varchar(100) DEFAULT NULL,
  `penulis` varchar(100) DEFAULT NULL,
  `penerbit` varchar(100) DEFAULT NULL,
  `tahun_terbit` year(4) DEFAULT NULL,
  `id_jenis` int(11) DEFAULT NULL,
  `id_rak` int(11) DEFAULT NULL,
  `stok` int(11) DEFAULT NULL,
  `cover` varchar(255) DEFAULT NULL,
  `isbn` varchar(30) DEFAULT NULL,
  `bahasa` varchar(50) DEFAULT NULL,
  `genre` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `buku`
--

INSERT INTO `buku` (`id_buku`, `kode_buku`, `judul`, `penulis`, `penerbit`, `tahun_terbit`, `id_jenis`, `id_rak`, `stok`, `cover`, `isbn`, `bahasa`, `genre`) VALUES
(1, '001', 'Hujan', 'Tere Liye', 'Gramedia Pustaka Utama', '2016', 1, 1, 20, '', '', 'Indonesia', 'Fiksi'),
(3, '002', 'Laut Bercerita', 'Leila S. Chudori', 'Kepustakaan Populer Gramedia', '2017', 1, 1, 50, '', 'ISBN 9786024246945', 'Indonesia', 'Fiksi'),
(8, '003', 'Detektif Conan Vol. 4', ' Gosho Aoyama', 'Elex Media Komputindo', '1997', 6, 2, 1, NULL, '979-663-494-5', 'Indonesia', 'Fiksi');

--
-- Triggers `buku`
--
DELIMITER $$
CREATE TRIGGER `after_update_buku` AFTER UPDATE ON `buku` FOR EACH ROW BEGIN
    INSERT INTO log_perubahan_buku (id_buku, aksi, data_lama, data_baru, id_admin)
    VALUES (
        OLD.id_buku, 
        'UPDATE', 
        CONCAT('Judul: ', OLD.judul, ', Stok: ', OLD.stok), 
        CONCAT('Judul: ', NEW.judul, ', Stok: ', NEW.stok),
        @current_admin_id
    );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_delete_buku` BEFORE DELETE ON `buku` FOR EACH ROW BEGIN
    DECLARE cek_pinjam INT;
    SELECT COUNT(*) INTO cek_pinjam FROM peminjaman WHERE id_buku = OLD.id_buku AND status = 'Dipinjam';
    
    IF cek_pinjam > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Gagal! Buku tidak bisa dihapus karena sedang dipinjam anggota.';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sebelum_hapus_buku` BEFORE DELETE ON `buku` FOR EACH ROW BEGIN
    DECLARE sedang_dipinjam INT;
    
    SELECT COUNT(*) INTO sedang_dipinjam 
    FROM peminjaman 
    WHERE id_buku = OLD.id_buku AND status = 'Dipinjam';
    
    IF sedang_dipinjam > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'GAGAL: Buku ini tidak boleh dihapus karena sedang dipinjam oleh anggota!';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `jenis_buku`
--

CREATE TABLE `jenis_buku` (
  `id_jenis` int(11) NOT NULL,
  `nama_jenis` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `jenis_buku`
--

INSERT INTO `jenis_buku` (`id_jenis`, `nama_jenis`) VALUES
(1, 'Novel'),
(6, 'Komik');

-- --------------------------------------------------------

--
-- Table structure for table `log_peminjaman`
--

CREATE TABLE `log_peminjaman` (
  `id_log` int(11) NOT NULL,
  `id_peminjaman` int(11) DEFAULT NULL,
  `aksi` varchar(50) DEFAULT NULL,
  `tanggal_log` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_peminjaman`
--

INSERT INTO `log_peminjaman` (`id_log`, `id_peminjaman`, `aksi`, `tanggal_log`) VALUES
(1, 5, 'Status diubah menjadi: Dikembalikan', '2026-06-08 03:34:38'),
(2, 7, 'Status diubah menjadi: Kembali', '2026-06-08 07:40:18');

-- --------------------------------------------------------

--
-- Table structure for table `log_perubahan_buku`
--

CREATE TABLE `log_perubahan_buku` (
  `id_log` int(11) NOT NULL,
  `id_buku` int(11) DEFAULT NULL,
  `aksi` varchar(20) DEFAULT NULL,
  `data_lama` text DEFAULT NULL,
  `data_baru` text DEFAULT NULL,
  `id_admin` int(11) DEFAULT NULL,
  `waktu` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `log_perubahan_buku`
--

INSERT INTO `log_perubahan_buku` (`id_log`, `id_buku`, `aksi`, `data_lama`, `data_baru`, `id_admin`, `waktu`) VALUES
(1, 8, 'UPDATE', 'Judul: Detektif Conan Vol. 4, Stok: 10', 'Judul: Detektif Conan Vol. 4, Stok: 5', 3959, '2026-06-08 07:22:25'),
(2, 8, 'UPDATE', 'Judul: Detektif Conan Vol. 4, Stok: 5', 'Judul: Detektif Conan Vol. 4, Stok: 4', 3959, '2026-06-08 07:24:23'),
(3, 8, 'UPDATE', 'Judul: Detektif Conan Vol. 4, Stok: 4', 'Judul: Detektif Conan Vol. 4, Stok: 3', 3959, '2026-06-08 07:24:23'),
(4, 1, 'UPDATE', 'Judul: Hujan, Stok: 23', 'Judul: Hujan, Stok: 22', 3959, '2026-06-08 07:24:33'),
(5, 1, 'UPDATE', 'Judul: Hujan, Stok: 22', 'Judul: Hujan, Stok: 21', 3959, '2026-06-08 07:24:33'),
(6, 1, 'UPDATE', 'Judul: Hujan, Stok: 21', 'Judul: Hujan, Stok: 22', 3959, '2026-06-08 07:40:18'),
(7, 8, 'UPDATE', 'Judul: Detektif Conan Vol. 4, Stok: 3', 'Judul: Detektif Conan Vol. 4, Stok: 2', 3959, '2026-06-08 07:40:59'),
(8, 8, 'UPDATE', 'Judul: Detektif Conan Vol. 4, Stok: 2', 'Judul: Detektif Conan Vol. 4, Stok: 1', 3959, '2026-06-08 07:40:59'),
(9, 10, 'UPDATE', 'Judul: rgrrgg, Stok: 3232', 'Judul: rgrrgg, Stok: 3232', 3959, '2026-06-08 07:43:50'),
(10, 1, 'UPDATE', 'Judul: Hujan, Stok: 22', 'Judul: Hujan, Stok: 21', 3959, '2026-06-08 12:25:21'),
(11, 1, 'UPDATE', 'Judul: Hujan, Stok: 21', 'Judul: Hujan, Stok: 20', 3959, '2026-06-08 12:25:21');

-- --------------------------------------------------------

--
-- Table structure for table `peminjaman`
--

CREATE TABLE `peminjaman` (
  `id_peminjaman` int(11) NOT NULL,
  `id_anggota` int(11) NOT NULL,
  `id_buku` int(11) NOT NULL,
  `tanggal_pinjam` date NOT NULL,
  `tanggal_harus_kembali` date DEFAULT NULL,
  `tanggal_kembali` date NOT NULL,
  `status` varchar(20) DEFAULT 'Dipinjam',
  `denda` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `peminjaman`
--

INSERT INTO `peminjaman` (`id_peminjaman`, `id_anggota`, `id_buku`, `tanggal_pinjam`, `tanggal_harus_kembali`, `tanggal_kembali`, `status`, `denda`) VALUES
(3, 1, 1, '2026-06-08', NULL, '2026-06-08', 'Dikembalikan', 0),
(4, 1, 3, '2026-06-08', NULL, '2026-06-08', 'Dikembalikan', 0),
(5, 2, 1, '2026-06-08', NULL, '2026-06-08', 'Dikembalikan', 0),
(7, 3, 1, '2026-06-08', '2026-06-15', '2026-06-08', 'Kembali', 0),
(8, 2, 8, '2026-06-08', '2026-06-15', '0000-00-00', 'Dipinjam', 0),
(9, 2, 1, '2026-06-08', '2026-06-15', '0000-00-00', 'Dipinjam', 0);

--
-- Triggers `peminjaman`
--
DELIMITER $$
CREATE TRIGGER `after_insert_peminjaman` AFTER INSERT ON `peminjaman` FOR EACH ROW BEGIN
    UPDATE buku 
    SET stok = stok - 1 
    WHERE id_buku = NEW.id_buku;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_update_peminjaman` AFTER UPDATE ON `peminjaman` FOR EACH ROW BEGIN
    IF NEW.status = 'Dikembalikan' AND OLD.status != 'Dikembalikan' THEN
        UPDATE buku 
        SET stok = stok + 1 
        WHERE id_buku = NEW.id_buku;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_insert_peminjaman` BEFORE INSERT ON `peminjaman` FOR EACH ROW BEGIN
    DECLARE sisa_stok INT;
    
    SELECT stok INTO sisa_stok FROM buku WHERE id_buku = NEW.id_buku;
    
    IF sisa_stok <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'GAGAL: Stok buku ini sudah habis!';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `log_update_peminjaman` AFTER UPDATE ON `peminjaman` FOR EACH ROW BEGIN
    INSERT INTO log_peminjaman (id_peminjaman, aksi)
    VALUES (NEW.id_peminjaman, CONCAT('Status diubah menjadi: ', NEW.status));
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sebelum_kembali_hitung_denda` BEFORE UPDATE ON `peminjaman` FOR EACH ROW BEGIN
    DECLARE jumlah_hari_terlambat INT;
    
    IF NEW.status != 'Dipinjam' AND OLD.status = 'Dipinjam' THEN
        SET jumlah_hari_terlambat = DATEDIFF(CURDATE(), OLD.tanggal_harus_kembali);
        
        IF jumlah_hari_terlambat > 0 THEN
            SET NEW.denda = jumlah_hari_terlambat * 1000;
        ELSE
            SET NEW.denda = 0;
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sebelum_pinjam_cek_batas` BEFORE INSERT ON `peminjaman` FOR EACH ROW BEGIN
    DECLARE jumlah_buku_dibawa INT;
    
    SELECT COUNT(*) INTO jumlah_buku_dibawa 
    FROM peminjaman 
    WHERE id_anggota = NEW.id_anggota AND status = 'Dipinjam';
    
    IF jumlah_buku_dibawa >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'GAGAL: Anggota ini sudah mencapai batas maksimal peminjaman (3 buku)!';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `rak`
--

CREATE TABLE `rak` (
  `id_rak` int(11) NOT NULL,
  `nama_rak` varchar(50) NOT NULL,
  `lokasi_rak` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rak`
--

INSERT INTO `rak` (`id_rak`, `nama_rak`, `lokasi_rak`) VALUES
(1, 'Rak A1', 'Lantai 1, Lorong 1'),
(2, 'Rak B1', 'Lantai 1, Lorong 2'),
(3, 'Rak A2', 'Lantai 1, Lorong 1');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`id_admin`);

--
-- Indexes for table `anggota`
--
ALTER TABLE `anggota`
  ADD PRIMARY KEY (`id_anggota`);

--
-- Indexes for table `buku`
--
ALTER TABLE `buku`
  ADD PRIMARY KEY (`id_buku`),
  ADD KEY `fk_jenis_buku` (`id_jenis`),
  ADD KEY `fk_rak_buku` (`id_rak`);

--
-- Indexes for table `jenis_buku`
--
ALTER TABLE `jenis_buku`
  ADD PRIMARY KEY (`id_jenis`);

--
-- Indexes for table `log_peminjaman`
--
ALTER TABLE `log_peminjaman`
  ADD PRIMARY KEY (`id_log`);

--
-- Indexes for table `log_perubahan_buku`
--
ALTER TABLE `log_perubahan_buku`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `id_buku` (`id_buku`),
  ADD KEY `fk_admin_log` (`id_admin`);

--
-- Indexes for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD PRIMARY KEY (`id_peminjaman`),
  ADD KEY `id_anggota` (`id_anggota`),
  ADD KEY `id_buku` (`id_buku`);

--
-- Indexes for table `rak`
--
ALTER TABLE `rak`
  ADD PRIMARY KEY (`id_rak`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `id_admin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3961;

--
-- AUTO_INCREMENT for table `anggota`
--
ALTER TABLE `anggota`
  MODIFY `id_anggota` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `buku`
--
ALTER TABLE `buku`
  MODIFY `id_buku` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `jenis_buku`
--
ALTER TABLE `jenis_buku`
  MODIFY `id_jenis` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `log_peminjaman`
--
ALTER TABLE `log_peminjaman`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `log_perubahan_buku`
--
ALTER TABLE `log_perubahan_buku`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `peminjaman`
--
ALTER TABLE `peminjaman`
  MODIFY `id_peminjaman` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `rak`
--
ALTER TABLE `rak`
  MODIFY `id_rak` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `buku`
--
ALTER TABLE `buku`
  ADD CONSTRAINT `fk_jenis_buku` FOREIGN KEY (`id_jenis`) REFERENCES `jenis_buku` (`id_jenis`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_rak_buku` FOREIGN KEY (`id_rak`) REFERENCES `rak` (`id_rak`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `peminjaman`
--
ALTER TABLE `peminjaman`
  ADD CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`id_anggota`) REFERENCES `anggota` (`id_anggota`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `log_perubahan_buku`
--
ALTER TABLE `log_perubahan_buku`
  ADD CONSTRAINT `fk_buku_log_perubahan` FOREIGN KEY (`id_buku`) REFERENCES `buku` (`id_buku`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_admin_log` FOREIGN KEY (`id_admin`) REFERENCES `admin` (`id_admin`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
