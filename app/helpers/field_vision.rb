require 'singleton'

class FieldVision
  include Singleton

  PXS_PER_YARD = 5
  PADDING = 10
  PADDING_TOP = 40

  def initialize
    field = Field.new(PADDING_TOP, PADDING)
    @area = Area.new(field)
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

  module Helper

    def yard_in_px(yard)
      yard * PXS_PER_YARD
    end

    def yard_to_coord(yard)
      PADDING + yard_in_px(10 + yard)
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
    end

    def place_ball_marker(game)
      unless @visitors == game.visitors
        @visitors  = game.visitors
        @home_team = game.home_team
      end

      home_has_ball = game.home_has_ball
      yard = game.ball_on
      yard = 100 - yard unless home_has_ball
      sign_direction = home_has_ball ? 1 : -1
      @ball_marker = ball_marker(yard, sign_direction)

      original_yard = game.ball_on - (10 - game.yard_to_go)
      original_yard = 100 - original_yard unless home_has_ball
      @yard_sticks = ChainCrew.yard_sticks(original_yard, sign_direction)

      @down_marker = ChainCrew.down_marker(yard, game.down)
    end

    def to_s
      to_html_element(
        :svg,
        @field, texts_in_end_zone, @ball_marker, @yard_sticks, @down_marker,
        x: 0,
        y: 0,
        width:  @field.width  + PADDING * 2,
        height: @field.height + PADDING_TOP + PADDING,
        style: "background-color: gray",
        id: 'field_vision_area'
      )
    end

    private

      TEAM_NAME_FONT_SIZE = 32

      BALL_MARKER_LENGTH = 10
      BALL_MARKER_HEIGHT = 6
      BALL_MARKER_COLOR = 'yellow'

      def ball_marker(yard, sign_direction)
        coord_point = [
          yard_to_coord(yard),
          y_ball_marker
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
          points: [coord_point, coord_end_top, coord_end_bottom].map { |x, y|
            [x, y].join(',')
          }.join(' '),
          fill: BALL_MARKER_COLOR,
          id: 'ball_marker'
        )
      end

      def y_ball_marker
        @field.y_hash_mark - BALL_MARKER_HEIGHT / 2
      end

      def texts_in_end_zone
        x_text_left , y_text_left  = @field.coords_for_left_end_zone_text
        x_text_right, y_text_right = @field.coords_for_right_end_zone_text
        [
          to_html_element(
            :text,
            @visitors&.abbr,
            'font-size': TEAM_NAME_FONT_SIZE,
            'font-weight': 'bold',
            transform: "translate(#{x_text_left}, #{y_text_left}) rotate(90)",
            'text-anchor': 'middle',
            'alignment-baseline': 'middle',
            fill: Field::TEAM_NAME_FONT_COLOR
          ),
          to_html_element(
            :text,
            @home_team&.abbr,
            'font-size': TEAM_NAME_FONT_SIZE,
            'font-weight': 'bold',
            transform: "translate(#{x_text_right}, #{y_text_right}) rotate(270)",
            'text-anchor': 'middle',
            'alignment-baseline': 'middle',
            fill: Field::TEAM_NAME_FONT_COLOR
          )
        ]
      end
  end

  class Field
    include Helper

    attr_reader :width, :height

    FIELD_COLOR = 'green'
    LINE_COLOR  = 'white'
    END_ZONE_COLOR = 'skyblue'
    TEAM_NAME_FONT_COLOR = 'black'

    YARDAGE_NUMBER_FONT_SIZE = 10
    LINE_WIDTH = 2
    MARK_LENGTH = 5

    def initialize(top, left)
      @top = top
      @left = left
      @width  = yard_in_px(120)
      @height = yard_in_px( 20)
    end

    def y_hash_mark
      @top + @height / 3
    end

    def coords_for_left_end_zone_text
      [
        @left + yard_in_px(5) - 3,
        @top + @height / 2
      ]
    end

    def coords_for_right_end_zone_text
      [
        @left + yard_in_px(115) + 3,
        @top + @height / 2
      ]
    end

    def to_s
      @to_s ||= [
        boundary,
        0.step(100, 5).map { |yard|
          yard_line_at(yard)
        },
        0.step(100, 1).map { |yard|
          yard_marks_at(yard)
        },
        10.step(90, 10).map { |yard|
          yardage_number_at(yard)
        },
        10.step(90, 10).map { |yard|
          next if yard == 50
          arrow_head_at(yard)
        }.compact,
        left_end_zone,
        right_end_zone,
      ].flatten.compact.join("\n")
    end

    private

      def bottom
        @top + @height
      end

      def y_yardage_number
        @top + @height * 2 / 3
      end

      def boundary
        to_html_element(
          :rect,
          x: @left,
          y: @top,
          width:  @width,
          height: @height,
          stroke: LINE_COLOR,
          'stroke-width': LINE_WIDTH,
          fill: FIELD_COLOR
        )
      end

      def yard_line_at(yard)
        to_html_element(
          :line,
          x1: yard_to_coord(yard),
          x2: yard_to_coord(yard),
          y1: @top,
          y2: bottom,
          stroke: LINE_COLOR,
          'stroke-width': LINE_WIDTH,
        )
      end

      def yard_marks_at(yard)
        [
          [@top, @top + MARK_LENGTH],
          [y_hash_mark, y_hash_mark + MARK_LENGTH],
          [bottom, bottom - MARK_LENGTH]
        ].map { |y1, y2|
          to_html_element(
            :line,
            x1: yard_to_coord(yard),
            x2: yard_to_coord(yard),
            y1: y1,
            y2: y2,
            stroke: LINE_COLOR,
            'stroke-width': LINE_WIDTH,
          )
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
          fill: LINE_COLOR
        )
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
          fill: LINE_COLOR
        )
      end

      def left_end_zone
        to_html_element(
          :rect,
          x: @left,
          y: @top,
          width:  yard_in_px(10),
          height: @height,
          stroke: LINE_COLOR,
          'stroke-width': LINE_WIDTH,
          fill: END_ZONE_COLOR
        )
      end

      def right_end_zone
        to_html_element(
          :rect,
          x: @left + yard_in_px(110),
          y: @top,
          width:  yard_in_px(10),
          height: @height,
          stroke: LINE_COLOR,
          'stroke-width': LINE_WIDTH,
            fill: END_ZONE_COLOR
        )
      end
  end

  module ChainCrew
    extend Helper

    module_function

    YARD_STICK_LENGTH = 30
    YARD_STICK_HEAD_RADIUS = 4
    YARD_STICK_HEAD_CLEARANCE = 2
    YARD_STICK_CHAIN_POSITION = 4
    YARD_STICK_CHAIN_wIDTH = 1

    YARD_STICK_BASE_COLOR = 'black'
    YARD_STICK_COLOR = 'chocolate'

    def yard_stick(yard)
      x = yard_to_coord(yard)
      y_top = PADDING_TOP - YARD_STICK_LENGTH

      coord_bottom = [
        x,
        PADDING_TOP - YARD_STICK_CHAIN_POSITION
      ]
      coord_top_left = [
        x - YARD_STICK_HEAD_RADIUS,
        y_top + YARD_STICK_HEAD_RADIUS + YARD_STICK_HEAD_CLEARANCE
      ]
      coord_top_right = [
        x + YARD_STICK_HEAD_RADIUS,
        y_top + YARD_STICK_HEAD_RADIUS + YARD_STICK_HEAD_CLEARANCE
      ]

      [
        to_html_element(
          :line,
          x1: x,
          x2: x,
          y1: PADDING_TOP,
          y2: y_top,
          stroke: YARD_STICK_BASE_COLOR,
          'stroke-width': 1,
        ),
        to_html_element(
          :polygon,
          points: [coord_bottom, coord_top_left, coord_top_right].map { |x, y|
            [x, y].join(',')
          }.join(' '),
          fill: YARD_STICK_COLOR
        ),
        yard_stick_body_lines(yard, 2),
        yard_stick_head(x, y_top)
      ]
    end

    def yard_stick_body_lines(yard, num_lines)
      x = yard_to_coord(yard)
      y_coord_bottom = PADDING_TOP - YARD_STICK_CHAIN_POSITION
      body_height = YARD_STICK_LENGTH - YARD_STICK_HEAD_RADIUS - YARD_STICK_HEAD_CLEARANCE
      body_top_width = YARD_STICK_HEAD_RADIUS * 2

      dy_interval = body_height / (num_lines + 1)
      y = y_coord_bottom - dy_interval
      num_lines.times.flat_map { |n|
        width = body_top_width * (n + 1) / num_lines
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
        ].tap { y -= dy_interval - 1 } # 1 is for top line y_coord adjustment.
      }
    end

    def yard_stick_head(cx, cy)
      [
        to_html_element(
          :circle,
          cx: cx,
          cy: cy,
          r: YARD_STICK_HEAD_RADIUS,
          stroke: YARD_STICK_COLOR,
          'stroke-width': 1,
          fill: YARD_STICK_COLOR
        ),
        to_html_element(
          :circle,
          cx: cx,
          cy: cy,
          r: YARD_STICK_HEAD_RADIUS - 2,
          stroke: 'black',
          'stroke-width': 1,
          fill: 'transparent'
        )
      ]
    end

    def yard_chain(yard, sign_direction)
      y = PADDING_TOP - YARD_STICK_CHAIN_POSITION
      to_html_element(
        :line,
        x1: yard_to_coord(yard),
        x2: yard_to_coord(yard + 10 * sign_direction),
        y1: y,
        y2: y,
        stroke: YARD_STICK_BASE_COLOR,
        'stroke-width': YARD_STICK_CHAIN_wIDTH
      )
    end

    def yard_sticks(original_yard, sign_direction)
      [
        yard_stick(original_yard),
        yard_stick(original_yard + 10 * sign_direction),
        yard_chain(original_yard, sign_direction)
      ]
    end

    DOWN_MARKER_LENGTH = YARD_STICK_LENGTH
    DOWN_MARKER_HEAD_SIDE_LENGTH = YARD_STICK_HEAD_RADIUS * 2
    DOWN_MARKER_BASE_COLOR = YARD_STICK_BASE_COLOR
    DOWN_MARKER_FONT_COLOR = YARD_STICK_COLOR
    DOWN_MARKER_FONT_SIZE = 11

    def down_marker(yard, down)
      x = yard_to_coord(yard)
      y_top = PADDING_TOP - DOWN_MARKER_LENGTH
      [
        to_html_element(
          :line,
          x1: x,
          x2: x,
          y1: PADDING_TOP,
          y2: y_top,
          stroke: DOWN_MARKER_BASE_COLOR,
          'stroke-width': 1,
        ),
        to_html_element(
          :rect,
          x: x - DOWN_MARKER_HEAD_SIDE_LENGTH / 2,
          y: y_top - DOWN_MARKER_HEAD_SIDE_LENGTH / 2,
          width:  DOWN_MARKER_HEAD_SIDE_LENGTH,
          height: DOWN_MARKER_HEAD_SIDE_LENGTH,
          stroke: DOWN_MARKER_BASE_COLOR,
          fill: DOWN_MARKER_BASE_COLOR
        ),
        to_html_element(
          :text,
          down,
          x: x,
          y: y_top + DOWN_MARKER_HEAD_SIDE_LENGTH / 2,
          'font-size': DOWN_MARKER_FONT_SIZE,
          'text-anchor': 'middle',
          fill: DOWN_MARKER_FONT_COLOR
        )
      ]
    end
  end
end