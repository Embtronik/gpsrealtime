# GPS RealTime — Guía de Despliegue

Sistema de seguimiento GPS y gestión de inspecciones vehiculares.  
Stack: **PHP 8.2 + Apache · MySQL 8 · Caddy (HTTPS automático) · Docker Compose**

---

## Índice

1. [Requisitos previos](#1-requisitos-previos)
2. [Estructura de archivos Docker](#2-estructura-de-archivos-docker)
3. [Configuración inicial (.env)](#3-configuración-inicial-env)
4. [Desarrollo local (XAMPP)](#4-desarrollo-local-xampp)
5. [Desarrollo local (Docker)](#5-desarrollo-local-docker)
6. [Migración desde producción antigua](#6-migración-desde-producción-antigua)
7. [Despliegue en producción (nuevo servidor)](#7-despliegue-en-producción-nuevo-servidor)
8. [Gestión de backups](#8-gestión-de-backups)
9. [Comandos de operación diaria](#9-comandos-de-operación-diaria)
10. [Solución de problemas](#10-solución-de-problemas)

---

## 1. Requisitos previos

### Servidor de producción
- Ubuntu 22.04 LTS (o Debian 12)
- Docker Engine ≥ 24 y Docker Compose plugin ≥ 2.20
- Puerto 80 y 443 abiertos en el firewall
- Dominio con registro A apuntando a la IP del servidor

### Instalación de Docker en Ubuntu
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker
docker --version        # debe mostrar 24.x o superior
docker compose version  # debe mostrar 2.x o superior
```

---

## 2. Estructura de archivos Docker

```
gpsrealtime/
├── Dockerfile                   # Imagen PHP 8.2 + Apache
├── docker-compose.yml           # Entorno base (dev y prod)
├── docker-compose.prod.yml      # Override de producción (Caddy + HTTPS)
├── .env                         # Variables secretas (NO subir a git)
├── .env.example                 # Plantilla de variables
├── docker/
│   ├── apache/000-default.conf  # Configuración de Apache
│   ├── php/php.ini              # Configuración de PHP
│   ├── caddy/Caddyfile          # Reverse proxy + HTTPS automático
│   └── mysql/
│       └── initdb/              # Coloca aquí .sql para seed inicial
└── scripts/
    └── restore.sh               # Script de restauración de backups
```

---

## 3. Configuración inicial (.env)

Copia la plantilla y edita los valores:

```bash
cp .env.example .env
nano .env
```

```dotenv
# ── Base de datos ──────────────────────────────────────────────────
DB_HOST=db                        # Nombre del servicio Docker (no cambiar)
DB_USER=gps
DB_PASSWORD=TuPasswordSeguro      # Cambiar por uno fuerte
DB_NAME=mydb

# Password del usuario root de MySQL (usado solo en el init del contenedor)
MYSQL_ROOT_PASSWORD=OtroPasswordRoot

# ── SMTP (Zoho u otro proveedor) ───────────────────────────────────
SMTP_HOST=smtp.zoho.com
SMTP_USER=comercial@tuempresa.com
SMTP_PASSWORD=TuPasswordSMTP
SMTP_PORT=465

# ── Dominio público (REQUERIDO en producción) ──────────────────────
DOMAIN=gpsrealtime.tuempresa.com  # Sin https://, solo el dominio
```

> **Importante:** El archivo `.env` nunca debe subirse a repositorios. Ya está incluido en `.gitignore` y `.dockerignore`.

---

## 4. Desarrollo local (XAMPP)

Si usas XAMPP no necesitas Docker. Las credenciales de fallback ya están en el código.

1. Abre XAMPP Control Panel → inicia **Apache** y **MySQL**
2. Importa el backup más reciente en phpMyAdmin (`http://localhost/phpmyadmin`)
3. Accede a la aplicación: `http://localhost/gpsrealtime/`
4. Login: `http://localhost/gpsrealtime/index.html`
5. Panel admin: `http://localhost/gpsrealtime/nice/`

---

## 5. Desarrollo local (Docker)

Levanta solo los servicios `app` y `db`, sin Caddy:

```bash
# Primera vez
cp .env.example .env
# Edita .env con tus credenciales locales

docker compose up -d --build

# Ver logs en tiempo real
docker compose logs -f

# Acceder
# Aplicación: http://localhost
# MySQL:       localhost:3306 (conectar con DBeaver o Workbench)
```

Para detener:
```bash
docker compose down
```

---

## 6. Migración desde producción antigua

### Paso 1 — Exportar el backup en el servidor viejo

Conectarte al servidor antiguo y ejecutar:

```bash
# Si MySQL está en el host
mysqldump -u gps -p mydb > backup_$(date +%Y%m%d_%H%M).sql

# Si MySQL también está en Docker en el servidor viejo
docker exec gpsrealtime_db mysqldump -u gps -p'PASSWORD' mydb > backup_$(date +%Y%m%d_%H%M).sql
```

### Paso 2 — Transferir el backup al nuevo servidor

```bash
# Desde tu PC local (reemplaza IPs y usuario)
scp backup_20260310_1430.sql usuario@IP-SERVIDOR-NUEVO:/home/usuario/gpsrealtime/
```

### Paso 3 — Clonar el repositorio en el nuevo servidor

```bash
ssh usuario@IP-SERVIDOR-NUEVO

# Clonar el código
git clone https://github.com/tu-usuario/gpsrealtime.git
cd gpsrealtime

# Configurar variables
cp .env.example .env
nano .env   # Editar dominio, passwords, SMTP
```

### Paso 4 — Cargar el backup e iniciar (modo fresh)

Este modo borra cualquier volumen previo y crea la BD desde el backup:

```bash
# Dale permisos al script (solo la primera vez)
chmod +x scripts/restore.sh

# Carga el backup y arranca los contenedores
./scripts/restore.sh /home/usuario/backup_20260310_1430.sql --fresh
```

El script:
1. Pide confirmación
2. Copia el `.sql` a `docker/mysql/initdb/01_restore.sql`
3. Elimina volúmenes anteriores
4. Construye y levanta los contenedores

Sigue el progreso:
```bash
docker logs -f gpsrealtime_db
```

Cuando veas `ready for connections` en los logs, continúa al siguiente paso.

---

## 7. Despliegue en producción (nuevo servidor)

**Prerequisito:** El DNS del dominio ya debe apuntar a la IP del servidor antes de ejecutar este paso. Caddy necesita resolver el dominio para obtener el certificado TLS.

```bash
# Asegúrate de estar en la carpeta del proyecto
cd /home/usuario/gpsrealtime

# Verificar que .env tiene el dominio correcto
grep DOMAIN .env
# Debe mostrar: DOMAIN=gpsrealtime.tuempresa.com

# Levantar en modo producción (app + db + Caddy con HTTPS)
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Caddy obtiene el certificado de Let's Encrypt automáticamente en el primer arranque.  
En ~30 segundos la aplicación estará disponible en `https://tudominio.com`.

Verificar que todos los servicios están corriendo:
```bash
docker compose ps
# Deben aparecer: gpsrealtime_app, gpsrealtime_db, gpsrealtime_caddy
# Estado: Up (healthy)
```

---

## 8. Gestión de backups

### Crear un backup desde el contenedor en ejecución

```bash
docker exec gpsrealtime_db \
  mysqldump -u gps -p'TuPassword' mydb \
  > backup/backup_$(date +%Y%m%d_%H%M).sql
```

### Restaurar un backup en caliente (sin reiniciar)

Útil para actualizar datos sin bajar el servicio:

```bash
./scripts/restore.sh ruta/al/backup.sql
```

### Restaurar con volumen limpio (fresh)

Útil para migraciones o cuando la BD está corrupta:

```bash
./scripts/restore.sh ruta/al/backup.sql --fresh
```

### Automatizar backups diarios (cron)

```bash
crontab -e

# Agregar esta línea (backup diario a las 2:00 AM)
0 2 * * * docker exec gpsrealtime_db mysqldump -u gps -p'PASSWORD' mydb > /home/usuario/gpsrealtime/backup/auto_$(date +\%Y\%m\%d).sql 2>> /var/log/gps_backup.log
```

---

## 9. Comandos de operación diaria

```bash
# Ver estado de los contenedores
docker compose ps

# Ver logs en tiempo real
docker compose logs -f
docker compose logs -f app    # Solo PHP/Apache
docker compose logs -f db     # Solo MySQL

# Reiniciar un servicio específico
docker compose restart app

# Actualizar la aplicación (nuevo código)
git pull
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build app

# Entrar al contenedor PHP (shell interactivo)
docker exec -it gpsrealtime_app bash

# Entrar a MySQL desde el contenedor
docker exec -it gpsrealtime_db mysql -u gps -p mydb

# Detener todo (sin borrar datos)
docker compose down

# Detener y borrar volúmenes (¡BORRA LA BD!)
docker compose down -v
```

---

## 10. Solución de problemas

### El certificado TLS no se genera

- Verificar que el DNS del dominio apunta a la IP del servidor: `nslookup tudominio.com`
- Verificar que los puertos 80 y 443 están abiertos: `curl -I http://tudominio.com`
- Revisar logs de Caddy: `docker compose logs caddy`

### La aplicación no conecta a la base de datos

```bash
# Verificar que el contenedor db está healthy
docker compose ps

# Verificar variables de entorno en el contenedor app
docker exec gpsrealtime_app env | grep DB_

# Probar conexión directa
docker exec -it gpsrealtime_db mysql -u gps -p'PASSWORD' -e "SHOW DATABASES;"
```

### Error 500 en PHP

```bash
# Ver logs de Apache dentro del contenedor
docker exec gpsrealtime_app cat /var/log/apache2/error.log | tail -50

# O seguir logs en tiempo real
docker compose logs -f app
```

### El backup de restore.sh no aplica

- Asegúrate de que el archivo `.sql` no esté vacío: `wc -l backup.sql`
- En modo `--fresh`, el initdb solo corre si el volumen `mysql_data` está vacío
- Si el volumen ya existe, usa el modo en caliente (sin `--fresh`)

### Puerto 80 o 443 ya en uso

```bash
# Identificar qué proceso usa el puerto
sudo lsof -i :80
sudo lsof -i :443

# Si hay un nginx o apache nativo corriendo, detenerlo
sudo systemctl stop nginx
sudo systemctl stop apache2
```

---

## Variables de entorno — referencia completa

| Variable | Descripción | Ejemplo |
|---|---|---|
| `DB_HOST` | Hostname del servicio MySQL | `db` |
| `DB_USER` | Usuario de la BD | `gps` |
| `DB_PASSWORD` | Password del usuario de BD | `MiPassword123` |
| `DB_NAME` | Nombre de la base de datos | `mydb` |
| `MYSQL_ROOT_PASSWORD` | Password root de MySQL | `RootPass456` |
| `SMTP_HOST` | Servidor SMTP | `smtp.zoho.com` |
| `SMTP_USER` | Email remitente | `no-reply@empresa.com` |
| `SMTP_PASSWORD` | Password SMTP | `SmtpPass789` |
| `SMTP_PORT` | Puerto SMTP (465=SSL, 587=TLS) | `465` |
| `DOMAIN` | Dominio público (solo producción) | `gps.empresa.com` |

---

*Última actualización: Marzo 2026*
