#!/bin/bash

source ../common.sh

choose_video() {
    # 請輸入來源影片路徑
    read -r -p "$(echo -e "${BLUE}請輸入來源影片路徑：${WHITE}")" source_video_path
    # 請輸入 Gif 檔案名稱
    read -r -p "$(echo -e "${GREEN}請輸入 Gif 檔案名稱：${WHITE}")" gif_file_name

    process_confirm
}

process_confirm() {
    # 先確認 input 的影片路徑是否存在
    if [ ! -f "${source_video_path}" ]; then
        echo -e "\n🚨 ${RED}來源影片路徑不存在，請重新輸入${WHITE}"
        choose_video
    fi

    gif_save_path="${source_video_path%/*}/${gif_file_name}.gif"
    echo -e "\n${BLUE}======= 選擇 ${YELLOW}${source_video_path} ${BLUE}預計轉換為 ${GREEN}${gif_file_name}.gif ${WHITE} ${BLUE}=======${WHITE}\n"
    read -r -p "$(echo -e "是否要執行轉換？ (請輸入 apply)：")" continue
    case $continue in
    "apply")
        ffmpeg -i ${source_video_path} -vf "fps=10" ${gif_save_path}
        ;;
    esac
}

# process_confirm
choose_video