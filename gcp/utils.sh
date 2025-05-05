#! /bin/bash

continue_or_exit() {
    local continue_op
    read -r -e -p "🔥 是否繼續操作？(y/n): " continue_op
    if [[ "$continue_op" =~ ^[Yy]$ ]]; then
        main
    else
        exit 0
    fi
}

