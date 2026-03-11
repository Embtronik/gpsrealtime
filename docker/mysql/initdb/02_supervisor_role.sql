-- ─────────────────────────────────────────────────────────────────────
-- 02_supervisor_role.sql
-- Inserta el rol Supervisor como id = 5 (el backup ya tiene 1-4 ocupados:
--   1=administrador, 2=cliente, 3=auxiliar, 4=Tecnico_instalador)
-- Este archivo se ejecuta automáticamente después del restore del backup.
-- ─────────────────────────────────────────────────────────────────────
USE mydb;

INSERT INTO p_rol (idp_rol, descripcion, estadoRegistro)
VALUES (5, 'Supervisor', 1)
ON DUPLICATE KEY UPDATE descripcion = 'Supervisor', estadoRegistro = 1;
