require 'fastlane/action'
require_relative '../helper/android_publisher_helper'

module Fastlane
  module Actions
    class GetRolloutPercentageAction < Action
      def self.run(params)
        
        if params[:track] then
          track = params[:track]
        else
          track = "production"
        end 

        auth_header = Helper::AndroidPublisherHelper.get_auth_header(params)
        user_fraction = Helper::AndroidPublisherHelper.fetch_rollout(auth_header, params[:package_name], track)
        rollout_percentage = user_fraction * 100
        rollout_percentage
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :service_account_path,
            env_name: "BITRISEIO_SERVICE_ACCOUNT_URL",
            description: "The service account path",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :package_name,
            description: "The app package name",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :track,
            description: "The track where app is available. eg: production, internal",
            optional: true,
            type: String
          )
        ]
      end

      def self.authors
        ["Daniel Nazareth"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end
