local Translations = {
    error = {
        invalid_items = 'Você não possui os itens corretos!',
    },
    progress = {
        pick_grapes = 'Colhendo Uvas...',
        process_wine = 'Processando Vinho',
        process_juice = 'Processando Suco de Uva'
    },
    task = {
        start_task = '[E] Para Iniciar',
        vineyard_processing = '[E] Processamento de Vinhedo',
        cancel_task = 'Você cancelou a tarefa'
    },
    menu = {
        title = 'Processamento de Vinhedo',
        process_wine_title = 'Processar Vinho',
        process_juice_title = 'Processar Suco de Uva',
        wine_items_needed = 'Item Necessário: Suco de Uva\nQuantidade Necessária: %{amount}',
        juice_items_needed = 'Item Necessário: Uva\nQuantidade Necessária: %{amount}'
    }
}

if GetConvar('qb_locale', 'en') == 'pt' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end