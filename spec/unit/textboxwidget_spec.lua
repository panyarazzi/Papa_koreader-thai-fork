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
            -- With XText enabled, charlist is an XText userdata, not a Lua table.
            local line_text = tw._xtext and tw._xtext:getText(line.offset, line.end_offset)
                or table.concat(tw.charlist, "", line.offset, line.end_offset)
            local _, word_end = line_text:find(word, 1, true)
            assert.is_not_nil(word_end)
            local end_char_idx = line.offset + word_end - 1

            if tw._xtext then
                -- XText does not populate char_width. Shape the line and use
                -- the actual glyph cluster bounds to place the hold point.
                tw:_shapeLine(line)
                for _, glyph in ipairs(line.xglyphs or {}) do
                    if glyph.is_cluster_start
                            and end_char_idx >= glyph.text_index
                            and end_char_idx < glyph.text_index + glyph.cluster_len then
                        return (glyph.x0 + glyph.x1) / 2
                    end
                end
                error("Could not find the XText glyph cluster for the word endpoint")
            end

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
            -- The selected word range excludes the trailing separator.
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
