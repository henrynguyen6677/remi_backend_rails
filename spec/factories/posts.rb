FactoryBot.define do
  factory :post do
    sequence(:post_id) { |n| "video_id_#{n}" }
    title { "Test Video" }
    content { "Video by TestAuthor" }
    url { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }
    embedUrl { "https://www.youtube.com/embed/dQw4w9WgXcQ" }
    association :user
  end
end
