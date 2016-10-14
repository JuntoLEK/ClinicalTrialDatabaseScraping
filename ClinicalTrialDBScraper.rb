# -*- coding: utf-8 -*-
require 'anemone'
require 'Nokogiri'
require 'kconv'
require './ClinicalTrial.rb'


BASE_URL = "https://upload.umin.ac.jp/cgi-open-bin/ctr"
NUMBER_OF_ROWS_FOR_PAGE = 101
OUTPUT_FILE = "doctors_test2.csv"

#get total numbers of clinical trials
doc = Nokogiri::HTML(open(BASE_URL + "/index.cgi"))
texts_containing_total_num = doc.xpath("/html/body/div[1]/text()").text
total_num_text = texts_containing_total_num.scan(/検索件数.+\d{5,10}/)
length = total_num_text[0].length
TOTAL_NUMBER = total_num_text[0][5, length-5].to_i
p TOTAL_NUMBER

TOTAL_PAGES = TOTAL_NUMBER/100 + 1

p TOTAL_PAGES



# put urls for the first loop
urls = []
# for i in 1..TOTAL_PAGES
for i in 1..1
	urls.push("https://upload.umin.ac.jp/cgi-open-bin/ctr/index.cgi?sort=03&isicdr=1&page=#{i}")
end

clinical_trials = []


Anemone.crawl(urls, :depth_limit => 0) do |anemone|
	anemone.on_every_page do |page|
		puts page.url
		doc = Nokogiri::HTML.parse(page.body.toutf8)
		# for i in 2..NUMBER_OF_ROWS_FOR_PAGE
		for i in 2..31
			p i.to_s + "page"
			id = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[2]").text
			brief_title_JP = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[3]").text
			condition_JP = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[4]").text
			sponser_institution = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[5]").text
			status = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[6]").text
			link = doc.xpath("/html/body/div[1]/table[3]/tr[#{i}]/td[7]/a")[0][:href]

			# p id.text
			# p indication.text
			# p organization.text
			# p status.text
			# p link[0][:href]
			if id.length==0
				p "break!!!!!!!!!!"
				break
			end
			clinical_trials.push(ClinicalTrial.new(id, brief_title_JP, condition_JP, sponser_institution, status, link))
		end
	end
end
p clinical_trials.size


#functin for second loop
def trim_tel (num)
	num = num.gsub("\+","")
	num
end
 p "came here"
#second loop - add detail with accessing the link on the each row
for clinical_trial in clinical_trials
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
	p "came here2"
end

p "came here3"
# add a row as heading
clinical_trials.unshift(ClinicalTrial.new_heading)
p "came here4"
p clinical_trials

# -- File I/O
file_strings = ""
for clinical_trial in clinical_trials
	# p clinical_trial
	file_strings += clinical_trial.to_csv
end
File.open(OUTPUT_FILE, 'w:Windows-31J', :invalid=>:replace, :undef=>:replace){|file|
file.write(file_strings)}





