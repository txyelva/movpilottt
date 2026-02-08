# MoviePilot（修改版）在群晖 DSM 7.1 打包/安装 SPK 指南

本仓库提供的 SPK 是 **Docker/Container Manager 套壳包**：SPK 负责在群晖上创建配置目录、生成 `.env`，并通过 `docker run` 启动 `ghcr.io/zqchris/moviepilot:latest` 容器。

## 打包（在 macOS/Linux 上执行）

在项目根目录执行：

```bash
bash synology/build-spk.sh
```

产物输出到：

- `dist/MoviePilot-<version>.spk`

## 群晖 DSM 7.1 安装前置条件

- 已安装 **Container Manager**（套件中心）。
- NAS 具备可用网络（首次安装会尝试 `docker pull` 镜像）。

## 安装（DSM 7.1）

- 打开 **套件中心** → 右上角 **手动安装** → 选择 `MoviePilot-*.spk`。
- 安装向导中可配置：
  - Web 访问端口（默认 `3000`）
  - 配置目录（容器 `/config` 映射目录，默认 `/volume1/docker/moviepilot/config`）

安装完成后，套件中心启动套件即可。

## 数据与目录映射

默认容器挂载：

- `CONFIG_DIR:/config`
- `/volume1:/volume1`

这意味着你可以在 MoviePilot 内直接访问群晖的 `/volume1` 下的媒体/下载目录（注意权限）。

## 启动/停止/卸载行为

- **启动**：脚本会移除同名容器 `moviepilot-mod` 后重新创建（确保配置更新生效）。
- **停止**：停止容器。
- **卸载**：会停止并移除容器，但 **保留配置目录**（需手动删除才会清理数据）。

## 常见问题

### 1) 启动失败：找不到 docker 命令

请确认已安装并打开 Container Manager；必要时在群晖 SSH 中确认 `docker` 可用。

### 2) 镜像拉取失败

安装阶段 `postinst` 会尝试 `docker pull`，网络不可用时会给出警告；你也可以在网络恢复后重启套件再拉取。

### 3) 端口冲突

安装向导选择其他端口，或修改 `/var/packages/MoviePilot/target/.env` 中的 `NGINX_PORT` 后重启套件。

