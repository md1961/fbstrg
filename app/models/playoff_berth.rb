class PlayoffBerth < ApplicationRecord
  belongs_to :league, class_name: 'TeamGroup', foreign_key: 'team_group_id'
  belongs_to :team

  def self.num_berths_in_conference
    3
  end

  def self.build_initial_berths(league)
    unless league.is_a?(League)
      raise "Arguemnt must be a League (#{league.class} given)"
    end

    unless league.conferences.size == 2
      raise "League (id=#{league.id}) must have 2 conferences"
    end

    berths = []
    league.conferences.each do |conference|
      conference.standing.each.with_index(1) do |team_record, rank|
        berths << new(league: league, team: team_record.team, rank: rank)
        break if rank >= num_berths_in_conference
      end
    end

    berths
  end

  def to_s
    "#{team} : #{team.conference} ##{rank}"
  end
end
