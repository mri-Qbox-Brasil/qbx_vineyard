fx_version 'cerulean'
game 'gta5'

description 'QB-Vineyard'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'config.lua'
}

server_script 'server.lua'
client_scripts {
    'client.lua'
}

dependencies {
    'ox_lib',
    'qb-core'
}

lua54 'yes'