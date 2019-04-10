class TeamStanding

  def initialize(team_group)
    @team_group = team_group

    @team_records = make_standing
    add_ranks_to(@team_records)
    break_ties_in(@team_records)
    @team_records.sort!
  end

  def teams
    @team_records.map(&:team)
  end

  def each(&block)
    @team_records.each(&block)
  end

  def rank_of(team)
    @team_records.detect { |team_record|
      team_record.team == team
    }&.rank
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

    def break_ties_in(team_records)
      team_records.sort_by(&:rank).group_by(&:rank).each do |_, records|
        next if records.size < 2
        head_to_head_group = HeadToHeadGroup.new(records.map(&:team))
        return if @team_group.is_a?(HeadToHeadGroup) && head_to_head_group.all_equal_by?(&:pct)
        head_to_head_standing = TeamStanding.new(head_to_head_group)
        records.each do |record|
          rank_in_head_to_head = head_to_head_standing.rank_of(record.team)
          rank_add = rank_in_head_to_head - 1
          if rank_add > 0
            record.rank += rank_add
            record.remarks << 'head-to-head'
          end
        end
      end
    end
end
