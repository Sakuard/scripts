#! /bin/bash

# 顏色設定
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
WHITE="\033[0m"

package_check() {
    local cmd=$1
    local pkg=${2:-$1}  # Use second parameter as package name, or default to command name
    
    if ! command -v ${cmd} 1>/dev/null; then
        read -r -e -p "本腳本需要安裝 ${cmd}，請確認是否安裝並繼續執行？(Y/N)：" continue
        case $continue in
            Y | y)
                brew install ${pkg} ;;
            N | n)
                echo -e "${RED}未安裝 ${cmd}，退出腳本${WHITE}"
                exit 1 ;;
            *)
                echo -e "${RED}無效參數 ($REPLY)，請重新輸入${WHITE}"
                exit 1 ;;
        esac
    fi
}
tap_package_check() {
    local cmd=$1
    local tap=$2
    local pkg=$3
    
    if ! command -v ${cmd} 1>/dev/null; then
        read -r -e -p "本腳本需要安裝 ${cmd}，請確認是否安裝並繼續執行？(Y/N)：" continue
        case $continue in
            Y | y)
                brew tap ${tap}
                brew install ${pkg} ;;
            N | n)
                echo -e "${RED}未安裝 ${cmd}，退出腳本${WHITE}"
                exit 1 ;;
            *)
                echo -e "${RED}無效參數 ($REPLY)，請重新輸入${WHITE}"
                exit 1 ;;
        esac
    fi
}