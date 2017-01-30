class OffensivePlaySet < ActiveRecord::Base
  include PlaySetTool

  has_many :offensive_play_set_choices

  def choose(game)
    # TODO: Move to somewhere else.
    condition = \
      if game.ball_on >= 100 - 10
        'number <= 12'
      elsif game.ball_on >= 100 - 20
        'number <= 16'
      else
        ''
      end
    choices = offensive_play_set_choices.joins(:offensive_play).where(condition)
    pick_from(choices).offensive_play
  end
end
