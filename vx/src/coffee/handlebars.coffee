# Helper to create a comma separated list of links
Handlebars.registerHelper 'generate_comma_links_list', (list) ->
    result = ''
    for element, i in list
        if i isnt 0
            result += ', '
        result += '<a href="'+element.url+'">'+element.name+'</a>'
    return new Handlebars.SafeString(result)

# Print safe string (html tags)
Handlebars.registerHelper 'print_safe', (str) ->
    if str?
        return new Handlebars.SafeString(str)
    else
        return ""

