angular.module("app").config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise "/"

  $stateProvider
    .state "login",
      url: "/"
      templateUrl: "templates/login-template.html"
      controller: ($scope, $rootScope, $auth, $state) ->
        $scope.authenticate = ->
          $auth.authenticate('google').then (response) ->
            sessionStorage.setItem('id', response.data.id)
            $state.go "projections"

    .state "projections",
      url: "/projections"
      templateUrl: "templates/projections-template.html"
      resolve:
        now: ->
          new Date()
        endOfMonth: (now) ->
          new Date(now.getFullYear(), now.getMonth() + 1, 0)
        user: (Restangular) ->
          Restangular.one("users", sessionStorage.getItem("id"))
        projections: (user, Restangular) ->
          user.all("projections").getList()
        currentProjections: (projections, now) ->

      controller: ($scope, $state, projections, currentProjections, now, endOfMonth) ->
        $scope.projections = projections
        $scope.now = now
        $scope.days = endOfMonth.getDate()
        $scope.divider = ($scope.days - now.getDate() + 1)

        $scope.logout = ->
          sessionStorage.removeItem("id")
          $state.go "login"

        $scope.$watch "projections", (projections) ->
          return unless projections

          if projections.length == 0
            $scope.total = null
          else
            $scope.total = projections.map (projection) ->
              projection.variation
            .reduce (x, y) -> x + y

            currentProjections = (projection for projection in projections when \
              (new Date(projection.created_at).getDate() == now.getDate() && !projection.recurring))

            if currentProjections.length == 0
              $scope.currentTotal = 0
            else
              $scope.currentTotal = currentProjections.map (projection) ->
                projection.variation * -1
              .reduce (x, y) -> x + y
        , true

    .state "projections.new",
      url: "/new/:type"
      onEnter: ($mdDialog, $state, $stateParams, Restangular, user, projections) ->
        $mdDialog.show
          clickOutsideToClose: true
          templateUrl: "templates/projections-new-dialog-template.html"
          controller: ($scope) ->
            $scope.projection = {}
            $scope.type = $stateParams.type
            $scope.create = ->
              if $scope.type == 'spending'
                $scope.projection.variation *= -1

              $mdDialog.hide()
              user.all("projections").post($scope.projection).then (projection) ->
                projections.unshift projection

        .finally ->
          $state.go "projections"

    .state "projections.edit",
      url: "/:id/edit"
      resolve:
        projection: (user, projections, Restangular, $stateParams) ->
          (projection for projection in projections when projection.id is Number($stateParams.id))[0]

      onEnter: ($mdDialog, $state, Restangular, user, projection, projections) ->
        $mdDialog.show
          clickOutsideToClose: true
          templateUrl: "templates/projections-edit-dialog-template.html"
          controller: ($scope) ->
            $scope.projection = Restangular.copy(projection)
            if $scope.projection.variation < 0
              $scope.type = 'spending'
              $scope.projection.variation *= -1
            else
              $scope.type = 'income'

            $scope.destroy = ->
              $scope.projection.remove().then ->
                index = projections.indexOf projection
                projections.splice index, 1
                $mdDialog.hide()

            $scope.update = ->
              $mdDialog.hide()

              if $scope.type == 'spending'
                $scope.projection.variation *= -1

              $scope.projection.put().then ->
                projection.label = $scope.projection.label
                projection.variation = $scope.projection.variation
                projection.recurring = $scope.projection.recurring

        .finally ->
          $state.go "projections"

.run ($rootScope, $state, $auth) ->
  $rootScope.$on "$stateChangeError", console.log.bind(console)
  $rootScope.$on '$stateChangeStart', (event, toState, toParams, fromState, fromParams) ->
    if !sessionStorage.getItem("id") and toState.name != "login"
      event.preventDefault();
      $state.transitionTo 'login'