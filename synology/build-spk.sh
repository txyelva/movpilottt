#!/bin/bash
#
# MoviePilot SPK 打包脚本
# 用于生成 Synology 群晖套件中心可安装的 .spk 包
#
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# 从 version.py 读取版本号
APP_VERSION=$(grep "^APP_VERSION" "$PROJECT_DIR/version.py" | cut -d"'" -f2)
# 修改版标识
MOD_VERSION="${APP_VERSION}-mod.1"
# SPK 内部版本号（去掉 v 前缀）
SPK_VERSION=$(echo "$MOD_VERSION" | sed 's/^v//')

PACKAGE_NAME="MoviePilot"
DOCKER_IMAGE="txyelva/movpilottt:latest"

# 输出目录
OUTPUT_DIR="${PROJECT_DIR}/dist"
BUILD_DIR=$(mktemp -d)

echo "================================================"
echo "  MoviePilot SPK Builder"
echo "  Version: ${SPK_VERSION}"
echo "  Docker Image: ${DOCKER_IMAGE}"
echo "================================================"

# 清理
cleanup() {
    rm -rf "$BUILD_DIR"
}
trap cleanup EXIT

# ====================================================
# macOS 兼容：禁止 tar 打包 ._ 资源文件
# ====================================================
export COPYFILE_DISABLE=1

# 创建输出目录
mkdir -p "$OUTPUT_DIR"

# ========== 1. 创建 INFO 文件 ==========
cat > "$BUILD_DIR/INFO" <<EOF
package="${PACKAGE_NAME}"
version="${SPK_VERSION}"
os_min_ver="7.0-40000"
description="MoviePilot - automated media management tool (mod version based on ${APP_VERSION})"
description_chs="MoviePilot 自动化影视管理工具（个人修改版，基于 ${APP_VERSION}）"
maintainer="zqchris"
maintainer_url="https://github.com/zqchris/MoviePilot"
distributor="zqchris"
distributor_url="https://github.com/zqchris/MoviePilot"
support_url="https://github.com/zqchris/MoviePilot/issues"
arch="noarch"
startable="yes"
displayname="MoviePilot (Mod)"
displayname_chs="MoviePilot (修改版)"
install_dep_packages="ContainerManager"
silent_install="yes"
silent_upgrade="yes"
EOF

# ========== 2. 创建 package.tgz ==========
PACKAGE_DIR="$BUILD_DIR/_package"
mkdir -p "$PACKAGE_DIR"

# 复制 docker-compose.yml
cp "$SCRIPT_DIR/package/docker-compose.yml" "$PACKAGE_DIR/"

# 创建默认 env 文件模板
cat > "$PACKAGE_DIR/env.defaults" <<'ENVEOF'
# MoviePilot 默认环境变量
# 详细说明请参考: https://wiki.movie-pilot.org
MOVIEPILOT_AUTO_UPDATE=false
NGINX_PORT=3000
PUID=1000
PGID=1000
UMASK=000
TZ=Asia/Shanghai
ENVEOF

# 打包 package.tgz（注意：用 -C 避免包含目录前缀）
tar czf "$BUILD_DIR/package.tgz" -C "$PACKAGE_DIR" .

# ========== 3. 复制脚本 ==========
mkdir -p "$BUILD_DIR/scripts"
for script in postinst preuninst start-stop-status; do
    cp "$SCRIPT_DIR/scripts/$script" "$BUILD_DIR/scripts/"
    chmod 755 "$BUILD_DIR/scripts/$script"
done

# ========== 4. 复制配置 ==========
mkdir -p "$BUILD_DIR/conf"
cp "$SCRIPT_DIR/conf/privilege" "$BUILD_DIR/conf/"
cp "$SCRIPT_DIR/conf/resource" "$BUILD_DIR/conf/" 2>/dev/null || true

# ========== 5. 复制安装向导 ==========
if [ -d "$SCRIPT_DIR/WIZARD_UIFILES" ]; then
    mkdir -p "$BUILD_DIR/WIZARD_UIFILES"
    cp "$SCRIPT_DIR/WIZARD_UIFILES/"* "$BUILD_DIR/WIZARD_UIFILES/" 2>/dev/null || true
fi

# ========== 6. 复制图标（可选） ==========
if [ -f "$SCRIPT_DIR/PACKAGE_ICON.PNG" ]; then
    cp "$SCRIPT_DIR/PACKAGE_ICON.PNG" "$BUILD_DIR/"
fi
if [ -f "$SCRIPT_DIR/PACKAGE_ICON_256.PNG" ]; then
    cp "$SCRIPT_DIR/PACKAGE_ICON_256.PNG" "$BUILD_DIR/"
fi

# ========== 7. 打包 SPK ==========
SPK_FILE="${OUTPUT_DIR}/${PACKAGE_NAME}-${SPK_VERSION}.spk"

# 列出所有要打包的文件（排除临时目录）
SPK_CONTENTS="INFO package.tgz scripts conf"
[ -d "$BUILD_DIR/WIZARD_UIFILES" ] && SPK_CONTENTS="$SPK_CONTENTS WIZARD_UIFILES"
[ -f "$BUILD_DIR/PACKAGE_ICON.PNG" ] && SPK_CONTENTS="$SPK_CONTENTS PACKAGE_ICON.PNG"
[ -f "$BUILD_DIR/PACKAGE_ICON_256.PNG" ] && SPK_CONTENTS="$SPK_CONTENTS PACKAGE_ICON_256.PNG"

# 使用 tar 打包，不压缩（SPK 外层不需要压缩）
tar cf "$SPK_FILE" -C "$BUILD_DIR" $SPK_CONTENTS

echo ""
echo "================================================"
echo "  SPK 构建完成!"
echo "  输出文件: ${SPK_FILE}"
echo "  文件大小: $(du -h "$SPK_FILE" | cut -f1)"
echo "================================================"

# 验证：列出 SPK 内容
echo ""
echo "SPK 包内容:"
tar tf "$SPK_FILE"
