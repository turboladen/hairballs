require 'hairballs'

# Quick and dirty benchmarking of whatever block you pass to the method.
#
# @see http://stackoverflow.com/a/123834/172106
Hairballs.add_plugin(:quick_benchmark) do |plugin|
  plugin.libraries %w[benchmark]

  plugin.on_load do
    Kernel.module_eval do
      def quick_benchmark(repetitions=20, &block)
        Benchmark.bmbm do |b|
          b.report { repetitions.times(&block) }
        end
      end
    end
  end
end
