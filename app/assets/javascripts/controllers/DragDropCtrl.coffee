# TODO: create modal for save option?
@bruseApp.controller 'DragDropCtrl', ['$scope', '$http', ($scope, $http) ->
    $scope.droppedFiles = []
    $scope.dataObjects = {}
    $scope.imageFiles = []
    $scope.isDropped = false
    $scope.isSaved = false
    $scope.message = ''

    $scope.saveOpt = (location) ->
      if location == ''
        $scope.isDropped = false
        $scope.droppedFiles = []
      else
        $scope.isDropped = false
        $scope.dataObjects.objects = $scope.droppedFiles
        $scope.dataObjects.location = location

        # send object to server
        $http.post('/upload_drop.json', $scope.dataObjects).then((response) ->
          if response.data.file != null
            $scope.isSaved = true
            $scope.message = "Saved to " + location
          else
            $scope.isSaved = false
            $scope.message = "Something went wrong"
          )
        .catch((response) ->
          console.error "Couldn't save.."
          )
]

