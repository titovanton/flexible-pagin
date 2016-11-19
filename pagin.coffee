jQuery ($) ->
    init = () ->
        defaultSettings =
            url: '.'
            container: '.page-container'
            loadingBar: false
            busy: false
            # footer: '#footer'
            pageName: 'page'
            nextPage: 2
            extraData: false,
            loging: true,
            offset: 200,
            getQuery: () ->
                search = {}

                for i in location.search[1..].split('&')
                    search[i.split('=')[0]] = i.split('=')[1]

                search
            getAjaxData: () ->
                data = {}
                data[@.pageName] = @.nextPage
                $.extend data, @.getQuery()

                if @.extraData
                    $.extend data, @.extraData

                data

        $.extend defaultSettings, flexiblePaginSettings

    settings = init()

    $(window).scroll () ->
        bottomOffset = $(settings.container).offset().top
        bottomOffset += $(settings.container).height()
        bottomOffset -= $(window).height() + settings.offset

        if $(window).scrollTop() >= bottomOffset and not settings.busy
            if settings.loging
                console.log 'Have started loading next page'

            if settings.hasNext
                data = settings.getAjaxData()
                $container = $ settings.container
                settings.busy = true

                if settings.loadingBar
                    $loadingBar = $ settings.loadingBar
                    $container.append $loadingBar

                $.ajax
                    url: settings.url
                    dataType: 'JSON'
                    data: data
                    success: (response) ->
                        content = response.content
                        settings.hasNext = response.hasNext

                        if settings.loging
                            console.log "Page #{settings.nextPage} loaded"

                        if settings.hasNext
                            settings.nextPage = response.nextPage

                        if settings.loadingBar
                            $container.find($loadingBar).replaceWith(content)
                        else
                            $container.append(content)

                        settings.busy = false
                    error: (err) ->
                        console.error err
                        $container.trigger('ajaxLoadError')
                        settings.busy = false

            else if settings.loging
                console.log 'Loading page - denied'
