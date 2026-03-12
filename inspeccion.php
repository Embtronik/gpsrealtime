<?php require __DIR__ . '/auth.php'; ?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <title>GPS Real Time – Inspección GPS</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <link rel="icon" type="image/png" href="/img/logo_32x32.png" sizes="32x32">
  <link rel="apple-touch-icon" href="/img/logo_32x32.png">
  <meta name="theme-color" content="#0b3d91">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"/>
  <link href="nice/assets/css/inspeccion.css" rel="stylesheet"/>
</head>

<body>

  <!-- Header fijo igual que client.html -->
  <header class="gps-header">
    <img src="./img/logo.png" alt="GPS Real Time" class="gps-logo">
    <div class="gps-header-center">
      <span class="gps-brand">GPS Real Time</span>
      <span class="gps-header-sub">Inspección de Instalación</span>
    </div>
    <div class="gps-header-right">
      <span class="gps-tecnico"><i class="bi bi-person-fill me-1"></i><?php echo htmlspecialchars($tecnicoNombre, ENT_QUOTES, 'UTF-8'); ?></span>
      <a href="logout.php" class="gps-logout" title="Cerrar sesión"><i class="bi bi-box-arrow-right"></i></a>
    </div>
  </header>

  <main class="gps-main">
    <div id="form-container">
      <div class="text-center py-5 text-muted">
        <div class="spinner-border text-primary mb-2" role="status"></div>
        <p class="mb-0">Cargando formulario…</p>
      </div>
    </div>
  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script>
    window.APP = {
      ENDPOINT_SCHEMA: 'codigo/get_form_schema.php',
      SESSION_USER: {
        user_id: <?php echo (int)$userId; ?>,
        nombre:  <?php echo json_encode($tecnicoNombre, JSON_UNESCAPED_UNICODE); ?>
      }
    };
  </script>
  <script src="nice/assets/js/inspeccion.js"></script>
</body>
</html>
