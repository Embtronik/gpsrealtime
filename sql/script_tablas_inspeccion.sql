CREATE TABLE IF NOT EXISTS checklist_categoria (
  id       BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  nombre   VARCHAR(150) NOT NULL,
  `orden`  INT NOT NULL DEFAULT 0,
  activo   TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS checklist_item (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  categoria_id  BIGINT UNSIGNED NOT NULL,
  nombre        VARCHAR(200) NOT NULL,
  `orden`       INT NOT NULL DEFAULT 0,
  activo        TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  KEY idx_item_categoria (categoria_id),
  KEY idx_item_categoria_orden_activo (categoria_id, `orden`, activo),
  CONSTRAINT fk_item_categoria
    FOREIGN KEY (categoria_id) REFERENCES checklist_categoria(id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  UNIQUE KEY uq_categoria_nombre (categoria_id, nombre)  -- opcional, pero útil
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inspeccion (
  id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  fecha             DATE NOT NULL,
  tecnico           VARCHAR(120),
  placa             VARCHAR(20),
  nombre_cliente    VARCHAR(100),
  email_cliente     VARCHAR(150),
  telefono_cliente  VARCHAR(30),
  novedades         TEXT,
  created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_inspeccion_placa (placa),
  KEY idx_inspeccion_fecha (fecha)
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS inspeccion_item (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  inspeccion_id   BIGINT UNSIGNED NOT NULL,
  item_id         BIGINT UNSIGNED NOT NULL,
  estado          ENUM('BUENO','REGULAR','MALO','NA') NOT NULL,
  observaciones   VARCHAR(500) NULL,
  created_at      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_inspeccion_item (inspeccion_id, item_id),
  KEY idx_item (item_id),
  KEY idx_inspeccion (inspeccion_id),
  CONSTRAINT fk_ins_item_inspeccion
    FOREIGN KEY (inspeccion_id) REFERENCES inspeccion(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ins_item_item
    FOREIGN KEY (item_id) REFERENCES checklist_item(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
