require File.expand_path("../spec_helper", __FILE__)

module Watir
  describe '#relaxed_locate?' do
    not_compliant_on :not_relaxed_locate do
      context 'when true' do
        before :each do
          browser.goto(WatirSpec.url_for("wait.html"))
        end

        context 'when acting on an element that is never present' do
          it 'raises exception after timing out' do
            begin
              time_out = 2
              Watir.default_timeout = time_out
              element = browser.link(id: 'not_there')
              start_time = ::Time.now
              expect { element.click }.to raise_exception(Exception::UnknownObjectException)
              expect(::Time.now - start_time).to be > time_out
            ensure
              Watir.default_timeout = 30
            end
          end
        end

        context 'when acting on an element that is already present' do
          it 'does not wait' do
            start_time = ::Time.now
            expect { browser.link.click }.to_not raise_exception
            expect(::Time.now - start_time).to be < 1
          end
        end

        context 'when acting on an element that eventually becomes present' do
          it 'waits to take action' do
            start_time = ::Time.now
            browser.a(id: 'show_bar').click
            expect { browser.div(id: 'bar').click }.to_not raise_exception
            expect(::Time.now - start_time).to be < Watir.default_timeout
          end
        end

        context 'when evaluating order of failure precedence' do
          it 'fails first for parent not existing' do
            begin
              Watir.default_timeout = 0
              selector = "{:id=>\"no_parent\", :tag_name=>\"div\"}"
              element = browser.div(id: 'no_parent').div(id: 'no_child')
              error = Watir::Exception::UnknownObjectException
              message = "timed out after #{Watir.default_timeout} seconds, waiting for #{selector} to be located"
              expect { element.click }.to raise_exception(error, message)
            ensure
              Watir.default_timeout = 30
            end
          end

          it 'fails for child not existing if parent exists' do
            begin
              Watir.default_timeout = 0
              selector = "{:id=>\"buttons\", :tag_name=>\"div\"} --> {:id=>\"no_child\", :tag_name=>\"div\"}"
              element = browser.div(id: 'buttons').div(id: 'no_child')
              error = Watir::Exception::UnknownObjectException
              message = "timed out after #{Watir.default_timeout} seconds, waiting for #{selector} to be located"
              expect { element.click }.to raise_exception(error, message)
            ensure
              Watir.default_timeout = 30
            end
          end

          it 'fails for parent not present if child exists' do
            begin
              Watir.default_timeout = 0.5
              selector = "{:id=>\"also_hidden\", :tag_name=>\"div\"}"
              element = browser.div(id: 'also_hidden').div(id: 'hidden_child')
              error = Watir::Exception::UnknownObjectException
              message = "element located, but timed out after #{Watir.default_timeout} seconds, waiting for true condition on #{selector}"
              expect { element.click }.to raise_exception(error, message)
            ensure
              Watir.default_timeout = 30
            end
          end

          it 'fails for child not present if parent is present' do
            begin
              Watir.default_timeout = 0.5
              selector = "{:id=>\"buttons\", :tag_name=>\"div\"} --> {:id=>\"btn2\", :tag_name=>\"button\"}"
              element = browser.div(id: 'buttons').button(id: 'btn2')
              error = Watir::Exception::UnknownObjectException
              message = "element located, but timed out after #{Watir.default_timeout} seconds, waiting for true condition on #{selector}"
              expect { element.click }.to raise_exception(error, message)
            ensure
              Watir.default_timeout = 30
            end
          end

          it 'fails for element not enabled if present' do
            browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
            begin
              Watir.default_timeout = 0.5
              selector = "{:id=>\"new_user\", :tag_name=>\"form\"} --> {:id=>\"good_luck\", :tag_name=>\"input or textarea\", :type=>\"(any text type)\"}"
              element = browser.form(id: 'new_user').text_field(id: 'good_luck')
              error = Watir::Exception::ObjectDisabledException
              message = "element present, but timed out after #{Watir.default_timeout} seconds, waiting for #{selector} to be enabled"
              expect { element.set('foo') }.to raise_exception(error, message)
            ensure
              Watir.default_timeout = 30
            end
          end

          it 'fails for element being readonly if enabled' do
            browser.goto(WatirSpec.url_for("forms_with_input_elements.html"))
            begin
              Watir.default_timeout = 0.5
              selector = "{:id=>\"new_user\", :tag_name=>\"form\"} --> {:id=>\"new_user_code\", :tag_name=>\"input or textarea\", :type=>\"(any text type)\"}"
              element = browser.form(id: 'new_user').text_field(id: 'new_user_code')
              error = Watir::Exception::ObjectReadOnlyException
              message = "element present and enabled, but timed out after #{Watir.default_timeout} seconds, waiting for #{selector} to not be readonly"
              expect { element.set('foo') }.to raise_exception(error, message)
            ensure
              Watir.default_timeout = 30
            end
          end
        end

        it 'gives warning when rescuing for flow control' do
          begin
            Watir.default_timeout = 1
            element = browser.link(id: 'not_there')
            message = "This test has slept for the duration of the default timeout. If your test is passing, consider using Element#exists? instead of rescuing this error\n"
            expect do
              begin
                element.click
              rescue Exception::UnknownObjectException
              end
            end.to output(message).to_stderr
          ensure
            Watir.default_timeout = 30
          end
        end

        it 'ensures all checks happen once even if time has expired' do
          begin
            Watir.default_timeout = -1
            expect { browser.link.click }.to_not raise_exception
          ensure
            Watir.default_timeout = 30
          end
        end

        it 'ensures that the same timeout is used for all of the calls' do
          begin
            Watir.default_timeout = 1
            start_time = ::Time.now
            browser.a(id: 'show_bar').click
            expect { browser.div(id: 'bar').div(id: 'not_there').click }.to raise_exception
            finish_time = ::Time.now - start_time
            expect(finish_time).to be > Watir.default_timeout
            expect(finish_time).to be < 2 * Watir.default_timeout
          ensure
            Watir.default_timeout = 30
          end
        end
      end
    end

    not_compliant_on :relaxed_locate do
      context 'when false' do
        before :each do
          browser.goto(WatirSpec.url_for("wait.html"))
        end

        context 'when acting on an element that is never present' do
          it 'raises exception immediately' do
            begin
              time_out = 2
              Watir.default_timeout = time_out
              element = browser.link(id: 'not_there')
              start_time = ::Time.now
              expect { element.click }.to raise_exception(Exception::UnknownObjectException)
              expect(::Time.now - start_time).to be < 1
            ensure
              Watir.default_timeout = 30
            end
          end
        end

        context 'when acting on an element that eventually becomes present' do
          it 'raises exception immediately' do
            start_time = ::Time.now
            browser.a(id: 'show_bar').click
            expect { browser.div(id: 'bar').click }.to raise_exception(Selenium::WebDriver::Error::ElementNotVisibleError)
            expect(::Time.now - start_time).to be < 1
          end
        end

        it 'receives a warning for using #when_present' do
          message = /#when_present would likely be unnecessary if Watir#relaxed_locate\? were set to true/
          browser.a(id: 'show_bar').click
          expect do
            browser.div(id: 'bar').when_present.click
          end.to output(message).to_stderr
        end
      end
    end
  end
end
