class DefensivePlaySet < ApplicationRecord
  include PlaySetTool

  has_many :defensive_play_set_choices, dependent: :destroy

  scope :normal, -> { where("name != 'Dumb Even'") }

  class << self
    DefensivePlaySet.pluck(:name).each do |name|
      method_name = name.titleize.gsub(/\s+/, '').underscore
      define_method method_name do
        instance_variable_get(:"@#{method_name}") \
          || instance_variable_set(:"@#{method_name}", find_by(name: name))
      end
    end
  end

  def choice_for(defensive_play)
    defensive_play_set_choices.find_by(defensive_play: defensive_play)
  end

  def choose
    pick_from(defensive_play_set_choices).defensive_play
  end

  def to_s
    name
  end
end
