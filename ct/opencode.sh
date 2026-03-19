#!/usr/bin/env bash
source <(curl -sSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)

# Basic variables for the container
APP="OpenCode"
var_tags="coding;ai"
var_cpu="2"
var_ram="2048"
var_disk="4"
var_os="debian"
var_version="12"
var_unprivileged="1"

# Header info in the terminal
header_info "$APP"

# Load basic functions
variables
color
catch_errors

# Define default settings
function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$APP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

# Update logic, in case the user runs the script again inside the LXC
function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -f /usr/local/bin/opencode ]]; then msg_error "No ${APP} installation found!"; exit; fi
  msg_info "Pushing update for $APP"
  export INSTALL_DIR=/usr/local/bin
  $STD bash -c "$(curl -fsSL https://opencode.ai/install)"
  systemctl restart opencode
  msg_ok "$APP successfully updated"
  exit
}

# Execute main process
start
build_container
description

msg_ok "Installation successfully completed!\n"
echo -e "${APP} should now be reachable at the following URL:
         ${BL}http://${IP}:4096${CL} \n"
