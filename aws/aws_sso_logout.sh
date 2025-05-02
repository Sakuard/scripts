#!/bin/bash

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