# -*- coding: utf-8 -*-
require 'anemone'
require 'Nokogiri'
require 'kconv'
require './ClinicalTrial.rb'
require 'csv'

CSV_INPUT = "doctors_full.csv"
OUTPUT_FILE = "new_doctors_full.csv"
BASE_URL = "https://upload.umin.ac.jp/cgi-open-bin/ctr"
NUMBER_OF_ROWS_FOR_PAGE = 101

urls = []
clinical_trials = []
clinical_trials_to_be_added = []


#Read CSV data and create the list of clinical trials
puts "start..."
open(CSV_INPUT, "rb:Windows-31J:UTF-8", :invalid=>:replace, undef: :replace) do |f|
	CSV.read(f, headers: true, encoding: "Windows-31J:UTF-8").each do |data|
		clinical_trial = ClinicalTrial.new(data["id"], data["brief_title_JP"], data["condition_JP"], data["sponser_institute"], data["status"], data["link_for_detail"])
		clinical_trial.official_title_JP = data["official_title_JP"]
		clinical_trial.official_title_EN = data["official_title_EN"]
		clinical_trial.brief_title_EN = data["brief_title_EN"]
		clinical_trial.region = data["region"]
		clinical_trial.condition_EN = data["condition_EN"]
		clinical_trial.classification_by_speciality = data["classification_by_speciality"]
		clinical_trial.classification_by_malignancy = data["classification_by_malignancy"]
		clinical_trial.narrative_objectives_JP = data["narrative_objectives_JP"]
		clinical_trial.narrarive_objectives_EN = data["narrarive_objectives_EN"]
		clinical_trial.name_research_contact_person = data["name_research_contact_person"]
		clinical_trial.organization_research_contact_person = data["organization_research_contact_person"]
		clinical_trial.division_research_contact_person = data["division_research_contact_person"]
		clinical_trial.address_research_contact_person = data["address_research_contact_person"]
		clinical_trial.tel_research_contact_person = data["tel_research_contact_person"]
		clinical_trial.email_research_contact_person = data["email_research_contact_person"]
		clinical_trial.name_public_contact_person = data["name_public_contact_person"]
		clinical_trial.organization_public_contact_person = data["organization_public_contact_person"]
		clinical_trial.division_public_contact_person = data["division_public_contact_person"]
		clinical_trial.address_public_contact_person = data["address_public_contact_person"]
		clinical_trial.tel_public_contact_person = data["tel_public_contact_person"]
		clinical_trial.email_public_contact_person = data["email_public_contact_person"]
		clinical_trial.registered_date = data["registered_date"]

		clinical_trials.push(clinical_trial)
	end
end

#get total numbers of clinical trials on the web
doc = Nokogiri::HTML(open(BASE_URL + "/index.cgi"))
texts_containing_total_num = doc.xpath("/html/body/div[1]/text()").text
total_num_text = texts_containing_total_num.scan(/検索件数.+\d{5,10}/)
length = total_num_text[0].length
TOTAL_NUMBER = total_num_text[0][5, length-5].to_i
p TOTAL_NUMBER
TOTAL_PAGES = TOTAL_NUMBER/100 + 1
p TOTAL_PAGES


# put urls for the first loop
for i in 1..TOTAL_PAGES
	urls.push("https://upload.umin.ac.jp/cgi-open-bin/ctr/index.cgi?sort=03&isicdr=1&page=#{i}")
end


#first loop - get ID from WEB and compare with clinical_trial.id
Anemone.crawl(urls, :depth_limit => 0) do |anemone|
	anemone.on_every_page do |page|
		puts page.url
		doc = Nokogiri::HTML.parse(page.body.toutf8)
		for i in 2..NUMBER_OF_ROWS_FOR_PAGE
			id = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[2]").text

			#if there are no more rows any more, break
			if id.length==0
				p "break!!!!!!!!!!"
				break
			end

			#check if this clinical trial is new item or already on csv
			newItem = true
			clinical_trials.each{ |clinical_trial|
				if (clinical_trial.id == id)
					newItem = false
				end
			}
			#if new item, will add this new clinical trial item
			if (newItem)
				brief_title_JP = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[3]").text
				condition_JP = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[4]").text
				sponser_institution = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[5]").text
				status = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[6]").text
				link = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[7]/a")[0][:href]
				clinical_trials_to_be_added.push(ClinicalTrial.new(id, brief_title_JP, condition_JP, sponser_institution, status, link))
			end
		end
	end
