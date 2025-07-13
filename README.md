# acsprime/oxipng

**acsprime/oxipng** is a minimal, statically compiled Docker image for [`oxipng`](https://github.com/shssoichiro/oxipng) — a fast, multithreaded PNG optimizer written in Rust.

This image is built from source using musl for full static linking, size-optimized, and suitable for use in constrained or minimal environments.

---

## 🐳 Docker Tags

| Tag         | Description                        |
|-------------|------------------------------------|
| `latest`    | Latest version (`v9.1.5` currently) |
| `v9.1.5`    | Pinned build of version 9.1.5       |
| `v9.1.4`    | Pinned build of version 9.1.4       |

---

## 📦 Usage

Run `oxipng` in a container to optimize a PNG file:

```bash
docker run --rm -v $(pwd):/data acsprime/oxipng -o 4 /data/image.png
```

You can also chain it in your image-processing pipelines.

---

## 🏗️ Build Locally

To build the image yourself:

```bash
make build
```

To build and push (requires Docker Hub login):

```bash
make release
```

You can also release specific versions:

```bash
make release-9.1.5
make release-9.1.4
```

---

## 🧰 Targets

```bash
make build          # Build Docker image
make push           # Push to Docker Hub
make release        # Build and push the latest version
make release-9.1.5  # Build/push v9.1.5 only (not tagged as latest)
make clean          # Remove local images
make help           # Show available targets
make test           # Ensure built binary in image works
```

---

## 🛠️ Build Details

- Compiled statically 
- Final image is based on `scratch` (no shell, no runtime)
---

## 📁 Using in Other Dockerfiles

You can use this image as a build stage to copy the `oxipng` binary into your own Docker images:

```dockerfile
FROM acsprime/oxipng:v9.1.5 as oxipng

# In your final image
FROM php:8.3-cli
COPY --from=oxipng /oxipng /usr/local/bin/oxipng
```

This gives you a static, portable `oxipng` binary inside any base image, ready for use in compression pipelines.


---


## 📄 License

This project builds the open-source [`oxipng`](https://github.com/shssoichiro/oxipng) tool.  
Please refer to that repository for license information.

---

## 👤 Maintainer

Maintained by [AntonioCS](https://github.com/antoniocs).
