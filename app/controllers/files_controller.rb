class FilesController < ApplicationController
  # make sure user is logged in
  before_filter :authenticate_user!
  before_filter :set_identity, except: :download
  before_filter :set_file, only: [:destroy, :download_url]
  before_filter :set_client, only: [:browse, :download_url]

  # Disable CSRF protection on create and destroy method, since we call them
  # using javascript. If we didn't do this, we'd get problems since the CSRF
  # params from rails isn't passed along.
  # http://api.rubyonrails.org/classes/ActionController/RequestForgeryProtection/ClassMethods.html
  skip_before_action :verify_authenticity_token, only: [:create, :destroy]

  require 'dropbox_sdk'

  def new
  end

  def browse
    path = params[:path] || '/'

    # load files
    @file = @client.metadata(path)
    # remove eveything after the last '/' in the current dropbox path
    @parent_path = @file["path"].slice(0..(@file["path"].rindex('/')))
  end

  def create
    @file = BruseFile.new(file_params)
    @file.identity = @identity

    unless @file.save
      @file = nil
    end
  end

  def destroy
    if @file.identity == @identity && @file.destroy
      @message = "File deleted."
      @file = nil
    else
      @message = "Could not delete file!"
    end
  end

  # Public: generates a secure download url only accessable for
  # the owner.
  #
  # identity_id - gets owner of file
  # file_id - specified file
  #
  # Examples
  #   {identity_id: 1, file_id: 1} --> download_url
  #   # => @filepath # a secure unique url
  #
  def download_url
    if @file.identity.user == current_user
      # downloads the file from dropbox
      download = @client.get_file(@file.foreign_ref)

      # creates desired directory
      dir = "#{Rails.root}/download/#{@file.generate_download_hash}"
      Dir.mkdir dir
      dir = "#{dir}/#{@file.name}"

      # creates an empty file with in the correct location
      newfile = File.new(dir, "w")
      if newfile
        # write the downloaded information from dropbox
        newfile.syswrite(download)
        @filepath = "get/#{@file.download_hash}/#{@file.name}"
      end
    end
  end

  # Todo: delete file after download
  #
  # Public: Sends requested file to user if the user has
  # the rights to download
  #
  # download_hash - unique hash for a file
  # name - name of the requested file
  # format - format of the file thats being downloaded
  #
  # Examples
  #   Get /get/lkajdflakjsdflhb/file.m
  #     # => downloads file.m
  #
  def download
    file = BruseFile.find_by(:download_hash => params[:download_hash])
    if file.identity.user == current_user
      filepath = "#{Rails.root}/download/#{file.download_hash}/#{params[:name]}.#{params[:format]}"
      # send the file to the user
      send_file filepath, :type => file.filetype
    end
  end

  private
    def set_identity
      @identity = Identity.find(params[:identity_id])
    end
    def set_file
      @file = BruseFile.find(params[:id])
    end
    def set_client
      @client = DropboxClient.new(@identity.token)
    end
    def file_params
      params.require(:file).permit(:name, :foreign_ref, :filetype, :meta)
    end
end
