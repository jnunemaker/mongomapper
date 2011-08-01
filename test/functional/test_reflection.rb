require 'test_helper'
require 'models'

class ReflectionTest < Test::Unit::TestCase
  
  context 'association_reflection' do
  
    class AwesomeUser
      include MongoMapper::Document
      many :posts, :class_name => 'ReflectionTest::AwesomePost', :foreign_key => :creator_id
    end
    AwesomeUser.collection.remove

    class AwesomeTag
      include MongoMapper::EmbeddedDocument
      key :name, String
      key :post_id, ObjectId
      belongs_to :post, :class_name => 'ReflectionTest::AwesomePost'
    end

    class AwesomePost
      include MongoMapper::Document
      key :creator_id, ObjectId

      belongs_to :creator, :class_name => 'ReflectionTest::AwesomeUser'
      many :tags, :class_name => 'ReflectionTest::AwesomeTag', :foreign_key => :post_id
    end

    should "reflect_on_associations" do
      [AwesomeUser, AwesomeTag, AwesomePost].each do |klass|
        klass.respond_to?(:reflect_on_association).should == true
        klass.new.respond_to?(:reflect_on_association).should == true
      end
    end
   
    should 'return a metadata object on association' do
      AwesomeUser.reflect_on_association(:posts).should_not == nil

    end
    
    should 'include an options hash' do
      assert_kind_of Hash, AwesomeUser.reflect_on_association(:posts).options
    end
    
    context 'when missing' do
      AwesomeUser.reflect_on_association(:missing).should == nil
    end
    
    context 'documents' do
      [AwesomeUser, AwesomeUser.new].each do |object|      
        metadata = object.reflect_on_association(:posts)
        metadata.embedded?.should == false
        metadata.klass.should == ReflectionTest::AwesomePost
        metadata.class_name.should == 'ReflectionTest::AwesomePost'
        metadata.name.should == :posts
        metadata.macro.should == :has_many
        metadata.foreign_key.should == "creator_id"              
      end
      
      metadata = AwesomePost.reflect_on_association(:creator)
      metadata.foreign_key.should == 'creator_id'
    end
    
    context 'embedded documents' do      
      metadata = AwesomeTag.reflect_on_association(:post)
      metadata.embedded?.should == false
      metadata.class_name.should == 'ReflectionTest::AwesomePost'
      metadata.name.should == :post
      metadata.macro.should == :belongs_to 
      metadata.foreign_key.should == "post_id"     
      
      metadata = AwesomePost.reflect_on_association(:tags)
      metadata.embedded?.should == true
      metadata.class_name.should == 'ReflectionTest::AwesomeTag'
      metadata.name.should == :tags
      metadata.macro.should == :has_many
      metadata.foreign_key.should == "post_id"
    end
   
  end
end