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
        user: (Restangular) ->
          Restangular.one("users", sessionStorage.getItem("id"))
        all: (user, Restangular) ->
          user.all("projections").getList()

      controller: "ProjectionsController"
      controllerAs: 'projections'

    .state "projections.new",
      url: "/new/:type"
      onEnter: ($mdDialog, $state, $stateParams, Restangular, user, all) ->
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
                all.unshift projection

        .finally ->
          $state.go "projections"

    .state "projections.edit",
      url: "/:id/edit"
      resolve:
        projection: (user, all, Restangular, $stateParams) ->
          (projection for projection in all when projection.id is Number($stateParams.id))[0]

      onEnter: ($mdDialog, $state, Restangular, user, projection, all) ->
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
                index = all.indexOf projection
                all.splice index, 1
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