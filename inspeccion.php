<?php require __DIR__ . '/auth.php'; ?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <title>Inspección Instalación GPS</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="/img/logo_32x32.png" sizes="32x32">
  <link rel="shortcut icon" type="image/png" href="/img/logo_32x32.png">
  <link rel="apple-touch-icon" href="/img/logo_32x32.png">
  <meta name="theme-color" content="#4154f1">

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="nice/assets/css/inspeccion.css" rel="stylesheet"/>
</head>

<body>
  <div class="container py-4">
    <!-- Encabezado -->
    <div class="brand-box rounded-3 p-3 mb-3">
      <div class="d-flex align-items-center justify-content-between flex-wrap">
        <div class="d-flex align-items-center gap-3">
          <img src="https://dummyimage.com/600x140/ffffff/000000&text=GPS+Real+Time" class="img-fluid" alt="Banner" style="max-height:64px">
          <div class="subtitle mt-2">Formulario de Inspección de Instalación GPS</div>
        </div>
        <div class="d-flex align-items-center gap-2">
          <span class="badge bg-dark text-wrap">
            Técnico: <?php echo htmlspecialchars($tecnicoNombre, ENT_QUOTES, 'UTF-8'); ?>
          </span>
          <a class="btn btn-outline-light btn-sm" href="logout.php">Cerrar sesión</a>
        </div>
      </div>
    </div>

    <!-- Contenedor del formulario dinámico -->
    <div id="form-container">
      <div class="alert alert-info">Cargando formulario…</div>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Config que necesita el JS externo -->
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
