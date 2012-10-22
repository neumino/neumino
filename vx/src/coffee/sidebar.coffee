class BlogLinks extends Backbone.View
    template: Handlebars.templates['blog_links-container']
    link_template: Handlebars.templates['blog_link']

    initialize: =>
        @.$el.append @template
            title: 'Recent posts'
            class_ul: 'recent_posts_list'
            class_img: 'loading_recent_posts'

        @.$el.append @template
            title: 'Categories'
            class_ul: 'categories_list'
            class_img: 'loading_categories'

        @.$el.append @template
            title: 'Archive'
            class_ul: 'archive_list'
            class_img: 'loading_archive'

        @load_sidebar()
        
    load_sidebar: =>
        @load_data '/blog/?json=get_recent_posts&count=5', @add_recent_link, @create_error_link
        @load_data '/blog/?json=get_category_index', @add_category_link, @create_error_link
        @load_data '/blog/?json=get_date_index', @add_archive_link, @create_error_link
 
    load_data: (url, success_callback, fail_callback) =>
        $.ajax
            contentType: 'application/json'
            url: url
            dataType: 'json'
            success: success_callback
            error: fail_callback

    add_recent_link: (response)  =>
        if response.error?
            @create_error_link()
            return ''
        for post, i in response.posts
            if i > 4
                break
            title = post.title
            if title.length > 30
                title = title.slice(0, 30)+'...'
            @.$('.recent_posts_list').append @link_template
                url: '#blog/get_post/'+post.id
                name_link: title

        @.$('.loading_recent_posts').slideUp 'fast'
        @.$('.recent_posts_list').slideDown 'fast'

    add_category_link: (response) =>
        if response.error?
            @create_error_link()
            return ''
        for category in response.categories
            @.$('.categories_list').append @link_template
                url: '#blog/get_category_posts/'+category.id+'/'+default_count+'/1'
                name_link: category.title

        @.$('.loading_categories').slideUp 'fast'
        @.$('.categories_list').slideDown 'fast'

    add_archive_link: (response) =>
        if response.error?
            @create_error_link()
            return ''
        years = []
        for year, list_month of response.tree
            years.unshift year
        for year in years
            for month of list_month
                @.$('.archive_list').append @link_template
                    url: '#blog/get_date_posts/'+year+'/'+month+'/'+default_count+'/1'
                    name_link: @map_months[month]+' '+year

        @.$('.loading_archive').slideUp 'fast'
        @.$('.archive_list').slideDown 'fast'


    create_error_link: =>
        # We silently fail here.
        # We should write a nice warning
        @.$('.loading_categories').slideUp 'fast'

    render: =>
        return @

    map_months:
        '01': 'January'
        '02': 'February'
        '03': 'March'
        '04': 'April'
        '05': 'May'
        '06': 'June'
        '07': 'July'
        '08': 'August'
        '09': 'September'
        '10': 'October'
        '11': 'November'
        '12': 'December'
