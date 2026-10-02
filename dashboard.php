<?php
session_start();
include 'config/koneksi.php';

if(!isset($_SESSION['admin'])){
    header("Location: login.php");
    exit;
}

$buku = mysqli_num_rows(
    mysqli_query($conn,"SELECT * FROM buku")
);

$anggota = mysqli_num_rows(
    mysqli_query($conn,"SELECT * FROM anggota")
);

$pinjam = mysqli_num_rows(
    mysqli_query($conn,"SELECT * FROM peminjaman")
);

$kategori = mysqli_num_rows(
    mysqli_query($conn,"SELECT * FROM jenis_buku")
);

$rak = mysqli_num_rows(
    mysqli_query($conn,"SELECT * FROM rak")
);
?>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard Admin</title>
    <link rel="stylesheet" href="assets/style.css?v=2.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>

<body class="dashboard-page">

<?php 
include 'template/sidebar.php'; 
?>

<div class="main-content">
    <div class="topbar">
        <div>
            <h2>Dashboard</h2>
            <p class="text-white">
                Selamat datang, <?= $_SESSION['admin']; ?>
            </p>
        </div>
        <div class="admin-icon">
            <i class="fa-solid fa-circle-user"></i>
        </div>
    </div>

    <div class="cards">
        <div class="card pink">
            <div>
                <h4>Total Buku</h4>
                <h1><?= $buku; ?></h1>
            </div>
            <i class="fa-solid fa-book"></i>
        </div>

        <div class="card purple">
            <div>
                <h4>Total Anggota</h4>
                <h1><?= $anggota; ?></h1>
            </div>
            <i class="fa-solid fa-users"></i>
        </div>

        <div class="card blue">
            <div>
                <h4>Peminjaman</h4>
                <h1><?= $pinjam; ?></h1>
            </div>
            <i class="fa-solid fa-repeat"></i>
        </div>
    </div>

    <div class="table-box">
        <div class="table-header">
            Data Peminjaman Terbaru
        </div>
        <table>
            <tr>
                <th>No</th>
                <th>Nama</th>
                <th>Buku</th>
                <th>Status</th>
            </tr>

            <?php
            $no = 1;
            $data = mysqli_query($conn,
                "SELECT peminjaman.*, anggota.nama, buku.judul 
                 FROM peminjaman 
                 JOIN anggota ON peminjaman.id_anggota = anggota.id_anggota 
                 JOIN buku ON peminjaman.id_buku = buku.id_buku 
                 ORDER BY peminjaman.id_peminjaman DESC 
                 LIMIT 5"
            );

            while($d = mysqli_fetch_array($data)){
            ?>

            <tr>
                <td><?= $no++; ?></td>
                <td><?= $d['nama']; ?></td>
                <td><?= $d['judul']; ?></td>
                <td>
                    <span class="status">
                        <?= $d['status']; ?>
                    </span>
                </td>
            </tr>

            <?php } ?>

        </table>
    </div>
</div>

</body>
</html>