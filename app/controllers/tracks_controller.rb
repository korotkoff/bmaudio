class TracksController < ApplicationController
  def index
    @tracks = Track.page(params[:page]).decorate
  end
end
