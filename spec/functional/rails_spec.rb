require 'spec_helper'

describe "Documents with the Rails plugin" do
  let(:doc) { Doc { key :foo, String } }
  context "with values from the DB" do
    subject { doc.create(:foo => "bar") }
    it "should have x_before_type_cast" do
      subject.foo_before_type_cast.should == "bar"
    end

    it "should honor app-set values over DB-set values" do
      subject.foo = nil
      subject.foo_before_type_cast.should == nil
    end
  end

  context "when blank" do
    subject { doc.create() }
    it "should have x_before_type_cast" do
      subject.foo_before_type_cast.should == nil
    end

    it "should honor app-set values over DB-set values" do
      subject.foo = nil
      subject.foo_before_type_cast.should == nil

      subject.foo = :baz
      subject.foo_before_type_cast.should == :baz

      subject.save
      subject.reload.foo_before_type_cast.should == "baz"
    end
  end
end