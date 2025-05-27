#!/bin/bash

source ./aws_profile_setup.sh
source ./aws_auth.sh

aws_config_check() {
    # 確認 ~/.aws/config 是否存在
    if [ ! -f ~/.aws/config ]; then
        echo -e "🚨 ${RED}未找到 AWS config${WHITE}"
        aws_profile_setup "none"
    else
        choose_action
    fi
}

choose_action() {
    local actions=("aws_profile_setup" "aws_sso_login" "aws_sso_logout")
    local action=$(printf "%s\n" "${actions[@]}" | fzf --prompt="👆 請選擇要操作的功能：")
    case $action in
    "aws_profile_setup")
        aws_profile_setup
        ;;
    "aws_sso_login")
        aws_sso_profile_login
        ;;
    "aws_sso_logout")
        aws_sso_logout
        ;;
    esac
}

main() {
    aws_config_check
    # aws_iam_user_setup
}

main