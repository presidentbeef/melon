require_relative 'job'

class Adder < Job
  def execute
    @args.reduce(&:+)
  end
end
