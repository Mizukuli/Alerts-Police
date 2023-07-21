-- Créé par Mizukuli.
fx_version 'cerulean'
game 'gta5'

author 'Mizukuli'
description 'Système d\'alerte de la police'
version '1.0.2'

lua54 'yes'

files {
    'sounds/dispatch.ogg',
    'sounds/panicbutton.ogg',
    'sounds/bipbip.ogg',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
}
-- Créé par Mizukuli.
