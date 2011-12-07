# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Browser" do

  describe "#exists?" do
    it "returns true if we are at a page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.should exist
    end

    not_compliant_on(:safariwatir) do
      it "returns false after Browser#close" do
        b = WatirSpec.new_browser
        b.close
        b.should_not exist
      end
    end
  end

  # this should be rewritten - the actual string returned varies alot between implementations
  describe "#html" do
    not_compliant_on :ie do
      it "returns the DOM of the page as an HTML string" do
        browser.goto(WatirSpec.files + "/right_click.html")
        html = browser.html.downcase # varies between browsers

        html.should =~ /^<html/
        html.should include('<meta ')
        html.should include(' content="text/html; charset=utf-8"')
        html.should include(' http-equiv="content-type"')
      end
    end

    deviates_on :ie do
      it "returns the DOM of the page as an HTML string" do
        browser.goto(WatirSpec.files + "/right_click.html")
        html = browser.html.downcase # varies between browsers

        html.should =~ /^<html/
        html.should include('<meta content="text/html; charset=utf-8" http-equiv=content-type>')
      end
    end
  end

  describe "#title" do
    it "returns the current page title" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.title.should == "Non-control elements"
    end
  end

  describe "#status" do
    # for firefox, this needs to be enabled in
    # Preferences -> Content -> Advanced -> Change status bar text
    #
    not_compliant_on [:webdriver, :firefox] do 
      it "returns the current value of window.status" do
        browser.goto(WatirSpec.files + "/non_control_elements.html")

        browser.execute_script "window.status = 'All done!';"
        browser.status.should == "All done!"
      end
    end
  end

  describe "#text" do
    it "returns the text of the page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.text.should include("Dubito, ergo cogito, ergo sum.")
    end

    it "returns the text also if the content-type is text/plain" do
      # more specs for text/plain? what happens if we call other methods?
      browser.goto(WatirSpec.host + "/plain_text")
      browser.text.strip.should == 'This is text/plain'
    end
  end

  describe "#url" do
    it "returns the current url" do
      browser.goto(WatirSpec.host + "/non_control_elements.html")
      browser.url.should == WatirSpec.host + "/non_control_elements.html"
    end
  end

  describe ".start" do
    not_compliant_on(:webdriver, :safariwatir) {
      it "goes to the given URL and return an instance of itself" do
        browser = WatirSpec.implementation.browser_class.start("#{WatirSpec.files}/non_control_elements.html")

        browser.should be_instance_of(WatirSpec.implementation.browser_class)
        browser.title.should == "Non-control elements"
        browser.close
      end
    }

    # we need to specify what browser to use
    deviates_on(:webdriver) {
      it "goes to the given URL and return an instance of itself" do
        driver = (ENV['WATIR_WEBDRIVER_BROWSER'] || :firefox).to_sym
        browser = Watir::Browser.start("#{WatirSpec.files}/non_control_elements.html", driver)

        browser.should be_instance_of(Watir::Browser)
        browser.title.should == "Non-control elements"
        browser.close
      end
    }
  end

  describe "#goto" do
    it "adds http:// to URLs with no URL scheme specified" do
      url = WatirSpec.host[%r{http://(.*)}, 1]
      url.should_not be_nil
      browser.goto(url)
      browser.url.should =~ %r[http://#{url}/?]
    end

    it "goes to the given url without raising errors" do
      lambda { browser.goto(WatirSpec.files + "/non_control_elements.html") }.should_not raise_error
    end

    it "goes to the url 'about:blank' without raising errors" do
      lambda { browser.goto("about:blank") }.should_not raise_error
    end

    not_compliant_on :ie do
      it "goes to a data URL scheme address without raising errors" do
        lambda { browser.goto("data:text/html;content-type=utf-8,foobar") }.should_not raise_error
      end
    end

    compliant_on :firefox do
      it "goes to internal Firefox URL 'about:mozilla' without raising errors" do
        lambda { browser.goto("about:mozilla") }.should_not raise_error
      end
    end

    compliant_on :opera do
      it "goes to internal Opera URL 'opera:config' without raising errors" do
        lambda { browser.goto("opera:config") }.should_not raise_error
      end
    end

    compliant_on :chrome do
      it "goes to internal Chrome URL 'chrome://settings/browser' without raising errors" do
        lambda { browser.goto("chrome://settings/browser") }.should_not raise_error
      end
    end

    it "updates the page when location is changed with setTimeout + window.location" do
      browser.goto(WatirSpec.files + "/timeout_window_location.html")
      sleep 1
      browser.url.should include("non_control_elements.html")
    end
  end

  describe "#refresh" do
    it "refreshes the page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.span(:class, 'footer').click
      browser.span(:class, 'footer').text.should include('Javascript')
      browser.refresh
      browser.span(:class, 'footer').text.should_not include('Javascript')
    end
  end

  describe "#execute_script" do
    it "executes the given JavaScript on the current page" do
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      browser.pre(:id, 'rspec').text.should_not == "javascript text"
      browser.execute_script("document.getElementById('rspec').innerHTML = 'javascript text'")
      browser.pre(:id, 'rspec').text.should == "javascript text"
    end
    it "should return value after executing the script" do
      browser.execute_script("2+2").to_i.should == 4
      browser.execute_script("null").should == nil
    end
  end

  describe "#back and #forward" do
    it "goes to the previous page" do
      browser.goto("#{WatirSpec.host}/non_control_elements.html")
      orig_url = browser.url
      browser.goto("#{WatirSpec.host}/tables.html")
      new_url = browser.url
      orig_url.should_not == new_url
      browser.back
      orig_url.should == browser.url
    end

    it "goes to the next page" do
      urls = []
      browser.goto(WatirSpec.host + "/non_control_elements.html")
      urls << browser.url
      browser.goto(WatirSpec.host + "/tables.html")
      urls << browser.url

      browser.back
      browser.url.should == urls.first
      browser.forward
      browser.url.should == urls.last
    end

    it "navigates between several history items" do
      urls = [ "#{WatirSpec.host}/non_control_elements.html",
               "#{WatirSpec.host}/tables.html",
               "#{WatirSpec.host}/forms_with_input_elements.html",
               "#{WatirSpec.host}/definition_lists.html"
      ].map do |page|
        browser.goto page
        browser.url
      end

      3.times { browser.back }
      browser.url.should == urls.first
      2.times { browser.forward }
      browser.url.should == urls[2]
    end
  end

  not_compliant_on :watir do
    describe "#element_by_xpath" do
      before :each do
        browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
      end

      it "finds submit buttons matching the given xpath" do
        browser.element_by_xpath("//input[@type='submit']").should exist
      end

      it "finds reset buttons matching the given xpath" do
        browser.element_by_xpath("//input[@type='reset']").should exist
      end

      it "finds image buttons matching the given xpath" do
        browser.element_by_xpath("//input[@type='image']").should exist
      end

      it "finds the element matching the given xpath" do
        browser.element_by_xpath("//input[@type='password']").should exist
      end

      it "will not find elements that doesn't exist" do
        e = browser.element_by_xpath("//input[@type='foobar']")
        e.should_not exist
        lambda { e.text }.should raise_error(UnknownObjectException)
      end
    end

    describe "#elements_by_xpath" do
      before :each do
        browser.goto(WatirSpec.files + "/forms_with_input_elements.html")
      end

      not_compliant_on [:webdriver, :ie], :celerity do
        it "returns an Array of matching elements" do
          objects = browser.elements_by_xpath("//*[@type='text']")
          objects.should be_kind_of(Array)

          objects.size.should == 5
        end
      end

      deviates_on [:webdriver, :ie], :celerity do
        it "returns an Array of matching elements" do
          objects = browser.elements_by_xpath("//*[@type='text']")
          objects.should be_kind_of(Array)

          objects.size.should == 6
        end
      end

      it "returns an empty Array if there are no matching elements" do
        objects = browser.elements_by_xpath("//*[@type='foobar']")
        objects.should be_kind_of(Array)
        objects.size.should == 0
      end
    end
  end

  describe "#add_checker" do
    it "raises ArgumentError when not given any arguments" do
      lambda { browser.add_checker }.should raise_error(ArgumentError)
    end

    it "runs the given proc on each page load" do
      output = ''
      proc = Proc.new { |browser| output << browser.text }

      begin
        browser.add_checker(proc)
        browser.goto(WatirSpec.files + "/non_control_elements.html")

        output.should include('Dubito, ergo cogito, ergo sum')
      ensure
        browser.disable_checker(proc)
      end
    end
  end

  describe "#disable_checker" do
    it "removes a previously added checker" do
      output = ''
      checker = lambda { |browser| output << browser.text }

      browser.add_checker(checker)
      browser.goto(WatirSpec.files + "/non_control_elements.html")
      output.should include('Dubito, ergo cogito, ergo sum')

      browser.disable_checker(checker)
      browser.goto(WatirSpec.files + "/definition_lists.html")
      output.should_not include('definition_lists')
    end
  end

  it "raises UnknownObjectException when trying to access DOM elements on plain/text-page" do
    browser.goto(WatirSpec.host + "/plain_text")
    lambda { browser.div(:id, 'foo').id }.should raise_error(UnknownObjectException)
  end

end
