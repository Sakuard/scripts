#!/bin/bash
source ../common.sh

source ./gce_op.sh
source ./kube_op.sh

choose_action() {
    actions=("gce_op" "kube_op")
    action=$(printf "%s\n" "${actions[@]}" | fzf --prompt="👆 請選擇要操作的功能：")
    case $action in
    "gce_op")
        gce_op
        ;;
    "kube_op")
        kube_op
        ;;
    esac
}

main() {
    # 先詢問使用者要操作什麼功能，並提供選擇
    choose_action
}

main
