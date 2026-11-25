describe("TextBoxWidget module", function()
    local TextBoxWidget, Font
    setup(function()
        require("commonrequire")
        Font = require("ui/font")
        TextBoxWidget = require("ui/widget/textboxwidget")
    end)

    it("should select the correct word on HoldWord event", function()
        local tw = TextBoxWidget:new{
            dimen = {x = 0, y = 0},
            face = Font:getFace("cfont", 25),
            text = 'YOOOOOOOOOOOOOOOO\nFoo.\nBar.\nFoo welcomes Bar into the fun.',
        }

        -- Keep the endpoint inside the final character of "into".
        -- Its x-coordinate depends on the active UI font's glyph metrics.
        local function getWordEndX(y, word)
            local line_num = math.ceil(y / tw.line_height_px) + tw.virtual_line_num - 1
            local line = assert(tw.vertical_string_list[line_num])
            local _, word_end = tw:_getLineText(line):find(word, 1, true)
            assert.is_not_nil(word_end)
            local end_char_idx = line.offset + word_end - 1
            local x = 0
            for idx = line.offset, end_char_idx do
                x = x + tw.char_width[tw.charlist[idx]] + (tw.idx_pad[idx] or 0)
            end
            local final_char_width = tw.char_width[tw.charlist[end_char_idx]] + (tw.idx_pad[end_char_idx] or 0)
            return x - final_char_width / 2
        end

        local pos={x=110,y=4}
        tw:onHoldStartText(nil, {pos=pos})
        tw:onHoldReleaseText(function(w)
            assert.is.same(w, 'YOOOOOOOOOOOOOOOO')
        end, {pos=pos})

        pos={x=0,y=50}
        tw:onHoldStartText(nil, {pos=pos})
        tw:onHoldReleaseText(function(w)
            assert.is.same(w, 'Foo')
        end, {pos=pos})

        pos={x=20,y=80}
        tw:onHoldStartText(nil, {pos=pos})
        tw:onHoldReleaseText(function(w)
            assert.is.same(w, 'Bar')
        end, {pos=pos})

        local end_x = getWordEndX(100, "into")
        tw:onHoldStartText(nil, {pos={x=50, y=100}})
        tw:onHoldReleaseText(function(w)
            assert.is.same(w, 'welcomes Bar into')
        end, {pos={x=end_x, y=100}})

        tw:onHoldStartText(nil, {pos={x=20, y=80}})
        tw:onHoldReleaseText(function(w)
            assert.is.same(w, 'Bar.\nFoo welcomes Bar into')
        end, {pos={x=end_x, y=100}})

        --[[
        -- No more used, not implemented when use_xtext=true
        tw:onHoldWord(function(w)
            assert.is.same(w, 'YOOOOOOOOOOOOOOOO')
        end, {pos={x=110,y=4}})
        tw:onHoldWord(function(w)
            assert.is.same(w, 'Foo')
        end, {pos={x=0,y=50}})
        tw:onHoldWord(function(w)
            assert.is.same(w, 'Bar')
        end, {pos={x=20,y=80}})
        ]]--
    end)
end)
