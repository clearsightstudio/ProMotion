class TestWebScreen < PM::WebScreen

  title "WebScreen Test"

  # accesor for wait_change method which is testing helper
  attr_accessor :is_load_started, :is_load_finished, :is_load_failed, :is_load_failed_error

  # implementation of PM::WebScreen's hook
  def load_started
    self.is_load_started = true
  end

  def load_finished
    self.is_load_finished = true
  end

  def load_failed(error)
    puts "Load Failed: #{error.localizedDescription}"
    puts error.localizedFailureReason
    self.is_load_failed = true
    self.is_load_failed_error = error
  end
end
