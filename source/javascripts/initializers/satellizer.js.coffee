angular.module("app").config ($authProvider, config) ->
  $authProvider.baseUrl = config.APIUrl

  $authProvider.google
    clientId: "791709844452-c5gulv0vv8j48ucpk2qng8asp0ouuk9r.apps.googleusercontent.com"
    url: "/users/auth/google"
