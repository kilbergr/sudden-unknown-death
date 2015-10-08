# require 'rubygems'
require 'pg'
require 'pry'
require 'nokogiri'
require 'typhoeus'
require 'selenium-webdriver'
require 'net/http' 
# so it doesn't timeout
http = Net::HTTP.new(@host, @port)
http.read_timeout = 500


driver = Selenium::WebDriver.for :firefox
def start(driver)
	driver.navigate.to "http://webappa.cdc.gov/sasweb/ncipc/dataRestriction_lcd.html"
	# get to form
	agree = driver.find_element(:class, "button2")
	agree.submit
end
	start(driver)
	# form load
	wait = Selenium::WebDriver::Wait.new(:timeout => 15)
  wait.until {
	    element = driver.find_element(:name, "frmWISQ")
	    element if element.displayed?
	}
	# Number of causes to show will always be 20
	causeNum = driver.find_element(:name, "RANKING")
	causeNumOpt = Selenium::WebDriver::Support::Select.new(causeNum)
	causeNumOpt.select_by(:value, "20")
	# Will always choose the same age segmentation pattern
	driver.find_element(:xpath, "//input[contains (@value, 'lcd3age')]").click


	state = driver.find_element(:name, "State")
	race = driver.find_element(:name, "Race")
	sex = driver.find_element(:name, "Sex")
	year1 = driver.find_element(:name, "year1")
	year2 = driver.find_element(:name, "year2")
	ethnicity = driver.find_element(:name, "Ethnicty")
	request = driver.find_element(:name, "Submit")

def allStates(state, race, sex, ethnicity, year1, year2, request, driver)
# The following don't exist...what to do? 3, 7, 14, 43, 52

	stNum = 8 
	# will stop at 14, since that state is missing. NBD may have some errors anyway
		wait = Selenium::WebDriver::Wait.new(:timeout => 15)
	  wait.until {
		    element = driver.find_element(:name, "frmWISQ")
		    element if element.displayed?
		}
		state = driver.find_element(:name, "State")
		stateOpt = Selenium::WebDriver::Support::Select.new(state)

		if stNum < 10
				chosenSt = stateOpt.select_by(:value, "0"+stNum.to_s)
		else 
				chosenSt = stateOpt.select_by(:value, stNum.to_s)
		end

		# nesting race (leads to nested sex, ethnicity, year choices)
		chooseRace(race, sex, ethnicity, year1, year2, request, driver)

		stNum+=1	 
		# keeping track
		puts "Congrats, made it through all of state corresponding to " + (stNum-1).to_s
		return
	# end
end

def chooseRace(race, sex, ethnicity, year1, year2, request, driver)

	chosenRaceVal = 0
	while chosenRaceVal < 3
		wait = Selenium::WebDriver::Wait.new(:timeout => 15)
	  wait.until {
		    element = driver.find_element(:name, "frmWISQ")
		    element if element.displayed?
		}
		race = driver.find_element(:name, "Race")
		raceOpt = Selenium::WebDriver::Support::Select.new(race)
		raceOpt.select_by(:value, chosenRaceVal.to_s)
		# nesting set sex
		chooseSex(sex, ethnicity, year1, year2, request, driver)
		chosenRaceVal+=1
		puts "Congrats, made it through all races corresponding to " + (chosenRaceVal-1).to_s
	end
end

def chooseSex(sex, ethnicity, year1, year2, request, driver)
	chosenSexVal = 0
	while chosenSexVal < 3
		wait = Selenium::WebDriver::Wait.new(:timeout => 15)
	  wait.until {
		    element = driver.find_element(:name, "frmWISQ")
		    element if element.displayed?
		}
		sex = driver.find_element(:name, "Sex")
		sexOpt = Selenium::WebDriver::Support::Select.new(sex)
		sexOpt.select_by(:value, chosenSexVal.to_s)
		#nesting choose ethnicity
		chooseEth( ethnicity, year1, year2, request, driver)
		chosenSexVal+=1
		puts "Congrats, made it through all sexes corresponding to " + (chosenSexVal-1).to_s
	end
end

def chooseEth(ethnicity, year1, year2, request, driver)
	chosenEthVal = 0
	while chosenEthVal < 3
		wait = Selenium::WebDriver::Wait.new(:timeout => 15)
	  wait.until {
		    element = driver.find_element(:name, "frmWISQ")
		    element if element.displayed?
		}
		ethnicity = driver.find_element(:name, "Ethnicty")
		ethnicityOpt = Selenium::WebDriver::Support::Select.new(ethnicity)
		ethnicityOpt.select_by(:value, chosenEthVal.to_s)
		# nesting set year
		setYear(year1, year2, request, driver)
		chosenEthVal +=1
	end
end

def setYear(year1, year2, request, driver)

	chosenYear = 1999
	while chosenYear < 2014
		wait = Selenium::WebDriver::Wait.new(:timeout => 15)
	  wait.until {
		    element = driver.find_element(:name, "frmWISQ")
		    element if element.displayed?
		}
		request = driver.find_element(:name, "Submit")
		year1 = driver.find_element(:name, "year1")
		year2 = driver.find_element(:name, "year2")
		yearOpt1 = Selenium::WebDriver::Support::Select.new(year1)
		yearOpt2 = Selenium::WebDriver::Support::Select.new(year2)
		yearOpt1.select_by(:value, chosenYear.to_s)
		yearOpt2.select_by(:value, chosenYear.to_s)
		
		submitQ(request, driver)
		chosenYear+=1
	end