end

puts "alrady on the csv"
puts clinical_trials.size

puts "to be added"
puts clinical_trials_to_be_added.size

#Util method for second loop
def trim_tel (num)
	num = num.gsub("\+","")
	num
end

#second loop - add detail with accessing the link on the each row
for clinical_trial in clinical_trials_to_be_added
	doc = Nokogiri::HTML(open(clinical_trial.link_for_detail))

	#fill the detail of clinical trial infos
	clinical_trial.official_title_JP = doc.xpath("/html/body/div[1]/table[1]/tr[2]/td[2]").text
	clinical_trial.official_title_EN = doc.xpath("/html/body/div[1]/table[1]/tr[2]/td[3]").text
	clinical_trial.brief_title_EN = doc.xpath("/html/body/div[1]/table[1]/tr[3]/td[3]").text
	clinical_trial.region = doc.xpath("/html/body/div[1]/table[1]/tr[4]/td[2]/table/tr/td").text
	clinical_trial.condition_EN = doc.xpath("/html/body/div[1]/table[2]/tr[2]/td[3]").text
	clinical_trial.classification_by_speciality = doc.xpath("/html/body/div[1]/table[2]/tr[3]/td[2]/table/tr[1]/td[1]").text
	clinical_trial.classification_by_malignancy = doc.xpath("/html/body/div[1]/table[2]/tr[4]/td[2]").text
	clinical_trial.narrative_objectives_JP = doc.xpath("/html/body/div[1]/table[3]/tr[2]/td[2]").text
	clinical_trial.narrarive_objectives_EN = doc.xpath("/html/body/div[1]/table[3]/tr[2]/td[3]").text
	clinical_trial.name_research_contact_person = doc.xpath("/html/body/div[1]/table[9]/tr[2]/td[2]").text
	clinical_trial.organization_research_contact_person = doc.xpath("/html/body/div[1]/table[9]/tr[3]/td[2]").text
	clinical_trial.division_research_contact_person = doc.xpath("/html/body/div[1]/table[9]/tr[4]/td[2]").text
	clinical_trial.address_research_contact_person = doc.xpath("/html/body/div[1]/table[9]/tr[5]/td[2]").text
	clinical_trial.tel_research_contact_person = trim_tel(doc.xpath("/html/body/div[1]/table[9]/tr[6]/td[2]").text)
	clinical_trial.email_research_contact_person = doc.xpath("/html/body/div[1]/table[9]/tr[7]/td[2]").text
	clinical_trial.name_public_contact_person = doc.xpath("/html/body/div[1]/table[10]/tr[2]/td[2]").text
	clinical_trial.organization_public_contact_person = doc.xpath("/html/body/div[1]/table[10]/tr[3]/td[2]").text
	clinical_trial.division_public_contact_person = doc.xpath("/html/body/div[1]/table[10]/tr[4]/td[2]").text
	clinical_trial.address_public_contact_person = doc.xpath("/html/body/div[1]/table[10]/tr[5]/td[2]").text
	clinical_trial.tel_public_contact_person = trim_tel(doc.xpath("/html/body/div[1]/table[10]/tr[6]/td[2]").text)
	clinical_trial.email_public_contact_person = doc.xpath("/html/body/div[1]/table[10]/tr[8]/td[2]").text
end

#combine the original list with the list of items which will be added
clinical_trials_to_be_added.concat(clinical_trials)

# add a row as heading
clinical_trials_to_be_added.unshift(ClinicalTrial.new_heading)

# -- File I/O
file_strings = ""
for clinical_trial in clinical_trials_to_be_added
	file_strings += clinical_trial.to_csv
end
File.open(OUTPUT_FILE, 'w:Windows-31J', :invalid=>:replace, :undef=>:replace){|file|
file.write(file_strings)}