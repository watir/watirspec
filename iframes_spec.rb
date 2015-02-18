# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "IFrames" do

  before :each do
    browser.goto(WatirSpec.url_for("iframes.html"))
  end

  bug "http://github.com/jarib/celerity/issues#issue/25", :celerity do
    describe "with selectors" do
      it "returns the matching elements" do
        expect(browser.iframes(:id => "iframe_2").to_a).to eq [browser.iframe(:id => "iframe_2")]
      end
    end
  end

  describe "eql?" do
    it "matches equality of iframe with that from a collection" do
      expect(browser.iframes.last).to eq browser.iframe(:id => "iframe_2")
    end

  end

  describe "#length" do
    it "returns the correct number of iframes" do
      expect(browser.iframes.length).to eq 2
    end
  end

  describe "#[]" do
    it "returns the iframe at the given index" do
      expect(browser.iframes[0].id).to eq "iframe_1"
    end

    it "handles race conditions" do
      iframes_list = browser.iframes

      # Simulates a race condition where the first collection call returns fewer than actual number of iframes
      # If all_elements is called before elements, it is possible for the matching elements to have more iframes than
      # the total number of iframes, which results in setting an iframe with an index of nil

      # This test fails if all_elements is called first and separately mocked out with this strategy
      allow(iframes_list).to receive(:elements) do
        @elements = ElementLocator.new(
            browser.driver,
            {tag_name: 'iframe'},
            IFrame.attribute_list
        ).locate_all[0, 1]
      end
      expect {iframes_list.find { |iframe| iframe.id == "iframe_2"}}.to_not raise_exception(TypeError)
    end
  end

  describe "#each" do
    it "iterates through frames correctly" do
      count = 0

      browser.iframes.each_with_index do |f, index|
        expect(f.name).to eq browser.iframe(:index, index).name
        expect(f.id).to eq browser.iframe(:index, index).id
        count += 1
      end

      expect(count).to be > 0
    end
  end
end
