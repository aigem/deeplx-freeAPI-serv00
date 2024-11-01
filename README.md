# DeepLX 部署与安装指南

本指南介绍如何在 FreeBSD (Serv00) 环境中使用 `pm2` 部署 [DeepLX](https://deeplx.owo.network)，并详细说明脚本的运行步骤。DeepLX 是一个开源的翻译服务，兼容 DeepL API，允许用户在本地化环境中部署翻译服务。

【 [视频教程](https://www.bilibili.com/video/BV1e9bceoECw/) 】

## 项目简介

DeepLX 是一个由 [OwO Network](https://deeplx.owo.network) 提供的 API 服务，能够模拟 DeepL 官方 API 进行翻译请求。用户可以选择开源的免费版本部署到本地，享受无限制的翻译请求服务。常见功能包括：
- 翻译任意文本。
- 支持设置 HTTP 代理。
- 提供访问令牌保护 API。
- 可选使用 DeepL Pro 的 `dl_session` 进行高级功能。

## 环境要求

1. FreeBSD 系统 (Serv00)。


## 安装步骤

### 0. 一键脚本
```bash
git clone https://github.com/aigem/deeplx-freeAPI-serv00.git
cd deeplx-freeAPI-serv00
chmod +x install_deeplx.sh
./install_deeplx.sh
```

### 1. 克隆项目代码

首先将项目克隆到用户主目录：
```bash
git clone https://github.com/aigem/deeplx-freeAPI-serv00.git
cd deeplx-freeAPI-serv00
```

### 2. 赋予安装脚本执行权限
```bash
chmod +x install_deeplx.sh
```

### 3. 运行安装脚本
执行以下命令来自动部署 DeepLX：
```bash
./install_deeplx.sh
```

### 4. 脚本执行流程

- **系统设置**：脚本首先启用 FreeBSD 的二进制执行权限：

- **下载最新的 DeepLX 版本**：通过 GitHub API 获取最新的 DeepLX 版本，并下载 FreeBSD 版本的二进制文件。

- **端口管理**：提示用户输入已有的开放端口或通过 `devil` 自动开通新的端口。

- **域名绑定**：脚本允许用户选择默认域名 (`$(whoami).serv00.net`) 或自定义域名进行绑定。使用 `devil www` 命令完成域名的重置和新建。

- **安装并启动 pm2**：使用 `npm` 安装 `pm2`，并通过 `pm2` 管理 DeepLX 服务，保证在系统重启后自动启动。

## 使用说明

[视频教程](https://www.bilibili.com/video/BV1e9bceoECw/)

### 命令行参数
DeepLX 支持多种命令行参数，具体说明请参考 [DeepLX 变量文档](https://deeplx.owo.network/install/variables.html)【24†source】【25†source】。

常见命令行参数包括：

- `-ip`：绑定服务的 IP 地址，默认为 `0.0.0.0`。
- `-port`：设置服务监听的端口，默认值为 `1188`。
- `-token`：设置访问 API 所需的令牌（可选）。
- `-proxy`：设置 HTTP 代理服务器地址（可选）。
- `-s`：设置 `dl_session` 用于 DeepL Pro 账户的高级功能（可选）。

### pm2 命令
你可以使用 `pm2` 命令查看和管理 DeepLX 服务的状态：
```bash
pm2 list       # 查看所有运行中的进程
pm2 logs deeplx  # 查看 DeepLX 的日志
```

### 日志与排查
如果服务启动失败，可以通过 `pm2 logs deeplx` 查看详细日志排查问题。

## 常见问题

- **DeepLX 无法启动**：检查所选端口是否已被占用，或者查看日志中是否存在错误。
- **域名绑定失败**：确保域名正确配置 A 记录指向你的服务器 IP，检查 `devil www` 的操作日志。可系统后台进行设置。

## 许可证

此项目基于 [MIT 许可证](https://opensource.org/licenses/MIT) 进行发布。

