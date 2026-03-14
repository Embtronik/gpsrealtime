-- ================================================================
-- 05_foto_table.sql  –  Tabla para fotos de inspecciones
-- Se ejecuta por el servicio migrate en docker-compose
-- ================================================================

CREATE TABLE IF NOT EXISTS `inspeccion_foto` (
  `id`             BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `inspeccion_id`  BIGINT UNSIGNED NOT NULL,
  `filename`       VARCHAR(255)    NOT NULL COMMENT 'Nombre seguro generado en el servidor',
  `original_name`  VARCHAR(255)    NOT NULL COMMENT 'Nombre original del archivo',
  `created_at`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `idx_foto_inspeccion_id` (`inspeccion_id`),
  CONSTRAINT `fk_foto_inspeccion`
    FOREIGN KEY (`inspeccion_id`) REFERENCES `inspeccion` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
