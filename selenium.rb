# require 'rubygems'
require 'selenium-webdriver'

driver = Selenium::WebDriver.for :firefox
driver.navigate.to "http://webappa.cdc.gov/sasweb/ncipc/dataRestriction_lcd.html"
agree = driver.find_element(:class, "button2")

agree.submit
wait = Selenium::WebDriver::Wait.new(:timeout => 15)

form = wait.until {
    element = driver.find_element(:name, "frmWISQ")
    element if element.displayed?
}
if form.displayed?
	state = driver.find_element(:name, "State")
	race = driver.find_element(:name, "Race")
	sex = driver.find_element(:name, "Sex")
	year1 = driver.find_element(:name, "year1")
	year2 = driver.find_element(:name, "year2")
	ethnicity = driver.find_element(:name, "Ethnicty")
	causeNum = driver.find_element(:name, "RANKING")
	# see below for age range selection
	# Number of causes to show will always be 20
	causeNumOpt = Selenium::WebDriver::Support::Select.new(causeNum)
	causeNumOpt.select_by(:value, "20")
	# Will always choose the same age segmentation pattern
	driver.find_element(:xpath, "//input[contains (@value, 'lcd3age')]").click
	

	def allStates(state, race, sex, year1, year2, ethnicity)
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
				chooseRace(race, sex, year1, year2, ethnicity)
				stNum+=1	
			end 
		end
	end

	def chooseRace(race, sex, year1, year2, ethnicity)
		raceOpt = Selenium::WebDriver::Support::Select.new(race)
		chosenRaceVal = 1
		while chosenRaceVal < 6
			raceOpt.select_by(:value, chosenRaceVal.to_s)
			# nesting set sex
			chooseSex(sex, year1, year2, ethnicity)
			chosenRaceVal+=1
		end
	end

	def chooseSex(sex, year1, year2, ethnicity)
		sexOpt = Selenium::WebDriver::Support::Select.new(sex)
		chosenSexVal = 1
		while chosenSexVal < 3
			sexOpt.select_by(:value, chosenSexVal.to_s)
			#nesting choose ethnicity
			chooseEth(year1, year2, ethnicity)
			chosenSexVal+=1
		end
	end
	def chooseEth(year1, year2, ethnicity)
		ethnicityOpt = Selenium::WebDriver::Support::Select.new(ethnicity)
		chosenEthVal = 1
		while chosenEthVal < 3
			ethnicityOpt.select_by(:value, chosenEthVal.to_s)
			# nesting set year
			setYear(year1, year2)
			chosenEthVal +=1
		end
	end

	def setYear(year1, year2)
		yearOpt1 = Selenium::WebDriver::Support::Select.new(year1)
		yearOpt2 = Selenium::WebDriver::Support::Select.new(year2)
		chosenYear = 1999
		while chosenYear < 2014
			yearOpt1.select_by(:value, chosenYear.to_s)
			yearOpt2.select_by(:value, chosenYear.to_s)
			# submitQ()
			chosenYear+=1
		end
	end
	
	def submitQ()
		request = driver.find_element(:name, "Submit")
		request.submit
	end

	allStates(state, race, sex, year1, year2, ethnicity)
	
	
	# raceOpt = Selenium::WebDriver::Support::Select.new(race)
	# raceOpt.select_by(:value, "1")
	# sexOpt = Selenium::WebDriver::Support::Select.new(sex)
	# sexOpt.select_by(:value, "1")
	# yearOpt1 = Selenium::WebDriver::Support::Select.new(year1)
	# yearOpt1.select_by(:value, "1999")
	# yearOpt2 = Selenium::WebDriver::Support::Select.new(year2)
	# yearOpt2.select_by(:value, "1999")

download = driver.find_element(:link, "Download Results in a Spreadsheet (CSV) File").click

end