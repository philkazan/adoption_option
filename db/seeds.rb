require 'httparty'
require 'json'
require 'dotenv-rails'

Pet.destroy_all

zipcodes = ["08226","19103", "08690"]
result_sets = []

zipcodes.each do |zipcode|
  url = "http://api.petfinder.com/pet.find?key=#{ENV["PETFINDER_API_KEY"]}&location=#{zipcode}&output=basic&format=json"
  response = HTTParty.get(url)
  result_sets << JSON.parse(response.body)
end

result_sets.each do |result_set|
  result_set["petfinder"]["pets"]["pet"].each do |pet|
    sex = ""
    size = ""
    if pet["sex"]["$t"].nil?
      sex = nil
    elsif pet["sex"]["$t"] == "M"
      sex = "Male"
    elsif pet["sex"]["$t"] == "F"
      sex = "Female"
    end

    if pet["size"]["$t"].nil?
      size = nil
    elsif pet["size"]["$t"] == "S"
      size = "Small"
    elsif pet["size"]["$t"] == "M"
      size = "Medium"
    elsif pet["size"]["$t"] == "L"
      size = "Large"
    elsif pet["size"]["$t"] == "XL"
      size = "Extra Large"
    end


    Pet.create(
      name:  pet["name"] ? pet["name"]["$t"] : nil,
      animal:  pet["animal"] ? pet["animal"]["$t"] : nil,
      description:  pet["description"] ? pet["description"]["$t"] : nil,
      size:  size,
      sex:  sex,
      age:  pet["age"] ? pet["age"]["$t"] : nil,
      location:  pet["contact"] ? pet["contact"]["zip"]["$t"] : nil,
      image: pet["media"]["photos"]["photo"][7] ? pet["media"]["photos"]["photo"][7]["$t"] : 'http://i.imgur.com/S94DBcZ.png'
    )
    # Pet.create(
    #   name: pet["name"]["$t"],
    #   animal: pet["animal"]["$t"],
    #   description: pet["description"]["$t"],
    #   size: pet["size"]["$t"],
    #   sex: pet["sex"]["$t"],
    #   location: pet["contact"]["zip"]["$t"],
    #   age: pet["age"]["$t"],
    #   image: pet["media"]["photos"]["photo"][7]["$t"]
    # )
  end
end
