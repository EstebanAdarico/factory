# Política de riesgo (la lee factory-gate)

Un cambio va a **revisión humana** si toca cualquiera de estos puntos:
- Esquema de base de datos, migraciones o queries que borran/modifican datos en masa
- Autenticación, autorización, pagos, manejo de secretos
- Lógica core de negocio del backend
- Dependencias nuevas o actualizadas
- Configuración de despliegue, CI/CD, Docker
- Más de ~300 líneas cambiadas o más de 10 archivos

Puede ir por la **vía rápida (merge automático)** si es solo:
- Textos, estilos, colores, copys, contenido estático
- Tests nuevos sin cambio de lógica
- Documentación

Ante la duda: **revisión humana**.
