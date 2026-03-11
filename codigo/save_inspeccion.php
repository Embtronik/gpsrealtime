<?php
require_once __DIR__ . '/api_guard.php';

// codigo/save_inspeccion.php
header('Content-Type: application/json; charset=utf-8');
require_once __DIR__ . '/coneccion.php'; // $conn (PDO)

// === DEBUG LOGGING ===
function dbg_log($msg){
  try {
    $dir = __DIR__ . '/../logs';
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    @file_put_contents($dir.'/inspeccion.log', "[".date('Y-m-d H:i:s')."] ".$msg.PHP_EOL, FILE_APPEND);
  } catch(Throwable $e) { /* no-op */ }
}

ini_set('display_errors', '0');
ini_set('log_errors', '1');

try {
  if (!($conn instanceof PDO)) {
    throw new Exception('No hay conexión PDO disponible.');
  }

  $raw  = file_get_contents('php://input');
  dbg_log("RAW: ".$raw);
  $data = json_decode($raw, true);
  if (!is_array($data)) {
    throw new Exception('JSON inválido: '.substr($raw,0,200));
  }

  // Cabecera
  $fecha            = trim((string)($data['fecha'] ?? ''));
  $tecnico          = trim((string)($data['tecnico'] ?? ''));
  $placa            = strtoupper(trim((string)($data['placa'] ?? '')));
  $nombre_cliente   = trim((string)($data['nombre_cliente'] ?? ''));
  $email_cliente    = trim((string)($data['email_cliente'] ?? ''));
  $telefono_cliente = trim((string)($data['telefono_cliente'] ?? ''));
  $novedades        = (string)($data['novedades'] ?? '');
  $detalle          = $data['detalle'] ?? [];

  // Validaciones mínimas
  if ($placa === '') throw new Exception('La placa es requerida');
  if ($fecha === '') $fecha = date('Y-m-d');
  if ($email_cliente !== '' && !filter_var($email_cliente, FILTER_VALIDATE_EMAIL)) {
    throw new Exception('Email inválido');
  }
  if (strlen($telefono_cliente) > 30) {
    throw new Exception('Teléfono demasiado largo (máx. 30)');
  }
  // recortes a longitudes de columnas
  $tecnico          = mb_substr($tecnico, 0, 120);
  $placa            = mb_substr($placa, 0, 20);
  $nombre_cliente   = mb_substr($nombre_cliente, 0, 100);
  $email_cliente    = mb_substr($email_cliente, 0, 150);
  $telefono_cliente = mb_substr($telefono_cliente, 0, 30);

  // Normalizador de estado (4 estados)
  $normEstado = function ($raw) {
    $v = strtoupper(trim((string)$raw));
    if (in_array($v, ['BUENO','OK','CUMPLE','✔ BUENO'], true)) return 'BUENO';
    if (in_array($v, ['REGULAR','INTERMEDIO','MEDIA'], true))  return 'REGULAR';
    if (in_array($v, ['MALO','NO_CUMPLE','✖ MALO','FALLA'], true)) return 'MALO';
    if (in_array($v, ['NA','N/A','NO APLICA'], true))          return 'NA';
    return 'NA';
  };

  // ===== VALIDACIÓN PREVIA DEL DETALLE =====
  $badItems = [];
  $badEstados = [];
  $itemIds = [];
  if (is_array($detalle)) {
    foreach ($detalle as $row) {
      $iid = (int)($row['itemId'] ?? 0);
      if ($iid > 0) $itemIds[] = $iid;
      $est = $normEstado($row['estado'] ?? '');
      if (!in_array($est, ['BUENO','REGULAR','MALO','NA'], true)) {
        $badEstados[] = ['itemId'=>$iid,'estado_raw'=>($row['estado'] ?? null),'estado_norm'=>$est];
      }
    }
  }

  // comprueba existencia de item_id en checklist_item
  if ($itemIds) {
    $in = implode(',', array_fill(0, count($itemIds), '?'));
    $stmt = $conn->prepare("SELECT id FROM checklist_item WHERE id IN ($in)");
    $stmt->execute($itemIds);
    $found = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);
    $found = array_map('intval', $found);
    $notFound = array_values(array_diff(array_unique($itemIds), $found));
    if ($notFound) $badItems = $notFound;
  }

  if ($badItems || $badEstados) {
    $msg = [];
    if ($badItems)   $msg[] = 'itemId inexistente: '.implode(',', $badItems);
    if ($badEstados) $msg[] = 'estados inválidos detectados';
    throw new Exception('Detalle inválido: '.implode(' | ', $msg));
  }

  // ===== INSERTS =====
  $conn->beginTransaction();

  $sqlIns = "INSERT INTO inspeccion
              (fecha, tecnico, placa, nombre_cliente, email_cliente, telefono_cliente, novedades)
             VALUES
              (:fecha, :tecnico, :placa, :nombre_cliente, :email_cliente, :telefono_cliente, :novedades)";
  $stmt = $conn->prepare($sqlIns);
  $stmt->execute([
    ':fecha'            => $fecha,
    ':tecnico'          => $tecnico,
    ':placa'            => $placa,
    ':nombre_cliente'   => ($nombre_cliente !== '' ? $nombre_cliente : null),
    ':email_cliente'    => ($email_cliente   !== '' ? $email_cliente   : null),
    ':telefono_cliente' => ($telefono_cliente!== '' ? $telefono_cliente: null),
    ':novedades'        => $novedades,
  ]);
  $inspeccion_id = (int)$conn->lastInsertId();

  if (is_array($detalle) && count($detalle) > 0) {
    $sqlDet = "INSERT INTO inspeccion_item (inspeccion_id, item_id, estado, observaciones)
               VALUES (:inspeccion_id, :item_id, :estado, :observaciones)
               ON DUPLICATE KEY UPDATE
                 estado = VALUES(estado),
                 observaciones = VALUES(observaciones)";
    $stmtD = $conn->prepare($sqlDet);

    foreach ($detalle as $row) {
      $item_id       = (int)($row['itemId'] ?? 0);
      if ($item_id <= 0) continue;

      $estado        = $normEstado($row['estado'] ?? '');
      $observaciones = mb_substr(trim((string)($row['observaciones'] ?? '')), 0, 500);

      $stmtD->execute([
        ':inspeccion_id' => $inspeccion_id,
        ':item_id'       => $item_id,
        ':estado'        => $estado,
        ':observaciones' => $observaciones,
      ]);
    }
  }

  $conn->commit();
  dbg_log("OK inspeccion_id=$inspeccion_id placa=$placa items=".count($detalle));
  echo json_encode(['success' => true, 'inspeccion_id' => $inspeccion_id], JSON_UNESCAPED_UNICODE);
  exit;

} catch (Throwable $e) {
  if (isset($conn) && ($conn instanceof PDO) && $conn->inTransaction()) {
    $conn->rollBack();
  }
  dbg_log("ERROR: ".$e->getMessage());
  http_response_code(400);
  echo json_encode(['success' => false, 'message' => $e->getMessage()], JSON_UNESCAPED_UNICODE);
  exit;
}
