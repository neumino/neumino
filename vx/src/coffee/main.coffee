# When the document is ready, we initialize everything
$(document).ready ->
    window.router = new Router
    Backbone.history.start()
