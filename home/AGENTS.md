## General Guidelines

- Never use the em dash "—". Use plain dash "-" instead.
- When writing commit messages, NEVER auto-add your agent name as co-author.
- Design systems and write code like a staff engineer.
- When verifying, ask yourself: "Would a staff engineer approve this?"
- When making technical decisions, do not give much weight to development cost. Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would encounter it. This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection. If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness. If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Default to writing no comments. Code should explain itself through clear naming and structure. Only add a comment when omitting it would genuinely make the code unmaintainable - for example a non-obvious "why", a subtle invariant, a workaround for external behavior, or a deliberate trade-off that cannot be read off the code. Never restate what the code already says. When a comment is truly warranted, keep it extremely concise, ideally one short line.
- Reply to me in Chinese, but keep proper nouns and technical terms in their original form instead of force-translating them.
- When you need a browser, use the `chrome-devtools-axi` skill first. Only fall back to the Playwright MCP if it cannot do the job.
