#!/bin/bash

# 系统重启后运行本脚本。

# 定义用户目录
USER_HOME="/usr/home/$(whoami)"
BASH_PROFILE="$USER_HOME/.bash_profile"

# 添加新的环境变量条目到 .bash_profile
if ! grep -q 'export PATH="$USER_HOME/node_modules/pm2/bin:$PATH"' "$BASH_PROFILE"; then
    echo "export PATH=\"$USER_HOME/node_modules/pm2/bin:\$PATH\"" >> "$BASH_PROFILE"
fi