#! /bin/bash

aws_sso_setup() {
    # 先確認 ~/.aws/config 內是否已經有 sso 的設定
    if [ ! -f ~/.aws/config ]; then
        aws configure sso
    #     return
    elif grep -q "\[sso-session.*\]" ~/.aws/config; then
        cat ~/.aws/config | grep "\[sso-session.*\]"
        # local sso_profiles=
    else
        # 先記錄當下的 ~/.aws/config 用於後續比對新增了哪個 sso profile
        local current_config=$(cat ~/.aws/config)
        aws configure sso
        local new_config=$(cat ~/.aws/config)
        diff <(echo "$current_config") <(echo "$new_config")
    fi
}

aws_iam_user_setup() {
    local profile
    local keyid
    local secretkey
    local region
    read -r -e -p "請輸入要設定的 profile 名稱：" profile
    read -r -e -p "請輸入要設定的 keyid：" keyid
    read -r -e -p "請輸入要設定的 secretkey：" secretkey
    read -r -e -p "請輸入要設定的 region：" region
    echo "[${profile}]" >> ~/.aws/credentials
    echo "aws_access_key_id = ${keyid}" >> ~/.aws/credentials
    echo "aws_secret_access_key = ${secretkey}" >> ~/.aws/credentials
    echo "[profile ${profile}]" >> ~/.aws/config
    echo "region = ${region}" >> ~/.aws/config
    echo "output = json" >> ~/.aws/config
    # if [ ! -f ~/.aws/credentials ]; then
    #     read -r -e -p "請輸入要設定的 profile 名稱：" profile
    #     read -r -e -p "請輸入要設定的 keyid：" keyid
    #     read -r -e -p "請輸入要設定的 secretkey：" secretkey
    #     read -r -e -p "請輸入要設定的 region：" region
    #     echo "[${profile}]" >> ~/.aws/credentials
    #     echo "aws_access_key_id = ${keyid}" >> ~/.aws/credentials
    #     echo "aws_secret_access_key = ${secretkey}" >> ~/.aws/credentials
    #     echo "[profile ${profile}]" >> ~/.aws/config
    #     echo "region = ${region}" >> ~/.aws/config
    #     echo "output = json" >> ~/.aws/config
    # elif grep -q "\[.*\]" ~/.aws/credentials; then
    #     echo -e "🚨 ${RED}已經有 iam user 的設定${WHITE}"
    #     # cat ~/.aws/credentials | grep "\[.*\]"
    #     local iam_user=$(cat ~/.aws/credentials | grep "\[.*\]" | cut -d '[' -f 2 | cut -d ']' -f 1)
    # fi
}

aws_profile_setup() {
    local status=$1
    local prompt
    if [ "$status" == "none" ]; then
        prompt="👆 請選擇要設定的 AWS_PROFILE 類型："
    fi
    local profile_types=("sso" "iam user")
    local profile_type=$(printf "%s\n" "${profile_types[@]}" | fzf --prompt="${prompt}")
    case $profile_type in
    "sso")
        aws_sso_setup
        ;;
    "iam user")
        aws_iam_user_setup
        ;;
    esac
}
