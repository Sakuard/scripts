#!/bin/bash

source ./utils.sh

gce_list() {
    gcloud compute instances list
}

gce_cp() {
    # 使用更通用的方式取得 VM 名稱和區域
    local vm_info
    vm_info=$(gcloud compute instances list --format="table[no-heading](name,zone)")
    
    # 建立陣列來存儲 VM 名稱和區域
    local vm_display_list=()
    local vm_names=()
    local vm_zones=()
    
    while read -r line; do
        if [ -n "$line" ]; then
            local name zone
            read -r name zone <<< "$line"
            vm_names+=("$name")
            vm_zones+=("$zone")
            vm_display_list+=("$name ($zone)")
        fi
    done <<< "$vm_info"
    
    # 讓使用者選擇 VM
    local selected_option
    selected_option=$(printf "%s\n" "${vm_display_list[@]}" | fzf --prompt="👆 請選擇要操作的 VM：")
    
    # 找出選擇的 VM 索引
    local index=-1
    for i in "${!vm_display_list[@]}"; do
        if [ "${vm_display_list[$i]}" = "$selected_option" ]; then
            index=$i
            break
        fi
    done
    
    if [ $index -ge 0 ]; then
        gce_vm="${vm_names[$index]}"
        gce_vm_zone="${vm_zones[$index]}"
        
        echo -e "選擇的 VM 為：${gce_vm} (區域: ${gce_vm_zone})"
        
        # 詢問使用者想操作的 file 路徑
        read -r -e -p "🔥 請輸入要操作的 file 路徑：" gce_file_path
        
        # 優先確認該檔案是否存在
        echo -e "🔥 ${BLUE}正在確認檔案:${gce_file_path} 是否存在於: ${gce_vm} 🔥${WHITE}"

        if gcloud compute ssh ${gce_vm} --zone=${gce_vm_zone} --command="ls -l ${gce_file_path}" >/dev/null 2>/dev/null; then
            echo -e "${GREEN}✅ 檔案存在 ✅${WHITE}"
            # 詢問使用者要 cp 的目的地
            local cp_options=("本地機器 (local)" "同一台 VM 上的其他路徑")
            local cp_dest_type=$(printf "%s\n" "${cp_options[@]}" | fzf --prompt="👆 請選擇複製目的地：")
            
            case "$cp_dest_type" in
                "本地機器 (local)")
                    # 詢問本地存放路徑
                    read -r -e -p "🔥 請輸入本地存放路徑：" local_path
                    echo -e "${BLUE}🔄 正在從 ${gce_vm} 複製檔案到本地...${WHITE}"
                    
                    # 使用 gcloud compute scp 來複製檔案到本地
                    if gcloud compute scp --zone=${gce_vm_zone} ${gce_vm}:${gce_file_path} ${local_path}; then
                        echo -e "${GREEN}✅ 檔案成功複製到本地: ${local_path} ✅${WHITE}"
                        continue_or_exit
                    else
                        echo -e "${RED}❌ 檔案複製失敗 ❌${WHITE}"
                        continue_or_exit
                    fi
                    ;;
                    
                "同一台 VM 上的其他路徑")
                    # 詢問目標路徑
                    read -r -e -p "🔥 請輸入 VM 上的目標路徑：" vm_dest_path
                    echo -e "${BLUE}🔄 正在 ${gce_vm} 上複製檔案...${WHITE}"
                    
                    # 在 VM 上執行 cp 命令
                    if gcloud compute ssh ${gce_vm} --zone=${gce_vm_zone} --command="cp ${gce_file_path} ${vm_dest_path}"; then
                        echo -e "${GREEN}✅ 檔案成功複製到: ${vm_dest_path} ✅${WHITE}"
                        continue_or_exit
                    else
                        echo -e "${RED}❌ 檔案複製失敗 ❌${WHITE}"
                        continue_or_exit
                    fi
                    ;;
                    
                *)
                    echo -e "${RED}未選擇目的地，操作取消${WHITE}"
                    ;;
            esac
        else
            echo -e "${RED}❌ 檔案不存在 ❌${WHITE}"
            continue_or_exit
        fi
    else
        echo "未選擇任何 VM，操作取消"
    fi
}

gce_op() {
    gce_actions=("gce_cp")
    gce_action=$(printf "%s\n" "${gce_actions[@]}" | fzf --prompt="👆 請選擇要操作的功能：")
    case $gce_action in
    "gce_cp")
        gce_cp
        ;;
    esac
}