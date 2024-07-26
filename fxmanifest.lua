fx_version "cerulean"
game "gta5"

author "maji"
description " "
version "1.0"

client_scripts {
    "client/**.lua"
}

server_scripts {
    "server/**.lua"
}

shared_scripts {
    "config.lua",
    '@ox_lib/init.lua'
}

files {
    "html/*",
    "html/assets/*",
    "html/img/*",
    "html/index.html"
}

ui_page "html/index.html"

lua54 'yes'
