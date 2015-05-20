class Explanations
  DATE = "\\d{1,2}\\.\\d{1,2}\\.\\d{4}"

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

  def parts
    main_content = @contents.slice(@contents.index("Erklärungen zum Kontoauszug vom")..-1)

    parts = main_content.scan(ExplanationPart::PARTS_REGEXP).flatten

    main_content = StringScanner.new(main_content.slice(main_content.index(parts.first)..-1))

    parts.map.with_index do |part, i|
      content = if (next_part = parts[i + 1])
        result = main_content.scan_until(Regexp.new(Regexp.escape(next_part)))
        main_content.pos -= next_part.bytesize
        result[0..-(next_part.length+1)]
      else
        main_content.rest
      end

      ExplanationPart.new(content)
    end
  end
end
