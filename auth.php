<?php
// auth.php
session_start();

// Logout mediante GET opcional (si lo quieres aquí)
if (isset($_GET['logout'])) {
  session_unset();
  session_destroy();
  header('Location: index.html'); // ajusta si tu landing es otra
  exit;
}

// Guard: rol 4 requerido
if (!isset($_SESSION['rol_usuario']) || (int)$_SESSION['rol_usuario'] !== 4) {
  header('Location: index.html');
  exit;
}

// Variables que usarás en la vista
$tecnicoNombre = isset($_SESSION['usuario']) ? $_SESSION['usuario'] : '';
$userId        = isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0;
