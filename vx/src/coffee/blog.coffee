# Default parameters
default_count = 10
default_page = 1

# The view to display a list of posts
class BlogView extends Backbone.View
    className: 'blog_container'
    pagination_template: Handlebars.templates['blog_pagination']

    initialize: (options) =>
        @view_list = []
        # We render the main template
        @render()
        # We then set options. Router will then call fetch later
        @set_options options

    # Set the options of the view
    # @params
    #     - options: an object containing the options (methodd, id, count, page, year, month)
    set_options: (options) =>
        @data = {}
        if options.method?
            @data.method = options.method
        if options.id?
            @data.id = options.id
        if options.count?
            @data.count = options.count
        if options.page?
            @data.page = options.page
        if options.year?
            @data.year = options.year
         if options.month?
            @data.month = options.month

    # Generate the url we will use to retrieve data from the server
    # @params:
    #     - params to retrieve the data (method, id, count, page, month, year
    generate_url: (data) ->
        url = '/blog/?json='+data.method
        if data.id? and data.id isnt ''
            url += '&id='+data.id
        if data.count? and data.count isnt ''
            url += '&count='+data.count
        if data.page? and data.page isnt ''
            url += '&page='+data.page
        if data.year? and data.year isnt '' and data.month? and data.month isnt ''
            url += '&date='+data.year+'-'+data.month
        return url

    # Generate the url we will display that will trigger the appropriate route.
    # @params:
    #     - params to retrieve the data (method, id, count, page, month, year
    generate_hash_url: (data) ->
        hash_url = '#blog'
        if data.method? and data.method isnt ''
            hash_url += '/'+data.method
        if data.id? and data.id isnt ''
            hash_url += '/'+data.id
        if data.count? and data.count isnt ''
            hash_url += '/'+data.count
        if data.page? and data.page isnt ''
            hash_url += '/'+data.page
        if data.year? and data.year isnt ''
            hash_url += '/'+data.year
        if data.month? and data.month isnt ''
            hash_url += '/'+data.month
        return hash_url

    # Fetch posts form server
    # @params:
    #     - callback: callback to be executed once 
    fetch_posts: (callback) =>
        $.ajax
            contentType: 'application/json'
            url: @generate_url @data
            dataType: 'json'
            success: callback
            error: @handle_ajax_fail

    handle_new_posts: (data) =>
        # Note: I don't need to destroy previous views since I don't bind listeners
        @view_list = []

        # If the data doesn't have any problem, we create a list of views (one for each post)
        if data?.status is 'ok'
            for post in data.posts
                new_view = new BlogPostView
                    id: post.id
                    title: post.title
                    content: post.content
                    date: post.date
                    categories: post.categories
                    tags: post.tags
                    comment_count: post.comment_count
                @view_list.push new_view
            if data.pages > @page
                @older_page = parseInt(@page)+1
                @has_older_page = true
            else
                @has_older_page = false
            if @page > 1
                @newer_page = @page-1
                @has_newer_page = true
            else
                @has_newer_page = false
        else
            # We should handle the error in a better way
            $('.loading_blog').slideUp()
            $('.error').slideDown()

    handle_ajax_fail: (data) =>
        # We should handle the error in a different way. Router set the callback for sucess.
        # Therefore, it should set it in case of failure too.
        $('.loading_blog').slideUp()
        $('.error').slideDown()

    # Render view
    render: =>
        @.$el.empty()
        for view in @view_list
            @.$el.append view.render().$el
        
        if @has_older_page is true or @has_newer_page is true
            @.$el.append @pagination_template
                has_newer_page: @has_newer_page
                has_older_page: @has_older_page
                url_older: @generate_hash_url ._extend({page: @older_page}, @data)
                url_newer: @generate_hash_url ._extend({page: @newer_page}, @data)
        return @

