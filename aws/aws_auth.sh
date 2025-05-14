#!/bin/bash
source ../common.sh
source ./aws_utils.sh

commands=("aws" "fzf")
packages=("awscli" "fzf")

for i in "${!commands[@]}"; do
    cmd="${commands[$i]}"
    pkg="${packages[$i]}"
    package_check "${cmd}" "${pkg}"
done

aws_configure() {
    aws configure sso
}

aws_get_profiles() {
    aws configure list-profiles
}
aws_get_sessions() {
    awk '/^\[sso-session / { gsub(/\[|\]/,""); print $2 }' ~/.aws/config
}

aws_sso_logout() {
    # aws sso logout
    # 確認 aws config list 的 profile 是否為 <not set>
    aws configure list
    if aws configure list | grep "profile" | grep "<not set>"; then
        echo -e "👍 ${GREEN}登出成功${WHITE}"
    else
        echo -e "🚨 ${RED}登出失敗${WHITE}"
    fi
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
        aws sso login --profile ${profile}
        aws_terminal_profile_export ${profile}
        ;;
    esac
}

aws_choose_session() {
    sessions=($(aws_get_sessions))

    session=$(printf "%s\n" "${sessions[@]}" | fzf --prompt="👆 請選擇 AWS Session：")
    if [ -z "$session" ]; then
        echo -e "${RED}未選擇 AWS Session，退出腳本 ....${WHITE}"
        exit 1
    fi

    aws_confirm_session
}

aws_confirm_session() {
    echo -e "\n${BLUE}======= 選擇為 ${YELLOW}${session}${WHITE} ${BLUE}=======${WHITE}\n"
    echo -e "手動執行指令如下：\n${GREEN}aws sso login --profile ${session}\n${WHITE}"
    read -r -e -p "是否要執行 SSO 登入？ (請輸入 apply)：" continue
    case $continue in
    "apply")
        aws sso login --sso-session ${session}
        aws_terminal_profile_export ${session}
        ;;
    esac
}


aws_sso_profile_login() {
    aws_config_check
    aws_choose_profile
}

aws_sso_session_login() {
    aws_config_check
    aws_choose_session
}
