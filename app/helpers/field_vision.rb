require 'singleton'

class FieldVision
  include Singleton

  def initialize
    config = Config.new(real: false)
    field = Field.new(config)
    @area = Area.new(field)
  end

  def real=(real)
    @area.config = Config.new(real: real)
  end

  def set_teams_from(game)
    @area.visitors  = game.visitors
    @area.home_team = game.home_team
  end

  def place_ball_marker(game)
    @area.place_ball_marker(game)
  end

  def to_s
    @area.to_s
  end

  class Config

    def initialize(real: false)
      @real = real
      @h_config = configure
    end

    def real?
      @real
    end

    def dig_and_merge!(key)
      @h_config.merge!(@h_config[key])
    end

    def pixels_per_yard
      @pixels_per_yard ||= read('pixels_per_yard')
    end

    def padding
      @padding ||= read('padding')
    end

    def padding_top
      @padding_top ||= read('padding_top')
    end

    def yard_in_px(yard)
      yard * pixels_per_yard
    end

    def yard_to_coord(yard)
      padding + yard_in_px(10 + yard)
    end

    def read(keyword)
      keys = keyword.split('.')
      @h_config.dig(*keys)
    end

    private

      def configure
        h = File.open('config/initializers/field_vision.yml') { |f|
          YAML.load(f)
        }
        @h_config = h['default'].tap do |h_config|
          h_config.merge!(h['real']) if real?
        end
      end
  end

  module Helper

    def padding_top
      @config.padding_top
    end

    def yard_in_px(yard)
      @config.yard_in_px(yard)
    end

    def yard_to_coord(yard)
      @config.yard_to_coord(yard)
    end

    def ball_on_in_field_coord(game)
      game.ball_on.then { |yard|
        game.home_has_ball ? yard : 100 - yard
      }
    end

    def sign_direction_in_field_coord(game)
      game.home_has_ball ? 1 : -1
    end

    def original_ball_on_in_field_coord(game)
      original_yard = game.ball_on - (10 - game.yard_to_go)
      if game.home_has_ball
        original_yard
      else
        original_yard = 100 - original_yard
      end
    end

    def to_html_element(name, *values, **attrs)
      attr_enum = attrs.reject { |_, v|
        v.blank?
      }.map { |k, v|
        %Q!#{k}="#{v}"!
      }.join(' ')

      [
        "<#{name} #{attr_enum}>",
        values.empty? ? nil : values.compact.join("\n"),
        "</#{name}>"
      ].compact.join("\n")
    end
  end

  class Area
    include Helper

    attr_writer :visitors, :home_team

    def initialize(field)
      @field = field
      @config = field.config
    end

    def config=(config)
      @config = config
      @field.config = config
    end

    def place_ball_marker(game)
      unless @visitors == game.visitors
        @visitors  = game.visitors
        @home_team = game.home_team
      end

      @chain_crew = ChainCrew.new(game, @config)
      @ball_marker = shows_ball_marker?(game) ? @chain_crew.ball_marker_for(@field) : nil
      @chain_crew = nil unless shows_chain_crew?(game)
    end

    def to_s
      to_html_element(
        :svg,
        @field,
        texts_in_end_zone,
        @ball_marker,
        @chain_crew,
        x: 0,
        y: 0,
        width:  @field.width  + @config.padding * 2,
        height: @field.height + @config.padding_top + @config.padding,
        style: "background-color: gray",
        id: 'field_vision_area'
      )
    end

    private

      def shows_ball_marker?(game)
        !game.final?
      end

      def shows_chain_crew?(game)
        game.scrimmage?
      end

      TEAM_NAME_FONT_SIZE = 32

      def texts_in_end_zone
        x_text_left , y_text_left  = @field.coords_for_left_end_zone_text
        x_text_right, y_text_right = @field.coords_for_right_end_zone_text
        [
          to_html_element(
            :text,
            @visitors&.abbr,
            'font-size': TEAM_NAME_FONT_SIZE,
            'font-weight': 'bold',
            transform: "translate(#{x_text_left}, #{y_text_left}) rotate(270)",
            'text-anchor': 'middle',
            'alignment-baseline': 'middle',
            fill: @field.team_name_font_color
          ),
          to_html_element(
            :text,
            @home_team&.abbr,
            'font-size': TEAM_NAME_FONT_SIZE,
            'font-weight': 'bold',
            transform: "translate(#{x_text_right}, #{y_text_right}) rotate(90)",
            'text-anchor': 'middle',
            'alignment-baseline': 'middle',
            fill: @field.team_name_font_color
          )
        ]
      end
  end

  class Field
    include Helper

    attr_reader :config, :width, :height

    %w[
      field_color
      line_color
      end_zone_color
      team_name_font_color
      touchback_line_color
    ].each do |name|
      define_method name do
        @config.read(name)
      end
    end

    YARDAGE_NUMBER_FONT_SIZE = 10
    LINE_WIDTH = 1
    YARD_MARK_LENGTH = 5

    def initialize(config)
      self.config = config
    end

    def config=(config)
      @config = config
      @top = @config.padding_top
      @left = @config.padding
      @width  = yard_in_px(120)
      @height = yard_in_px(field_height_in_yard)
      redraw
    end

    def real?
      @config.real?
    end

    def coords_for_left_end_zone_text
      [
        @left + yard_in_px(5) + 3,
        @top + @height / 2
      ]
    end

    def coords_for_right_end_zone_text
      [
        @left + yard_in_px(115) - 3,
        @top + @height / 2
      ]
    end

    BALL_MARKER_LENGTH = 10
    BALL_MARKER_HEIGHT = 6
    BALL_MARKER_COLOR = 'cyan'

    def ball_marker(yard, sign_direction, **options)
      coord_point = [
        yard_to_coord(yard),
        y_ball_marker_point
      ]
      coord_end_top = [
        coord_point.first - BALL_MARKER_LENGTH * sign_direction,
        coord_point.last - BALL_MARKER_HEIGHT / 2
      ]
      coord_end_bottom = [
        coord_end_top.first,
        coord_end_top.last + BALL_MARKER_HEIGHT
      ]
      to_html_element(
        :polygon,
        {
          points: [coord_point, coord_end_top, coord_end_bottom].map { |x, y|
            [x, y].join(',')
          }.join(' '),
          fill: BALL_MARKER_COLOR,
          id: 'ball_marker',
          class: 'ball_marker'
        }.merge(options)
      )
    end

    def to_s
      @to_s ||= [
        boundary,
        0.step(100, 1).map { |yard|
          yard_marks_at(yard)
        },
        0.step(100, 5).map { |yard|
          yard_line_at(yard)
        },
        real? ? yardage_numbers : nil,
        real? ? arrow_heads : nil,
        left_end_zone,
        right_end_zone,
        real? ? logo_at_midfield : nil,
        ball_markers_for_announcer
      ].flatten.compact.join("\n")
    end

    private

      def redraw
        @to_s = nil
      end

      def field_height_in_yard
        real? ? 20 : 5
      end

      def bottom
        @top + @height
      end

      def y_hash_mark
        @top + @height / 3
      end

      def y_yardage_number
        @top + @height * 2 / 3
      end

      def y_ball_marker_point
        real? ? y_hash_mark - BALL_MARKER_HEIGHT / 2 \
              : @top + @height / 2
      end

      def boundary
        to_html_element(
          :rect,
          x: @left,
          y: @top,
          width:  @width,
          height: @height,
          stroke: line_color,
          'stroke-width': LINE_WIDTH,
          fill: field_color
        )
      end

      TOUCHBACK_LINE_COLOR = 'chocolate'
      TOUCHBACK_LINE_OFFSET = 1

      def yard_line_at(yard)
        x = yard_to_coord(yard)
        [
          to_html_element(
            :line,
            x1: x,
            x2: x,
            y1: @top,
            y2: bottom,
            stroke: line_color,
            'stroke-width': LINE_WIDTH,
          )
        ].tap { |elements|
          if [20, 50, 80].include?(yard)
            elements \
              << to_html_element(
                :line,
                x1: x - LINE_WIDTH - TOUCHBACK_LINE_OFFSET,
                x2: x - LINE_WIDTH - TOUCHBACK_LINE_OFFSET,
                y1: @top + LINE_WIDTH,
                y2: bottom - LINE_WIDTH,
                stroke: touchback_line_color,
                'stroke-width': LINE_WIDTH,
              ) \
              << to_html_element(
                :line,
                x1: x + LINE_WIDTH + TOUCHBACK_LINE_OFFSET,
                x2: x + LINE_WIDTH + TOUCHBACK_LINE_OFFSET,
                y1: @top + LINE_WIDTH,
                y2: bottom - LINE_WIDTH,
                stroke: touchback_line_color,
                'stroke-width': LINE_WIDTH,
              )
          end
        }
      end

      def yard_marks_at(yard)
        [
          real? ? [@top, @top + YARD_MARK_LENGTH] : nil,
          real? ? [y_hash_mark, y_hash_mark + YARD_MARK_LENGTH] : nil,
          [bottom, bottom - YARD_MARK_LENGTH]
        ].compact.map { |y1, y2|
          to_html_element(
            :line,
            x1: yard_to_coord(yard),
            x2: yard_to_coord(yard),
            y1: y1,
            y2: y2,
            stroke: line_color,
            'stroke-width': LINE_WIDTH,
          )
        }
      end

      def yardage_numbers
        10.step(90, 10).map { |yard|
          yardage_number_at(yard)
        }
      end

      def yardage_number_at(yard)
        number = yard <= 50 ? yard : 100 - yard
        to_html_element(
          :text,
          number.to_s.chars.join(' '),
          x: yard_to_coord(yard),
          y: y_yardage_number,
          'font-size': YARDAGE_NUMBER_FONT_SIZE,
          'text-anchor': 'middle',
          fill: line_color
        )
      end

      def arrow_heads
        10.step(90, 10).map { |yard|
          next if yard == 50
          arrow_head_at(yard)
        }.compact
      end

      X_OFFSET_ARROW_HEAD_POINT = 13
      Y_OFFSET_ARROW_HEAD_POINT = 4
      ARROW_HEAD_LENGTH = 5
      ARROW_HEAD_HEIGHT = 3

      def arrow_head_at(yard)
        sign_direction = yard < 50 ? 1 : -1
        coord_point = [
          yard_to_coord(yard) - X_OFFSET_ARROW_HEAD_POINT * sign_direction,
          y_yardage_number - Y_OFFSET_ARROW_HEAD_POINT
        ]
        coord_end_top = [
          coord_point.first + ARROW_HEAD_LENGTH * sign_direction,
          coord_point.last - ARROW_HEAD_HEIGHT / 2
        ]
        coord_end_bottom = [
          coord_end_top.first,
          coord_end_top.last + ARROW_HEAD_HEIGHT
        ]
        to_html_element(
          :polygon,
          points: [coord_point, coord_end_top, coord_end_bottom].map { |x, y|
            [x, y].join(',')
          }.join(' '),
          fill: line_color
        )
      end

      def left_end_zone
        to_html_element(
          :rect,
          x: @left,
          y: @top,
          width:  yard_in_px(10),
          height: @height,
          stroke: line_color,
          'stroke-width': LINE_WIDTH,
          fill: end_zone_color
        )
      end

      def right_end_zone
        to_html_element(
          :rect,
          x: @left + yard_in_px(110),
          y: @top,
          width:  yard_in_px(10),
          height: @height,
          stroke: line_color,
          'stroke-width': LINE_WIDTH,
            fill: end_zone_color
        )
      end

      def logo_at_midfield
        to_html_element(
          :svg,
          nfl_logo,
          x: @left + yard_in_px(58),
          y: @top + 5,
          width:  20,
          height: 20,
          viewBox: "0 0 192.756 192.756"
        )
      end

      def nfl_logo
        File.open('app/helpers/nfl_logo.svg', 'r') { |f|
          f.read()
        } rescue nil
      end

      def ball_markers_for_announcer
        %w[home_team visitors].flat_map { |team|
          -10.step(110, 1).map { |yard|
            yard_in_field, sign_direction = if team == 'home_team'
                                              [yard, 1]
                                            else
                                              [100 - yard, -1]
                                            end
            ball_marker(
              yard_in_field, sign_direction,
              id: "ball_marker-#{team.first}#{yard}",
              class: 'ball_marker',
              fill: 'cyan',
              display: 'none'
            )
          }
        }
      end
  end

  class ChainCrew
    include Helper

    def initialize(game, config)
      @config = config

      @original_yard = original_ball_on_in_field_coord(game)
      @sign_direction = sign_direction_in_field_coord(game)
      @yard = ball_on_in_field_coord(game)
      @down = game.down
    end

    def ball_marker_for(field)
      field.ball_marker(@yard, @sign_direction)
    end

    def to_s
      [
        YardStickSet.new(@original_yard, @sign_direction, @config),
        DownMarker.new(@yard, @down, @config)
      ].join("\n")
    end

    class YardStickSet

      def initialize(original_yard, sign_direction, config)
        @original_yard = original_yard
        @sign_direction = sign_direction
        @config = config
      end

      def to_s
        [
          YardStick.new(@original_yard, @config),
          YardStick.new(@original_yard + 10 * @sign_direction, @config),
          YardChain.new(@original_yard, @sign_direction, @config)
        ].join("\n")
      end

    end

    class YardStick
      include Helper

      %w[
        length
        head_radius
        head_clearance
        chain_position
        chain_width
        base_color
        main_color
        number_of_body_lines
      ].each do |name|
        define_method name do
          @config.read(name)
        end
      end

      def initialize(yard, config)
        @yard = yard
        @config = config
        @config.dig_and_merge!('yard_stick')
      end

      def to_s
        x = yard_to_coord(@yard)
        y_top = padding_top - length

        [
          stick(x, y_top),
          head(x, y_top),
          body(x, y_top),
          body_lines(x, number_of_body_lines)
        ].flatten.join("\n")
      end

      private

        def stick(x, y_top)
          to_html_element(
            :line,
            x1: x,
            x2: x,
            y1: padding_top,
            y2: y_top,
            stroke: base_color,
            'stroke-width': 1,
          )
        end

        def head(cx, cy)
          [
            to_html_element(
              :circle,
              cx: cx,
              cy: cy,
              r: head_radius,
              stroke: main_color,
              'stroke-width': 1,
              fill: main_color
            ),
            to_html_element(
              :circle,
              cx: cx,
              cy: cy,
              r: head_radius - 2,
              stroke: 'black',
              'stroke-width': 1,
              fill: 'transparent'
            )
          ]
        end

        def body(x, y_top)
          coord_bottom = [
            x,
            padding_top - chain_position
          ]
          coord_top_left = [
            x - head_radius,
            y_top + head_radius + head_clearance
          ]
          coord_top_right = [
            x + head_radius,
            y_top + head_radius + head_clearance
          ]

          to_html_element(
            :polygon,
            points: [coord_bottom, coord_top_left, coord_top_right].map { |x, y|
              [x, y].join(',')
            }.join(' '),
            fill: main_color
          )
        end

        BODY_LINE_POSITIONING_OFFSET_FROM_BOTTOM = 4

        def body_lines(x, num_lines)
          y_coord_bottom = padding_top - chain_position
          body_height = length - head_radius - head_clearance
          body_top_width = head_radius * 2

          offset_from_bottom = BODY_LINE_POSITIONING_OFFSET_FROM_BOTTOM
          dy_interval = (body_height - offset_from_bottom) / (num_lines + 1)
          y = y_coord_bottom - offset_from_bottom - dy_interval
          num_lines.times.flat_map { |n|
            width = body_top_width * (n + 1) / num_lines \
                  + body_top_width * offset_from_bottom / body_height
            [
              to_html_element(
                :line,
                x1: x - width / 2,
                x2: x + width / 2,
                y1: y,
                y2: y,
                stroke: 'black',
                'stroke-width': 1,
              ),
              to_html_element(
                :line,
                x1: x - width / 2 + 1,
                x2: x + width / 2 - 1,
                y1: y + 1,
                y2: y + 1,
                stroke: 'white',
                'stroke-width': 1,
              )
            ].tap { y -= dy_interval }
          }
        end
    end

    class YardChain
      include Helper

      def initialize(yard, sign_direction, config)
        @yard = yard
        @sign_direction = sign_direction
        @config = config
        @config.dig_and_merge!('yard_stick')
      end

      def to_s
        y = padding_top - @config.read('chain_position')
        to_html_element(
          :line,
          x1: yard_to_coord(@yard),
          x2: yard_to_coord(@yard + 10 * @sign_direction),
          y1: y,
          y2: y,
          stroke: @config.read('base_color'),
          'stroke-width': @config.read('chain_width')
        )
      end
    end

    class DownMarker
      include Helper

      def initialize(yard, down, config)
        @yard = yard
        @down = down
        @config = config
        @config.dig_and_merge!('yard_stick')
      end

      def to_s
        x = yard_to_coord(@yard)
        length = @config.read('length')
        y_top = padding_top - length
        head_side_length = @config.read('head_radius') * 2
        base_color = @config.read('base_color')
        font_color = @config.read('main_color')
        font_size = @config.read('down_marker.font_size')

        [
          to_html_element(
            :line,
            x1: x,
            x2: x,
            y1: padding_top,
            y2: y_top,
            stroke: base_color,
            'stroke-width': 1,
          ),
          to_html_element(
            :rect,
            x: x - head_side_length / 2,
            y: y_top - head_side_length / 2,
            width:  head_side_length,
            height: head_side_length,
            stroke: base_color,
            fill: base_color
          ),
          to_html_element(
            :text,
            @down,
            x: x,
            y: y_top + head_side_length / 2 - 1,
            'font-size': font_size,
            'text-anchor': 'middle',
            fill: font_color
          )
        ].join("\n")
      end
    end
  end
end
