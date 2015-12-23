# encoding: utf-8
require 'rails_helper'

describe Ballot do
  it "validates on presence of instructions" do
    b = build_stubbed(:ballot); b.validate
    expect(b.errors.keys).to include(:instructions)
  end

  it "validates on presence of voting system type" do
    b = build_stubbed(:ballot); b.validate
    expect(b.errors.keys).to include(:voting_system_type)
  end

  it "validates on presence of starts_at" do
    b = build_stubbed(:ballot); b.validate
    expect(b.errors.keys).to include(:starts_at)
  end

  it "validates on presence of ends_at" do
    b = build_stubbed(:ballot); b.validate
    expect(b.errors.keys).to include(:ends_at)
  end
end
