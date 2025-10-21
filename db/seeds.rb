# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "open-uri"
require "json"

puts "Cleaning database..."
Movie.destroy_all

puts "Seeding static examples..."
Movie.create!(
  title: "Wonder Woman 1984",
  overview: "Wonder Woman comes into conflict with the Soviet Union during the Cold War in the 1980s",
  poster_url: "https://image.tmdb.org/t/p/original/8UlWHLMpgZm9bx6QYh0NFoq67TZ.jpg",
  rating: 6.9
)

Movie.create!(
  title: "The Shawshank Redemption",
  overview: "Framed in the 1940s for double murder, upstanding banker Andy Dufresne begins a new life at the Shawshank prison",
  poster_url: "https://image.tmdb.org/t/p/original/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
  rating: 8.7
)

Movie.create!(
  title: "Titanic",
  overview: "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic.",
  poster_url: "https://image.tmdb.org/t/p/original/9xjZS2rlVxm8SFx8kPC3aIGCOYQ.jpg",
  rating: 7.9
)

Movie.create!(
  title: "Ocean's Eight",
  overview: "Debbie Ocean, a criminal mastermind, gathers a crew of female thieves to pull off the heist of the century.",
  poster_url: "https://image.tmdb.org/t/p/original/MvYpKlpFukTivnlBhizGbkAe3v.jpg",
  rating: 7.0
)

puts "Seeded static examples."

def seed_from_tmdb(tmdb_count: 20)
  puts "Seeding from TMDB proxy (top_rated, limit: #{tmdb_count})..."
  url = "https://tmdb.lewagon.com/movie/top_rated"
  begin
    serialized = URI.open(url).read
    data = JSON.parse(serialized)
    results = data["results"] || []

    results.first(tmdb_count).each do |m|
      title = m["title"] || m["original_title"]
      overview = m["overview"] || "No overview"
      poster_path = m["poster_path"]
      poster_url = poster_path ? "https://image.tmdb.org/t/p/original#{poster_path}" : nil
      rating = m["vote_average"]

      Movie.find_or_create_by!(title: title) do |movie|
        movie.overview = overview
        movie.poster_url = poster_url
        movie.rating = rating
      end
    end
    puts "TMDB seeding finished. Created/ensured #{[results.size, tmdb_count].min} movies."
  rescue OpenURI::HTTPError => e
    puts "Failed to fetch TMDB data: #{e.message}"
  rescue StandardError => e
    puts "Something went wrong while seeding from TMDB: #{e.message}"
  end
end

puts "Seeds done."

seed_from_tmdb(tmdb_count: 20)

