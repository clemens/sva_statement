class ExplanationEntry < Entry
  def as_json(*args)
    attributes.except('period')
  end
end
