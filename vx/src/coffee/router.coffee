# The main class that is going to control everything
class Router extends Backbone.Router
    routes:
        '': 'index'
        'about': 'about'
        'blog': 'index'
        'blog/get_post/:id': 'blog_post'
        'blog/get_recent_posts/:count/:page': 'blog_recent'
        'blog/get_tag_posts/:id/:count/:page': 'blog_tag'
        'blog/get_category_posts/:id/:count/:page': 'blog_category'
        'blog/get_date_posts/:year/:month/:count/:page': 'blog_date'

    # Initialize the sidebar and define the main container
    initialize: =>
        # Let's save a reference for the main container so we don't have to search the dom tree every time
        @view_container = $('#content_container')

        # We initialize the links on the sidebar
        @blog_links= new BlogLinks
        $('.blog_links').html @blog_links.render().$el

    # Method in case of an empty route. We just load recent posts
    index: =>
        @blog_recent()

    # Method to load the "about me" page
    about: =>
        @view = new AboutView
        @show_loading @delay_about

    # Because we don't want to immediatly show the page
    delay_about: =>
        setTimeout @show_about, 500

    # Show the about me page
    show_about: =>
        @hide_loading()
        @view_container.html @view.render().$el

    # Load recent blogs
    # @params:
    #     - count: the number of posts to display
    #     - page: the page to display
    blog_recent: (count, page) =>
        data =
            method: 'get_recent_posts'
            count: if count? then count else 10
            page: if page? then page else 1
            
        if @view instanceof BlogView
            @view.set_options data
        else
            @view = new BlogView data
        @show_loading()
        @view.fetch_posts @render_view

    # Load posts with a certain tag
    # @params:
    #     - id: the id of the tag
    #     - count: the number of posts to display
    #     - page: the page to display
    blog_tag: (id, count, page) =>
        if not id?
            @blog_recent(count, page)
            return true

        data =
            method: 'get_tag_posts'
            id: id
            count: if count? then count else 10
            page: if page? then page else 1
        if @view instanceof BlogView
            @view.set_options data
        else
            @view = new BlogView data
        @show_loading()
        @view.fetch_posts @render_view

    # Load a category's posts
    # @params:
    #     - id: the id of the category
    #     - count: the number of posts to display
    #     - page: the page to display
    blog_category: (id, count, page) =>
        if not id?
            @blog_recent(count, page)
            return true

        data =
            method: 'get_category_posts'
            id: id
            count: if count? then count else 10
            page: if page? then page else 1

        if @view instanceof BlogView
            @view.set_options data
        else
            @view = new BlogView data
        @show_loading()
        @view.fetch_posts @render_view

    # Load posts from a certain date (month here)
    # @params:
    #     - year: year of the post
    #     - month: month of the post
    #     - count: the number of posts to display
    #     - page: the page to display
    blog_date: (year, month, count, page) =>
        data =
            method: 'get_date_posts'
            year: year
            month: month
            count: if count? then count else 10
            page: if page? then page else 1

        if @view instanceof BlogView
            @view.set_options data
        else
            @view = new BlogView data
        @show_loading()
        @view.fetch_posts @render_view

    # Load one post
    # @params:
    #     - id: the id of the post
    blog_post: (id) =>
        if id?
            @view = new BlogFullPostView
                id: id
            @show_loading()
            @view.fetch_post @render_full_view
        else
            console.log 'Id not found'

    # Show a loading gif
    # @params:
    #     - callback: callback to be executed once the loading is fully displayed
    show_loading: (callback) =>
        if callback?
            $('.loading_blog').slideDown 'fast', callback
        else
            $('.loading_blog').slideDown 'fast'

    # Hide the loading gif
    # @params:
    #     - callback: callback to be executed once the loading is fully hidden
    hide_loading: (callback) =>
        if callback?
            $('.loading_blog').slideUp 'fast', callback
        else
            $('.loading_blog').slideUp 'fast'
        
    # Render a view with a list of posts
    # @params:
    #     - data: data sent by the server (list of posts + metadata)
    render_view: (data) =>
        @view.handle_new_posts data
        @view_container.html @view.render().$el
        @view_container.slideDown 'fast'
        @hide_loading()
        prettyPrint()

    # Render a view with one post
    # @params:
    #     - data: data sent by the server (post + metadata)
    render_full_view: (data) =>
        @view.handle_new_post data
        @view_container.html @view.render().$el
        @view_container.slideDown 'fast'
        @hide_loading()
        prettyPrint();
