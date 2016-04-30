require 'spec_helper'

describe DelayedPaperclip do
  before :each do
    reset_dummy
  end

  describe ".options" do
    it ".options returns basic options" do
      DelayedPaperclip.options.should == {:background_job_class => DelayedPaperclip::Jobs::ActiveJob,
                                          :url_with_processing => true,
                                          :processing_image_url => nil,
                                          :queue => "paperclip"}
    end
  end

  describe ".processor" do
    it ".processor returns processor" do
      DelayedPaperclip.processor.should == DelayedPaperclip::Jobs::ActiveJob
    end
  end

  describe ".enqueue" do
    it "delegates to processor" do
      DelayedPaperclip::Jobs::ActiveJob.expects(:enqueue_delayed_paperclip).with("Dummy", 1, :image)
      DelayedPaperclip.enqueue("Dummy", 1, :image)
    end
  end

  describe ".process_job" do
    let(:dummy) { Dummy.create! }

    it "finds dummy and calls #process_delayed!" do
      dummy_stub = stub
      dummy_stub.expects(:where).with(id: dummy.id).returns([dummy])
      Dummy.expects(:unscoped).returns(dummy_stub)
      dummy.image.expects(:process_delayed!)
      DelayedPaperclip.process_job("Dummy", dummy.id, :image)
    end

    it "doesn't find dummy and it doesn't raise any exceptions" do
      dummy_stub = stub
      dummy_stub.expects(:where).with(id: dummy.id).returns([])
      Dummy.expects(:unscoped).returns(dummy_stub)
      expect do
        DelayedPaperclip.process_job("Dummy", dummy.id, :image)
      end.not_to raise_exception
    end
  end

  describe "paperclip definitions" do
    before :each do
      reset_dummy :paperclip => { styles: { thumbnail: "25x25"} }
    end

    it "returns paperclip options regardless of version" do
      expect(Dummy.paperclip_definitions).to eq({:image =>   { :styles => { :thumbnail => "25x25" },
                                              :delayed => { :priority => 0,
                                                            :only_process => [],
                                                            :url_with_processing => true,
                                                            :processing_image_url => nil,
                                                            :queue => "paperclip"}
                                                          }
                                              })
    end
  end
end
