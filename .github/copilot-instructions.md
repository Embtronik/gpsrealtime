# GPS Real Time - AI Coding Instructions

## Project Overview
A PHP/MySQL-based GPS tracking and vehicle inspection management system running on XAMPP. The application handles client management, service tracking, and vehicle inspections with a role-based access control system.

## Architecture

### Tech Stack
- **Backend**: PHP 7.x+ with PDO for database access
- **Database**: MySQL 8.x (`mydb` database)
- **Frontend**: Vanilla JavaScript + Bootstrap 5 (NiceAdmin template)
- **Server**: XAMPP (Apache + MySQL)
- **Dependencies**: PHPMailer (via Composer), Python 3.x for ETL scripts

### Directory Structure
```
/codigo/        → Backend API endpoints (api*.php files)
/nice/          → Admin UI (HTML pages + assets/)
/nice/assets/js/→ Frontend JavaScript modules
/js/            → Legacy/public JavaScript
/sql/           → Database schemas, stored procedures (SP_*.sql)
/ETL/           → Python ETL scripts
/html/          → Email templates
/backup/        → Database backups
```

## Database Architecture

### Connection
- **File**: `codigo/coneccion.php`
- **Credentials**: User `gps`, database `mydb` (see coneccion.php for password)
- **Always use PDO** with prepared statements - never raw SQL concatenation

### Key Tables
- `usuario`, `usuarioCredenciales`, `usuariorol` → User management
- `p_rol` → Roles (1=Admin, 3=Commercial, 4=Technician)
- `checklist_categoria`, `checklist_item` → Inspection schema
- `inspeccion`, `inspeccion_item` → Inspection records
- All parametric tables start with `p_` prefix (e.g., `p_comercial`, `p_tipoServicio`)

### Stored Procedures Pattern
- Named `sp_<operation>_<entity>` or `SP_<Operation><Entity>` (inconsistent casing)
- All CRUD operations use SPs with `estadoRegistro=1/0` for soft deletes
- Authentication: `sp_validar_credenciales` returns OUT params for user session

## Critical Patterns

### Authentication Flow
1. Login POST to `codigo/apicredenciales.php` with `usuario`/`password`
2. SP `sp_validar_credenciales` validates and returns `id_usuario`, `rol_usuario`
3. Session variables set: `$_SESSION['user_id']`, `$_SESSION['usuario']`, `$_SESSION['rol_usuario']`
4. Role-based guards (e.g., `auth.php` requires `rol_usuario === 4` for technicians)

### API Endpoint Convention
- **Location**: All in `/codigo/` directory
- **Naming**: `api<Entity>.php` (select), `api<Action><Entity>.php` (CRUD)
  - Examples: `apicomercial.php`, `apiInsertarComercial.php`, `apiEliminarComercial.php`
- **Headers**: Always set `Content-Type: application/json; charset=utf-8`
- **Input**: Read `php://input` and `json_decode($raw, true)`
- **Output**: Always `json_encode()` responses with `success` boolean

### Frontend-Backend Communication
- Fetch pattern: Relative paths from `/nice/` pages use `../codigo/api*.php`
- From root pages: `./codigo/api*.php`
- Inspection form uses `codigo/save_inspeccion.php` and `codigo/get_form_schema.php`

### Form Input Transformations (cliente.js pattern)
- **Uppercase**: All text inputs except email → `.toUpperCase()` on input
- **Lowercase**: Email inputs → `.toLowerCase()`
- **No spaces**: Placa (license plate) → `.replace(/\s+/g, '')`

### Dynamic Form Generation (Inspection System)
- Schema stored in `checklist_categoria` + `checklist_item` tables
- Frontend fetches via `get_form_schema.php` → renders dynamic form
- Special items: "Ubicación del GPS", "Donde Toma Energía", "Color" have custom dropdowns
- State: `BUENO`, `REGULAR`, `MALO`, `NA`

## Development Workflows

### Creating New API Endpoints
1. Create SP in `/sql/` directory (follow `SP_CRUD_*.sql` pattern)
2. Implement PHP endpoint in `/codigo/api<Name>.php`:
   ```php
   require 'coneccion.php';
   header('Content-Type: application/json; charset=utf-8');
   // Use prepared statements with PDO
   ```
3. Add frontend JS in `/nice/assets/js/<module>.js` using fetch API

### Database Changes
1. Write migration in `/sql/` directory
2. Update relevant stored procedures
3. Test with current XAMPP setup (localhost:3306)
4. Backup before deploy: `backup/` directory

### Adding New Admin Pages
1. Copy template from `/nice/` (e.g., `buscar.html`)
2. Include Bootstrap 5 + NiceAdmin assets (already in template)
3. Create corresponding JS in `/nice/assets/js/<page>.js`
4. Add navigation link in sidebar (check existing pages)

## Common Gotchas

- **Session Management**: Always call `session_start()` before accessing `$_SESSION`
- **Stored Procedure Cursors**: After CALL with OUT params, use `nextRowset()` loop then `closeCursor()`
- **Soft Deletes**: Never DELETE; always UPDATE `estadoRegistro = 0`
- **Rol IDs**: Hardcoded checks (rol 4 = Technician in `auth.php`)
- **Path Resolution**: APIs expect relative paths; adjust based on calling file location
- **Logging**: Inspection saves to `/logs/inspeccion.log` for debugging

## Testing & Debugging

### Local Environment
- XAMPP must be running (Apache + MySQL)
- Access via `http://localhost/gpsrealtime/`
- Login page: `index.html`
- Admin area: `/nice/` directory

### Database Console
- Use phpMyAdmin at `http://localhost/phpmyadmin/`
- Direct SQL: Query `mydb` database
- Test SPs: `CALL sp_<name>(...); SELECT @out_param;`

### Logs
- Inspection logs: `logs/inspeccion.log`
- PHP errors: Check XAMPP's `apache/logs/error.log`

## Email System
- Uses PHPMailer (installed via Composer in `/vendor/`)
- Templates in `/html/plantilla_bienvenida.html`
- Send via `codigo/email.php` (check implementation for SMTP config)

## Migration Notes
- Python ETL in `/ETL/db_connection.py` for data imports
- Credentials differ: Python uses `root` (no password), PHP uses `gps` user
- Main script: `codigo/main.py` (context unclear - verify purpose before modifying)
