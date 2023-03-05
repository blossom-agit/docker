#!/bin/bash

set -Ee

function capture_mode() {
  if [[ -z "${1}" ]]; then
    echo -e "Usage: \n bash setup.sh [OPTIONS]\n \n Available Options: \n      check-inventory   Check provided inventory\n      install           Install TAO Toolkit API\n      uninstall         Uninstall TAO Toolkit API\n      validate          Validate TAO Toolkit API Installation"
    echo
    exit 1
  fi
}

function get_os() {
  grep -iw ID /etc/os-release | awk -F '=' '{print $2}'
}

function get_os_version() {
  grep -iw VERSION_ID /etc/os-release | awk -F '=' '{print $2}' | tr -d '"'
}

function get_target_os() {
  cat target-os
}

function get_target_os_version() {
  cat target-os-version
}

function check_os_and_version_supported() {
	local os
	os=$(get_os)
	local os_version
	os_version=$(get_os_version)
  if [[ ${os} != "ubuntu" || ! ( ${os_version} == "20.04" || ${os_version} == "18.04" ) ]]; then
    echo "Script cannot be run from a machine running ${os} : ${os_version}"
    exit 1
  fi
}

function check_user_has_password_less_sudo() {
  if ! sudo -n true 2> /dev/null; then
    echo "Script must be run as a user having password-less sudo"
    exit 1
  fi
}

function check_internet_access() {
  if ! wget --quiet --spider www.google.com; then
    echo "This system does not have a internet access"
    exit 1
  fi
}

function ansible_install() {
  if ! hash ansible sshpass 2>/dev/null; then
    local os
    os=$(get_os)
    local os_version
    os_version=$(get_os_version)
    if [[ ${os} == "ubuntu" && ${os_version} == "20.04"  ]]; then
      echo "Installing ansible"
      {
        sudo apt-get update
        sudo apt-get install ansible sshpass -y
      } > /dev/null
    fi
    if [[ $os == "ubuntu" && $os_version == "18.04" ]]; then
      echo "Installing ansible"
      {
        sudo apt-add-repository ppa:ansible/ansible -y
        sudo apt-get update
        sudo apt-get install ansible sshpass -y
      } > /dev/null
    fi
  fi
}

function pip_modules_install() {
  if ! hash pip 2>/dev/null; then
    local os
    os=$(get_os)
    local os_version
    os_version=$(get_os_version)
    if [[ ${os} == "ubuntu" && ${os_version} == "20.04"  ]]; then
      echo "Installing pip"
      {
        sudo apt-get update
        sudo apt-get install python3-pip -y
      } > /dev/null
    fi
    if [[ $os == "ubuntu" && $os_version == "18.04" ]]; then
      echo "Installing pip"
      {
        sudo apt-get update
        sudo apt-get install python-pip -y
      } > /dev/null
    fi
  fi
  pip install -r requirements.txt > /dev/null
}

function install_local_tools() {
  check_os_and_version_supported
  check_user_has_password_less_sudo
  check_internet_access
  ansible_install
  pip_modules_install
}

function capture_inventory() {
  local hosts_file_path
  local default_hosts_file_path
  default_hosts_file_path="./hosts"
  read -r -p "Provide the path to the hosts file [${default_hosts_file_path}]: " hosts_file_path
  if [[ -n "${hosts_file_path}" && "${default_hosts_file_path}" != "${hosts_file_path}" ]]; then
    cp "${hosts_file_path}" "${default_hosts_file_path}"
  fi
}

