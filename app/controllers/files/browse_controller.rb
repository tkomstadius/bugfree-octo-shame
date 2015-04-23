class Files::BrowseController < Files::FilesController
  skip_before_filter :set_file
  skip_before_filter :set_identity, only: [:upload, :upload_from_base64]
  # getting 'can't verify CSRF token authenticity'
  # this could be a serius problem in security?
  skip_before_filter :verify_authenticity_token, only: :upload_from_base64
  require 'base64'

  def browse
    path = params[:path] || '/'

    # setup client
    @client = DropboxClient.new(@identity.token)
    @client = Google::APIClient.new(
      :application_name => 'Bruse',
      :application_version => '1.0.0'
      )

    # load files
    @file = @identity.browse(path)
  end


  def upload
    uploader = LocalFileUploader.new

    uploader.store!(params[:bruse_file][:file])

    file = BruseFile.new(name: params[:bruse_file][:file].original_filename,
                         foreign_ref: uploader.file.identifier,
                         filetype: uploader.content_type,
                         identity: current_user.local_identity)

    if file.save #file.identity.bruse_files << file
        flash[:notice] = "#{file.name} was saved!"
        redirect_to bruse_files_path
    else
      flash[:notice] = "you must log in to your bruse acount!"
        redirect_to bruse_files_path
    end
  end


  def upload_from_base64
  
    if params[:location] == 'local'
      #check if user has local identity
      if current_user.local_identity
        # if so, create brusefile
        @file = create_drop_file(params)

        # insert our file on the users local identity
        if current_user.local_identity.bruse_files << @file
          # send response that everything is ok!
        else
          flash[:notice] = "nonono"
        end
      else
        # no file! not working!
        @file = nil
        render status :not_acceptable
      end
    elsif params[:location] == 'dropbox'
      flash[:notice] = "nonono, not yet"
    elsif params[:location] == 'drive'
      flash[:notice] = "nonono, maybe later"
    else
      flash[:notice] = "No storage option"
    end
  end

  private
    # Private: Create a file containing dropped content
    #
    # content   - the file content
    #
    # Returns a new BruseFile
    def create_drop_file(content)
      # generate file name
      fileref = SecureRandom.uuid
      local_file_name = Rails.root.join('usercontent', fileref)
      # create file
      decoded_content =  Base64.urlsafe_decode64(content[:data]).force_encoding('utf-8')
      IO.write(local_file_name, decoded_content)
      # return new BruseFile
      BruseFile.new(name: content[:name],
                    foreign_ref: fileref,
                    filetype: content[:type])
    end
end
