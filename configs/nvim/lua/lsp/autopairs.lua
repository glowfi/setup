-- Settings
local npairs = require('nvim-autopairs')
local Rule = require('nvim-autopairs.rule')

-- cmp based autopairs
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require('cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())

npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string'},
        javascript = {'template_string'},
        java = false
    }
})

-- Treesitter checking of autopairs
require('nvim-treesitter.configs').setup {autopairs = {enable = true}}

local ts_conds = require('nvim-autopairs.ts-conds')

npairs.add_rules({
    Rule("%", "%", "lua"):with_pair(ts_conds.is_ts_node({'string', 'comment'})),
    Rule("$", "$", "lua"):with_pair(ts_conds.is_not_ts_node({'function'}))
})
