#!/bin/bash

source ./aws_auth.sh

choose_action() {
    actions=("aws_sso_setup" "aws_sso_login" "aws_sso_logout")
    action=$(printf "%s\n" "${actions[@]}" | fzf --prompt="👆 請選擇要操作的功能：")
    case $action in
    "aws_sso_setup")
        aws_configure
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
    # 先詢問使用者要操作什麼功能，並提供選擇
    choose_action
}

main