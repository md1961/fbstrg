class LeaguesController < ApplicationController

  def index
    redirect_to League.first
  end

  def show
    @league = League.find(params[:id])
  end
end
