# frozen_string_literal: true

module YouTubeTrendingMap
  module TopVideosRepository
    # Repository for Countries
    class TopVideos
      def self.find_title(title)
        rebuild_entity Database::HotVideoOrm.first(title: title)
      end

      def self.find_channel_title(channel_title)
        rebuild_entity Database::HotVideoOrm.first(channel_title: channel_title)
      end

      def self.rebuild_entity(db_record) # rubocop:disable Metrics/MethodLength
        return nil unless db_record

        Entity::TopVideo.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          publish_time: db_record.publish_time,
          title: db_record.title,
          description: db_record.description,
          channel_title: db_record.channel_title,
          view_count: db_record.view_count,
          like_count: db_record.like_count,
          dislike_count: db_record.dislike_count,
          embed_link: db_record.embed_link
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_record|
          HotVideos.rebuild_entity(db_record)
        end
      end

      def self.find_or_create(entity)
        Database::HotVideoOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
