require "open-uri"

module Importer
  class << self
    def import_json(file_url) = parse_json(file_url).sort_by { |item| item["created_at"] }

    private

    def parse_json(file_url) = JSON.parse(read(file_url))

    def read(file_url) = URI.parse(file_url).open.read
  end
end
