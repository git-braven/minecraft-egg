# Custom Minecraft Egg

Three pieces, working together:

- **`Dockerfile`** — the image Wings pulls and runs for each server (Java 21 + Debian, runs as the `container` user, files live in `/home/container`).
- **`entrypoint.sh`** — what actually launches the server process inside the container.
- **`egg-minecraft-custom.json`** — the Egg definition you import into the Panel (Admin → Nests → Import Egg). It references the image, defines the install script, startup command, and the variables shown in the server's config page.

## 1. Build and push the image

Wings pulls the image from a registry — it won't build it for you, so this step is required before the egg will work.

```bash
docker build -t ghcr.io/yourusername/minecraft-egg:latest .
docker push ghcr.io/yourusername/minecraft-egg:latest
```

Swap `ghcr.io/yourusername` for your actual registry (GHCR, Docker Hub, a private registry, etc.), and update the `docker_images` and `container` fields in `egg-minecraft-custom.json` to match before importing.

## 2. Import the egg

In the Panel: **Admin → Nests → your Nest → Import Egg**, upload `egg-minecraft-custom.json`.

## 3. Create a server using it

When you create a server on this egg, Wings will:

1. Spin up a throwaway container from the image and run the **installation script** (downloads the Minecraft server jar for the version you specify, accepts the EULA).
2. On subsequent boots, run the **startup command** (`java -Xms128M -Xmx{{SERVER_MEMORY}}M ... -jar {{SERVER_JARFILE}} nogui`) inside a container from the same image, with `/home/container` as the persistent server data directory.

## Notes / things you'll likely want to adjust

- **Java version**: this image only installs Temurin 21. If you want to support older Minecraft versions (pre-1.20.5, which need Java 17 or 8), install additional JDKs and either pick one at container start based on a variable, or build separate egg images per Java version — this is how Pterodactyl's own `yolks` images do it.
- **Memory**: `SERVER_MEMORY` isn't declared as an egg variable above — Wings actually injects it automatically from the server's configured memory limit, so you don't need to add it yourself. Don't remove it from the startup command.
- **Port**: `server.properties` server-port/query.port are auto-synced to the Panel-allocated port via the `config.files` block — no action needed there.
- **This is a Vanilla server.** For Paper/Spigot/Forge/Fabric you'd change the install script to pull from the respective API (PaperMC's API, a Forge installer, etc.) — the Dockerfile and entrypoint stay the same.
- Pterodactyl already publishes a well-maintained Java image (`ghcr.io/pterodactyl/yolks:java_21`) with multiple JDKs preinstalled. If you don't specifically need custom OS packages baked in, you could skip building your own image and point `docker_images` at that instead — only the egg JSON would be needed then.

## Files
- `Dockerfile`
- `entrypoint.sh`
- `egg-minecraft-custom.json`
