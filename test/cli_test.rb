require_relative 'base_test'

class CliTest < BaseTest
  def test_new_basic_project
    within_project_directory do
      stubborn(:new, 'stubborn-homepage')
      
      directory_contents = Dir.glob('./**/*')
      
      assert_equal(directory_contents, [
        './stubborn-homepage',
        './stubborn-homepage/index.slim',
        './stubborn-homepage/site',
        './stubborn-homepage/site/style.css'
      ])
      
      index_template_contents = Pathname('./stubborn-homepage/index.slim').read
      assert_equal(index_template_contents, <<-SLIM)
html
  head
    title Stubborn
    link href="style.css" type="text/css" rel="stylesheet"

  body
SLIM
    end
  end

  def test_build
    within_project_directory do
      stubborn(:new, 'stubborn-homepage')
      Dir.chdir('stubborn-homepage')
      stubborn(:build)
      index_html_contents = Pathname('./site/index.html').read
      assert_equal(<<-HTML.gsub(/\n\Z/, ''), index_html_contents)
<html>
  <head>
    <title>Stubborn</title>
    <link href="style.css" rel="stylesheet" type="text/css" />
  </head>
  <body></body>
</html>
HTML
    end
  end
  
  def test_server
    within_project_directory do
      stubborn(:new, 'stubborn-homepage')
      Dir.chdir('stubborn-homepage')
      stubborn(:build)

      res = stubborn(:server) do |i, o, e, wt|
        get('/')
      end

      assert_equal(<<-HTML.gsub(/\n\Z/, ''), res.body)
<html>
  <head>
    <title>Stubborn</title>
    <link href="style.css" rel="stylesheet" type="text/css" />
  </head>
  <body></body>
</html>
      HTML
    end
  end
end
