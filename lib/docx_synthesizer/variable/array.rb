module DocxSynthesizer
  class Variable::Array < Variable
    def initialize(value, spacer: nil)
      value = [value] unless ::Array === value
      super(value)
      @spacer = spacer
    end

    def each
      value.each
    end

    def process(node_template, env, opts = {})
      spacer = opts.fetch(:spacer) { @spacer }

      nodes = value.map { |v| [v.process(node_template, env)] }

      if spacer
        nodes
      else
        spacer_variable = Variable::Text.new(spacer)
        nodes.zip(
          ::Array.new(nodes.size - 1) {
            spacer_variable.process(node_template, env)
          }
        )
      end
    end
  end
end