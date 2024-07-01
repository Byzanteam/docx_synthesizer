module DocxSynthesizer
  class Template
    DOCUMENT_FILE_PATH     = 'word/document.xml'.freeze
    RELS_FILE_PATH         = 'word/_rels/document.xml.rels'.freeze
    CONTENT_TYPE_FILE_PATH = '[Content_Types].xml'.freeze
    STYLES_FILE_PATH       = 'word/styles.xml'.freeze

    attr_reader :zip_contents
    attr_accessor :env

    # the path of the docx file
    def initialize(path_or_buffer)
      @zip_contents = {}

      stream =
        begin
          Zip::File.open(path_or_buffer)
        rescue ArgumentError
          Zip::File.open_buffer(path_or_buffer)
        end

      begin
        stream.each do |entry|
          zip_contents[entry.name] = entry.get_input_stream.try(:read)
        end
      rescue
        raise InvalidTemplateError
      end
    end

    def render_to_string(hash)
      @env = Environment.new

      env.relationships = Relationships.new(zip_contents[RELS_FILE_PATH])
      env.styles        = Styles.new(zip_contents[STYLES_FILE_PATH])
      env.context       = Context.new(hash)

      processors = Processors.new(Template.processors)

      buffer = Zip::OutputStream.write_buffer do |out|
        zip_contents.each do |entry_name, entry_bytes|
          unless processors.stage(entry_name, entry_bytes)
            out.put_next_entry(entry_name)
            out.write(entry_bytes)
          end
        end

        processors.process(out, env)
        env.write_media(out)
      end

      buffer.string
    end

    def render_to_file(hash, output_path)
      File.open(output_path, "wb".freeze) { |f| f.write(render_to_string(hash)) }
    end

    class << self
      def register_processor(entry_name, processor)
        processors[entry_name].push processor
      end

      def processors
        @processors ||= Hash.new { |hash, key| hash[key] = [] }
      end
    end

    register_processor(DOCUMENT_FILE_PATH,     Processor::Document)
    register_processor(RELS_FILE_PATH,         Processor::Relationships)
    register_processor(CONTENT_TYPE_FILE_PATH, Processor::ContentTypes)
    register_processor(STYLES_FILE_PATH,       Processor::Styles)
  end
end
