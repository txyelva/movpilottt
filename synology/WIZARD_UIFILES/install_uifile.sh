#!/bin/bash
#
# MoviePilot SPK 安装向导
# 在群晖套件中心安装时显示配置界面
#

cat <<'WIZEOF'
[{
    "step_title": "MoviePilot 配置",
    "items": [{
        "type": "textfield",
        "desc": "Web 访问端口",
        "subitems": [{
            "key": "wizard_port",
            "desc": "端口号",
            "defaultValue": "3000",
            "validator": {
                "allowBlank": false,
                "regex": {
                    "expr": "^[0-9]+$",
                    "errorText": "请输入有效的端口号"
                }
            }
        }]
    }, {
        "type": "textfield",
        "desc": "配置文件存储路径（容器的 /config 映射目录）",
        "subitems": [{
            "key": "wizard_config_dir",
            "desc": "路径",
            "defaultValue": "/volume1/docker/moviepilot/config",
            "validator": {
                "allowBlank": false,
                "regex": {
                    "expr": "^/volume",
                    "errorText": "路径必须以 /volume 开头"
                }
            }
        }]
    }, {
        "type": "multiselect",
        "desc": "提示信息",
        "subitems": [{
            "key": "wizard_info",
            "desc": "安装后将自动拉取 Docker 镜像，请确保群晖已安装 Container Manager 且网络可用。首次启动可能需要几分钟。",
            "defaultValue": true,
            "disabled": true
        }]
    }]
}]
WIZEOF
