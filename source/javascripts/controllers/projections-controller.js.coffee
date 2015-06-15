angular.module("app").controller "ProjectionsController",
  [
    "$scope"
    "$state"
    "all"
    ($scope, $state, @all) ->
      @now = new Date()
      @endOfMonth = new Date(@now.getFullYear(), @now.getMonth() + 1, 0)
      @days = @endOfMonth.getDate()
      @divider = @days - @now.getDate() + 1

      @logout = ->
        sessionStorage.removeItem("id")
        $state.go "login"

      $scope.$watch =>
        @all
      , (all) =>
        return unless all

        if all.length == 0
            @total = null
        else
          @total = all.map (projection) ->
            projection.variation
          .reduce (x, y) -> x + y
          @moneyPerDay = @total / @divider

          currentProjections = (projection for projection in all when \
            (new Date(projection.created_at).getDate() == @now.getDate() && !projection.recurring))

          if currentProjections.length == 0
            @currentTotal = 0
          else
            @currentTotal = currentProjections.map (projection) ->
              projection.variation * -1
            .reduce (x, y) -> x + y
      , true
      return this
]
