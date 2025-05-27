#!/bin/bash

source ./aws_auth.sh
source ./aws_init.sh

choose_action() {
    actions=("aws_sso_add_profile" "aws_sso_setup" "aws_switch_profile" "aws_sso_logout" "aws_add_kubecontext")
    action=$(printf "%s\n" "${actions[@]}" | fzf --prompt="👆 請選擇要操作的功能：")
    case $action in
    "aws_sso_add_profile")
        aws_configure_add_profile
        ;;
    "aws_sso_setup")
        aws_configure
        ;;
    "aws_switch_profile")
        aws_switch_profile
        ;;
    "aws_sso_logout")
        aws_sso_logout
        ;;
    "aws_add_kubecontext")
        read -r -e -p "🔥 請輸入要新增的 cluster 所屬 region" region
        read -r -e -p "🔥 請輸入要新增的 cluster name" cluster_name

        ;;
    esac
}

main() {
    # 先詢問使用者要操作什麼功能，並提供選擇
    if aws_init_check == 0; then
        aws_config_init
    else
        choose_action
    fi
}

main

#  aws eks --region ap-southeast-1 update-kubeconfig --name pd-lm-dev
# context=$(kubectl config get-contexts -o name | grep "arn:aws:eks:ap-southeast-1:.*:cluster/pd-lm-dev" )