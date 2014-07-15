class Job
  attr_reader :id

  def initialize *args
    @args = args
    @id = rand 2**62
  end

  def execute
    raise "Implement me!"
  end
end
