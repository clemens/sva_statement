class ExplanationEntry < Entry
  def as_json(*args)
    attributes
  end
end
