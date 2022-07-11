require 'fastlane_core/ui/ui'
require 'json'
require 'net/http'
require 'googleauth'
require 'google/apis/androidpublisher_v3'
require 'google/apis'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper

    $base_url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications"

    class AndroidPublisherHelper
      Androidpublisher = Google::Apis::AndroidpublisherV3

      def self.get_auth_header(params)
        if params[:service_account_path] then
          service_account_path = params[:service_account_path]
          scope = 'https://www.googleapis.com/auth/androidpublisher'
          authorizer = Google::Auth::ServiceAccountCredentials.make_creds(json_key_io: File.open(service_account_path), scope: scope)
  
          authorizer.fetch_access_token!['access_token']
        else
          UI.user_error!("Service account path must be supplied.")
          return
        end
      end

      def self.fetch_publisher(access_header, package_name)
        android_publisher = Androidpublisher::AndroidPublisherService.new
        android_publisher.authorization = access_header
        android_publisher
      end

      def self.fetch_edit_id(access_header, package_name)
        android_publisher = fetch_publisher(access_header, package_name)
        edit = android_publisher.insert_edit(package_name)
        edit_id = edit.id
        edit_id
      end

      def self.fetch_track_details(access_header, package_name, track_name)
        android_publisher = fetch_publisher(access_header, package_name)
        edit_id = fetch_edit_id(access_header, package_name)
        track = android_publisher.get_edit_track(package_name, edit_id, track_name)
        track
      end

      def self.fetch_last_release(access_header, package_name, track_name)
        track = fetch_track_details(access_header, package_name, track_name)
        last_release = track.releases[0]
        last_release
      end

      def self.fetch_rollout(access_header, package_name, track_name)
        last_release = fetch_last_release(access_header, package_name, track_name)
        if (last_release.user_fraction != nil) then
          user_fraction = last_release.user_fraction
        else
          user_fraction = 1
        end
        user_fraction
      end

      def self.fetch_version_name(access_header, package_name, track_name)
        last_release = fetch_last_release(access_header, package_name, track_name)
        version_name = last_release.name
        version_name
      end

      def self.update_track_data(access_header, package_name, track_name, track_data)
        track = fetch_track_details(access_header, package_name, track_name)
        android_publisher = fetch_publisher(access_header, package_name)
        edit_id = fetch_edit_id(access_header, package_name)

        android_publisher.update_edit_track(package_name, edit_id, track_name, track_data)
        android_publisher.commit_edit(package_name, edit_id)
      end

    end
  end
end
