#!/usr/bin/env bash
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
catch_errors

function dependencies() {
    msg_info "Installing System Dependencies"
    $STD apt-get update
    $STD apt-get install -y curl sudo mc
    msg_ok "Dependencies installed"
}

function install_opencode() {
    msg_info "Installing OpenCode CLI"
    # Set INSTALL_DIR to /usr/local/bin so the systemd service can find the file
    export INSTALL_DIR=/usr/local/bin
    $STD bash -c "$(curl -fsSL https://opencode.ai/install)"
    msg_ok "OpenCode successfully installed"
}

function configure_service() {
    msg_info "Creating Systemd Service for automatic start"
    cat <<EOF >/etc/systemd/system/opencode.service
[Unit]
Description=OpenCode Web Server
After=network.target

[Service]
Type=simple
User=root
# Default password (should be changed by the user in this file after installation)
Environment="OPENCODE_SERVER_PASSWORD=opencode"
ExecStart=/usr/local/bin/opencode web --hostname 0.0.0.0 --port 4096
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    systemctl enable -q --now opencode.service
    msg_ok "Service created and started"
}

# Execute functions in order
dependencies
install_opencode
configure_service

# Standard cleanup functions
motd_ssh
customize

msg_info "Cleaning up temporary files"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "System cleaned"
