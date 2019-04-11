class TeamStanding

  def initialize(team_group)
    @team_group = team_group

    initialize_remarks_by_team

    @team_records = make_standing
    cmp_names.each do |cmp_name|
      add_ranks_to( @team_records, cmp_name)
      break if fully_ranked?
      break_ties_in(@team_records, cmp_name)
    end
    @team_records.sort!

    write_remarks
  end

  def teams
    @team_records.map(&:team)
  end

  def each(&block)
    @team_records.each(&block)
  end

  def rank_of(team)
    team_record_of(team)&.rank
  end

  private

    def head_to_head?
      @is_head_to_head ||= @team_group.is_a?(HeadToHeadGroup)
    end

    def initialize_remarks_by_team
      @@remarks_by_team = {} unless head_to_head?
    end

    def write_remarks
      return if head_to_head?
      @team_records.each do |team_record|
        team = team_record.team
        remark = @@remarks_by_team[team.id]
        team_record.remarks << remark if remark
      end
    end

    def cmp_names
      [:pct].tap { |names|
        names.concat([:conference_pct]) if head_to_head?
      }
    end

    def fully_ranked?
      ranks = @team_records.map(&:rank)
      ranks.uniq.size == ranks.size
    end

    def add_remark_to(team, remark)
      return if @@remarks_by_team[team.id]
      @@remarks_by_team[team.id] = remark
    end

    def team_record_of(team)
      @team_records.detect { |team_record|
        team_record.team == team
      }
    end

    def make_standing
      @team_group.teams.map { |team|
        @team_group.team_record_for(team)
      }
    end

    H_REMARKS = {
      pct: 'head-to-head',
      conference_pct: 'conference'
    }

    def add_ranks_to(team_records, cmp_name)
      rank_add = 0
      team_records.sort_by(&cmp_name).group_by(&cmp_name).each do |_, records|
        records.each do |record|
          if rank_add > 0
            record.rank += rank_add
            add_remark_to(record.team, H_REMARKS[cmp_name]) if head_to_head?
          end
        end
        rank_add += records.size
      end
    end

    def break_ties_in(team_records, cmp_name)
      team_records.sort_by(&:rank).group_by(&:rank).each do |_, records|
        next if records.size < 2
        head_to_head_group = HeadToHeadGroup.new(records.map(&:team))
        return if @team_group.is_a?(HeadToHeadGroup) && head_to_head_group.all_equal_by?(&cmp_name)
        head_to_head_standing = TeamStanding.new(head_to_head_group)
        records.each do |record|
          rank_in_head_to_head = head_to_head_standing.rank_of(record.team)
          rank_add = rank_in_head_to_head - 1
          if rank_add > 0
            record.rank += rank_add
            add_remark_to(record.team, H_REMARKS[cmp_name])
          end
        end
      end
    end
end
