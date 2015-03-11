@bruseApp.controller 'SearchCtrl', ['$scope', '$http', ($scope, $http) ->
  $scope.files = []

  $scope.$watch "search", () ->
    if($scope.search != "")
      $http.get('/search/'+$scope.search)
        .then((response) ->
          console.log response
          $scope.files = response.data.files;
          )
        .catch((response) ->
          alert "Couldn't search.."
          )
    else
      $scope.files = []
]
