module RunLoop

  # A class for waiting on processes.
  class ProcessWaiter

    attr_reader :process_name

    def initialize(process_name, options={})
      @options = DEFAULT_OPTIONS.merge(options)
      @process_name = process_name
    end

    # Collect a list of Integer pids.
    # @return [Array<Integer>] An array of integer pids for the `process_name`
    def pids
      process_info = `ps x -o pid,comm | grep -v grep | grep #{process_name}`
      process_array = process_info.split("\n")
      process_array.map { |process| process.split(' ').first.strip.to_i }
    end

    # Is the `process_name` a running?
    def running_process?
      !pids.empty?
    end

    # Wait for `process_name` to start.
    def wait_for_any
      return true if running_process?

      now = Time.now
      poll_until = now + @options[:timeout]
      delay = @options[:interval]
      is_alive = false
      while Time.now < poll_until
        is_alive = running_process?
        break if is_alive
        sleep delay
      end

      if RunLoop::Environment.debug?
        puts "Waited for #{Time.now - now} seconds for '#{process_name}' to start."
      end

      if @options[:raise_on_timeout] and !is_alive
        raise "Waited #{@options[:timeout]} seconds for '#{process_name}' to start."
      end
      is_alive
    end

    # Wait for all `process_name` to finish.
    def wait_for_none
      return true if !running_process?

      now = Time.now
      poll_until = now + @options[:timeout]
      delay = @options[:interval]
      has_terminated = false
      while Time.now < poll_until
        has_terminated = !self.running_process?
        break if has_terminated
        sleep delay
      end

      if RunLoop::Environment.debug?
        puts "Waited for #{Time.now - now} seconds for '#{process_name}' to die."
      end

      if @options[:raise_on_timeout] and !has_terminated
        raise "Waited #{@options[:timeout]} seconds for '#{process_name}' to die."
      end
      has_terminated
    end

    private

    # @!visibility private
    DEFAULT_OPTIONS =
          {
                :timeout => 10.0,
                :interval => 0.1,
                :raise_on_timeout => false
          }
  end
end
