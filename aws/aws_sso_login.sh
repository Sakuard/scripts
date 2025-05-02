#!/bin/bash
source ../common.sh

commands=("aws" "fzf")
packages=("awscli" "fzf")

for i in "${!commands[@]}"; do
    cmd="${commands[$i]}"
    pkg="${packages[$i]}"
    package_check "${cmd}" "${pkg}"
done

aws_get_profiles() {
    aws configure list-profiles
}

aws_configure() {
    aws configure sso
}

aws_config_check() {
    profiles=($(aws_get_profiles))
    if [ ${#profiles[@]} -eq 0 ]; then
        echo -e "🚨 ${RED}未找到 AWS config${WHITE}"
        read -r -e -p "🔥 是否要對 AWS CLI 進行設置？ 🔥 (Y/N)：" continue
        case $continue in
        Y | y)
            aws_configure
            ;;
        N | n)
            exit 1
            ;;
        *)
            echo -e "${RED}無效參數 ($REPLY)，請重新輸入${WHITE}"
            exit 1
            ;;
        esac
    fi
}

aws_choose_profile() {
    profiles=($(aws_get_profiles))

    profile=$(printf "%s\n" "${profiles[@]}" | fzf --prompt="👆 請選擇 AWS 帳號：")
    if [ -z "$profile" ]; then
        echo -e "${RED}未選擇 AWS 帳號，退出腳本 ....${WHITE}"
        exit 1
    fi

    aws_confirm_profile
}

aws_confirm_profile() {
    echo -e "\n${BLUE}======= 選擇為 ${YELLOW}${profile}${WHITE} ${BLUE}=======${WHITE}\n"
    echo -e "手動執行指令如下：\n${GREEN}aws sso login --profile ${profile}\n${WHITE}"
    read -r -e -p "是否要執行 SSO 登入？ (請輸入 apply)：" continue
    case $continue in
    "apply")
        aws_sso_login ${profile}
        ;;
    esac
}

aws_sso_login() {
    aws sso login --profile ${profile}
    aws configure list
    export AWS_PROFILE=${profile}
    if aws configure list | grep "profile" | grep "<not set>"; then
        echo -e "\n🚨 ${RED}登入失敗${WHITE}"
    else
        echo -e "\n👍 ${GREEN}登入成功${WHITE}"
    fi
}
