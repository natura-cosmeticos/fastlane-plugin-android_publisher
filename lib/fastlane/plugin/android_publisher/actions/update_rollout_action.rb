require 'fastlane/action'
require_relative '../helper/android_publisher_helper'

module Fastlane
  module Actions
    class UpdateRolloutAction < Action
      def self.run(params)
        
        if params[:track] then
          track = params[:track]
        else
          track = "production"
        end 

        auth_header = Helper::AndroidPublisherHelper.get_auth_header(params)
        track_releases = Helper::AndroidPublisherHelper.fetch_track_details(auth_header, params[:package_name], track)

        has_updated_rollout = false
        rollout_percentage = 0

        old_result = track_releases.clone
        old_result.releases = track_releases.releases.map(&:clone)

        track_releases.releases.each do |release|
          if (release.user_fraction != nil) then
            user_fraction = release.user_fraction

            if user_fraction == 0
              puts "Release not rolled out yet"
              next
            elsif user_fraction < 0.02
              release.user_fraction = 0.02 
              rollout_percentage = 2
            elsif user_fraction < 0.05
              release.user_fraction = 0.05 
              rollout_percentage = 5
            elsif user_fraction < 0.1
              release.user_fraction = 0.1 
              rollout_percentage = 10
            elsif user_fraction < 0.2
              release.user_fraction = 0.2 
              rollout_percentage = 20
            elsif user_fraction < 0.5
              release.user_fraction = 0.5 
              rollout_percentage = 50
            elsif user_fraction < 1.0
              release.user_fraction = null
              release.status = "completed"
              rollout_percentage = 100
            else
              puts "Release already fully rolled out"
              next
            end
          end
        end

        if (old_result.to_json != track_releases.to_json)
          completed_releases = track_releases.releases.select {|release| release.status == "completed" }
          if completed_releases.size == 2
            track_releases.releases.delete(completed_releases[1])
          end

          Helper::AndroidPublisherHelper.update_track_data(auth_header, params[:package_name], track, track_releases)
          has_updated_rollout = true

          puts "✅ Release rolled out to #{rollout_percentage}%"
        else
          puts "✅ No rollout update needed, already in 100%"
        end

        has_updated_rollout
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
