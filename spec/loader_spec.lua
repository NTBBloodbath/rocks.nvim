local loader = require("rocks.loader")

describe("rocks.loader", function()
    it("Can enable luarocks.loader", function()
        assert.True(loader.enable())
    end)
end)
