# -*- coding: utf-8 -*-

class ClinicalTrial
	@@attrs = :name_research_contact_person,:condition_JP, :brief_title_JP,:registered_date, :organization_research_contact_person, :division_research_contact_person, :email_research_contact_person, :tel_research_contact_person,:address_research_contact_person,\
	 :sponser_institute,:official_title_JP,  :region,  :classification_by_speciality, :classification_by_malignancy, :narrative_objectives_JP,\
	 :official_title_EN, :brief_title_EN, :condition_EN, :narrarive_objectives_EN,\
	 :name_public_contact_person, :organization_public_contact_person, :division_public_contact_person, :address_public_contact_person, :tel_public_contact_person, :email_public_contact_person, \
	 :id, :status, :link_for_detail

	attr_accessor *@@attrs 

	@@BASE_URL = "https://upload.umin.ac.jp/cgi-open-bin/ctr"

	def self.new_heading
		p "come here1"
		obj = self.new(nil,nil,nil,nil,nil,nil)
		obj.id = "id"
		obj.brief_title_JP = "brief_title_JP"
		obj.condition_JP = "condition_JP"
		obj.sponser_institute = "sponser_institute"
		obj.status = "status"
		obj.link_for_detail = "link_for_detail"
		obj.official_title_JP = "official_title_JP"
		obj.official_title_EN = "official_title_EN"
		obj.brief_title_EN = "brief_title_EN"
		obj.region = "region"
		obj.condition_EN = "condition_EN"
		obj.classification_by_speciality = "classification_by_speciality"
		obj.classification_by_malignancy = "classification_by_malignancy"
		obj.narrative_objectives_JP = "narrative_objectives_JP"
		obj.narrarive_objectives_EN = "narrarive_objectives_EN"
		obj.name_research_contact_person = "name_research_contact_person"
		obj.organization_research_contact_person = "organization_research_contact_person"
		obj.division_research_contact_person = "division_research_contact_person"
		obj.address_research_contact_person = "address_research_contact_person"
		obj.tel_research_contact_person = "tel_research_contact_person"
		obj.email_research_contact_person = "email_research_contact_person"
		obj.name_public_contact_person = "name_public_contact_person"
		obj.organization_public_contact_person = "organization_public_contact_person"
		obj.division_public_contact_person = "division_public_contact_person"
		obj.address_public_contact_person = "address_public_contact_person"
		obj.tel_public_contact_person = "tel_public_contact_person"
		obj.email_public_contact_person = "email_public_contact_person"
		obj.registered_date = "registered_date"
		return obj
	end

	def initialize (id, brief_title_JP, condition_JP, sponser_institute, status, link_for_detail)
		@id = id if !id.nil? 
		@brief_title_JP = brief_title_JP if !brief_title_JP.nil? 
		@condition_JP = condition_JP if !condition_JP.nil? 
		@sponser_institute = sponser_institute if !sponser_institute.nil? 
		@status = status if !status.nil? 
		@link_for_detail = @@BASE_URL + link_for_detail[1, link_for_detail.length] if !link_for_detail.nil? 
		@registered_date = id[-10,10] if !id.nil? 
	end

	def process_for_csv (str)
		new_str = str.gsub('"','""' )
		new_str = new_str.gsub(/\r\n|\r|\n/, " ")
		'"' + new_str + '"'
	end

	def to_csv
		attrs = @@attrs.map{ |a| process_for_csv("#{send(a)}")}.join(",")
		attrs + "\n"
	end
end