#!/bin/sh

# 系统必要设置
devil binexec on

# 用户目录
PROJECT_NAME="deeplx"
GITHUB_REPO_NAME="deeplx-freeAPI-serv00"
USER_HOME="/usr/home/$(whoami)"
BASH_PROFILE="$USER_HOME/.bash_profile"

chmod +x ./make_info.sh
echo "生成 info.html 文件..."
./make_info.sh

cp /usr/home/$(whoami)/$GITHUB_REPO_NAME/set_env_vars.sh /usr/home/$(whoami)/$PROJECT_NAME/set_env_vars.sh
chmod +x /usr/home/$(whoami)/$PROJECT_NAME/set_env_vars.sh

# 切换到用户目录
cd "$USER_HOME"

# 创建 deeplx 目录
mkdir -p "$USER_HOME/$PROJECT_NAME"

# 获取最新版本的 DeepLX
last_version=$(curl -Ls "https://api.github.com/repos/OwO-Network/DeepLX/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$last_version" ]; then
    echo "无法获取 DeepLX 最新版本。"
    exit 1
fi

echo "DeepLX 最新版本: $last_version，开始安装..."

# 下载 FreeBSD 版本的 DeepLX 二进制文件
fetch -o "$USER_HOME/deeplx/deeplx" "https://github.com/OwO-Network/DeepLX/releases/download/${last_version}/deeplx_freebsd_amd64"

# 赋予可执行权限
chmod +x "$USER_HOME/deeplx/deeplx"

# 提示用户输入端口号或开通新端口
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
echo "你在Serv00开通的端口号为: "
devil port list

read -p "请输入其中某个已开通的端口号，或输入 'add' 来开通一个新的端口号 (总共最多3个): " user_input

if [[ "$user_input" == "add" ]]; then
    # 自动开通一个随机端口
    devil port add tcp random
    echo "端口开通成功: "
    devil port list
    echo "请输入刚才生成的端口号: "
    read -r DEEPLX_PORT
    if [[ "$DEEPLX_PORT" -lt 1024 || "$DEEPLX_PORT" -gt 65535 ]]; then
        echo "端口号不在有效范围内 (1024-65535)。"
        exit 1
    fi
else
    DEEPLX_PORT="$user_input"
    if [[ "$DEEPLX_PORT" -lt 1024 || "$DEEPLX_PORT" -gt 65535 ]]; then
        echo "端口号不在有效范围内 (1024-65535)。"
        exit 1
    fi
    echo "选定端口为: $user_input"
fi

# 绑定网站部分
echo "现需要绑定网站并指向 $DEEPLX_PORT"
echo "警告：这将会重置选择的这个网站（删除网站所有内容）！"
echo "=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
read -p "请输入 'yes' 来重置网站 ($(whoami).serv00.net)，或输入你自己的域名（需要A记录解析到你的IP）或输入 'no' 来退出自动设置：" user_input

if [[ "$user_input" == "yes" ]]; then
    if [[ -f "$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html" ]]; then
        rm "$USER_HOME/domains/$(whoami).serv00.net/public_html/index.html"
    fi
    echo "开始重置网站..."

    # 删除旧域名，无论删除是否成功，都会继续新增域名
    DELETE_OUTPUT=$(devil www del "$(whoami).serv00.net")

    if [[ echo "$DELETE_OUTPUT" | grep -q "Domain deleted" ]]; then
        echo "旧网站 $(whoami).serv00.net 删除成功。"
    else
        echo "旧网站 $(whoami).serv00.net 删除失败，继续创建新网站。"
    fi

    # 新增网站
    ADD_OUTPUT=$(devil www add "$(whoami).serv00.net" proxy localhost "$DEEPLX_PORT")

    if [[ echo "$ADD_OUTPUT" | grep -q "Domain added succesfully" ]]; then
        echo "网站成功重置并指向端口，网址为：$(whoami).serv00.net。"
    else
        echo "新建网站失败，请之后检查。不影响安装。"
    fi

elif [[ "$user_input" != "no" ]]; then
    custom_domain="$user_input"

    # 删除旧域名，无论删除是否成功，都会继续新增域名
    DELETE_OUTPUT=$(devil www del "$custom_domain")

    if [[ echo "$DELETE_OUTPUT" | grep -q "Domain deleted" ]]; then
        echo "旧域名 $custom_domain 删除成功。"
    else
        echo "旧域名 $custom_domain 删除失败，继续创建新网站。"
    fi

    # 新增网站
    ADD_OUTPUT=$(devil www add "$custom_domain" proxy localhost "$DEEPLX_PORT")

    if [[ echo "$ADD_OUTPUT" | grep -q "Domain added succesfully"]]; then
        echo "网站 $custom_domain 成功绑定。"
    else
        echo "新建网站失败，请之后检查。不影响安装。"
    fi
    
    if [[ -f "$USER_HOME/domains/$custom_domain/public_html/index.html" ]]; then
        rm "$USER_HOME/domains/$custom_domain/public_html/index.html"
    fi

    cp ~/set_env_vars.sh /usr/home/$(whoami)/deeplx/set_env_vars.sh
    chmod +x /usr/home/$(whoami)/deeplx/set_env_vars.sh

else
    # 用户选择跳过网站设置
    echo "跳过网站设置，之后进行人工设置。"
fi

# 安装 PM2 (使用 npm)
if [ ! -f "$USER_HOME/node_modules/pm2/bin/pm2" ]; then
    echo "正在安装 PM2..."
    npm install pm2
else
    echo "PM2 已安装。"
fi

# 删除 .bash_profile 中可能存在的旧 PM2 环境变量
sed -i.bak '/export PATH=".*\/node_modules\/pm2\/bin:$PATH"/d' "$BASH_PROFILE"

# 添加 PM2 到环境变量
echo "export PATH=\"$USER_HOME/node_modules/pm2/bin:\$PATH\"" >> "$BASH_PROFILE"

# 重新加载 .bash_profile
source "$BASH_PROFILE"

# 使用 PM2 启动 DeepLX
echo "使用 PM2 启动 DeepLX..."
pm2 start "$USER_HOME/deeplx/deeplx" --name deeplx -- -l 0.0.0.0:"$DEEPLX_PORT"

# 检查是否启动成功
if pm2 list | grep -q "deeplx"; then
    echo "DeepLX 启动成功，正在监听端口 $DEEPLX_PORT。"
else
    echo "DeepLX 启动失败，请检查配置。"
    exit 1
fi

# 保存 PM2 状态
pm2 save

# 配置重启后自动启动 PM2
PM2_PATH=$(which pm2 | tr -d '\n')
crontab -l | grep -v '@reboot.*pm2 resurrect' | crontab -
(crontab -l 2>/dev/null; echo "@reboot $PM2_PATH resurrect") | crontab -

echo "DeepLX 安装完成，服务已启动，当前运行在端口: $DEEPLX_PORT"