#!/bin/bash

# 系统必要设置
devil binexec on

# 配置变量
PROJECT_NAME="deeplx"
GITHUB_REPO_NAME="deeplx-freeAPI-serv00"
API_TOKEN="deeplx"
USER_HOME="/usr/home/$(whoami)"
BASH_PROFILE="$USER_HOME/.bash_profile"
OK_SITE="待配置"

# 色彩设置
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无色彩

# 输出信息
function print_success {
    echo -e "${GREEN}$1${NC}"
}

function print_error {
    echo -e "${RED}$1${NC}"
}

function print_warning {
    echo -e "${YELLOW}$1${NC}"
}

# 生成 info.html 文件
chmod +x ./make_info.sh
print_success "生成 info.html 文件..."
./make_info.sh

# 拷贝配置文件并设置权限
cp "$USER_HOME/$GITHUB_REPO_NAME/set_env_vars.sh" "$USER_HOME/$PROJECT_NAME/set_env_vars.sh"
chmod +x "$USER_HOME/$PROJECT_NAME/set_env_vars.sh"

# 创建目录并获取最新版本的 DeepLX
cd "$USER_HOME"
mkdir -p "$USER_HOME/$PROJECT_NAME"

last_version=$(curl -Ls "https://api.github.com/repos/OwO-Network/DeepLX/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
if [ -z "$last_version" ]; then
    print_error "无法获取 DeepLX 最新版本。"
    exit 1
fi

print_success "DeepLX 最新版本: $last_version，开始安装..."

# 下载并赋予执行权限
fetch -o "$USER_HOME/deeplx/deeplx" "https://github.com/OwO-Network/DeepLX/releases/download/${last_version}/deeplx_freebsd_amd64"
chmod +x "$USER_HOME/deeplx/deeplx"

# 选择端口
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
print_warning "你在 Serv00 开通的端口号为: "
devil port list
read -p "请输入开通的端口号，或输入 'add' 来开通一个新的端口号: " user_input

if [[ "$user_input" == "add" ]]; then
    devil port add tcp random
    devil port list
    read -r DEEPLX_PORT
    if [[ "$DEEPLX_PORT" -lt 1024 || "$DEEPLX_PORT" -gt 65535 ]]; then
        print_error "端口号不在有效范围内 (1024-65535)。"
        exit 1
    fi
else
    DEEPLX_PORT="$user_input"
    if [[ "$DEEPLX_PORT" -lt 1024 || "$DEEPLX_PORT" -gt 65535 ]]; then
        print_error "端口号不在有效范围内 (1024-65535)。"
        exit 1
    fi
    print_success "选定端口为: $DEEPLX_PORT"
fi

# 网站绑定
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
print_warning "现需要绑定网站并指向 $DEEPLX_PORT"
read -p "输入 'yes' 来重置网站 ($(whoami).serv00.net)，或输入自定义域名，或输入 'no' 退出: " user_input

if [[ "$user_input" == "yes" ]]; then
    fi
    print_success "开始重置网站..."
    DELETE_OUTPUT=$(devil www del "$(whoami).serv00.net")
    ADD_OUTPUT=$(devil www add "$(whoami).serv00.net" proxy localhost "$DEEPLX_PORT")
    if echo "$ADD_OUTPUT" | grep -q "Domain added succesfully"; then
        print_success "网站 $(whoami).serv00.net 成功重置。"
        OK_SITE="$(whoami).serv00.net"
    else
        print_error "新建网站失败，请之后检查。"
    fi
elif [[ "$user_input" != "no" ]]; then
    custom_domain="$user_input"
    DELETE_OUTPUT=$(devil www del "$custom_domain")
    ADD_OUTPUT=$(devil www add "$custom_domain" proxy localhost "$DEEPLX_PORT")
    if echo "$ADD_OUTPUT" | grep -q "Domain added succesfully"; then
        print_success "网站 $custom_domain 成功绑定。"
        OK_SITE="$custom_domain"
    else
        print_error "新建网站失败，请之后检查。"
    fi
else
    print_warning "跳过网站设置。"
fi

# 安装 PM2
if [ ! -f "$USER_HOME/node_modules/pm2/bin/pm2" ]; then
    print_success "正在安装 PM2..."
    npm install pm2
else
    print_success "PM2 已安装。"
fi

# 删除旧的 PM2 环境变量
sed -i.bak '/export PATH=".*\/node_modules\/pm2\/bin:$PATH"/d' "$BASH_PROFILE"
echo "export PATH=\"$USER_HOME/node_modules/pm2/bin:\$PATH\"" >> "$BASH_PROFILE"
source "$BASH_PROFILE"

# 启动 DeepLX
pm2 start "$USER_HOME/deeplx/deeplx" --name deeplx -- -ip 0.0.0.0 -port "$DEEPLX_PORT" -token "$API_TOKEN"
if pm2 list | grep -q "deeplx"; then
    print_success "DeepLX 启动成功，监听端口 $DEEPLX_PORT。"
else
    print_error "DeepLX 启动失败。"
    exit 1
fi

# 保存 PM2 状态并配置重启自启
pm2 save
PM2_PATH=$(which pm2 | tr -d '\n')
crontab -l | grep -v '@reboot.*pm2 resurrect' | crontab -
(crontab -l 2>/dev/null; echo "@reboot $PM2_PATH resurrect") | crontab -
(crontab -l 2>/dev/null; echo "@reboot /usr/home/$(whoami)/$PROJECT_NAME/set_env_vars.sh") | crontab -

if [[ -f "$USER_HOME/domains/$OK_SITE/public_html/index.html" ]]; then
    rm "$USER_HOME/domains/$OK_SITE/public_html/index.html"

print_success "DeepLX 安装完成，服务已启动，查看网站: $OK_SITE"