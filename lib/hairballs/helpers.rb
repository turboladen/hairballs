class Hairballs
  # Helpers specifying and requiring dependencies for Themes and Plugins.
  module Helpers
    # @param libs [Array<String>]
    def libraries(libs=nil)
      return @libraries if @libraries && libs.nil?

      @libraries = block_given? ? yield : libs

      unless @libraries.is_a?(Array)
        fail ArgumentError,
          "Block must return an Array but returned #{@libraries}."
      end

      @libraries
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
