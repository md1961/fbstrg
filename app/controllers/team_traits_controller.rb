class TeamTraitsController < ApplicationController

  def decrement
    team_trait = TeamTrait.find(params[:id])
    team_trait.decrement!(params[:name])
    redirect_to teams_path(team_trait_id: team_trait)
  end

  def increment
    team_trait = TeamTrait.find(params[:id])
    TeamTrait.find(params[:id]).increment!(params[:name])
    redirect_to teams_path(team_trait_id: team_trait)
  end
end
