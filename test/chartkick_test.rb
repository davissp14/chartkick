require_relative "test_helper"

class ChartkickTest < Minitest::Test
  include Chartkick::Helper

  def setup
    @data = [[34, 42], [56, 49]]
    @content_for = {}
  end

  def test_line_chart
    assert_chart line_chart(@data)
  end

  def test_pie_chart
    assert_chart pie_chart(@data)
  end

  def test_column_chart
    assert_chart column_chart(@data)
  end

  def test_bar_chart
    assert_chart column_chart(@data)
  end

  def test_area_chart
    assert_chart area_chart(@data)
  end

  def test_scatter_chart
    assert_chart scatter_chart(@data)
  end

  def test_geo_chart
    assert_chart geo_chart(@data)
  end

  def test_timeline
    assert_chart timeline(@data)
  end

  def test_escape_data
    bad_data = "</script><script>alert('xss')</script>"
    assert_includes column_chart(bad_data), "\\u003cscript\\u003e"
    refute_includes column_chart(bad_data), "<script>"
  end

  def test_escape_options
    bad_options = {xss: "</script><script>alert('xss')</script>"}
    assert_includes column_chart([], **bad_options), "\\u003cscript\\u003e"
    refute_includes column_chart([], **bad_options), "<script>"
  end

  def test_options_not_mutated
    options = {id: "boom"}
    line_chart @data, **options
    assert_equal "boom", options[:id]
  end

  def test_chartkick_deep_merge_different_inner_key
    global_option = {library: {backgroundColor: "#eee"}}
    local_option = {library: {title: "test"}}
    correct_merge = {library: {backgroundColor: "#eee", title: "test"}}
    assert_equal chartkick_deep_merge(global_option, local_option), correct_merge
  end

  def test_chartkick_deep_merge_same_inner_key
    global_option = {library: {backgroundColor: "#eee"}}
    local_option = {library: {backgroundColor: "#fff"}}
    correct_merge = {library: {backgroundColor: "#fff"}}
    assert_equal chartkick_deep_merge(global_option, local_option), correct_merge
  end

  def test_id
    assert_match "id=\"test-id\"", line_chart(@data, id: "test-id")
  end

  def test_id_escaped
    assert_match "id=\"test-123&quot;\"", line_chart(@data, id: "test-123\"")
  end

  def test_height
    assert_match "height: 150px;", line_chart(@data, height: "150px")
  end

  def test_height_escaped
    assert_match "height: 150px&quot;;", line_chart(@data, height: "150px\"")
  end

  def test_width
    assert_match "width: 80%;", line_chart(@data, width: "80%")
  end

  def test_width_escaped
    assert_match "width: 80%&quot;;", line_chart(@data, width: "80%\"")
  end

  def test_nonce
    assert_match "nonce=\"test-123\"", line_chart(@data, nonce: "test-123")
  end

  def test_nonce_escaped
    assert_match "nonce=\"test-123&quot;\"", line_chart(@data, nonce: "test-123\"")
  end

  def test_defer
    assert_match "window.addEventListener", line_chart(@data, defer: true)
  end

  def test_content_for
    refute_match "<script", line_chart(@data, content_for: :charts_js)
    assert_match "<script", @content_for[:charts_js]
  end

  def test_default_options
    Chartkick.options = {id: "test-123"}
    assert_match "id=\"test-123\"", line_chart(@data)
  ensure
    Chartkick.options = {}
  end

  def test_chart_ids
    @chartkick_chart_id = 0
    3.times do |i|
      assert_match "chart-#{i + 1}", line_chart(@data)
    end
  end

  def assert_chart(chart)
    assert_match "new Chartkick", chart
  end

  def content_for(value)
    @content_for[value] = yield
  end
end
