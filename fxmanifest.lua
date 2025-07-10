fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'juwe'
description 'veh control made with ox radial menu'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

dependencies {
    'es_extended',
    'ox_lib'
}