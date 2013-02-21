Code.require_file "../test_helper.exs", __FILE__

defmodule Tirexs.DslTest do
  use ExUnit.Case
  use Tirexs.ElasticSettings
  import Tirexs
  import Tirexs.HTTP

  @path Path.join([File.cwd!, "examples"])

   test :load_dsl_file do
     Tirexs.DSL.load_all(@path)
     settings = elastic_settings.new([uri: "localhost"])
     assert exist?(settings, "test_dsl_index") == true
     delete(settings, "test_dsl_index")
     assert exist?(settings, "test_dsl_index") == false

     assert exist?(settings, "test_dsl_setting") == true
     delete(settings, "test_dsl_setting")
     assert exist?(settings, "test_dsl_setting") == false
   end
end