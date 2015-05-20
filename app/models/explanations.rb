class Explanations
  def initialize(contents)
    @contents = contents
  end

  def social_security_number
    slice = @contents.slice(0..@contents.index("Erklärungen zum Kontoauszug vom"))
    slice.match(/VSNR: (\d{4} \d{6})/)[1]
  end

  def name
    slice = @contents.slice(@contents.index("DVR 0024244")..@contents.index("VSNR: #{social_security_number}")-1)
    slice.lines.last.strip
  end
end
