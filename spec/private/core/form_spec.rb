require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Multiple nested params" do
  it "should be corretly posted" do
    Webrat.configuration.mode = :rails

    with_html <<-HTML
      <html>
      <form method="post" action="/family">
        <div class="couple">
          <div class="parent">
            <select name="user[family][parents][0][][gender]">
              <option selected="selected" value="Mother">Mother</option>
              <option value="Father">Father</option>
            </select>
            <input type="text" value="Alice" name="user[family][parents][0][][name]" />
          </div>
          <div class="parent">
            <select name="user[family][parents][0][][gender]">
              <option value="Mother">Mother</option>
              <option selected="selected" value="Father">Father</option>
            </select>
            <input type="text" value="Michael" name="user[family][parents][0][][name]" />
          </div>
        </div>
        <div class="couple">
          <div class="parent">
            <select name="user[family][parents][1][][gender]">
              <option selected="selected" value="Mother">Mother</option>
              <option value="Father">Father</option>
            </select>
            <input type="text" value="Jenny" name="user[family][parents][1][][name]" />
          </div>
        </div>
        <input type="submit" />
      </form>
      </html>
    HTML

    params = { "user" => { "family" => { "parents" => {
            "0" => [ {"name" => "Alice", "gender"=>"Mother"}, {"name" => "Michael", "gender"=>"Father"} ],
            "1" => [ {"name" => "Jenny", "gender"=>"Mother"} ]
          }
        }
      }
    }

    webrat_session.should_receive(:post).with("/family", params)
    click_button
  end
end
