# Terminal 環境設置
aws_terminal_profile_export() {
    local profile=$1
    local current_dir=$(pwd)

    local profile_regex='^export AWS_PROFILE='
    local target_profile="export AWS_PROFILE=${profile}"

    cd ~/
    local bash_profile=$(cat .zshrc | grep "AWS_PROFILE=")
    if [ -z "$bash_profile" ]; then
        echo $target_profile >> .zshrc
    else
        sed -i '' "s|${profile_regex}.*|${target_profile}|" ~/.zshrc
    fi

    local current_profile=$(cat .zshrc | grep "AWS_PROFILE=")
    if [ "$current_profile" == "$target_profile" ]; then
        echo -e "👍 ${GREEN}登入成功 使用 profile 為 ${BLUE}${profile}${WHITE}"
    else
        echo -e "❌ ${RED}登入失敗${WHITE}"
    fi
    cd ${current_dir}
}
