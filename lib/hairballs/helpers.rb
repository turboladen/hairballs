class Hairballs
  module Helpers

    # Is IRB getting loaded for a rails console?
    #
    # @return [Boolean]
    def rails?
      ENV['RAILS_ENV'] || defined? Rails
    end

    # Name of the relative directory.
    #
    # @return [String]
    def project_name
      @project_name ||= File.basename(Dir.pwd)
    end

    # @param libs [Array<String>]
    def libraries(libs=nil)
      return @libraries if @libraries && libs.nil? && !block_given?

      if libs.nil? && !block_given?
        fail ArgumentError, "Must either provide an Array or a block."
      end

      @libraries = if block_given?
        libs = yield

        unless libs.kind_of?(Array)
          fail ArgumentError, "Block must return an Array."
        end

        libs
      else
        libs
      end
    end

    # Requires #libraries on load.  If they're not installed, install them.  If
    # it can't be installed, move on to the next.
    def require_libraries
      return if @libraries.nil?

      @libraries.each do |lib|
        retry_count = 0

        begin
          next if retry_count == 2
          vputs "Requiring library: #{lib}"
          require lib
        rescue LoadError
          vputs "#{lib} not installed; installing now..."
          Gem.install lib
          require lib
          retry_count += 1
          retry
        end
      end
    end

  end
end
