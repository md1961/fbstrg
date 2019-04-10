class TeamStanding

  def initialize(team_group)
    @team_group = team_group

    @team_records = make_standing
    add_ranks_to(@team_records)
    @team_records.sort!
  end

  def teams
    @team_records.map(&:team)
  end

  def each(&block)
    @team_records.each(&block)
  end

  private

    def make_standing
      @team_group.teams.map { |team|
        @team_group.team_record_for(team)
      }
    end

    def add_ranks_to(team_records)
      rank_add = 0
      team_records.sort_by(&:pct).group_by(&:pct).each do |_, records|
        records.each do |record|
          record.rank += rank_add
        end
        rank_add += records.size
      end
    end
end
