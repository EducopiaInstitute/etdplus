module Etdplus
  module GenericFile
    module PiiDetect
      extend ActiveSupport::Concern

      include do
        validate :detect_pii
      end

      # Default behavior is to raise a validation error and halt the save if pii is found
      def detect_pii
        bulk_extractor_inspect
      end
    end
  end
end
