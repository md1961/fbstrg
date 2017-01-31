class OffensivePlaySet < ActiveRecord::Base
  include PlaySetTool

  has_many :offensive_play_set_choices

  class << self
    OffensivePlaySet.pluck(:name).each do |name|
      method_name = name.titleize.gsub(/\s+/, '').underscore
      define_method method_name do
        instance_variable_get(:"@#{method_name}") \
          || instance_variable_set(:"@#{method_name}", find_by(name: name))
      end
    end
  end

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
