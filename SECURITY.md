# Seguridad

**Este proyecto no está auditado y es experimental.** No confíes información irrecuperable sin backups probados y cifrado completo del disco.

- Reporta fallos de seguridad al mantenedor del repositorio por un canal privado (GitHub Security Advisories si está habilitado); **no adjuntes claves reales ni archivos personales**.
- No publiquéis `~/BovedaFIDO2`, identidades `AGE-PLUGIN-...`, archivos `recuperacion-doble.age` personales ni backups.
- El software utiliza un plugin FIDO2 de terceros y descarga un binario precompilado que el instalador no verifica mediante una firma propia.
- El borrado de archivos temporales no garantiza la eliminación segura del SSD.
- El sistema de doble contraseña consiste en dos capas de cifrado. No hay comprobación automática de que ambas contraseñas elegidas sean diferentes.
- La revocación de llaves y cambio de contraseñas no afectan respaldos antiguos.

Antes de publicar nuevas versiones: ejecutar tests, realizar restauraciones con una segunda llave y con dos contraseñas en un segundo equipo, comprobar integridad y auditar las rutas de fallo y los archivos temporales.
