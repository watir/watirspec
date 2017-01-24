# encoding: utf-8
require File.expand_path("../spec_helper", __FILE__)

describe "Nesting Elements" do
  before :each do
    browser.goto(WatirSpec.url_for("nested_elements.html", :needs_server => true))
  end

  let(:el_collect) { browser.body.divs.first.div }
  let(:frame) { browser.body.iframe.div }
  let(:fr_collect) { browser.body.iframes.first.div }

  let(:el_collect_frame) { browser.body.divs.first.iframe.div }
  let(:el_collect_fr_collect) { browser.body.divs.first.iframes.first.div }
  let(:frame_el_collect) { browser.body.iframe.divs.first.div }
  let(:frame_fr_collect) { browser.body.iframe.iframes.first.div }
  let(:fr_collect_el_collect) { browser.body.iframes.first.divs.first.div }
  let(:fr_collect_frame) { browser.body.iframes.first.iframe.div }

  let(:element_1) { browser.body.divs.first.iframe.iframes.first.div }
  let(:element_2) { browser.body.divs.last.iframe.iframes.first.div }
  let(:element_3) { browser.body.divs.first.iframes.first.iframe.div }
  let(:element_4) { browser.body.divs.last.iframes.first.iframe.div }
  let(:element_5) { browser.body.iframe.divs.first.iframes.first.div }
  let(:element_6) { browser.body.iframe.divs.last.iframes.first.div }
  let(:element_7) { browser.body.iframe.iframes.first.divs.first.div }
  let(:element_8) { browser.body.iframe.iframes.last.divs.first.div }
  let(:element_9) { browser.body.iframes.first.divs.first.iframe.div }
  let(:element_10) { browser.body.iframes.last.divs.first.iframe.div }
  let(:element_11) { browser.body.iframes.first.iframe.divs.first.div }
  let(:element_12) { browser.body.iframes.last.iframe.divs.first.div }

  context "Exists when evaluated separately" do

    context "Fails before commit bb1e446" do
      it "Element 1" do
        expect(element_1.exists?).to be true
      end

      it "Element 2" do
        expect(element_2.exists?).to be true
      end

      it "Element 3" do
        expect(element_3.exists?).to be true
      end

      it "Element 4" do
        expect(element_4.exists?).to be true
      end
    end

    context "Always passes" do

      it "Element Collection Exists" do
        expect(el_collect).to exist
      end

      it "Frame Exists" do
        expect(frame).to exist
      end

      it "Frame Collection Exists" do
        expect(fr_collect).to exist
      end

      it "Element Collection with Frame Exists" do
        expect(el_collect_frame).to exist
      end

      it "Element Collection with Frame Collection Exists" do
        expect(el_collect_fr_collect).to exist
      end

      it "Frame with Element Collection Exists" do
        expect(frame_el_collect).to exist
      end

      it "Frame with Frame Collection Exists" do
        expect(frame_fr_collect).to exist
      end

      it "Frame Collection with Element Collection Exists" do
        expect(fr_collect_el_collect).to exist
      end

      it "Frame Collection with Frame Exists" do
        expect(fr_collect_frame).to exist
      end

      it "Element 5" do
        expect(element_5).to exist
      end

      it "Element 6" do
        expect(element_6).to exist
      end

      it "Element 7" do
        expect(element_7).to exist
      end

      it "Element 8" do
        expect(element_8).to exist
      end

      it "Element 9" do
        expect(element_9).to exist
      end

      it "Element 10" do
        expect(element_10).to exist
      end

      it "Element 11" do
        expect(element_11).to exist
      end

      it "Element 12" do
        expect(element_12).to exist
      end
    end
  end

  context "Present when evaluated separately" do

    it "Element Collection Present" do
      expect(el_collect.present?).to be true
    end

    it "Frame Present" do
      expect(frame.present?).to be true
    end

    it "Frame Collection Present" do
      expect(fr_collect.present?).to be true
    end

    it "Element Collection with Frame Present" do
      expect(el_collect_frame.present?).to be true
    end

    it "Element Collection with Frame Collection Present" do
      expect(el_collect_fr_collect.present?).to be true
    end

    it "Frame with Element Collection Present" do
      expect(frame_el_collect.present?).to be true
    end

    it "Frame with Frame Collection Present" do
      expect(frame_fr_collect.present?).to be true
    end

    it "Frame Collection with Element Collection Present" do
      expect(fr_collect_el_collect.present?).to be true
    end

    it "Frame Collection with Frame Present" do
      expect(fr_collect_frame.present?).to be true
    end


    it "Element 1" do
      expect(element_1.present?).to be true
    end

    it "Element 2" do
      expect(element_2.present?).to be true
    end

    it "Element 3" do
      expect(element_3.present?).to be true
    end

    it "Element 4" do
      expect(element_4.present?).to be true
    end

    it "Element 5" do
      expect(element_5.present?).to be true
    end

    it "Element 6" do
      expect(element_6.present?).to be true
    end

    it "Element 7" do
      expect(element_7.present?).to be true
    end

    it "Element 8" do
      expect(element_8.present?).to be true
    end

    it "Element 9" do
      expect(element_9.present?).to be true
    end

    it "Element 10" do
      expect(element_10.present?).to be true
    end

    it "Element 11" do
      expect(element_11.present?).to be true
    end

    it "Element 12" do
      expect(element_12.present?).to be true
    end
  end

  context "Exists when switching browsing contexts" do
    it "Element 1 to Element 2" do
      expect(element_1 == element_2).to be false
      expect(element_1).to exist
      expect(element_2).to exist
    end

    it "Element 3 to Element 4" do
      expect(element_3 == element_4).to be false
      expect(element_3).to exist
      expect(element_4).to exist
    end

    it "Element 5 to Element 6" do
      expect(element_5 == element_6).to be false
      expect(element_5).to exist
      expect(element_6).to exist
    end

    it "Element 7 to Element 8" do
      expect(element_7 == element_8).to be false
      expect(element_7).to exist
      expect(element_8).to exist
    end

    it "Element 9 to Element 10" do
      expect(element_9 == element_10).to be false
      expect(element_9).to exist
      expect(element_10).to exist
    end

    it "Element 11 to Element 12" do
      expect(element_11 == element_12).to be false
      expect(element_11).to exist
      expect(element_12).to exist
    end
  end

  context "Exists when looping" do
    it "over a collection of divs" do
      expect {
        browser.body.divs.find { |div| div.iframe(id: "not_here").exists? }
      }.to_not raise_error
    end
  end

end