end

def submitQ(request, driver)
	request.submit

	find_percentages(driver)

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
	all = driver.find_element(:link, "All Ages")

	eachAge = [youngest, oneFour, fiveNine, tenFourteen, fifteenTwentyfour, twentyfiveThirtyfour, thirtyfiveFortyfour, fortyfiveFiftyfour, fiftyfiveSixtyfour, sixtyfiveSeventyfour, seventyfiveEightyfour, oldest, all]
 	
 	getRes(eachAge)
	
end
def getRes(arr)
	conn = PG.connect(:dbname => 'MortalityApp_development')
	conn.prepare('statement1', 'insert into demographics (state, year, race, sex, ethnicity, age) values ($1, $2, $3, $4, $5, $6)')
	conn.prepare('statement2', 'insert into deaths (cause) values ($1)')
	conn.prepare('statement3', 'insert into figures (number, percent, demographic_id, death_id) values ($1, $2, $3, $4)')
		
	# Finding ids from death and demographic tables to create associations
	conn.prepare('statement4', "select * from deaths where cause LIKE $1")
	conn.prepare('statement5', "select * from demographics where state LIKE $1 AND state NOT LIKE '%South Dakota%' AND age LIKE $2 AND race LIKE $3 AND CAST(year AS text) LIKE $4 AND sex LIKE $5 AND ethnicity LIKE $6 AND ethnicity NOT LIKE $7")
			
	arr.each do |ageGroup|
		response = Nokogiri::HTML(Typhoeus.get(ageGroup.attribute("href")).response_body).children[1].children[7]
		if response.css("table").length == 3
			tabledata = response.css("table")[0].css("tr")
			tablelength = tabledata.length
			# all the demographic info
			demGroup = response.css("p")[0].css("font")[1].text
			# geographic info
			stateName = response.css("p")[0].css("font")[0].text
			whichState = stateName.split(",")[1].lstrip.rstrip
			whichYear = demGroup.split(",")[0].lstrip.rstrip
			whichRace = demGroup.split(",")[1].lstrip.rstrip
			# Accounting for the fact that some include ethnicities, others don't
			if demGroup.split(",").length == 3
				whichAge = demGroup.split(",")[2].split(":")[1].lstrip.rstrip
				l = demGroup.split(",")[2].split(":")[0].length
				whichSex = demGroup.split(",")[2].split(":")[0].slice(0, l-5).lstrip.rstrip	
				whichEthnicity = "All"	
			elsif demGroup.split(",").length == 4
				whichEthnicity = demGroup.split(",")[2].lstrip.rstrip
				whichAge = demGroup.split(",")[3].split(":")[1].lstrip.rstrip
				l = demGroup.split(",")[3].split(":")[0].length
				whichSex = demGroup.split(",")[3].split(":")[0].slice(0, l-5).lstrip.rstrip	
			end
			# Accounting for the blank ages (<1)
			if whichAge == ""
				whichAge = "<1"
			end
			
			begin
				conn.exec_prepared('statement1', [whichState, whichYear, whichRace, whichSex, whichEthnicity, whichAge])	
			rescue PG::Error => e
				puts "another error"
			end
			# starting one below "all deaths"
			j = 2
			while j < tablelength
				cause = tabledata.css("tr")[j].css("td")[0].text.lstrip.rstrip
				# remove commas from numbers
				numArr = tabledata.css("tr")[j].css("td")[1].text.lstrip.rstrip.split(",")
				num = numArr.join("")
				# remove percentage sign
				percent = tabledata.css("tr")[j].css("td")[3].text.lstrip.rstrip	
				percent.slice!(-1)
				# insert cause into death table
				
				begin
					conn.exec_prepared('statement2', [cause])
				rescue PG::Error => e
					puts "error"
				end
				
				cause_res = conn.exec_prepared('statement4', ["%"+ cause + "%"])
				dem_res = conn.exec_prepared('statement5', ["%" + whichState + "%", "%" + whichAge + "%", "%" + whichRace + "%", "%" + whichYear + "%", "%" + whichSex + "%", "%" + whichEthnicity + "%", "%Non-" + whichEthnicity + "%"])
				
				if cause_res.ntuples > 0 && dem_res.ntuples > 0
					cause_id = cause_res[0]['id']
					dem_id = dem_res[0]['id']
					# instances where recordings without numbers/percentages
					if num == "---" || num == "--" || num == "-"
						num = 0
					end
					if percent == "." || percent == ". " || percent == "   . " || percent == "  . "
						percent = 0.0
					end
					conn.exec_prepared('statement3', [num, percent, dem_id, cause_id])
				else 
					puts 'CHECK THIS state: ' + whichState  + ' raised an error on 243'
				end
				j+=1
			end
		end
	end
end 

allStates(state, race, sex, ethnicity, year1, year2, request, driver)