function capture_ngc_config() {
  touch tao-toolkit-api-ansible-values.yml
  local ngc_api_key
  local existing_ngc_api_key
  existing_ngc_api_key=$(grep '^ngc_api_key' tao-toolkit-api-ansible-values.yml | awk '{print $2}')
  if [[ -n "${existing_ngc_api_key}" ]]; then
    read -r -p "Provide the ngc-api-key [${existing_ngc_api_key}]: " ngc_api_key
    ngc_api_key="${ngc_api_key:=${existing_ngc_api_key}}"
  else
    read -r -p "Provide the ngc-api-key: " ngc_api_key
    if [[ -z "${ngc_api_key}" ]]; then
      echo "Script requires ngc-api-key to proceed"
      exit 1
    fi
  fi
  local ngc_email
  local existing_ngc_email
  existing_ngc_email=$(grep '^ngc_email' tao-toolkit-api-ansible-values.yml | awk '{print $2}')
  if [[ -n "${existing_ngc_email}" ]]; then
    read -r -p "Provide the ngc-email [${existing_ngc_email}]: " ngc_email
    ngc_email="${ngc_email:=${existing_ngc_email}}"
  else
    read -r -p "Provide the ngc-email: " ngc_email
    if [[ -z "${ngc_email}" ]]; then
      echo "Script requires ngc-email to proceed"
      exit 1
    fi
  fi
  local api_chart
  local existing_api_chart
  existing_api_chart=$(grep '^api_chart' tao-toolkit-api-ansible-values.yml | awk '{print $2}')
  if [[ -n "${existing_api_chart}" ]]; then
    read -r -p "Provide the api-chart [${existing_api_chart}]: " api_chart
    api_chart="${api_chart:=${existing_api_chart}}"
  else
    read -r -p "Provide the api-chart: " ngc_email
    if [[ -z "${api_chart}" ]]; then
      echo "Script requires api-chart to proceed"
      exit 1
    fi
  fi
  local api_values
  local existing_api_values
  existing_api_values="$(grep '^api_values' tao-toolkit-api-ansible-values.yml | awk '{print $2}')"
  if [[ -n "${existing_api_values}" ]]; then
    read -r -p "Provide the api-values [${existing_api_values}]: " api_values
    api_values="${api_values:=${existing_api_values}}"
  else
    read -r -p "Provide the api-values: " api_values
    if [[ -z "${api_values}" ]]; then
      echo "Script requires api-values to proceed"
      exit 1
    fi
  fi
  sed -e '/^ngc_api_key:.*/d' -e '/^ngc_email:.*/d' -e '/^api_chart:.*/d' -e '/^api_values:.*/d' -i tao-toolkit-api-ansible-values.yml
  local cluster_name
  local existing_cluster_name
  existing_cluster_name="$(grep '^cluster_name' tao-toolkit-api-ansible-values.yml | awk '{print $2}')"
  if [[ -n "${existing_cluster_name}" ]]; then
    read -r -p "Provide the cluster-name [${existing_cluster_name}]: " cluster_name
    cluster_name="${cluster_name:=${existing_cluster_name}}"
  else
    read -r -p "Provide the cluster-name: " cluster_name
    if [[ -z "${cluster_name}" ]]; then
      echo "Script requires cluster-name to proceed"
      exit 1
    fi
  fi
  sed -e '/^ngc_api_key:.*/d' -e '/^ngc_email:.*/d' -e '/^api_chart:.*/d' -e '/^api_values:.*/d' -e '/^cluster_name:.*/d' -i tao-toolkit-api-ansible-values.yml
  echo "ngc_api_key: ${ngc_api_key}" | tee -a tao-toolkit-api-ansible-values.yml 1> /dev/null
  echo "ngc_email: ${ngc_email}" | tee -a tao-toolkit-api-ansible-values.yml 1> /dev/null
  echo "api_chart: ${api_chart}" | tee -a tao-toolkit-api-ansible-values.yml 1> /dev/null
  echo "api_values: ${api_values}" | tee -a tao-toolkit-api-ansible-values.yml 1> /dev/null
  echo "cluster_name: ${cluster_name}" | tee -a tao-toolkit-api-ansible-values.yml 1> /dev/null
}

function check_inventory() {
  ansible-playbook -i hosts --flush-cache check-inventory.yml
}

function prepare_cnc() {
  local os
	os=$(get_target_os)
	local os_version
	os_version=$(get_target_os_version)
  if [[ ${os} == "Ubuntu" && ${os_version} == "20.04"  ]]; then
    cp cnc/cnc_values_6.1.yaml cnc/cnc_values.yaml
  elif [[ ${os} == "Ubuntu" && ${os_version} == "18.04"  ]]; then
    cp cnc/cnc_values_3.1.yaml cnc/cnc_values.yaml
  else
    echo "Cluster cannot be configured on hosts running ${os} : ${os_version}"
    exit 1
  fi
}

function uninstall_existing_nvidia_drivers() {
  ansible-playbook -i hosts --flush-cache uninstall-nvidia-drivers.yml
}

function uninstall_existing_cluster() {
  ansible-playbook -i hosts --flush-cache cnc/cnc-uninstall.yaml
}

function install_new_cluster() {
  ansible-playbook -i hosts --flush-cache cnc/cnc-installation.yaml
}

function validate_cluster() {
  ansible-playbook -i hosts --flush-cache cnc/cnc-validation.yaml
}

function install_tao_toolkit_api() {
  ansible-playbook -i hosts --flush-cache install-tao-toolkit-api.yml
}

capture_mode "${@}"
install_local_tools
capture_inventory
if [[ "${1}" == "check-inventory" ]]; then
  check_inventory
fi
if [[ "${1}" == "install" ]]; then
  capture_ngc_config
  check_inventory
  prepare_cnc
  uninstall_existing_nvidia_drivers
  uninstall_existing_cluster
  install_new_cluster
  validate_cluster
  install_tao_toolkit_api
fi
if [[ "${1}" == "uninstall" ]]; then
  check_inventory
  prepare_cnc
  uninstall_existing_nvidia_drivers
  uninstall_existing_cluster
fi
if [[ "${1}" == "validate" ]]; then
  check_inventory
  prepare_cnc
  validate_cluster
fi