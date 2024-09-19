

# DeepLX Installation and Setup on FreeBSD (Serv00)

This guide provides step-by-step instructions to deploy the [DeepLX](https://github.com/OwO-Network/DeepLX) service on FreeBSD (Serv00) using `pm2` for process management. The script automates downloading, configuring, and starting the DeepLX service while binding it to a domain.

## Prerequisites

1. **FreeBSD** system (Serv00).
2. Installed tools:
    - `devil` for domain and port management.
    - `npm` for installing `pm2`.
    - Internet connection to download DeepLX binaries.

## Script Overview

The script performs the following tasks:

1. Sets necessary system settings with `devil binexec on`.
2. Fetches the latest DeepLX version from GitHub and downloads the FreeBSD binary.
3. Asks for the port to bind the service or opens a new port using `devil`.
4. Prompts for domain binding, allowing you to use an existing domain or reset an old one.
5. Installs and configures `pm2` to manage the DeepLX service.
6. Starts DeepLX and saves the process state for future reboots.

## Installation Steps

1. **Clone or Download** this repository into your home directory:
   ```bash
   git clone https://github.com/aigem/deeplx-freeAPI-serv00.git
   cd deeplx-freeAPI-serv00
   ```

2. **Make the install script executable**:
   ```bash
   chmod +x install_deeplx.sh
   ```

3. **Run the script**:
   ```bash
   ./install_deeplx.sh
   ```

## Customizing the Installation

You can customize the following variables in the script:

- **`API_TOKEN`**: If you have a token for the DeepLX API, set it here to protect your service.
- **`DEEPLX_PORT`**: You can select an existing port or create a new one dynamically.
- **Domain**: You can use an existing domain or reset your default domain (`$(whoami).serv00.net`).

## Troubleshooting

- **DeepLX not starting**: Ensure the port you've selected is open and not in use.
- **Domain binding issues**: If the domain fails to bind, check `devil www` for any errors and re-run the script to attempt the binding process again.
- **PM2 logs**: You can view logs for the DeepLX service using the following command:
   ```bash
   pm2 logs deeplx
   ```

## License

This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).

---
