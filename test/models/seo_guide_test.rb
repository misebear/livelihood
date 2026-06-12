# frozen_string_literal: true

require "test_helper"

class SeoGuideTest < ActiveSupport::TestCase
  test "guides have unique slugs and enough content for public landing pages" do
    slugs = SeoGuide.all.map(&:slug)

    assert_equal slugs.uniq, slugs
    assert_operator SeoGuide.all.size, :>=, 11
    SeoGuide.all.each do |guide|
      assert_operator guide.sections.size, :>=, 2
      assert_operator guide.faqs.size, :>=, 3
      assert guide.meta_description.length >= 45
    end
  end
end
