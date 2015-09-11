# require 'rubygems'
require 'pry'
require 'nokogiri'
require 'typhoeus'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://webappa.cdc.gov/sasweb/ncipc/dataRestriction_lcd.html"
# get to form
agree = driver.find_element(:class, "button2")
agree.submit
# form load

wait = Selenium::WebDriver::Wait.new(:timeout => 15)
form = wait.until {
    element = driver.find_element(:name, "frmWISQ")
    element if element.displayed?
}
# once form available, find all
if form.displayed?
	state = driver.find_element(:name, "State")
	race = driver.find_element(:name, "Race")
	sex = driver.find_element(:name, "Sex")
	year1 = driver.find_element(:name, "year1")
	year2 = driver.find_element(:name, "year2")
	ethnicity = driver.find_element(:name, "Ethnicty")
	causeNum = driver.find_element(:name, "RANKING")
	request = driver.find_element(:name, "Submit")
	# see below for age range selection
	# Number of causes to show will always be 20
	causeNumOpt = Selenium::WebDriver::Support::Select.new(causeNum)
	causeNumOpt.select_by(:value, "20")
	# Will always choose the same age segmentation pattern
	driver.find_element(:xpath, "//input[contains (@value, 'lcd3age')]").click
	

	def allStates(state, race, sex, ethnicity, year1, year2, request, driver)
		stateOpt = Selenium::WebDriver::Support::Select.new(state)
		stNum = 1
		until stNum == 57
			if stNum < 10
				chosenSt = stateOpt.select_by(:value, "0"+stNum.to_s)
			else 
				chosenSt = stateOpt.select_by(:value, stNum.to_s)
			end

			if chosenSt.nil?
				stNum+=1
			else
				# nesting race (leads to nested sex, ethnicity, year choices)
				chooseRace(state, race, sex, ethnicity, year1, year2, request, driver)
				stNum+=1	
			end 
		end
	end

	def chooseRace(state, race, sex, ethnicity, year1, year2, request, driver)
		raceOpt = Selenium::WebDriver::Support::Select.new(race)
		chosenRaceVal = 1
		while chosenRaceVal < 6
			raceOpt.select_by(:value, chosenRaceVal.to_s)
			# nesting set sex
			chooseSex(state, race, sex, ethnicity, year1, year2, request, driver)
			chosenRaceVal+=1
		end
	end

	def chooseSex(state, race, sex, ethnicity, year1, year2, request, driver)
		sexOpt = Selenium::WebDriver::Support::Select.new(sex)
		chosenSexVal = 1
		while chosenSexVal < 3
			sexOpt.select_by(:value, chosenSexVal.to_s)
			#nesting choose ethnicity
			chooseEth(state, race, sex, ethnicity, year1, year2, request, driver)
			chosenSexVal+=1
		end
	end
	def chooseEth(state, race, sex, ethnicity, year1, year2, request, driver)
		ethnicityOpt = Selenium::WebDriver::Support::Select.new(ethnicity)
		chosenEthVal = 1
		while chosenEthVal < 3
			ethnicityOpt.select_by(:value, chosenEthVal.to_s)
			# nesting set year
			setYear(state, race, sex, ethnicity, year1, year2, request, driver)
			chosenEthVal +=1
		end
	end

	def setYear(state, race, sex, ethnicity, year1, year2, request, driver)
		yearOpt1 = Selenium::WebDriver::Support::Select.new(year1)
		yearOpt2 = Selenium::WebDriver::Support::Select.new(year2)
		chosenYear = 1999
		while chosenYear < 2014
			yearOpt1.select_by(:value, chosenYear.to_s)
			yearOpt2.select_by(:value, chosenYear.to_s)
			submitQ(state, race, sex, ethnicity, year1, year2, request, driver)
			chosenYear+=1
		end
	end
	
	def submitQ(state, race, sex, ethnicity, year1, year2, request, driver)
		request.submit
		find_percentages(driver)
		# download = driver.find_element(:link, "Download Results in a Spreadsheet (CSV) File")
		driver.navigate().back();
	end
	def find_percentages(driver)
		youngest = driver.find_element(:link, "<1")
		oneFour = driver.find_element(:link, "1-4")
		fiveNine = driver.find_element(:link, "5-9")
		tenFourteen = driver.find_element(:link, "10-14")
		fifteenTwentyfour = driver.find_element(:link, "15-24")
		twentyfiveThirtyfour = driver.find_element(:link, "25-34")
		thirtyfiveFortyfour = driver.find_element(:link, "35-44")
		fortyfiveFiftyfour = driver.find_element(:link, "45-54")
		fiftyfiveSixtyfour = driver.find_element(:link, "55-64")
		sixtyfiveSeventyfour = driver.find_element(:link, "65-74")
		seventyfiveEightyfour = driver.find_element(:link, "75-84")
		oldest = driver.find_element(:link, "85+")
		eachAge = [youngest, oneFour, fiveNine, tenFourteen, fifteenTwentyfour, twentyfiveThirtyfour, thirtyfiveFortyfour, fortyfiveFiftyfour, fiftyfiveSixtyfour, sixtyfiveSeventyfour, seventyfiveEightyfour, oldest]

		eachAge.each do |ageGroup|
			response = Nokogiri::HTML(Typhoeus.get(ageGroup.attribute("href")).response_body).children[1].children[7]
			p response
		end 
		# Need to save up to youngestRes.children[1].children[7] because that's where they diverge
		# ytext = youngestRes.children[1].children[7].children[3].children[10].children[5].children[0].children.children.text
		# ypercent = youngestRes.children[1].children[7].children[3].children[10].children[5].children[3].children.children[2].text
		
	 driver.navigate().back();


	end

	allStates(state, race, sex, ethnicity, year1, year2, request, driver)

	
	# raceOpt = Selenium::WebDriver::Support::Select.new(race)
	# raceOpt.select_by(:value, "1")
	# sexOpt = Selenium::WebDriver::Support::Select.new(sex)
	# sexOpt.select_by(:value, "1")
	# yearOpt1 = Selenium::WebDriver::Support::Select.new(year1)
	# yearOpt1.select_by(:value, "1999")
	# yearOpt2 = Selenium::WebDriver::Support::Select.new(year2)
	# yearOpt2.select_by(:value, "1999")
end
