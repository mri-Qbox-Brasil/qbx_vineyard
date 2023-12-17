local Translations = {
    error = {
        invalid_items = '¡No tienes el item correcto!',
    },
    progress = {
        pick_grapes = 'Recogiendo uvas..',
        process_wine = 'Processing Wine',
        process_juice = 'Processing Grape Juice'
    },
    task = {
        start_task = '[E] Para empezar',
        vineyard_processing = '[E] Vineyard Processing',
        cancel_task = 'Has cancelado la tarea'
    },
    menu = {
        title = 'Vineyard Processing',
        process_wine_title = 'Process Wine',
        process_juice_title = 'Process Grape Juice',
        wine_items_needed = 'Required Item: Grape Juice\nAmount Needed: %{amount}',
        juice_items_needed = 'Required Item: Grape\nAmount Needed: %{amount}'
    }
}

if GetConvar('qb_locale', 'en') == 'es' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end