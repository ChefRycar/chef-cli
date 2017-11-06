require "spec_helper"
require "chef-dk/policyfile/attribute_merge_checker"

describe ChefDK::Policyfile::AttributeMergeChecker do
  let(:checker) { ChefDK::Policyfile::AttributeMergeChecker.new }

  describe "when the same attribute is provided multiple times with the same value" do
    describe "at the top level" do
      before do
        checker.with_attributes("foo", { "a" => "b" })
        checker.with_attributes("bar", { "a" => "b", "c" => "d" })
      end

      it "does not raise an error" do
        expect { checker.check! }.not_to raise_error
      end
    end

    describe "deeply nested" do
      before do
        checker.with_attributes("foo", { "a" => { "b" => "c" } })
        checker.with_attributes("bar", { "a" => { "b" => "c" } })
      end

      it "does not raise an error" do
        expect { checker.check! }.not_to raise_error
      end
    end
  end

  describe "when conflicts are present" do
    describe "at the top level" do
      before do
        checker.with_attributes("foo", { "a" => "b" })
        checker.with_attributes("bar", { "a" => "c", "c" => "d" })
      end

      it "raises an error" do
        expect { checker.check! }.to raise_error(
          ChefDK::Policyfile::AttributeMergeChecker::ConflictError) do |e|
            expect(e.attribute_path).to eq("[a]")
            expect(e.provided_by).to include("foo", "bar")
          end
      end
    end

    describe "deeply nested" do
      before do
        checker.with_attributes("foo", { "a" => { "b" => "c" } })
        checker.with_attributes("bar", { "a" => { "b" => "d" } })
      end

      it "raises an error" do
        expect { checker.check! }.to raise_error(
          ChefDK::Policyfile::AttributeMergeChecker::ConflictError) do |e|
            expect(e.attribute_path).to eq("[a][b]")
            expect(e.provided_by).to include("foo", "bar")
          end
      end
    end
  end

end
