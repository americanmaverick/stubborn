require './test/base_test'

class StubbornTest < BaseTest
  def test_build_with_helper
    within_project_directory do
      Stubborn.new_project('stubborn-homepage')
      Dir.chdir('stubborn-homepage')
      Pathname('stubborn_helper.rb').write(<<-HELPER)
def my_helper
  'Written by Helper'
end
      HELPER
      
      Pathname('index.slim').write(<<-INDEX)
html
  head
    title Stubborn
    link href="style.css" type="text/css" rel="stylesheet"

  body
    = my_helper
      INDEX
      
      Stubborn.build_project
      index_html_contents = Pathname('docs/index.html').read
      assert_match(/Written by Helper/, index_html_contents)
    end
  end
end
