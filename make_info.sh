#!/bin/bash

# 用户目录
PROJECT_NAME="deeplx"
GITHUB_REPO_NAME="deeplx-freeAPI-serv00"
USER_HOME="/usr/home/$(whoami)"
BASH_PROFILE="$USER_HOME/.bash_profile"

# 生成 info文件
INFO_FILE="/usr/home/$(whoami)/$GITHUB_REPO_NAME/info.html"

cat <<EOF > "$INFO_FILE"
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WebDAV-go 安装成功</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        h1 {
            color: #333;
        }
        p {
            line-height: 1.6;
            color: #666;
        }
        a {
            color: #0066cc;
            text-decoration: none;
        }
        a:hover {
            text-decoration: underline;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>WebDAV 已成功安装</h1>
        <p>恭喜！WebDAV-go 已成功安装并运行在 <strong>$(whoami).serv00.net</strong> 上。当前的 WebDAV 服务正在 <strong>运行</strong> 。</p>
        <h2> <a href="/" target="_blank">打 开 网 盘</a></h2>
        <h2>主要功能</h2>
        <ul>
            <li>一键安装 WebDAV 文件共享服务</li>
            <li>一劳永逸</li>
            <li>使用 PM2 管理服务，确保其在系统重启后自动恢复</li>
        </ul>

        <h2>进一步阅读</h2>
        <p>欲了解更多详细说明和安装步骤，请访问 GitHub 仓库：</p>
        <p><a href="https://github.com/aigem/serv00-webdav" target="_blank">WebDAV-go GitHub 仓库</a></p>

        <h2>常见问题</h2>
        <p>1. 如何启动及重启 WebDAV-go 服务？</p>
        <p>使用以下命令恢复启动 PWebDAV-go：</p>
        <pre><code>pm2 resurrect</code></pre>
        <p>使用以下命令重启 PM2 中的所有服务：</p>
        <pre><code>pm2 restart all</code></pre>

        <p>2. 如何查看 WebDAV-go 的运行日志？</p>
        <p>使用以下命令查看 PM2 的日志：</p>
        <pre><code>pm2 logs</code></pre>

        <p>3. 如何停止 WebDAV-go 服务？</p>
        <p>使用以下命令停止服务：</p>
        <pre><code>pm2 stop WebDAV-go</code></pre>

        <p>4. 相关路径</p>
        <p>网盘具体路径如下，更多详情请查看<a href="https://github.com/aigem/serv00-webdav" target="_blank">WebDAV-go GitHub 仓库</a></p>
        <pre><code>/usr/home/用户名/webdav//</code></pre>
    </div>
</body>
</html>
EOF