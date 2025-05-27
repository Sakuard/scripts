#!/bin/bash

aws_init_check() {
    # 優先檢查 ~/.aws/config 是否存在
    if [ ! -f ~/.aws/config ]; then
        echo "~/.aws/config 不存在，請先設定 AWS 設定"
        return 0
    else
        return 1
    fi
}

aws_config_init() {
    aws configure sso
    if [ ! -f ~/.aws/config ]; then
        exit 0
    fi
    read -r -e -p "請輸入要設定的 profile 名稱：" profile
    # 用 grep 到 ~/.aws/config 內，搜尋 [profile.*] 並把該行資訊用 [profile $profile] 取代
    current_profile=$(awk '/^\[profile /{gsub(/\[profile |\]/,""); print $0}' ~/.aws/config | tail -1)
    if [[ "$current_profile" == "$profile" || -z "$profile" ]]; then
        exit 0
    else
        sed -i '' "s/\[profile $current_profile\]/[profile $profile]/" ~/.aws/config
    fi


}