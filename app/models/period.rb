class Period
  include Virtus.model

  attribute :start_date, Date
  attribute :end_date, Date

  def ==(other)
    [start_date, end_date] == [other.start_date, other.end_date]
  end
end
