require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

require "webrat/merb"

describe Webrat::MerbSession do
  it "should not pass empty params if data is and empty hash" do
    session = Webrat::MerbSession.new
    response = OpenStruct.new
    response.status = 200
    session.should_receive(:request).with('url', {:params=> nil, :method=>"GET", :headers=>nil}).and_return(response)
    session.get('url', {}, nil)
  end

  %w{post put delete}.each do |request_method|
    it "should call do request with method #{request_method.upcase} for a #{request_method} call" do
      session = Webrat::MerbSession.new
      response = OpenStruct.new
      response.status = 200

      session.should_receive(:request).with('url', {:params=>nil, :method=>request_method.upcase, :headers=>nil}).and_return(response)
      session.send(request_method, 'url', {}, nil)
    end
  end

  context "a session with a response" do
    before do
      @session = Webrat::MerbSession.new
      @response = OpenStruct.new
      @response.status = 200
      @response.body = 'test response'
      @session.instance_variable_set(:@response, @response)
    end

    it "should return body of a request as a response_body" do
      @session.response_body.should == @response.body
    end

    it "should return status of a request as a response_code" do
      @session.response_code.should == @response.status
    end
  end
end
