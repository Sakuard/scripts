#!/bin/bash

source ./utils.sh

kube_cp() {
    # 獲取列表
    local kube_pods_list=$(kubectl get pods --all-namespaces --no-headers | awk '{print $1" "$2}')

    # 讓用戶選擇
    local selected_option
    selected_option=$(printf "%s\n" "${kube_pods_list}" | fzf --prompt="👆 請選擇要操作的 Pod：")

    # 直接從選擇中解析
    local kube_namespace=$(echo "$selected_option" | awk '{print $1}')
    local kube_pod=$(echo "$selected_option" | awk '{print $2}')
    
    echo -e "🔥 ${BLUE}選擇的 Pod 為: ${kube_pod} (namespace: ${kube_namespace}) 🔥${WHITE}"

    local cp_options=("local_2_pod" "pod_2_local")
    local cp_option=$(printf "%s\n" "${cp_options[@]}" | fzf --prompt="👆 請選擇要操作的 Pod：")
    case "$cp_option" in
        "local_2_pod")
            read -r -e -p "🔥 請輸入本地存放路徑： 🔥" local_path
            read -r -e -p "🔥 請輸入存放於 Pod 的路徑： 🔥" pod_path
            echo -e "手動執行指令如下：\n${GREEN}kubectl cp ${local_path} ${kube_namespace}/${kube_pod}:${pod_path}\n${WHITE}"
            read -r -e -p "是否要執行指令？ (請輸入 apply)：" continue
            case $continue in
            "apply")
                echo -e "${BLUE}🔄 正在從 ${local_path} 複製到 ${kube_namespace}/${kube_pod}:${pod_path}...${WHITE}"
                kubectl cp ${local_path} ${kube_namespace}/${kube_pod}:${pod_path}
                ;;
            esac
            ;;
        "pod_2_local")
            read -r -e -p "🔥 請輸入存放於 Pod 的路徑：" pod_path
            read -r -e -p "🔥 請輸入本地存放路徑：" local_path
            echo -e "手動執行指令如下：\n${GREEN}kubectl cp ${kube_namespace}/${kube_pod}:${pod_path} ${local_path}\n${WHITE}"
    esac

}

kube_op() {
    kube_actions=("kube_cp")
    kube_action=$(printf "%s\n" "${kube_actions[@]}" | fzf --prompt="👆 請選擇要操作的功能：")
    case $kube_action in
    "kube_cp")
        kube_cp
        ;;
    esac
}
