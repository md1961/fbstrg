class TeamsController < ApplicationController

  def index
    @teams = Team.where.not(abbr: %w[H V])
  end

  private

    def trait_names
      @__trait_names ||= TeamTrait.first.attributes.keys.reject { |name|
        %w[id team_id created_at updated_at].include?(name)
      }
    end
    helper_method :trait_names
end
