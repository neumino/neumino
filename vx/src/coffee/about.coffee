# A simple class to show a "about me" page
class AboutView extends Backbone.View
    className: 'section about'
    template: Handlebars.templates['about']

    # Render the page
    render: =>
        @.$el.html @template()
        return @
