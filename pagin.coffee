jQuery ($) ->

    log = (text) ->

        try
            console.log text
        catch e
            ;

    init = () ->

        defaultSettings =
            url: '.'
            container: '.page-container'
            loading: false
            busy: false
            # footer: '#footer'
            pageName: 'page'
            nextPage: 2
            extraData: false,
            loging: true,

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
        # dHeight = $(document).height() - $(window).height()

        # if settings.footer
        #     dHeight = dHeight - $(settings.footer).height()

        bottomOffset = $(settings.container).offset().top
        bottomOffset += $(settings.container).height()
        bottomOffset -= $(window).height()

        if $(window).scrollTop() >= bottomOffset and not settings.busy

            if settings.hasNext
                data = settings.getAjaxData()
                $container = $ settings.container
                settings.busy = true

                if settings.loading
                    $loading = $ settings.loading
                    $container.append $loading

                $.ajax
                    url: settings.url
                    dataType: 'JSON'
                    data: data

                    success: (response) ->
                        content = response.content
                        settings.hasNext = response.hasNext

                        if settings.loging
                            log "Page #{settings.nextPage} loaded"

                        if settings.hasNext
                            settings.nextPage = response.nextPage

                        if settings.loading
                            $container.find($loading).replaceWith(content)
                        else
                            $container.append(content)

                        settings.busy = false

                    error: (err) ->
                        log err
                        $container.trigger('ajaxLoadError')
                        settings.busy = false

            else if settings.loging
                log 'Loading page - denied'