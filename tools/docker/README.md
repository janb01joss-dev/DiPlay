# Compilar DiPlay con Docker

Compila el APK dentro de un contenedor con JDK 25, Android SDK 37, Build-Tools 36.0.0 y NDK
28.2.13676358 (las versiones de `.github/workflows/android.yml`). No hace falta instalar
nada en tu computadora aparte de Docker.

## Uso

Desde la raíz del repositorio:

```sh
tools/docker/build.sh              # APK de depuración, sin identidad de iPhone
tools/docker/build.sh check        # igual que la CI: pruebas, lint y APK de debug
```

El APK queda en `mobile/build/outputs/apk/debug/mobile-debug.apk`.

Para un APK que conecte con el iPhone en el carro hacen falta los archivos de autenticación,
que **no** van en Git:

```text
runtime-assets/
└── offline-mfi/
    ├── identity.pk8
    └── certificate.p7b
```

```sh
DIPLAY_AUTH_ASSETS_DIR=/ruta/absoluta/a/runtime-assets tools/docker/build.sh standalone
```

La carpeta se monta en el contenedor solo de lectura y nunca entra en la imagen.
Para actualizar una app ya instalada hay que firmar con la misma clave; ver `docs/BUILD.md`.

## Con Claude Code

Pídele: "Compila el APK con `tools/docker/build.sh` y dime dónde queda". Si tiene la carpeta
de autenticación, dile su ruta para que use `standalone`.

## Notas

- La primera vez descarga el SDK (varios GB) y las dependencias de Gradle; las siguientes usan
  la caché en `~/.cache/diplay-gradle` (cámbiala con `DIPLAY_GRADLE_CACHE`).
- Gradle usa 4 GB de memoria: Docker Desktop debe tener al menos 6 GB asignados.
- En Windows usa Git Bash o WSL para ejecutar `build.sh`.
- Este directorio es herramienta personal: no hace falta incluirlo en un PR al repositorio principal.
