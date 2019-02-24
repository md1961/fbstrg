class TeamsController < ApplicationController

  def index
    league = League.find_by(id: params[:league_id])
    teams = league&.teams || Team.all
    @teams = teams.where.not(abbr: %w[H V])
  end

  private

    def trait_names
      @__trait_names ||= TeamTrait.first.attributes.keys.reject { |name|
        %w[id team_id created_at updated_at].include?(name)
      }
    end
    helper_method :trait_names
end
