%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      requires: [],
      strict: false,
      color: true,
      checks: [
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Refactor.PipeChainStart, false}
      ]
    }
  ]
}
