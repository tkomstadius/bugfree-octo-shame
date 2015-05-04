@bruseApp.directive 'bDropzone', () ->
  # restriction to only match the attribute name
  restrict: 'A'
  # create an isolate scope to map the outer scope to our directives inner scope
  scope: {
    # use = when the attribute name is the same as the value in directive
    # used as: file="", else use var: '=file'
    theFiles: '='
    images: '='
    drop: '='
    saved: '='
    info: '='
  }
  # use link when we want to modify the DOM
  # scope - angular scope object
  # element - element that this directive matches
  # attrs - hash object with key/value paris
  link: (scope, element, attrs) ->

    # prevent default browser behavior (loading file) 
    # copy restricts the type of drag the user can perform
    processDragOverOrEnter = (event) ->
      if event?
        event.preventDefault()
      (event.originalEvent or event).dataTransfer.effectAllowed = 'move'
      false

    # bind to events dragover and dragenter
    element.bind 'dragover', processDragOverOrEnter
    element.bind 'dragenter', processDragOverOrEnter 

    # bind to drop event on the element, trigger FileReader API
    # on drop events we stop browser and read the dropped file via the FileReader
    # the resulting dropped file is bound to the image property of the scope of this directive
    element.bind 'drop', (event) ->
      if event?
        event.preventDefault()
      files = event.originalEvent.dataTransfer.files
      
      #
      addFile = (file) ->
        obj = {}
        obj.name = file.name
        obj.type = file.type
        
        reader = new FileReader()
        reader.onload = (evt) ->
          # TODO: add some security checks?
          #if event.originalEvent.dataTransfer.files[0].type in validMimeTypes
          # update bindings
          scope.$apply ->
            obj.data = reader.result.split(",")[1]
            scope.drop = true
            scope.info = ''
            scope.theFiles.push obj
            if file.type in ['image/jpeg', 'image/png', 'image/tiff', 'image/gif']
              scope.images.push evt.target.result
            return
        if file.type != ''
          reader.readAsDataURL file
        else
          console.log file.name + " has no type"

      i = 0
      temp = []
      scope.images = []
      scope.saved = false
      while i < files.length
        addFile(files[i])
        i++

      return false
