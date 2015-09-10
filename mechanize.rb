require 'mechanize'

agent = Mechanize.new { |agent| 
	agent.user_agent_alias = 'Windows Chrome'
}
page = agent.get("http://webappa.cdc.gov/sasweb/ncipc/dataRestriction_lcd.html")

# page = agent.get("http://webappa.cdc.gov/sasweb/ncipc/dataRestriction_lcd.html")
# # pp page
 forms = agent.page.forms_with(:name=>nil)
 form = forms[1]
page = agent.submit(form)
sleep(5)
# pp page
form = page.form_with(:name=>"frmWISQ")
# page = agent.get("http://webappa.cdc.gov/sasweb/ncipc/leadcaus10_us.html")
# form = agent.page.form_with(:name=>"frmWISQ")

pp form
pp form.fields
# WISQ = agent.page.form_with(:name=>"frmWISQ")
# puts WISQ['State']
# # pp WISQ
# state = WISQ.field_with(:name=>"State")
# pp state.options[00]

# button = page.button_with(:name => "action")
# click_button(button)
# puts button

# page = button.submit(form, button)

# CDC_Search = "http://webappa.cdc.gov/sasweb/ncipc
# /leadcaus10_us.html"

# form = page.forms.first
# puts form

