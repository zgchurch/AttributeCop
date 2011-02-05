require 'spec_helper'

class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :phone, :if => :yes
  validates_presence_of :address, :if => :no
  validates_presence_of :cow, :unless => :yes
  validates_presence_of :horse, :unless => :no
  validates_presence_of :duck, :if => lambda { yes }
  validates_presence_of :moose, :unless => lambda { yes }
  
  def yes; true; end
  def no; false; end
end

describe "calling #required? on a required field" do
  it "should return true because the field is required" do
    Person.new.required?(:first_name).should == true
  end
end

describe "calling #required? on a non-required field" do
  it "should return false because the field is not required" do
    Person.new.required?(:last_name).should == false
  end
end

describe "calling #required? on a conditionally (if) required field" do
  it "should return true when the supplied 'if' method returns true" do
    Person.new.required?(:phone).should == true
  end

  it "should return false when the supplied 'if' method returns false" do
    Person.new.required?(:address).should == false
  end

  it "should support lambdas for the 'if' parameter" do
    Person.new.required?(:duck).should == true
  end

  it "should support lambdas for the 'unless' parameter" do
    Person.new.required?(:moose).should == false
  end
end

describe "calling #required? on a conditionally (unless) required field" do
  it "should return true when the supplied 'unless' method returns true" do
    Person.new.required?(:cow).should == false
  end

  it "should return false when the supplied 'unless' method returns false" do
    Person.new.required?(:horse).should == true
  end
end


describe "label helper" do
  it "should have class 'required' only when the field is a required attribute" do
    extend SpecHelper
    a, b = '', ''
    form_for Person.new do |f|
      a = f.label :first_name
      b = f.label :last_name
    end
    
    a.should == %|<label class="required" for="person_first_name">First name</label>|
    b.should == %|<label for="person_last_name">Last name</label>|
  end

  it "should maintain class options passed to it" do
    extend SpecHelper
    a, b = '', ''
    form_for Person.new do |f|
      a = f.label :first_name, "First name", :class => 'first'
      b = f.label :last_name, "Last name", :class => 'last'
    end
    
    a.should == %|<label class="first required" for="person_first_name">First name</label>|
    b.should == %|<label class="last" for="person_last_name">Last name</label>|
  end

  it "should always have class 'required' when the option require is true" do
    extend SpecHelper
    a = ''
    form_for Person.new do |f|
      a = f.label :last_name, "Last name", :required => true
    end
    
    a.should == %|<label class="required" for="person_last_name">Last name</label>|
  end

  it "should never have class 'required' when the option require is false" do
    extend SpecHelper
    a = ''
    form_for Person.new do |f|
      a = f.label :first_name, "First name", :class => 'first', :required => false
    end
    
    a.should == %|<label class="first" for="person_first_name">First name</label>|
  end
end
