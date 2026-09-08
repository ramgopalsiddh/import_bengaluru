# Run after `bundle exec jekyll build`.
require "yaml"

html = File.read("_site/index.html", encoding: "UTF-8")
event = YAML.load_file("_data/event.yml")
partners = YAML.load_file("_data/partners.yml")
sponsors = YAML.load_file("_data/sponsors.yml")
agenda = YAML.load_file("_data/agenda.yml")
jobs = YAML.load_file("_data/jobs.yml")

raise "missing partner slides" unless html.scan("data-partner-slide>").size == partners.size
raise "missing BangPypers link" unless html.include?("https://bangalore.pythonindia.org/")
raise "wrong X link" unless html.include?("https://x.com/__bangpypers__")
raise "wrong contact email" unless html.scan("mailto:banglorepy@gmail.com").size == 1
raise "wrong favicon" unless html.include?("/Assets/logos/bangpypers.svg")
raise "wrong venue logo" unless html.include?("/Assets/logos/InMobi_Glance_Color.png")
sponsors.each do |sponsor|
  raise "missing sponsor" unless html.include?(sponsor.fetch("name")) && html.include?(sponsor.fetch("url"))
  raise "missing sponsor logo" unless File.file?(sponsor.fetch("image").delete_prefix("/"))
end
raise "missing venue map" unless html.include?("https://www.google.com/maps/embed?pb=")
raise "missing mobile poster inset" unless html.include?("width: calc(100% - 1rem)")
raise "carousel interval changed" unless html.include?("5000")
([event.fetch("hero_image")] + partners.map { |partner| partner.fetch("image") }).each do |image|
  raise "missing image: #{image}" unless File.file?(image.delete_prefix("/"))
end
agenda.flat_map { |item| item.fetch("speakers", []) }.each do |speaker|
  raise "missing speaker: #{speaker.fetch("name")}" unless html.include?(speaker.fetch("name"))
  raise "missing speaker image: #{speaker.fetch("image")}" unless File.file?(speaker.fetch("image").delete_prefix("/"))
end
raise "missing talk details" unless html.scan('<details class="talk-details">').size == agenda.count { |item| item["details"] }
raise "missing jobs section" unless html.include?('id="jobs"')
jobs.each do |job|
  %w[company position description link].each { |field| job.fetch(field) }
  raise "missing job" unless html.include?(job.fetch("company")) && html.include?(job.fetch("link"))
  raise "missing job poster" if job["poster"] && !File.file?(job["poster"].delete_prefix("/"))
end

volunteers_html = File.read("_site/volunteers.html", encoding: "UTF-8")
baseurl = YAML.load_file("_config.yml").fetch("baseurl")
event.fetch("volunteers").each do |volunteer|
  image = volunteer.fetch("image")
  raise "volunteer image must be local: #{image}" unless image.start_with?("/Assets/")
  raise "missing built volunteer image: #{image}" unless File.size?("_site#{image}")
  raise "missing volunteer photo: #{volunteer.fetch('name')}" unless volunteers_html.include?(%{src="#{baseurl}#{image}"})
end

puts "Site checks passed"
