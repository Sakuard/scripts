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

aws_configure_add_profile() {
    # 這是用於新增 sso-session profile 的功能
    # 先對 ~/.aws/config grep 確認有哪些 sso-session
    # 用 printf 列出所有 sso-session，讓 user 選擇要操作的 sso-session
    sso_sessions=($(awk '/^\[sso-session / { gsub(/\[|\]/,""); print $2 }' ~/.aws/config))
    sso_session=$(printf "%s\n" "${sso_sessions[@]}" | fzf --prompt="👆 請選擇要新增的 sso-session：")
    if [ -z "$sso_session" ]; then
        echo -e "${RED}未選擇 sso-session，退出腳本 ....${WHITE}"
        exit 1
    fi
    # 後續再選擇要新增的 profile name
    read -r -e -p "🔥 請輸入要新增的 profile 名稱：" profile
    if [ -z "$profile" ]; then
        echo "profile 名稱不可為空！"
        exit 1
    fi
    read -r -e -p "🔥 請輸入要新增的 Role 名稱：" role
    if [ -z "$role" ]; then
        echo "Role 名稱不可為空！"
        exit 1
    fi


    # 用腳本的方式，對 ~/.aws/config 新增 profil，記得 sso_session 以及 sso_role_name 需要對應設定
    sso_account_id=$(awk -v ss="$sso_session" '
            $0 ~ /^\[profile / {in_profile=1; found=0}
            $0 ~ /^\[/ && $0 !~ /^\[profile / {in_profile=0}
            in_profile && $0 ~ "^sso_session[ ]*=[ ]*"ss {found=1}
            in_profile && found && $0 ~ /^sso_account_id[ ]*=/ {
                gsub(/[ ]*sso_account_id[ ]*=[ ]*/,"")
                print $0
                exit
            }
        ' ~/.aws/config)
    echo "[profile ${profile}]
sso_session = ${sso_session}
sso_account_id = ${sso_account_id}
sso_role_name = ${role}" >> ~/.aws/config
}

aws_configure() {
    aws configure sso
}

aws_get_profiles() {
    aws configure list-profiles
}
aws_get_sessions() {
    awk '/^\[sso-session / { gsub(/\[|\]/,""); print $2 }' ~/.aws/config
}

aws_sso_login() {
    local profiles=($(awk '
/^\[profile / {profile=$2; gsub(/\]/,"",profile)}
/sso_session[ ]*=/ {print profile}
' ~/.aws/config))
    profile=$(printf "%s\n" "${profiles[@]}" | fzf --prompt="👆 請選擇要登入的 profile：")
    if [ -z "$profile" ]; then
        echo -e "${RED}未選擇 profile，退出腳本 ....${WHITE}"
        exit 1
    fi
    aws sso login --profile ${profile}
    aws_terminal_profile_export ${profile}
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
    read -r -e -p "是否要切換到 ${profile} ？ (請輸入 apply)：" continue
    case $continue in
    "apply")
        # aws sso login --profile ${profile}
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


aws_switch_profile() {
    aws_config_check
    aws_choose_profile
}

aws_sso_session_login() {
    aws_config_check
    aws_choose_session
}
