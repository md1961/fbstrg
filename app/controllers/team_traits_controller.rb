class TeamTraitsController < ApplicationController

  def decrement
    team_trait = TeamTrait.find(params[:id])
    team_trait.decrement!(params[:name])
    redirect_to teams_path, flash: {team_trait_id: team_trait.id}
  end

  def increment
    team_trait = TeamTrait.find(params[:id])
    team_trait.increment!(params[:name])
    redirect_to teams_path, flash: {team_trait_id: team_trait.id}
  end
end
