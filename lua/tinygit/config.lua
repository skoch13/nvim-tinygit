local M = {}
--------------------------------------------------------------------------------

---@class pluginConfig
---@field commitMsg commitConfig
---@field issueIcons issueIconConfig
---@field historySearch historySearchConfig
---@field push pushConfig
---@field statusline { branchState: branchStateConfig, blame: blameConfig }

---@class issueIconConfig
---@field closedIssue string
---@field openIssue string
---@field openPR string
---@field mergedPR string
---@field closedPR string

---@class commitConfig
---@field conventionalCommits {enforce: boolean, keywords: string[]}
---@field spellcheck boolean
---@field openReferencedIssue boolean
---@field commitPreview boolean
---@field keepAbortedMsgSecs number
---@field inputFieldWidth number
---@field insertIssuesOnHash { enabled: boolean, cycleIssuesKey: string, issuesToFetch: number }

---@class historySearchConfig
---@field diffPopup { width: number, height: number, border: "single"|"double"|"rounded"|"solid"|"none"|"shadow"|string[]}
---@field autoUnshallowIfNeeded boolean

---@class pushConfig
---@field preventPushingFixupOrSquashCommits boolean
---@field confirmationSound boolean

---@class blameConfig
---@field ignoreAuthors string[]
---@field hideAuthorNames string[]
---@field maxMsgLen number
---@field icon string

---@class branchStateConfig
---@field icons { ahead: string, behind: string, diverge: string }

--------------------------------------------------------------------------------

---@type pluginConfig
local defaultConfig = {
	commitMsg = {
		-- Shows diffstats of the changes that are going to be committed.
		-- (requires nvim-notify)
		commitPreview = true,

		conventionalCommits = {
			enforce = false, -- disallow commit messages without a keyword
			-- stylua: ignore
			keywords = {
				"fix", "feat", "chore", "docs", "refactor", "build", "test",
				"perf", "style", "revert", "ci", "break", "improv",
			},
		},

		-- enable vim's builtin spellcheck for the commit message input field.
		-- (configured to ignore capitalization and correctly consider camelCase)
		spellcheck = false,

		-- if message references issue/PR, open it in the browser after commit
		openReferencedIssue = false,

		-- how long to remember the state of the message input field when aborting
		keepAbortedMsgSecs = 300,

		-- if `false`, will use the width set in the dressing.nvim config
		inputFieldWidth = 72,

		-- Experimental. Typing `#` will insert the most recent open issue.
		-- Requires nvim-notify.
		insertIssuesOnHash = {
			enabled = false,
			next = "<Tab>", -- insert & normal mode
			prev = "<S-Tab>",
			issuesToFetch = 20,
		},
	},
	backdrop = {
		enabled = true,
		blend = 60, -- 0-100
	},
	push = {
		preventPushingFixupOrSquashCommits = true,
		confirmationSound = true, -- currently macOS only, PRs welcome
	},
	issueIcons = {
		openIssue = "🟢",
		closedIssue = "🟣",
		openPR = "🟩",
		mergedPR = "🟪",
		closedPR = "🟥",
	},
	historySearch = {
		diffPopup = {
			width = 0.8, -- float, 0 to 1
			height = 0.8,
			border = "single",
		},
		-- if trying to call `git log` on a shallow repository, automatically
		-- unshallow the repo by running `git fetch --unshallow`
		autoUnshallowIfNeeded = false,
	},
	statusline = {
		blame = {
			-- Any of these authors and the component is not shown (useful for bots)
			ignoreAuthors = {},

			-- show component, but leave out names (useful for your own name)
			hideAuthorNames = {},

			maxMsgLen = 40,
			icon = "ﰖ ",
		},
		branchState = {
			icons = {
				ahead = "󰶣",
				behind = "󰶡",
				diverge = "󰃻",
			},
		},
	},
}

--------------------------------------------------------------------------------

M.config = defaultConfig -- in case user does not call `setup`

---@param userConfig? pluginConfig
function M.setupPlugin(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	-- VALIDATE border `none` does not work with and title/footer used by this plugin
	if M.config.historySearch.diffPopup.border == "none" then
		local fallback = defaultConfig.historySearch.diffPopup.border
		M.config.historySearch.diffPopup.border = fallback
		local msg = ('Border type "none" is not supported, falling back to %q.'):format(fallback)
		require("tinygit.shared.utils").notify(msg, "warn")
	end
end

--------------------------------------------------------------------------------
return M
