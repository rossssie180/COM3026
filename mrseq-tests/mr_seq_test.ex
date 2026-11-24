defmodule MRSeqTest do

  def print_test_config(s, t) do
    IO.puts("script: " <> s)
    IO.puts("test inputs dir: " <> t)
  end

  def run_test(script, long, test, nM) do
    File.rm("mr-out-0")
    try do
      {test_dir, test_out} = (fn
                              suff -> {"tests/test_" <> suff,
                                  "tests/test_out/test_" <> suff <> "_" <> hd(String.split(script, "."))}
                            end).(
                            (fn
                              true, nM, t -> "long_#{inspect(nM)}" <> t
                              false, nM, t -> "short_#{inspect(nM)}" <> t
                            end).(long, nM, test))
      # print_test_config(script, test_dir)
      MRSeq.run_mr_job(script, test_dir)
      # File.mkdir_p(test_out)
      # File.cp("mr-out-0", test_out <> "/mr-out-0")
      if File.read("mr-out-0") == File.read(test_out <> "/mr-out-0"), do: :PASS, else: :FAIL
    rescue
      e -> {:EXCEPTION, e}
    end

  end

  def test_fun, do: %{
      test_short_1:  &MRSeqTest.run_test(&1, false, "", 1),
      test_short_3: &MRSeqTest.run_test(&1, false, "", 3),
      test_short_10: &MRSeqTest.run_test(&1, false, "", 10),
      test_short_one_key: &MRSeqTest.run_test(&1, false, "_one_key", 5),
      test_long_1: &MRSeqTest.run_test(&1, true, "", 1),
      test_long_7: &MRSeqTest.run_test(&1, true, "", 7),
      test_long_10: &MRSeqTest.run_test(&1, true, "", 10),
      test_long_uneven: &MRSeqTest.run_test(&1, true, "_uneven", 2),
      }

  def test_script(script) do
    test_fun()
    |> Map.to_list()
    |> Enum.map(fn {test, fun} -> {script, test, fun.(script)} end)
  end

  def test_wc, do: test_script("word_count.ex")
  def test_ind, do: test_script("indexer.ex")
  def test_all, do: (fn l -> l ++ test_ind() end).(test_wc())

end
