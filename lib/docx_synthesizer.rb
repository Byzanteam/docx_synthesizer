require 'nokogiri'
require 'zip'

require 'docx_synthesizer/version'

require 'docx_synthesizer/configuration'
require 'docx_synthesizer/helper'
require 'docx_synthesizer/image_fetcher'

require 'docx_synthesizer/context'
require 'docx_synthesizer/variable'
require 'docx_synthesizer/filter'
require 'docx_synthesizer/environment'
require 'docx_synthesizer/relationships'
require 'docx_synthesizer/fragment'
require 'docx_synthesizer/processors'
require 'docx_synthesizer/template'

module DocxSynthesizer
  class ImageFetchFailure < StandardError # :nodoc:
  end

  class InvalidTemplateError< StandardError # :nodoc:
  end

  def self.template(path)
    Template.new(path)
  end

  def self.configuration
    if block_given?
      yield Configuration.instance
    else
      Configuration.instance
    end
  end
end
