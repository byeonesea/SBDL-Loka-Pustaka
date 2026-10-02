<?php
session_start();
include 'config/koneksi.php';

if(isset($_SESSION['admin'])) {
    header("Location: dashboard.php");
    exit;
}

if(isset($_SESSION['anggota'])) {
    header("Location: panel_anggota/dashboard.php");
    exit;
}

if(isset($_POST['admin'])) { 
    $username_input = $_POST['username']; 
    $query_admin = mysqli_query($conn, "SELECT * FROM admin WHERE username='$username_input'");
    
    if(mysqli_num_rows($query_admin) > 0){
        $data_admin = mysqli_fetch_array($query_admin);
        $_SESSION['admin'] = $data_admin['username'];
        $_SESSION['id_admin'] = $data_admin['id_admin'];
        $_SESSION['status'] = 'login'; 
        header("Location: dashboard.php");
        exit;
    } else {
        header("Location: login.php?pesan=gagal");
        exit;
    }
}

if(isset($_POST['anggota'])) {
    $username_input = $_POST['username']; 
    $query_anggota = mysqli_query($conn, "SELECT * FROM anggota WHERE kode_anggota='$username_input'");
    
    if(mysqli_num_rows($query_anggota) > 0){
        $data_anggota = mysqli_fetch_array($query_anggota);
        
        $_SESSION['anggota'] = $data_anggota['nama']; 
        $_SESSION['id_anggota'] = $data_anggota['id_anggota']; 
        $_SESSION['kode_anggota'] = $data_anggota['kode_anggota'];
        $_SESSION['nama'] = $data_anggota['nama']; 
        
        header("Location: panel_anggota/dashboard.php");
        exit;
    } else {
        header("Location: login.php?pesan=gagal");
        exit;
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Login - Loka Pustaka</title>
    <link rel="stylesheet" href="assets/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="login-page">
    <div class="login-header">
        <div class="header-left">
            <img src="assets/logo.png" class="header-logo">
            <div>
                <h3 class="header-title">LOKA PUSTAKA</h3>
                <p class="header-desc">
                    MEMBACA ∙ MENYELAMI CERITA ∙ MENJELAJAHI IMAJINASI<br>
                    Tempat membaca novel dan komik di desa
                </p>
            </div>
        </div>
    </div>

    <div class="login-container">
        <div class="login-top">
            <div class="login-logo">
                <i class="fa-solid fa-user"></i>
            </div>
            <h2>LOGIN</h2>
        </div>

        <?php if(isset($_GET['pesan']) && $_GET['pesan'] == 'gagal') { ?>
            <div style="background: #f8d7da; color: #721c24; padding: 10px; border-radius: 5px; text-align: center; margin-bottom: 15px; font-size: 14px;">
                Username / Kode Anggota Salah!
            </div>
        <?php } ?>

        <form method="POST" action="login.php">
            <div class="login-input">
                <i class="fa-solid fa-user"></i>
                <input type="text" name="username" placeholder="Username / Kode Anggota" required autocomplete="off">
            </div>

            <div class="login-input">
                <i class="fa-solid fa-lock"></i>
                <input type="password" name="password" placeholder="Password / No HP">
            </div>

            <div class="button-group" style="display: flex; gap: 10px; margin-top: 20px;">
                <button type="submit" name="admin" class="login-button" style="flex: 1; cursor: pointer;">
                    ADMIN
                </button>
                <button type="submit" name="anggota" class="login-button" style="flex: 1; cursor: pointer;">
                    ANGGOTA
                </button>
            </div>
        </form>
    </div>
</body>
</html>