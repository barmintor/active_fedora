require 'spec_helper'

require 'active_fedora'
require "rexml/document"

describe ActiveFedora::Datastreams do
  describe "#has_file_datastream" do
    before :all do
      class HasFile < ActiveFedora::Base
        has_file_datastream :name => "file_ds", :versionable => false
        def load_datastreams
          puts "NOTICE: HasFile.load_datastreams"
          ds_specs = self.class.ds_specs.dup
          inner_object.datastreams.each do |dsid, ds|
            puts "NOTICE: loading #{inner_object.pid}/#{dsid}"
            self.add_datastream(ds)
            configure_datastream(datastreams[dsid])
            ds_specs.delete(dsid)
          end
          puts "NOTICE: ds_specs:" + ds_specs.inspect
          ds_specs.each do |name,ds_spec|
            puts "NOTICE: " + ds_spec.inspect
            ds = datastream_from_spec(ds_spec, name)
            puts "NOTICE: " + ds.inspect unless ds.class == ActiveFedora::RelsExtDatastream
            self.add_datastream(ds)
            configure_datastream(ds, ds_spec)
          end
        end      
      end
    end
    after :all do
      Object.send(:remove_const, :HasFile)
    end
    before :each do
      @base = ActiveFedora::Base.new(:pid=>"test:ds_versionable_base")
      @base.save
      @has_file = HasFile.new(:pid=>"test:ds_versionable_has_file")
      puts "NOTICE: HasFile.new"
      @has_file.save
    end
    
    after :each do
      @base.delete
      @has_file.delete
    end
    
    it "should correctly assign the :versionable attribute" do
      @has_file.file_ds.versionable.should be_false
      @has_file.file_ds.content = "blah blah blah"
      @has_file.save
      @has_file.file_ds.versionable.should be_false
      HasFile.find(@has_file.pid).file_ds.versionable.should be_false
      puts "NOTICE: HasFile.find"
    end
    
    it "should correctly assign the :versionable attribute when migrating an existing object" do
      test_obj = HasFile.find(@base.pid)
      puts "NOTICE: HasFile.find"
      test_obj.file_ds.versionable.should be_false
      test_obj.file_ds.new?.should be_true
      test_obj.file_ds.content = "blah blah blah"
      test_obj.save
      test_obj.file_ds.versionable.should be_false
      # look it up again to check datastream profile
      test_obj = HasFile.find(@base.pid)
      puts "NOTICE: HasFile.find"
      test_obj.file_ds.versionable.should be_false
    end
  end
end