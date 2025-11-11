# poc1-secure-access

> Proof of Concept for Secure Access Implementation with CI/CD Pipeline

[![CI Pipeline](https://github.com/infra-neo/poc1-secure-access/actions/workflows/ci-pipeline.yml/badge.svg)](https://github.com/infra-neo/poc1-secure-access/actions/workflows/ci-pipeline.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 📋 Objetivos

Este repositorio es un POC (Proof of Concept) diseñado para demostrar:

1. **Estructura de Repositorio Estándar**: Organización clara con directorios para workflows, scripts y configuración
2. **Pipeline CI/CD Completo**: Flujo automatizado con setup → test → summary → artifacts
3. **Seguridad Integrada**: Validaciones de seguridad en cada ejecución
4. **Documentación Clara**: READMEs explicativos en cada componente
5. **Artefactos Generados**: Reportes y metadatos disponibles tras cada ejecución

## 🏗️ Arquitectura

```
poc1-secure-access/
├── .github/
│   ├── workflows/          # GitHub Actions workflows
│   │   └── ci-pipeline.yml # Pipeline principal
│   └── agents/             # Configuraciones para GitHub Copilot
├── config/                 # Archivos de configuración
│   ├── app-config.json     # Configuración de la aplicación
│   └── README.md           # Documentación de configuración
├── scripts/                # Scripts de utilidad
│   ├── validate.sh         # Validación de estructura
│   └── security-check.sh   # Verificaciones de seguridad
├── .gitignore             # Archivos ignorados por git
├── LICENSE                # Licencia MIT
└── README.md              # Este archivo
```

## 🚀 Pipeline CI/CD

El pipeline se ejecuta automáticamente en los siguientes eventos:
- Push a la rama `main`
- Push a ramas `copilot/**`
- Pull requests hacia `main`
- Ejecución manual (workflow_dispatch)

### Etapas del Pipeline

1. **Setup** 🔧
   - Checkout del código
   - Generación de timestamp
   - Validación de la estructura del repositorio
   - Configuración del entorno

2. **Test** ✅
   - Ejecución de tests de validación
   - Verificaciones de seguridad
   - Generación de reportes

3. **Summary** 📊
   - Generación de resumen en GitHub
   - Creación de documentación de resultados
   - Compilación de metadatos

4. **Upload Artifacts** 📦
   - Preparación de artefactos
   - Subida a GitHub Artifacts
   - Retención por 30 días

### Artefactos Generados

Cada ejecución del pipeline genera:
- `test-report.txt` - Reporte detallado de tests
- `pipeline-summary.md` - Resumen de la ejecución
- `metadata.json` - Metadatos en formato JSON

## 🎯 Cómo Disparar el Pipeline

### Opción 1: Push a una Rama

```bash
git add .
git commit -m "Descripción del cambio"
git push origin main
```

### Opción 2: Ejecución Manual

1. Ve a la pestaña **Actions** en GitHub
2. Selecciona el workflow **CI Pipeline**
3. Haz clic en **Run workflow**
4. Selecciona la rama deseada
5. Haz clic en **Run workflow** (botón verde)

### Opción 3: Pull Request

1. Crea una nueva rama
2. Realiza cambios
3. Abre un Pull Request hacia `main`
4. El pipeline se ejecutará automáticamente

## 📥 Acceso a Artefactos

1. Ve a la pestaña **Actions** en GitHub
2. Selecciona la ejecución del workflow
3. Desplázate hacia abajo a la sección **Artifacts**
4. Descarga el archivo ZIP con los artefactos

URL directa: `https://github.com/infra-neo/poc1-secure-access/actions`

## 🔐 Seguridad

El repositorio incluye:
- ✅ Verificaciones automáticas de seguridad
- ✅ Validación de sintaxis de scripts
- ✅ Detección de secretos hardcodeados
- ✅ Auditoría de permisos de archivos

## 📝 Scripts Disponibles

- `scripts/validate.sh` - Valida la estructura del repositorio
- `scripts/security-check.sh` - Ejecuta verificaciones de seguridad

Para ejecutar localmente:
```bash
bash scripts/validate.sh
bash scripts/security-check.sh
```

## 🛠️ Configuración

La configuración de la aplicación se encuentra en `config/app-config.json`.

Ver [config/README.md](config/README.md) para más detalles sobre configuración.

## 📄 Licencia

Este proyecto está licenciado bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🤝 Contribución

1. Haz fork del proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📞 Contacto

Organización: [infra-neo](https://github.com/infra-neo)

Repositorio: [poc1-secure-access](https://github.com/infra-neo/poc1-secure-access)

---

**Nota**: Este es un repositorio de prueba de concepto. Todos los flujos y configuraciones pueden ser adaptados según las necesidades del proyecto.