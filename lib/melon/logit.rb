module Logit
  def debug msg
    warn msg if $DEBUG
  end

  def notify msg
    puts msg
  end
end
