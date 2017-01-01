require 'rmagick'
require 'rspec/expectations'

RSpec::Matchers.define :be_similar_to_file do |dst_file|
  match do |src_base64|
    src_img = Magick::Image.read_inline(src_base64)
    dst_img = Magick::Image.read(dst_file)
    @diff_img, @diff_metric = src_img[0].compare_channel(dst_img[0], Magick::MeanSquaredErrorMetric)
    @diff_metric <= @mse.to_f
  end

  chain :with_mse_less_then do |mse|
    @mse = mse
  end

  failure_message_for_should do |actual|
    "expected that mse #{@diff_metric} would be less or equal #{@mse.to_f}"
  end
end