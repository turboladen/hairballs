require_relative '../../hairballs'

# http://stackoverflow.com/a/123834/172106
Hairballs.add_plugin(:quick_benchmark) do |plugin|
  plugin.libraries %w[benchmark]

  plugin.when_used do
    Kernel.module_eval do
      def quick_benchmark(repetitions=100, &block)
        Benchmark.bmbm do |b|
          b.report { repetitions.times(&block) }
        end
      end
    end
  end
end
