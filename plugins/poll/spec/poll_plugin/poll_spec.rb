require 'spec_helper'

describe PollPlugin::Poll do
  let(:topic) { create_topic(title: "Poll: Chitoge vs Onodera") }
  let(:post) { create_post(topic: topic, raw: "Pick one.\n\n[poll]\n* Chitoge\n* Onodera\n[/poll]") }
  let(:poll) { PollPlugin::Poll.new(post) }
  let(:user) { Fabricate(:user) }

  it "should detect poll post correctly" do
    expect(poll.is_poll?).to be_true
    post2 = create_post(topic: topic, raw: "This is a generic reply.")
    expect(PollPlugin::Poll.new(post2).is_poll?).to be_false
    post.topic.title = "Not a poll"
    expect(poll.is_poll?).to be_false
  end

  it "should get options correctly" do
    expect(poll.options).to eq(["Chitoge", "Onodera"])
  end

  it "should get details correctly" do
    expect(poll.details).to eq({"Chitoge" => 0, "Onodera" => 0})
  end

  it "should set details correctly" do
    poll.set_details!({})
    poll.details.should eq({})
    PollPlugin::Poll.new(post).details.should eq({})
  end

  it "should get and set votes correctly" do
    poll.get_vote(user).should eq(nil)
    poll.set_vote!(user, "Onodera")
    poll.get_vote(user).should eq("Onodera")
    poll.details["Onodera"].should eq(1)
  end

  it "should serialize correctly" do
    poll.serialize(user).should eq({options: poll.details, selected: nil})
    poll.set_vote!(user, "Onodera")
    poll.serialize(user).should eq({options: poll.details, selected: "Onodera"})
    poll.serialize(nil).should eq({options: poll.details, selected: nil})
  end

  it "should serialize to nil if there are no poll options" do
    topic = create_topic(title: "This is not a poll topic")
    post = create_post(topic: topic, raw: "no options in the content")
    poll = PollPlugin::Poll.new(post)
    poll.serialize(user).should eq(nil)
  end
end