# A small view for a post (no comment)
class BlogPostView extends Backbone.View
    className: 'section post'
    template: Handlebars.templates['blog_post']

    # Initialize @data
    initialize: (options) =>
        @data =
            id: options.id
            title: options.title
            content: options.content
            date: options.date
            categories: @format_categories(options.categories)
            tags: @format_tags(options.tags)

    # Format data related to categories
    # @params:
    #     - categories: raw categories sent by the server
    format_categories: (categories) ->
        categories_formated = []
        for category in categories
            categories_formated.push
                url: '#blog/get_category_posts/'+category.id+'/'+default_count+'/'+default_page
                name: category.title
        return categories_formated

    # Format data related to tags
    # @params:
    #     - tags: raw tags sent by the server
    format_tags: (tags) ->
        tags_formated = []
        for tag in tags
            tags_formated.push
                url: '#blog/get_tag_posts/'+tag.id+'/'+default_count+'/'+default_page
                name: tag.title
        return tags_formated

    # Render view
    render: =>
        @.$el.html @template @data
        return @

# The complete view for 
class BlogFullPostView extends Backbone.View
    className: 'full_post'
    template: Handlebars.templates['blog_full_post']
    comment_template: Handlebars.templates['comment']

    events:
        'click .comment_button': 'submit_comment'
        'click .close_alert-link': 'close_alert'


    initialize: (options) =>
        @data =
            id: options.id
        @fetch_post()

    close_alert: (event) ->
        event.preventDefault()
        $(event.target).parent().parent().slideUp 'fast'

    generate_url: (id)  =>
        url = '/blog/?json=get_post&id='+id
        return url

    fetch_post: (callback) =>
        $.ajax
            contentType: 'application/json'
            url: @generate_url @id
            dataType: 'json'
            success: callback
            error: @handle_ajax_fail

    submit_comment: =>
        name = @.$('#comment_name').val()
        email = @.$('#comment_email').val()
        content = @.$('#comment_content').val()
        errors = []
        if name is ''
            errors.push 'We do not requier a real name, but a name is still required.'
        if email is ''
            errors.push 'Wordpress requires your email evem if it will not be displayed.'
        if content is ''
            errors.push 'We have detected an empty comment. Did you hit submit by accident?'
        if errors.length > 0
            errors_string = ''
            for error, i in errors
                if i isnt 0
                    errors_string += '<br/>'
                errors_string += error
            @.$('.alert_content').html errors_string
            @.$('.alert').slideDown 'fast'
        else
            data =
                post_id: parseInt @id
                name: name
                email: email
                content: content
            @data_cached = data
            $.ajax
                contentType: 'application/json'
                url: '/blog/?json=submit_comment'
                type: 'GET'
                dataType: 'json'
                data: data
                success: @success_new_comment
                error: @fail_new_comment
    
    success_new_comment: (response) =>
        if response?.error?
            @.$('.alert_content').html response.error
            @.$('.alert').slideDown 'fast'
            return ''

        @.$('.alert_content').html 'You comment was submitted'
        @.$('.alert').slideDown 'fast'
        @append_comment @data_cached # That's a flaw, but it's just my blog.

    append_comment: (data) =>
        if data.url is ''
            data.url = null
        @.$('.comments_content').append @comment_template data

    fail_new_comment: (response) =>
        @.$('.alert_content').html 'Sorry, the ajax request fails. Please try again.'
        @.$('.alert').slideDown 'fast'

    handle_ajax_fail: =>
        console.log 'Could not fetch post'

    handle_new_post: (data) =>
        _.extend @data, data.post
        @data.tags = @format_tags(@data.tags)
        @data.categories = @format_categories(@data.categories)

    format_categories: (categories) ->
        categories_formated = []
        for category in categories
            categories_formated.push
                url: '#blog/get_category_posts/'+category.id+'/'+default_count+'/'+default_page
                name: category.title
        return categories_formated

    format_tags: (tags) ->
        tags_formated = []
        for tag in tags
            tags_formated.push
                url: '#blog/get_tag_posts/'+tag.id+'/'+default_count+'/'+default_page
                name: tag.title
        return tags_formated


    render: =>
        if @data.title?
            @.$el.html @template @data
            if @data.comments.length is 0
                @.$('.no_comment').show()
            else
                @.$('.no_comment').hide()
                for comment, i in @data.comments
                    if i is 0
                        comment.is_first = true
                    @append_comment comment
            
        @delegateEvents()
        return @
