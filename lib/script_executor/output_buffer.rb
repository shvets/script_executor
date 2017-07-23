class OutputBuffer
  attr_reader :buffer

  def initialize
    @buffer = []
  end

  def save(line)
    buffer << line
  end
end