require 'spec_helper'

describe "moderation" do
  context" of topics" do
    let!(:moderator) { FactoryGirl.create(:user, :login => "moderator") }
    let!(:group) do
      group = FactoryGirl.create(:group)
      group.members << moderator
      group.save!
      group
    end

    let!(:forum) { FactoryGirl.create(:forum) }
    let!(:topic) { FactoryGirl.create(:topic, :forum => forum) }

    before do
      forum.moderators << group
      sign_in(moderator)
    end
    
    context "moderation tools view" do
      before do
        visit forum_path(forum)
        click_link "Moderation Tools"
      end
      
      it "should have no posts" do
        page.should have_content("No posts")        
      end
      
      it "should have 1 topic" do
        page.should have_content("1 topic")
        within("#topics") do
          assert find("#topic_1")
          assert find(".topic")
          assert find(".odd")
        end
      end

      it "should have a link to the topic moderation page" do
        assert find_link("FIRST TOPIC")
        click_link("FIRST TOPIC")
        assert page.current_path.should match(forum_topic_path(forum, topic))
      end

    end

    context "singular moderation" do
      it "can approve a topic by a new user" do
        visit forum_topic_path(forum, topic)
        within("#topic_moderation") do
          choose "Approve"
          click_button "Moderate"
        end
        flash_notice!("The selected topic has been moderated.")
        page.should_not have_content("This topic is currently pending review.")
      end
    end
  end
end
